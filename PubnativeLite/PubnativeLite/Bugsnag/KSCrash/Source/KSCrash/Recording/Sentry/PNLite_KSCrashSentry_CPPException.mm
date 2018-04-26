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

#import <Foundation/Foundation.h>

#include "PNLite_KSCrashSentry_CPPException.h"
#include "PNLite_KSCrashSentry_Private.h"
#include "PNLite_KSMach.h"

//#define PNLite_KSLogger_LocalLevel TRACE
#include "PNLite_KSLogger.h"

#include <cxxabi.h>
#include <dlfcn.h>
#include <exception>
#include <execinfo.h>
#include <typeinfo>

#define PNLite_STACKTRACE_BUFFER_LENGTH 30
#define PNLite_DESCRIPTION_BUFFER_LENGTH 1000

// Compiler hints for "if" statements
#define likely_if(x) if (__builtin_expect(x, 1))
#define unlikely_if(x) if (__builtin_expect(x, 0))

// ============================================================================
#pragma mark - Globals -
// ============================================================================

/** True if this handler has been installed. */
static volatile sig_atomic_t pnlite_g_installed = 0;

/** True if the handler should capture the next stack trace. */
static bool pnlite_g_captureNextStackTrace = false;

static std::terminate_handler pnlite_g_originalTerminateHandler;

/** Buffer for the backtrace of the most recent exception. */
static uintptr_t pnlite_g_stackTrace[PNLite_STACKTRACE_BUFFER_LENGTH];

/** Number of backtrace entries in the most recent exception. */
static int pnlite_g_stackTraceCount = 0;

/** Context to fill with crash information. */
static PNLite_KSCrash_SentryContext *pnlite_g_context;

// ============================================================================
#pragma mark - Callbacks -
// ============================================================================

typedef void (*cxa_throw_type)(void *, std::type_info *, void (*)(void *));

extern "C" {
void __cxa_throw(void *thrown_exception, std::type_info *tinfo,
                 void (*dest)(void *)) __attribute__((weak));

void __cxa_throw(void *thrown_exception, std::type_info *tinfo,
                 void (*dest)(void *)) {
    if (pnlite_g_captureNextStackTrace) {
        pnlite_g_stackTraceCount =
            backtrace((void **)pnlite_g_stackTrace,
                      sizeof(pnlite_g_stackTrace) / sizeof(*pnlite_g_stackTrace));
    }

    static cxa_throw_type orig_cxa_throw = NULL;
    unlikely_if(orig_cxa_throw == NULL) {
        orig_cxa_throw = (cxa_throw_type)dlsym(RTLD_NEXT, "__cxa_throw");
    }
    orig_cxa_throw(thrown_exception, tinfo, dest);
    __builtin_unreachable();
}
}

static void CPPExceptionTerminate(void) {
    PNLite_KSLOG_DEBUG(@"Trapped c++ exception");

    bool isNSException = false;
    char descriptionBuff[PNLite_DESCRIPTION_BUFFER_LENGTH];
    const char *name = NULL;
    const char *description = NULL;

    PNLite_KSLOG_DEBUG(@"Get exception type name.");
    std::type_info *tinfo = __cxxabiv1::__cxa_current_exception_type();
    if (tinfo != NULL) {
        name = tinfo->name();
    }

    description = descriptionBuff;
    descriptionBuff[0] = 0;

    PNLite_KSLOG_DEBUG(@"Discovering what kind of exception was thrown.");
    pnlite_g_captureNextStackTrace = false;
    try {
        throw;
    } catch (NSException *exception) {
        PNLite_KSLOG_DEBUG(@"Detected NSException. Letting the current "
                        @"NSException handler deal with it.");
        isNSException = true;
    } catch (std::exception &exc) {
        strncpy(descriptionBuff, exc.what(), sizeof(descriptionBuff));
    }
#define CATCH_VALUE(TYPE, PRINTFTYPE)                                          \
    catch (TYPE value) {                                                       \
        snprintf(descriptionBuff, sizeof(descriptionBuff), "%" #PRINTFTYPE,    \
                 value);                                                       \
    }
    CATCH_VALUE(char, d)
    CATCH_VALUE(short, d)
    CATCH_VALUE(int, d)
    CATCH_VALUE(long, ld)
    CATCH_VALUE(long long, lld)
    CATCH_VALUE(unsigned char, u)
    CATCH_VALUE(unsigned short, u)
    CATCH_VALUE(unsigned int, u)
    CATCH_VALUE(unsigned long, lu)
    CATCH_VALUE(unsigned long long, llu)
    CATCH_VALUE(float, f)
    CATCH_VALUE(double, f)
    CATCH_VALUE(long double, Lf)
    CATCH_VALUE(char *, s)
    catch (...) {
        description = NULL;
    }
    pnlite_g_captureNextStackTrace = (pnlite_g_installed != 0);

    if (!isNSException) {
        bool wasHandlingCrash = pnlite_g_context->handlingCrash;
        bsg_kscrashsentry_beginHandlingCrash(pnlite_g_context);

        if (wasHandlingCrash) {
            PNLite_KSLOG_INFO(@"Detected crash in the crash reporter. Restoring "
                           @"original handlers.");
            pnlite_g_context->crashedDuringCrashHandling = true;
            bsg_kscrashsentry_uninstall((PNLite_KSCrashType)PNLite_KSCrashTypeAll);
        }

        PNLite_KSLOG_DEBUG(@"Suspending all threads.");
        bsg_kscrashsentry_suspendThreads();

        pnlite_g_context->crashType = PNLite_KSCrashTypeCPPException;
        pnlite_g_context->offendingThread = bsg_ksmachthread_self();
        pnlite_g_context->registersAreValid = false;
        pnlite_g_context->stackTrace =
            pnlite_g_stackTrace + 1; // Don't record __cxa_throw stack entry
        pnlite_g_context->stackTraceLength = pnlite_g_stackTraceCount - 1;
        pnlite_g_context->CPPException.name = name;
        pnlite_g_context->crashReason = description;

        PNLite_KSLOG_DEBUG(@"Calling main crash handler.");
        pnlite_g_context->onCrash();

        PNLite_KSLOG_DEBUG(
            @"Crash handling complete. Restoring original handlers.");
        bsg_kscrashsentry_uninstall((PNLite_KSCrashType)PNLite_KSCrashTypeAll);
        bsg_kscrashsentry_resumeThreads();
    }

    pnlite_g_originalTerminateHandler();
}

// ============================================================================
#pragma mark - Public API -
// ============================================================================

extern "C" bool bsg_kscrashsentry_installCPPExceptionHandler(
    PNLite_KSCrash_SentryContext *context) {
    PNLite_KSLOG_DEBUG(@"Installing C++ exception handler.");

    if (pnlite_g_installed) {
        PNLite_KSLOG_DEBUG(@"C++ exception handler already installed.");
        return true;
    }
    pnlite_g_installed = 1;

    pnlite_g_context = context;

    pnlite_g_originalTerminateHandler = std::set_terminate(CPPExceptionTerminate);
    pnlite_g_captureNextStackTrace = true;
    return true;
}

extern "C" void bsg_kscrashsentry_uninstallCPPExceptionHandler(void) {
    PNLite_KSLOG_DEBUG(@"Uninstalling C++ exception handler.");
    if (!pnlite_g_installed) {
        PNLite_KSLOG_DEBUG(@"C++ exception handler already uninstalled.");
        return;
    }

    pnlite_g_captureNextStackTrace = false;
    std::set_terminate(pnlite_g_originalTerminateHandler);
    pnlite_g_installed = 0;
}
