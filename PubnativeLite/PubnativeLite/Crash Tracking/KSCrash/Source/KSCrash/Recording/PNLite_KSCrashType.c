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

#include "PNLite_KSCrashType.h"

#include <stdlib.h>

static const struct {
    const PNLite_KSCrashType type;
    const char *const name;
} pnlite_g_crashTypes[] = {
#define PNLite_CRASHTYPE(NAME)                                                    \
    { NAME, #NAME }
    PNLite_CRASHTYPE(PNLite_KSCrashTypeMachException),
    PNLite_CRASHTYPE(PNLite_KSCrashTypeSignal),
    PNLite_CRASHTYPE(PNLite_KSCrashTypeCPPException),
    PNLite_CRASHTYPE(PNLite_KSCrashTypeNSException),
    PNLite_CRASHTYPE(PNLite_KSCrashTypeMainThreadDeadlock),
    PNLite_CRASHTYPE(PNLite_KSCrashTypeUserReported),
};
static const int pnlite_g_crashTypesCount =
    sizeof(pnlite_g_crashTypes) / sizeof(*pnlite_g_crashTypes);

const char *pnlite_kscrashtype_name(const PNLite_KSCrashType crashType) {
    for (int i = 0; i < pnlite_g_crashTypesCount; i++) {
        if (pnlite_g_crashTypes[i].type == crashType) {
            return pnlite_g_crashTypes[i].name;
        }
    }
    return NULL;
}
