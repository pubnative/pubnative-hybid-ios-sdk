//
//  Copyright © 2020 PubNative. All rights reserved.
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

#import "AppMonet.h"

@class DFPRequest;
@class DFPBannerView;
@class GADRequest;
@class GADBannerView;
@class DFPInterstitial;
@class GADInterstitial;

@interface AppMonet (DFP) <HyBidAdRequestDelegate>

+ (void) addBids:(DFPBannerView *)adView andAppMonetAdUnitId:(NSString *)appMonetAdUinitId andDfpAdRequest:(DFPRequest *)adRequest andTimeout:(NSNumber *)timeout
andDfpRequestBlock:(void (^)(DFPRequest *dfpRequest))dfpRequestBlock;

//+ (void)    addBids:(DFPBannerView *)adView andDfpAdRequest:(DFPRequest *)adRequest
//andAppMonetAdUnitId:(NSString *)appMonetAdUnitId andTimeout:(NSNumber *)timeout
// andDfpRequestBlock:(void (^)(DFPRequest *dfpRequest))dfpRequestBlock;
//
//+ (DFPRequest *)addBids:(DFPBannerView *)adView andDfpAdRequest:(DFPRequest *)adRequest;
//
//+ (void)   addBids:(DFPRequest *)adRequest andAppMonetAdUnitId:(NSString *)appMonetAdUnitId andTimeout:(NSNumber *)timeout
//andDfpRequestBlock:(void (^)(DFPRequest *dfpRequest))dfpRequestBlock;
//
//+ (DFPRequest *)addBids:(DFPRequest *)adRequest andAppMonetAdUnitId:(NSString *)appMonetAdUnitId;
//
//+ (void)    addBids:(GADBannerView *)adView andGadRequest:(GADRequest *)adRequest
//andAppMonetAdUnitId:(NSString *)appMonetAdUnitId andTimeout:(NSNumber *)timeout
// andGadRequestBlock:(void (^)(GADRequest *gadRequest))gadRequestBlock;
//
//+ (GADRequest *)addBids:(GADBannerView *)adView andGadRequest:(GADRequest *)adRequest
//    andAppMonetAdUnitId:(NSString *)appMonetAdUnitId;
//
//+ (void)    addBids:(GADBannerView *)adView andDfpRequest:(DFPRequest *)adRequest
//andAppMonetAdUnitId:(NSString *)appMonetAdUnitId andTimeout:(NSNumber *)timeout
// andDfpRequestBlock:(void (^)(DFPRequest *dfpRequest))dfpRequestBlock;
//
//+ (DFPRequest *)addBids:(GADBannerView *)adView andDfpRequest:(DFPRequest *)adRequest
//    andAppMonetAdUnitId:(NSString *)appMonetAdUnitId;
//
//+ (void)addInterstitialBids:(DFPInterstitial *)interstitial
//            andDfpAdRequest:(DFPRequest *)adRequest
//                 andTimeout:(NSNumber *)timeout
//                  withBlock:(void (^)(DFPRequest *completeRequest))requestBlock;
//
//+ (void)addInterstitialBids:(DFPInterstitial *)interstitial
//        andAppMonetAdUnitId:(NSString *)appmonetAdUnitID
//            andDfpAdRequest:(DFPRequest *)adRequest
//                 andTimeout:(NSNumber *)timeout
//                  withBlock:(void (^)(DFPRequest *completeRequest))requestBlock;
//
//+(void)addInterstitialBids:(GADInterstitial *)interstitial
//              andAdRequest:(GADRequest *)adRequest
//                andTimeout:(NSNumber *)timeout
//                 withBlock:(void (^)(GADRequest *))requestBlock;

@end
