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
#import "HyBidAd.h"
#import "HyBidIntegrationType.h"
#import "HyBidAdSize.h"

@class HyBidAdRequest;
@class PNLiteAdRequestModel;

typedef enum {
    HyBidOpenRTBAdNative,
    HyBidOpenRTBAdBanner,
    HyBidOpenRTBAdVideo
 } HyBidOpenRTBAdType;

@protocol HyBidAdRequestDelegate <NSObject>

- (void)requestDidStart:(HyBidAdRequest *)request;
- (void)request:(HyBidAdRequest *)request didLoadWithAd:(HyBidAd *)ad;
- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error;

@end

@interface HyBidAdRequest : NSObject

@property (nonatomic, strong) HyBidAdSize *adSize;
@property (nonatomic, assign) BOOL isRewarded;
@property (nonatomic, readonly) NSArray<NSString *> *supportedAPIFrameworks;
@property (nonatomic) HyBidOpenRTBAdType openRTBAdType;
@property (nonatomic, assign) BOOL isAutoCacheOnLoad;
@property (nonatomic, readonly) IntegrationType integrationType;

- (void)setIntegrationType:(IntegrationType)integrationType withZoneID:(NSString *)zoneID;
- (void)setIntegrationType:(IntegrationType)integrationType withZoneID:(NSString *)zoneID withAppToken:(NSString *)appToken;
- (void)requestAdWithDelegate:(NSObject<HyBidAdRequestDelegate> *)delegate withZoneID:(NSString *)zoneID;
- (void)requestAdWithDelegate:(NSObject<HyBidAdRequestDelegate> *)delegate withZoneID:(NSString *)zoneID withAppToken:(NSString *)appToken;
- (void)requestVideoTagFrom:(NSString *)url andWithDelegate:(NSObject<HyBidAdRequestDelegate> *)delegate;
- (NSURL*)requestURLFromAdRequestModel:(PNLiteAdRequestModel *)adRequestModel;
- (void)processCustomMarkupFrom:(NSString *)markup andWithDelegate:(NSObject<HyBidAdRequestDelegate> *)delegate;
- (void)cacheAd:(HyBidAd *)ad;
- (void)setMediationVendor:(NSString *)mediationVendor;

@end
