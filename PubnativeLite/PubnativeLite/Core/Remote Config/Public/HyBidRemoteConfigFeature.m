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

#import "HyBidRemoteConfigFeature.h"

@implementation HyBidRemoteConfigFeature

+ (NSString *)hyBidRemoteAdFormatToString:(HyBidRemoteAdFormat)format
{
    NSArray *adFormats = @[
                                  @"native",
                                  @"banner",
                                  @"interstitial",
                                  @"rewarded",
                                  ];
    return adFormats[format];
}

+ (NSString *)hyBidRemoteRenderingToString:(HyBidRemoteRendering)render
{
    NSArray *renders = @[
                                  @"mraid",
                                  @"vast",
                                  ];
    return renders[render];
}

+ (NSString *)hyBidRemoteReportingToString:(HyBidRemoteReporting)report
{
    NSArray *reports = @[
                                  @"ad_events",
                                  @"ad_errors",
                                  @"diagnostic_init",
                                  @"diagnostic_placement"
                                  ];
    return reports[report];
}

+ (NSString *)hyBidRemoteUserConsentToString:(HyBidRemoteUserConsent)consent
{
    NSArray *consents = @[
                                  @"ccpa",
                                  @"gdpr"
                                  ];
    return consents[consent];
}

@end
