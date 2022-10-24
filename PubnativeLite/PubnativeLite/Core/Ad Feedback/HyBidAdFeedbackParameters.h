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
#import "HyBidAdRequest.h"
#import "HyBidAd.h"

@interface HyBidAdFeedbackParameters : NSObject

@property (nonatomic, strong) NSString *requestedZoneID;

@property (readonly) NSString *appToken;
@property (readonly) NSString *audioState;
@property (readonly) NSString *appVersion;
@property (readonly) NSString *deviceInfo;
@property (readonly) NSString *sdkVersion;
@property (readonly) NSString *zoneID;
@property (readonly) NSString *creativeID;
@property (readonly) NSString *creative;
@property (readonly) NSString *impressionBeacon;
@property (readonly) NSString *integrationType;
@property (readonly) NSString *adFormat;
@property (readonly) BOOL hasEndCard;

+ (HyBidAdFeedbackParameters *)sharedInstance;
- (void)cacheAd:(HyBidAd *)ad andAdRequest:(HyBidAdRequest *) adRequest withZoneID:(NSString *)zoneID;

@end
