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

#import "HyBidSignalDataProcessor.h"
#import "PNLiteResponseModel.h"
#import "HyBidLogger.h"
#import "HyBidAd.h"
#import "PNLiteAssetGroupType.h"
#import "HyBidVideoAdProcessor.h"
#import "HyBidVideoAdCacheItem.h"
#import "HyBidVideoAdCache.h"

NSString *const HyBidSignalDataResponseOK = @"ok";

@interface HyBidSignalDataProcessor()

@property (nonatomic, strong) HyBidAd *ad;

@end

@implementation HyBidSignalDataProcessor

- (void)dealloc {
    self.ad = nil;
    self.delegate = nil;
}

- (NSDictionary *)createDictionaryFromData:(NSData *)data {
    NSError *parseError;
    NSDictionary *jsonDictonary = [NSJSONSerialization JSONObjectWithData:data
                                                                  options:NSJSONReadingMutableContainers
                                                                    error:&parseError];
    if (parseError) {
        [self invokeDidFail:parseError];
        return nil;
    } else {
        return jsonDictonary;
    }
}

- (void)processSignalData:(NSString *)signalDataString withZoneID:(NSString *)zoneID {
    NSData *signalData = [signalDataString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDictonary = [self createDictionaryFromData:signalData];
    if (jsonDictonary) {
        PNLiteResponseModel *response = [[PNLiteResponseModel alloc] initWithDictionary:jsonDictonary];
        if(!response) {
            NSError *error = [NSError errorWithDomain:@"Can't parse JSON from server"
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
        } else if ([HyBidSignalDataResponseOK isEqualToString:response.status]) {
            NSMutableArray *responseAdArray = [[NSArray array] mutableCopy];
            for (HyBidAdModel *adModel in response.ads) {
                HyBidAd *ad = [[HyBidAd alloc] initWithData:adModel withZoneID:zoneID];
                [responseAdArray addObject:ad];
                switch (ad.assetGroupID.integerValue) {
                    case VAST_INTERSTITIAL:
                    case VAST_MRECT: {
                        HyBidVideoAdProcessor *videoAdProcessor = [[HyBidVideoAdProcessor alloc] init];
                        [videoAdProcessor processVASTString:ad.vast completion:^(PNLiteVASTModel *vastModel, NSError *error) {
                            if (!vastModel) {
                                [self invokeDidFail:error];
                            } else {
                                HyBidVideoAdCacheItem *videoAdCacheItem = [[HyBidVideoAdCacheItem alloc] init];
                                videoAdCacheItem.vastModel = vastModel;
                                [[HyBidVideoAdCache sharedInstance] putVideoAdCacheItemToCache:videoAdCacheItem withZoneID:zoneID];
                                self.ad = [[HyBidAd alloc] initWithAssetGroup:ad.assetGroupID.integerValue withAdContent:signalDataString withAdType:kHyBidAdTypeVideo];
                                [self invokeDidLoad:self.ad];
                            }
                        }];
                        break;
                    }
                    case MRAID_320x480: {
                        if (responseAdArray.count > 0) {
                            self.ad = [[HyBidAd alloc] initWithAssetGroup:ad.assetGroupID.integerValue withAdContent:signalDataString withAdType:kHyBidAdTypeHTML];
                            [self invokeDidLoad:self.ad];
                        } else {
                            NSError *error = [NSError errorWithDomain:@"No fill"
                                                                 code:0
                                                             userInfo:nil];
                            [self invokeDidFail:error];
                        }
                        break;
                    }
                    default:
                        if (responseAdArray.count > 0) {
                            [self invokeDidLoad:responseAdArray.firstObject];
                        } else {
                            NSError *error = [NSError errorWithDomain:@"No fill"
                                                                 code:0
                                                             userInfo:nil];
                            [self invokeDidFail:error];
                        }
                        break;
                }
            }
            
            if (responseAdArray.count <= 0) {
                NSError *error = [NSError errorWithDomain:@"No fill"
                                                     code:0
                                                 userInfo:nil];
                [self invokeDidFail:error];
            }
            
        } else {
            NSString *errorMessage = [NSString stringWithFormat:@"HyBidSignalDataProcessor - %@", response.errorMessage];
            NSError *responseError = [NSError errorWithDomain:errorMessage
                                                         code:0
                                                     userInfo:nil];
            [self invokeDidFail:responseError];
        }
    }
}

- (void)invokeDidFail:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];
    if(self.delegate && [self.delegate respondsToSelector:@selector(signalDataDidFailWithError:)]) {
        [self.delegate signalDataDidFailWithError:error];
    }
    self.delegate = nil;
}

- (void)invokeDidLoad:(HyBidAd *)ad {
    if (self.delegate && [self.delegate respondsToSelector:@selector(signalDataDidFinishWithAd:)]) {
        [self.delegate signalDataDidFinishWithAd:ad];
    }
    self.delegate = nil;
}

@end
