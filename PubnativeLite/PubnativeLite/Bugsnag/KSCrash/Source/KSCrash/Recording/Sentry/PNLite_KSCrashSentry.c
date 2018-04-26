//
//  Copyright © 2018 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#include "PNLite_KSCrashSentry.h"
#include "PNLite_KSCrashSentry_Private.h"

#include "PNLite_KSCrashSentry_CPPException.h"
#include "PNLite_KSCrashSentry_Deadlock.h"
#include "PNLite_KSCrashSentry_NSException.h"
#include "PNLite_KSCrashSentry_Signal.h"
#include "PNLite_KSCrashSentry_User.h"
#include "BSG_KSLogger.h"
#include "BSG_KSMach.h"

// ============================================================================
#pragma mark - Globals -
// ============================================================================

typedef struct {
    PNLite_KSCrashType crashType;
    bool (*install)(PNLite_KSCrash_SentryContext *context);
    void (*uninstall)(void);
} PNLite_CrashSentry;

static PNLite_CrashSentry pnlite_g_sentries[] = {
#if PNLite_KSCRASH_HAS_MACH
    {
        PNLite_KSCrashTypeMachException, bsg_kscrashsentry_installMachHandler,
        bsg_kscrashsentry_uninstallMachHandler,
    },
#endif
    {
        PNLite_KSCrashTypeSignal, bsg_kscrashsentry_installSignalHandler,
        bsg_kscrashsentry_uninstallSignalHandler,
    },
    {
        PNLite_KSCrashTypeCPPException,
        bsg_kscrashsentry_installCPPExceptionHandler,
        bsg_kscrashsentry_uninstallCPPExceptionHandler,
    },
    {
        PNLite_KSCrashTypeNSException, bsg_kscrashsentry_installNSExceptionHandler,
        bsg_kscrashsentry_uninstallNSExceptionHandler,
    },
    {
        PNLite_KSCrashTypeMainThreadDeadlock,
        bsg_kscrashsentry_installDeadlockHandler,
        bsg_kscrashsentry_uninstallDeadlockHandler,
    },
    {
        PNLite_KSCrashTypeUserReported,
        bsg_kscrashsentry_installUserExceptionHandler,
        bsg_kscrashsentry_uninstallUserExceptionHandler,
    },
};
static size_t pnlite_g_sentriesCount =
    sizeof(pnlite_g_sentries) / sizeof(*pnlite_g_sentries);

/** Context to fill with crash information. */
static PNLite_KSCrash_SentryContext *pnlite_g_context = NULL;

/** Keeps track of whether threads have already been suspended or not.
 * This won't handle multiple suspends in a row.
 */
static bool pnlite_g_threads_are_running = true;

// ============================================================================
#pragma mark - API -
// ============================================================================

PNLite_KSCrashType
bsg_kscrashsentry_installWithContext(PNLite_KSCrash_SentryContext *context,
                                     PNLite_KSCrashType crashTypes,
                                     void (*onCrash)(void)) {
    if (bsg_ksmachisBeingTraced()) {
        if (context->reportWhenDebuggerIsAttached) {
            BSG_KSLOG_WARN("KSCrash: App is running in a debugger. Crash "
                           "handling is enabled via configuration.");
            BSG_KSLOG_INFO(
                "Installing handlers with context %p, crash types 0x%x.",
                context, crashTypes);
        } else {
            BSG_KSLOG_WARN("KSCrash: App is running in a debugger. Only user "
                           "reported events will be handled.");
            crashTypes = PNLite_KSCrashTypeUserReported;
        }
    } else {
        BSG_KSLOG_DEBUG(
            "Installing handlers with context %p, crash types 0x%x.", context,
            crashTypes);
    }

    pnlite_g_context = context;
    bsg_kscrashsentry_clearContext(pnlite_g_context);
    pnlite_g_context->onCrash = onCrash;

    PNLite_KSCrashType installed = 0;
    for (size_t i = 0; i < pnlite_g_sentriesCount; i++) {
        PNLite_CrashSentry *sentry = &pnlite_g_sentries[i];
        if (sentry->crashType & crashTypes) {
            if (sentry->install == NULL || sentry->install(context)) {
                installed |= sentry->crashType;
            }
        }
    }

    BSG_KSLOG_DEBUG("Installation complete. Installed types 0x%x.", installed);
    return installed;
}

void bsg_kscrashsentry_uninstall(PNLite_KSCrashType crashTypes) {
    BSG_KSLOG_DEBUG("Uninstalling handlers with crash types 0x%x.", crashTypes);
    for (size_t i = 0; i < pnlite_g_sentriesCount; i++) {
        PNLite_CrashSentry *sentry = &pnlite_g_sentries[i];
        if (sentry->crashType & crashTypes) {
            if (sentry->install != NULL) {
                sentry->uninstall();
            }
        }
    }
    BSG_KSLOG_DEBUG("Uninstall complete.");
}

// ============================================================================
#pragma mark - Private API -
// ============================================================================

void bsg_kscrashsentry_suspendThreads(void) {
    BSG_KSLOG_DEBUG("Suspending threads.");
    if (!pnlite_g_threads_are_running) {
        BSG_KSLOG_DEBUG("Threads already suspended.");
        return;
    }

    if (pnlite_g_context != NULL) {
        int numThreads = sizeof(pnlite_g_context->reservedThreads) /
                         sizeof(pnlite_g_context->reservedThreads[0]);
        BSG_KSLOG_DEBUG(
            "Suspending all threads except for %d reserved threads.",
            numThreads);
        if (bsg_ksmachsuspendAllThreadsExcept(pnlite_g_context->reservedThreads,
                                              numThreads)) {
            BSG_KSLOG_DEBUG("Suspend successful.");
            pnlite_g_threads_are_running = false;
        }
    } else {
        BSG_KSLOG_DEBUG("Suspending all threads.");
        if (bsg_ksmachsuspendAllThreads()) {
            BSG_KSLOG_DEBUG("Suspend successful.");
            pnlite_g_threads_are_running = false;
        }
    }
    BSG_KSLOG_DEBUG("Suspend complete.");
}

void bsg_kscrashsentry_resumeThreads(void) {
    BSG_KSLOG_DEBUG("Resuming threads.");
    if (pnlite_g_threads_are_running) {
        BSG_KSLOG_DEBUG("Threads already resumed.");
        return;
    }

    if (pnlite_g_context != NULL) {
        int numThreads = sizeof(pnlite_g_context->reservedThreads) /
                         sizeof(pnlite_g_context->reservedThreads[0]);
        BSG_KSLOG_DEBUG("Resuming all threads except for %d reserved threads.",
                        numThreads);
        if (bsg_ksmachresumeAllThreadsExcept(pnlite_g_context->reservedThreads,
                                             numThreads)) {
            BSG_KSLOG_DEBUG("Resume successful.");
            pnlite_g_threads_are_running = true;
        }
    } else {
        BSG_KSLOG_DEBUG("Resuming all threads.");
        if (bsg_ksmachresumeAllThreads()) {
            BSG_KSLOG_DEBUG("Resume successful.");
            pnlite_g_threads_are_running = true;
        }
    }
    BSG_KSLOG_DEBUG("Resume complete.");
}

void bsg_kscrashsentry_clearContext(PNLite_KSCrash_SentryContext *context) {
    void (*onCrash)(void) = context->onCrash;
    bool threadTracingEnabled = context->threadTracingEnabled;
    bool reportWhenDebuggerIsAttached = context->reportWhenDebuggerIsAttached;
    bool suspendThreadsForUserReported = context->suspendThreadsForUserReported;
    bool writeBinaryImagesForUserReported =
        context->writeBinaryImagesForUserReported;

    memset(context, 0, sizeof(*context));
    context->onCrash = onCrash;

    context->threadTracingEnabled = threadTracingEnabled;
    context->reportWhenDebuggerIsAttached = reportWhenDebuggerIsAttached;
    context->suspendThreadsForUserReported = suspendThreadsForUserReported;
    context->writeBinaryImagesForUserReported =
        writeBinaryImagesForUserReported;
}

void bsg_kscrashsentry_beginHandlingCrash(PNLite_KSCrash_SentryContext *context) {
    bsg_kscrashsentry_clearContext(context);
    context->handlingCrash = true;
}
