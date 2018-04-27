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

#include "PNLite_KSCrashSentry_User.h"
#include "PNLite_KSCrashSentry_Private.h"
#include "PNLite_KSMach.h"

//#define PNLite_KSLogger_LocalLevel TRACE
#include "PNLite_KSLogger.h"

#include <execinfo.h>
#include <stdlib.h>

/** Context to fill with crash information. */
static PNLite_KSCrash_SentryContext *pnlite_g_context;

bool bsg_kscrashsentry_installUserExceptionHandler(
    PNLite_KSCrash_SentryContext *const context) {
    PNLite_KSLOG_DEBUG("Installing user exception handler.");
    pnlite_g_context = context;
    return true;
}

void bsg_kscrashsentry_uninstallUserExceptionHandler(void) {
    PNLite_KSLOG_DEBUG("Uninstalling user exception handler.");
    pnlite_g_context = NULL;
}

void bsg_kscrashsentry_reportUserException(const char *name, const char *reason,
                                           const char *language,
                                           const char *lineOfCode,
                                           const char *stackTrace,
                                           bool terminateProgram) {
    if (pnlite_g_context == NULL) {
        PNLite_KSLOG_WARN("User-reported exception sentry is not installed. "
                       "Exception has not been recorded.");
    } else {
        bsg_kscrashsentry_beginHandlingCrash(pnlite_g_context);

        if (pnlite_g_context->suspendThreadsForUserReported) {
            PNLite_KSLOG_DEBUG("Suspending all threads");
            bsg_kscrashsentry_suspendThreads();
        }

        PNLite_KSLOG_DEBUG("Fetching call stack.");
        int callstackCount = 100;
        uintptr_t callstack[callstackCount];
        callstackCount = backtrace((void **)callstack, callstackCount);
        if (callstackCount <= 0) {
            PNLite_KSLOG_ERROR("backtrace() returned call stack length of %d",
                            callstackCount);
            callstackCount = 0;
        }

        PNLite_KSLOG_DEBUG("Filling out context.");
        pnlite_g_context->crashType = PNLite_KSCrashTypeUserReported;
        pnlite_g_context->offendingThread = bsg_ksmachthread_self();
        pnlite_g_context->registersAreValid = false;
        pnlite_g_context->crashReason = reason;
        pnlite_g_context->stackTrace = callstack;
        pnlite_g_context->stackTraceLength = callstackCount;
        pnlite_g_context->userException.name = name;
        pnlite_g_context->userException.language = language;
        pnlite_g_context->userException.lineOfCode = lineOfCode;
        pnlite_g_context->userException.customStackTrace = stackTrace;

        PNLite_KSLOG_DEBUG("Calling main crash handler.");
        pnlite_g_context->onCrash();

        if (terminateProgram) {
            bsg_kscrashsentry_uninstall(PNLite_KSCrashTypeAll);
            bsg_kscrashsentry_resumeThreads();
            abort();
        } else {
            bsg_kscrashsentry_clearContext(pnlite_g_context);
            bsg_kscrashsentry_resumeThreads();
        }
    }
}
