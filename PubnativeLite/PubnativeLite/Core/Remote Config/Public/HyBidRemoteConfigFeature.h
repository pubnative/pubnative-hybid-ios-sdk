//
//  Copyright © 2021 PubNative. All rights reserved.
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

typedef enum {
    HyBidRemoteAdFormat_NATIVE,
    HyBidRemoteAdFormat_BANNER,
    HyBidRemoteAdFormat_INTERSTITIAL,
    HyBidRemoteAdFormat_REWARDED
} HyBidRemoteAdFormat;

typedef enum {
    HyBidRemoteRendering_MRAID,
    HyBidRemoteRendering_VAST
} HyBidRemoteRendering;

typedef enum {
    HyBidRemoteReporting_AD_EVENTS,
    HyBidRemoteReporting_AD_ERRORS,
    HyBidRemoteReporting_DIAGNOSTIC_INIT,
    HyBidRemoteReporting_DIAGNOSTIC_PLACEMENT
} HyBidRemoteReporting;

typedef enum {
    HyBidRemoteUserConsent_CCPA,
    HyBidRemoteUserConsent_GDPR
} HyBidRemoteUserConsent;

@interface HyBidRemoteConfigFeature : NSObject

+ (NSString *)hyBidRemoteAdFormatToString:(HyBidRemoteAdFormat)adFormat;
+ (NSString *)hyBidRemoteRenderingToString:(HyBidRemoteRendering)render;
+ (NSString *)hyBidRemoteReportingToString:(HyBidRemoteReporting)report;
+ (NSString *)hyBidRemoteUserConsentToString:(HyBidRemoteUserConsent)consent;

@end
