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


#include "PNLite_KSCrashC.h"

#include "PNLite_KSCrashReport.h"
#include "PNLite_KSCrashSentry_Deadlock.h"
#include "PNLite_KSCrashSentry_User.h"
#include "PNLite_KSMach.h"
#include "PNLite_KSObjC.h"
#include "PNLite_KSString.h"
#include "PNLite_KSSystemInfoC.h"
#include "PNLite_KSZombie.h"

//#define PNLite_KSLogger_LocalLevel TRACE
#include "PNLite_KSLogger.h"

#include <mach/mach_time.h>

// ============================================================================
#pragma mark - Globals -
// ============================================================================

/** True if PNLite_KSCrash has been installed. */
static volatile sig_atomic_t pnlite_g_installed = 0;

/** Single, global crash context. */
static PNLite_KSCrash_Context pnlite_g_crashReportContext = {
    .config = {.handlingCrashTypes = PNLite_KSCrashTypeProductionSafe}};

/** Path to store the next crash report. */
static char *pnlite_g_crashReportFilePath;

/** Path to store the next crash report (only if the crash manager crashes). */
static char *pnlite_g_recrashReportFilePath;

/** Path to store the state file. */
static char *pnlite_g_stateFilePath;

// ============================================================================
#pragma mark - Utility -
// ============================================================================

static inline PNLite_KSCrash_Context *crashContext(void) {
    return &pnlite_g_crashReportContext;
}

// ============================================================================
#pragma mark - Callbacks -
// ============================================================================

// Avoiding static methods due to linker issue.

/** Called when a crash occurs.
 *
 * This function gets passed as a callback to a crash handler.
 */
void bsg_kscrash_i_onCrash(void) {
    PNLite_KSLOG_DEBUG("Updating application state to note crash.");
    bsg_kscrashstate_notifyAppCrash();

    PNLite_KSCrash_Context *context = crashContext();

    if (context->config.printTraceToStdout) {
        bsg_kscrashreport_logCrash(context);
    }

    if (context->crash.crashedDuringCrashHandling) {
        bsg_kscrashreport_writeMinimalReport(context,
                                             pnlite_g_recrashReportFilePath);
    } else {
        bsg_kscrashreport_writeStandardReport(context,
                                              pnlite_g_crashReportFilePath);
    }
}

// ============================================================================
#pragma mark - API -
// ============================================================================

PNLite_KSCrashType bsg_kscrash_install(const char *const crashReportFilePath,
                                    const char *const recrashReportFilePath,
                                    const char *stateFilePath,
                                    const char *crashID) {
    PNLite_KSLOG_DEBUG("Installing crash reporter.");

    PNLite_KSCrash_Context *context = crashContext();

    if (pnlite_g_installed) {
        PNLite_KSLOG_DEBUG("Crash reporter already installed.");
        return context->config.handlingCrashTypes;
    }
    pnlite_g_installed = 1;

    bsg_ksmach_init();

    if (context->config.introspectionRules.enabled) {
        bsg_ksobjc_init();
    }

    bsg_kscrash_reinstall(crashReportFilePath, recrashReportFilePath,
                          stateFilePath, crashID);

    PNLite_KSCrashType crashTypes =
        bsg_kscrash_setHandlingCrashTypes(context->config.handlingCrashTypes);

    context->config.systemInfoJSON = pnlite_kssysteminfo_toJSON();
    context->config.processName = pnlite_kssysteminfo_copyProcessName();

    PNLite_KSLOG_DEBUG("Installation complete.");
    return crashTypes;
}

void bsg_kscrash_reinstall(const char *const crashReportFilePath,
                           const char *const recrashReportFilePath,
                           const char *const stateFilePath,
                           const char *const crashID) {
    PNLite_KSLOG_TRACE("reportFilePath = %s", crashReportFilePath);
    PNLite_KSLOG_TRACE("secondaryReportFilePath = %s", recrashReportFilePath);
    PNLite_KSLOG_TRACE("stateFilePath = %s", stateFilePath);
    PNLite_KSLOG_TRACE("crashID = %s", crashID);

    bsg_ksstring_replace((const char **)&pnlite_g_stateFilePath, stateFilePath);
    bsg_ksstring_replace((const char **)&pnlite_g_crashReportFilePath,
                         crashReportFilePath);
    bsg_ksstring_replace((const char **)&pnlite_g_recrashReportFilePath,
                         recrashReportFilePath);
    PNLite_KSCrash_Context *context = crashContext();
    bsg_ksstring_replace(&context->config.crashID, crashID);

    if (!bsg_kscrashstate_init(pnlite_g_stateFilePath, &context->state)) {
        PNLite_KSLOG_ERROR("Failed to initialize persistent crash state");
    }
    context->state.appLaunchTime = mach_absolute_time();
}

PNLite_KSCrashType bsg_kscrash_setHandlingCrashTypes(PNLite_KSCrashType crashTypes) {
    PNLite_KSCrash_Context *context = crashContext();
    context->config.handlingCrashTypes = crashTypes;

    if (pnlite_g_installed) {
        bsg_kscrashsentry_uninstall(~crashTypes);
        crashTypes = bsg_kscrashsentry_installWithContext(
            &context->crash, crashTypes, bsg_kscrash_i_onCrash);
    }

    return crashTypes;
}

void bsg_kscrash_setUserInfoJSON(const char *const userInfoJSON) {
    PNLite_KSLOG_TRACE("set userInfoJSON to %p", userInfoJSON);
    PNLite_KSCrash_Context *context = crashContext();
    bsg_ksstring_replace(&context->config.userInfoJSON, userInfoJSON);
}

void bsg_kscrash_setDeadlockWatchdogInterval(double deadlockWatchdogInterval) {
    bsg_kscrashsentry_setDeadlockHandlerWatchdogInterval(
        deadlockWatchdogInterval);
}

void bsg_kscrash_setPrintTraceToStdout(bool printTraceToStdout) {
    crashContext()->config.printTraceToStdout = printTraceToStdout;
}

void bsg_kscrash_setSearchThreadNames(bool shouldSearchThreadNames) {
    crashContext()->config.searchThreadNames = shouldSearchThreadNames;
}

void bsg_kscrash_setSearchQueueNames(bool shouldSearchQueueNames) {
    crashContext()->config.searchQueueNames = shouldSearchQueueNames;
}

void bsg_kscrash_setIntrospectMemory(bool introspectMemory) {
    crashContext()->config.introspectionRules.enabled = introspectMemory;
}

void bsg_kscrash_setCatchZombies(bool catchZombies) {
    bsg_kszombie_setEnabled(catchZombies);
}

void bsg_kscrash_setDoNotIntrospectClasses(const char **doNotIntrospectClasses,
                                           size_t length) {
    const char **oldClasses =
        crashContext()->config.introspectionRules.restrictedClasses;
    size_t oldClassesLength =
        crashContext()->config.introspectionRules.restrictedClassesCount;
    const char **newClasses = nil;
    size_t newClassesLength = 0;

    if (doNotIntrospectClasses != nil && length > 0) {
        newClassesLength = length;
        newClasses = malloc(sizeof(*newClasses) * newClassesLength);
        if (newClasses == nil) {
            PNLite_KSLOG_ERROR("Could not allocate memory");
            return;
        }

        for (size_t i = 0; i < newClassesLength; i++) {
            newClasses[i] = strdup(doNotIntrospectClasses[i]);
        }
    }

    crashContext()->config.introspectionRules.restrictedClasses = newClasses;
    crashContext()->config.introspectionRules.restrictedClassesCount =
        newClassesLength;

    if (oldClasses != nil) {
        for (size_t i = 0; i < oldClassesLength; i++) {
            free((void *)oldClasses[i]);
        }
        free(oldClasses);
    }
}

void bsg_kscrash_setCrashNotifyCallback(
    const PNLite_KSReportWriteCallback onCrashNotify) {
    PNLite_KSLOG_TRACE("Set onCrashNotify to %p", onCrashNotify);
    crashContext()->config.onCrashNotify = onCrashNotify;
}

void bsg_kscrash_reportUserException(const char *name, const char *reason,
                                     const char *language,
                                     const char *lineOfCode,
                                     const char *stackTrace,
                                     bool terminateProgram) {
    bsg_kscrashsentry_reportUserException(name, reason, language, lineOfCode,
                                          stackTrace, terminateProgram);
}

void bsg_kscrash_setSuspendThreadsForUserReported(
    bool suspendThreadsForUserReported) {
    crashContext()->crash.suspendThreadsForUserReported =
        suspendThreadsForUserReported;
}

void bsg_kscrash_setWriteBinaryImagesForUserReported(
    bool writeBinaryImagesForUserReported) {
    crashContext()->crash.writeBinaryImagesForUserReported =
        writeBinaryImagesForUserReported;
}

void bsg_kscrash_setReportWhenDebuggerIsAttached(
    bool reportWhenDebuggerIsAttached) {
    crashContext()->crash.reportWhenDebuggerIsAttached =
        reportWhenDebuggerIsAttached;
}

void bsg_kscrash_setThreadTracingEnabled(bool threadTracingEnabled) {
    crashContext()->crash.threadTracingEnabled = threadTracingEnabled;
}
