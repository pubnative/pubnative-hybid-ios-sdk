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

#include <TargetConditionals.h>

#include "PNLite_KSCrashSentry_Private.h"
#include "PNLite_KSCrashSentry_Signal.h"

#include "BSG_KSMach.h"
#include "PNLite_KSSignalInfo.h"

//#define PNLite_KSLogger_LocalLevel TRACE
#include "PNLite_KSLogger.h"

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

// ============================================================================
#pragma mark - Globals -
// ============================================================================

/** Flag noting if we've installed our custom handlers or not.
 * It's not fully thread safe, but it's safer than locking and slightly better
 * than nothing.
 */
static volatile sig_atomic_t pnlite_g_installed = 0;

#if !TARGET_OS_TV
/** Our custom signal stack. The signal handler will use this as its stack. */
static stack_t pnlite_g_signalStack = {0};
#endif

/** Signal handlers that were installed before we installed ours. */
static struct sigaction *pnlite_g_previousSignalHandlers = NULL;

/** Context to fill with crash information. */
static PNLite_KSCrash_SentryContext *pnlite_g_context;

// ============================================================================
#pragma mark - Callbacks -
// ============================================================================

// Avoiding static functions due to linker issues.

/** Our custom signal handler.
 * Restore the default signal handlers, record the signal information, and
 * write a crash report.
 * Once we're done, re-raise the signal and let the default handlers deal with
 * it.
 *
 * @param sigNum The signal that was raised.
 *
 * @param signalInfo Information about the signal.
 *
 * @param userContext Other contextual information.
 */
void bsg_kssighndl_i_handleSignal(int sigNum, siginfo_t *signalInfo,
                                  void *userContext) {
    PNLite_KSLOG_DEBUG("Trapped signal %d", sigNum);
    if (pnlite_g_installed) {
        bool wasHandlingCrash = pnlite_g_context->handlingCrash;
        bsg_kscrashsentry_beginHandlingCrash(pnlite_g_context);

        PNLite_KSLOG_DEBUG(
            "Signal handler is installed. Continuing signal handling.");

        PNLite_KSLOG_DEBUG("Suspending all threads.");
        bsg_kscrashsentry_suspendThreads();

        if (wasHandlingCrash) {
            PNLite_KSLOG_INFO("Detected crash in the crash reporter. Restoring "
                           "original handlers.");
            pnlite_g_context->crashedDuringCrashHandling = true;
            bsg_kscrashsentry_uninstall(PNLite_KSCrashTypeAsyncSafe);
        }

        PNLite_KSLOG_DEBUG("Filling out context.");
        pnlite_g_context->crashType = PNLite_KSCrashTypeSignal;
        pnlite_g_context->offendingThread = bsg_ksmachthread_self();
        pnlite_g_context->registersAreValid = true;
        pnlite_g_context->faultAddress = (uintptr_t)signalInfo->si_addr;
        pnlite_g_context->signal.userContext = userContext;
        pnlite_g_context->signal.signalInfo = signalInfo;

        PNLite_KSLOG_DEBUG("Calling main crash handler.");
        pnlite_g_context->onCrash();

        PNLite_KSLOG_DEBUG(
            "Crash handling complete. Restoring original handlers.");
        bsg_kscrashsentry_uninstall(PNLite_KSCrashTypeAsyncSafe);
        bsg_kscrashsentry_resumeThreads();
    }

    PNLite_KSLOG_DEBUG("Re-raising signal for regular handlers to catch.");
    // This is technically not allowed, but it works in OSX and iOS.
    raise(sigNum);
}

// ============================================================================
#pragma mark - API -
// ============================================================================

bool bsg_kscrashsentry_installSignalHandler(
    PNLite_KSCrash_SentryContext *context) {
    PNLite_KSLOG_DEBUG("Installing signal handler.");

    if (pnlite_g_installed) {
        PNLite_KSLOG_DEBUG("Signal handler already installed.");
        return true;
    }
    pnlite_g_installed = 1;

    pnlite_g_context = context;

#if !TARGET_OS_TV
    if (pnlite_g_signalStack.ss_size == 0) {
        PNLite_KSLOG_DEBUG("Allocating signal stack area.");
        pnlite_g_signalStack.ss_size = SIGSTKSZ;
        pnlite_g_signalStack.ss_sp = malloc(pnlite_g_signalStack.ss_size);
    }

    PNLite_KSLOG_DEBUG("Setting signal stack area.");
    if (sigaltstack(&pnlite_g_signalStack, NULL) != 0) {
        PNLite_KSLOG_ERROR("signalstack: %s", strerror(errno));
        goto failed;
    }
#endif

    const int *fatalSignals = bsg_kssignal_fatalSignals();
    int fatalSignalsCount = bsg_kssignal_numFatalSignals();

    if (pnlite_g_previousSignalHandlers == NULL) {
        PNLite_KSLOG_DEBUG("Allocating memory to store previous signal handlers.");
        pnlite_g_previousSignalHandlers =
            malloc(sizeof(*pnlite_g_previousSignalHandlers) *
                   (unsigned)fatalSignalsCount);
    }

    struct sigaction action = {{0}};
    action.sa_flags = SA_SIGINFO | SA_ONSTACK;
#ifdef __LP64__
    action.sa_flags |= SA_64REGSET;
#endif
    sigemptyset(&action.sa_mask);
    action.sa_sigaction = &bsg_kssighndl_i_handleSignal;

    for (int i = 0; i < fatalSignalsCount; i++) {
        PNLite_KSLOG_DEBUG("Assigning handler for signal %d", fatalSignals[i]);
        if (sigaction(fatalSignals[i], &action,
                      &pnlite_g_previousSignalHandlers[i]) != 0) {
            char sigNameBuff[30];
            const char *sigName = bsg_kssignal_signalName(fatalSignals[i]);
            if (sigName == NULL) {
                snprintf(sigNameBuff, sizeof(sigNameBuff), "%d",
                         fatalSignals[i]);
                sigName = sigNameBuff;
            }
            PNLite_KSLOG_ERROR("sigaction (%s): %s", sigName, strerror(errno));
            // Try to reverse the damage
            for (i--; i >= 0; i--) {
                sigaction(fatalSignals[i], &pnlite_g_previousSignalHandlers[i],
                          NULL);
            }
            goto failed;
        }
    }
    PNLite_KSLOG_DEBUG("Signal handlers installed.");
    return true;

failed:
    PNLite_KSLOG_DEBUG("Failed to install signal handlers.");
    pnlite_g_installed = 0;
    return false;
}

void bsg_kscrashsentry_uninstallSignalHandler(void) {
    PNLite_KSLOG_DEBUG("Uninstalling signal handlers.");
    if (!pnlite_g_installed) {
        PNLite_KSLOG_DEBUG("Signal handlers were already uninstalled.");
        return;
    }

    const int *fatalSignals = bsg_kssignal_fatalSignals();
    int fatalSignalsCount = bsg_kssignal_numFatalSignals();

    for (int i = 0; i < fatalSignalsCount; i++) {
        PNLite_KSLOG_DEBUG("Restoring original handler for signal %d",
                        fatalSignals[i]);
        sigaction(fatalSignals[i], &pnlite_g_previousSignalHandlers[i], NULL);
    }

    PNLite_KSLOG_DEBUG("Signal handlers uninstalled.");
    pnlite_g_installed = 0;
}
