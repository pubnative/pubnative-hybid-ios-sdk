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

#ifndef HDR_PNLite_KSSystemCapabilities_h
#define HDR_PNLite_KSSystemCapabilities_h

#include <TargetConditionals.h>

#define PNLite_KSCRASH_HOST_IOS TARGET_OS_IOS
#define PNLite_KSCRASH_HOST_TVOS TARGET_OS_TV
#define PNLite_KSCRASH_HOST_WATCH TARGET_OS_WATCH
#define PNLite_KSCRASH_HOST_OSX                                                   \
    (TARGET_OS_MAC && !(TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH))

#if PNLite_KSCRASH_HOST_IOS || PNLite_KSCRASH_HOST_TVOS
#define PNLite_KSCRASH_HAS_UIKIT 1
#else
#define PNLite_KSCRASH_HAS_UIKIT 0
#endif

#if PNLite_KSCRASH_HOST_IOS
#define PNLite_KSCRASH_HAS_MESSAGEUI 1
#else
#define PNLite_KSCRASH_HAS_MESSAGEUI 0
#endif

#if PNLite_KSCRASH_HOST_IOS || PNLite_KSCRASH_HOST_TVOS
#define PNLite_KSCRASH_HAS_UIDEVICE 1
#else
#define PNLite_KSCRASH_HAS_UIDEVICE 0
#endif

#if PNLite_KSCRASH_HOST_IOS || PNLite_KSCRASH_HOST_OSX
#define PNLite_KSCRASH_HAS_ALERTVIEW 1
#else
#define PNLite_KSCRASH_HAS_ALERTVIEW 0
#endif

#if PNLite_KSCRASH_HOST_IOS
#define PNLite_KSCRASH_HAS_UIALERTVIEW 1
#else
#define PNLite_KSCRASH_HAS_UIALERTVIEW 0
#endif

#if PNLite_KSCRASH_HOST_OSX
#define PNLite_KSCRASH_HAS_NSALERT 1
#else
#define PNLite_KSCRASH_HAS_NSALERT 0
#endif

#if PNLite_KSCRASH_HOST_IOS || PNLite_KSCRASH_HOST_OSX
#define PNLite_KSCRASH_HAS_MACH 1
#else
#define PNLite_KSCRASH_HAS_MACH 0
#endif

#endif // HDR_KSSystemCapabilities_h
