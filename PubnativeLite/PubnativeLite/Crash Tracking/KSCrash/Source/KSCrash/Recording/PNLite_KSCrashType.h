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

#ifndef HDR_PNLite_KSCrashType_h
#define HDR_PNLite_KSCrashType_h

/** Different ways an application can crash:
 * - Mach kernel exception
 * - Fatal signal
 * - Uncaught C++ exception
 * - Uncaught Objective-C NSException
 * - Deadlock on the main thread
 * - User reported custom exception
 */
typedef enum {
    PNLite_KSCrashTypeMachException = 0x01,
    PNLite_KSCrashTypeSignal = 0x02,
    PNLite_KSCrashTypeCPPException = 0x04,
    PNLite_KSCrashTypeNSException = 0x08,
    PNLite_KSCrashTypeMainThreadDeadlock = 0x10,
    PNLite_KSCrashTypeUserReported = 0x20,
} PNLite_KSCrashType;

#define PNLite_KSCrashTypeAll                                                     \
    (PNLite_KSCrashTypeMachException | PNLite_KSCrashTypeSignal |                    \
     PNLite_KSCrashTypeCPPException | PNLite_KSCrashTypeNSException |                \
     PNLite_KSCrashTypeMainThreadDeadlock | PNLite_KSCrashTypeUserReported)

#define PNLite_KSCrashTypeExperimental (PNLite_KSCrashTypeMainThreadDeadlock)

#define PNLite_KSCrashTypeDebuggerUnsafe                                          \
    (PNLite_KSCrashTypeMachException | PNLite_KSCrashTypeNSException)

#define PNLite_KSCrashTypeAsyncSafe                                               \
    (PNLite_KSCrashTypeMachException | PNLite_KSCrashTypeSignal)

/** Crash types that are safe to enable in a debugger. */
#define PNLite_KSCrashTypeDebuggerSafe                                            \
    (PNLite_KSCrashTypeAll & (~PNLite_KSCrashTypeDebuggerUnsafe))

/** It is safe to catch these kinds of crashes in a production environment.
 * All other crash types should be considered experimental.
 */
#define PNLite_KSCrashTypeProductionSafe                                          \
    (PNLite_KSCrashTypeAll & (~PNLite_KSCrashTypeExperimental))

#define PNLite_KSCrashTypeNone 0

const char *pnlite_kscrashtype_name(PNLite_KSCrashType crashType);

#endif // HDR_KSCrashType_h
