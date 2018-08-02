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

#if defined(__arm64__)

#include "PNLite_KSMach.h"

//#define PNLite_KSLogger_LocalLevel TRACE
#include "PNLite_KSLogger.h"

static const char *pnlite_g_registerNames[] = {
    "x0",  "x1",  "x2",  "x3",  "x4",  "x5",  "x6",  "x7",  "x8",
    "x9",  "x10", "x11", "x12", "x13", "x14", "x15", "x16", "x17",
    "x18", "x19", "x20", "x21", "x22", "x23", "x24", "x25", "x26",
    "x27", "x28", "x29", "fp",  "lr",  "sp",  "pc",  "cpsr"};
static const int pnlite_g_registerNamesCount =
    sizeof(pnlite_g_registerNames) / sizeof(*pnlite_g_registerNames);

static const char *pnlite_g_exceptionRegisterNames[] = {"exception", "esr", "far"};
static const int pnlite_g_exceptionRegisterNamesCount =
    sizeof(pnlite_g_exceptionRegisterNames) /
    sizeof(*pnlite_g_exceptionRegisterNames);

uintptr_t
pnlite_ksmachframePointer(const PNLite_STRUCT_MCONTEXT_L *const machineContext) {
    return machineContext->__ss.__fp;
}

uintptr_t
pnlite_ksmachstackPointer(const PNLite_STRUCT_MCONTEXT_L *const machineContext) {
    return machineContext->__ss.__sp;
}

uintptr_t pnlite_ksmachinstructionAddress(
    const PNLite_STRUCT_MCONTEXT_L *const machineContext) {
    return machineContext->__ss.__pc;
}

uintptr_t
pnlite_ksmachlinkRegister(const PNLite_STRUCT_MCONTEXT_L *const machineContext) {
    return machineContext->__ss.__lr;
}

bool pnlite_ksmachthreadState(const thread_t thread,
                           PNLite_STRUCT_MCONTEXT_L *const machineContext) {
    return pnlite_ksmachfillState(thread, (thread_state_t)&machineContext->__ss,
                               ARM_THREAD_STATE64, ARM_THREAD_STATE64_COUNT);
}

bool pnlite_ksmachfloatState(const thread_t thread,
                          PNLite_STRUCT_MCONTEXT_L *const machineContext) {
    return pnlite_ksmachfillState(thread, (thread_state_t)&machineContext->__ns,
                               ARM_VFP_STATE, ARM_VFP_STATE_COUNT);
}

bool pnlite_ksmachexceptionState(const thread_t thread,
                              PNLite_STRUCT_MCONTEXT_L *const machineContext) {
    return pnlite_ksmachfillState(thread, (thread_state_t)&machineContext->__es,
                               ARM_EXCEPTION_STATE64,
                               ARM_EXCEPTION_STATE64_COUNT);
}

int pnlite_ksmachnumRegisters(void) { return pnlite_g_registerNamesCount; }

const char *pnlite_ksmachregisterName(const int regNumber) {
    if (regNumber < pnlite_ksmachnumRegisters()) {
        return pnlite_g_registerNames[regNumber];
    }
    return NULL;
}

uint64_t
pnlite_ksmachregisterValue(const PNLite_STRUCT_MCONTEXT_L *const machineContext,
                        const int regNumber) {
    if (regNumber <= 29) {
        return machineContext->__ss.__x[regNumber];
    }

    switch (regNumber) {
    case 30:
        return machineContext->__ss.__fp;
    case 31:
        return machineContext->__ss.__lr;
    case 32:
        return machineContext->__ss.__sp;
    case 33:
        return machineContext->__ss.__pc;
    case 34:
        return machineContext->__ss.__cpsr;
    }

    PNLite_KSLOG_ERROR("Invalid register number: %d", regNumber);
    return 0;
}

int pnlite_ksmachnumExceptionRegisters(void) {
    return pnlite_g_exceptionRegisterNamesCount;
}

const char *pnlite_ksmachexceptionRegisterName(const int regNumber) {
    if (regNumber < pnlite_ksmachnumExceptionRegisters()) {
        return pnlite_g_exceptionRegisterNames[regNumber];
    }
    PNLite_KSLOG_ERROR("Invalid register number: %d", regNumber);
    return NULL;
}

uint64_t pnlite_ksmachexceptionRegisterValue(
    const PNLite_STRUCT_MCONTEXT_L *const machineContext, const int regNumber) {
    switch (regNumber) {
    case 0:
        return machineContext->__es.__exception;
    case 1:
        return machineContext->__es.__esr;
    case 2:
        return machineContext->__es.__far;
    }

    PNLite_KSLOG_ERROR("Invalid register number: %d", regNumber);
    return 0;
}

uintptr_t
pnlite_ksmachfaultAddress(const PNLite_STRUCT_MCONTEXT_L *const machineContext) {
    return machineContext->__es.__far;
}

int pnlite_ksmachstackGrowDirection(void) { return -1; }

#endif
