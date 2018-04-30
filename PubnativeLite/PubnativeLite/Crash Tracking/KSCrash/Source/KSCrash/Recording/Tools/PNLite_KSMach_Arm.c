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

#if defined(__arm__)

#include "PNLite_KSMach.h"

//#define PNLite_KSLogger_LocalLevel TRACE
#include "PNLite_KSLogger.h"

static const char *pnlite_g_registerNames[] = {
    "r0", "r1",  "r2",  "r3", "r4", "r5", "r6", "r7",  "r8",
    "r9", "r10", "r11", "ip", "sp", "lr", "pc", "cpsr"};
static const int pnlite_g_registerNamesCount =
    sizeof(pnlite_g_registerNames) / sizeof(*pnlite_g_registerNames);

static const char *pnlite_g_exceptionRegisterNames[] = {"exception", "fsr", "far"};
static const int pnlite_g_exceptionRegisterNamesCount =
    sizeof(pnlite_g_exceptionRegisterNames) /
    sizeof(*pnlite_g_exceptionRegisterNames);

uintptr_t
bsg_ksmachframePointer(const PNLite_STRUCT_MCONTEXT_L *const machineContext) {
    return machineContext->__ss.__r[7];
}

uintptr_t
bsg_ksmachstackPointer(const PNLite_STRUCT_MCONTEXT_L *const machineContext) {
    return machineContext->__ss.__sp;
}

uintptr_t bsg_ksmachinstructionAddress(
    const PNLite_STRUCT_MCONTEXT_L *const machineContext) {
    return machineContext->__ss.__pc;
}

uintptr_t
bsg_ksmachlinkRegister(const PNLite_STRUCT_MCONTEXT_L *const machineContext) {
    return machineContext->__ss.__lr;
}

bool bsg_ksmachthreadState(const thread_t thread,
                           PNLite_STRUCT_MCONTEXT_L *const machineContext) {
    return bsg_ksmachfillState(thread, (thread_state_t)&machineContext->__ss,
                               ARM_THREAD_STATE, ARM_THREAD_STATE_COUNT);
}

bool bsg_ksmachfloatState(const thread_t thread,
                          PNLite_STRUCT_MCONTEXT_L *const machineContext) {
    return bsg_ksmachfillState(thread, (thread_state_t)&machineContext->__fs,
                               ARM_VFP_STATE, ARM_VFP_STATE_COUNT);
}

bool bsg_ksmachexceptionState(const thread_t thread,
                              PNLite_STRUCT_MCONTEXT_L *const machineContext) {
    return bsg_ksmachfillState(thread, (thread_state_t)&machineContext->__es,
                               ARM_EXCEPTION_STATE, ARM_EXCEPTION_STATE_COUNT);
}

int bsg_ksmachnumRegisters(void) { return pnlite_g_registerNamesCount; }

const char *bsg_ksmachregisterName(const int regNumber) {
    if (regNumber < bsg_ksmachnumRegisters()) {
        return pnlite_g_registerNames[regNumber];
    }
    return NULL;
}

uint64_t
bsg_ksmachregisterValue(const PNLite_STRUCT_MCONTEXT_L *const machineContext,
                        const int regNumber) {
    if (regNumber <= 12) {
        return machineContext->__ss.__r[regNumber];
    }

    switch (regNumber) {
    case 13:
        return machineContext->__ss.__sp;
    case 14:
        return machineContext->__ss.__lr;
    case 15:
        return machineContext->__ss.__pc;
    case 16:
        return machineContext->__ss.__cpsr;
    }

    PNLite_KSLOG_ERROR("Invalid register number: %d", regNumber);
    return 0;
}

int bsg_ksmachnumExceptionRegisters(void) {
    return pnlite_g_exceptionRegisterNamesCount;
}

const char *bsg_ksmachexceptionRegisterName(const int regNumber) {
    if (regNumber < bsg_ksmachnumExceptionRegisters()) {
        return pnlite_g_exceptionRegisterNames[regNumber];
    }
    PNLite_KSLOG_ERROR("Invalid register number: %d", regNumber);
    return NULL;
}

uint64_t bsg_ksmachexceptionRegisterValue(
    const PNLite_STRUCT_MCONTEXT_L *const machineContext, const int regNumber) {
    switch (regNumber) {
    case 0:
        return machineContext->__es.__exception;
    case 1:
        return machineContext->__es.__fsr;
    case 2:
        return machineContext->__es.__far;
    }

    PNLite_KSLOG_ERROR("Invalid register number: %d", regNumber);
    return 0;
}

uintptr_t
bsg_ksmachfaultAddress(const PNLite_STRUCT_MCONTEXT_L *const machineContext) {
    return machineContext->__es.__far;
}

int bsg_ksmachstackGrowDirection(void) { return -1; }

#endif
