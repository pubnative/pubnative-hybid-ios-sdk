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
#import "HyBidAdCache.h"
#import "PNLiteAssetGroupType.h"
#import "HyBidVideoAdProcessor.h"
#import "HyBidVideoAdCacheItem.h"
#import "HyBidVideoAdCache.h"
#import "HyBidSignalDataModel.h"
#import "PNLiteHttpRequest.h"
#import "HyBidError.h"

NSString *const HyBidSignalDataResponseOK = @"ok";
NSString *const HyBidSignalDataResponseError = @"error";
NSInteger const HyBidSignalDataResponseStatusOK = 200;
NSInteger const HyBidSignalDataResponseStatusRequestMalformed = 422;

@interface HyBidSignalDataProcessor() <PNLiteHttpRequestDelegate>

@property (nonatomic, strong) HyBidAd *ad;
@property (nonatomic, strong) HyBidSignalDataModel *signalDataModel;

@end

@implementation HyBidSignalDataProcessor

- (void)dealloc {
    self.ad = nil;
    self.signalDataModel = nil;
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

- (void)processSignalData:(NSString *)signalDataString {
    NSData *signalData = [signalDataString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDictonary = [self createDictionaryFromData:signalData];
    if (jsonDictonary) {
        self.signalDataModel = [[HyBidSignalDataModel alloc] initWithDictionary:jsonDictonary];
        if(!self.signalDataModel) {
            [self invokeDidFail:[NSError hyBidParseError]];
        } else if ([HyBidSignalDataResponseOK isEqualToString: self.signalDataModel.status]) {
            if (self.signalDataModel.admurl && self.signalDataModel.admurl.length != 0) {
                [[PNLiteHttpRequest alloc] startWithUrlString:self.signalDataModel.admurl withMethod:@"GET" delegate:self];
            } else {
                [self invokeDidFail:[NSError hyBidInvalidUrl]];
            }
        } else {
            NSError *responseError = [NSError hyBidInvalidSignalData];
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

- (void)processResponseWithData:(NSData *)data {
    NSDictionary *jsonDictonary = [self createDictionaryFromData:data];
    if (jsonDictonary) {
        PNLiteResponseModel *response = [[PNLiteResponseModel alloc] initWithDictionary:jsonDictonary];
        
        if(!response) {
            NSError *error = [NSError hyBidParseError];
            [self invokeDidFail:error];
        } else if ([HyBidSignalDataResponseOK isEqualToString:response.status]) {
            NSMutableArray *responseAdArray = [[NSArray array] mutableCopy];
            for (HyBidAdModel *adModel in response.ads) {
                HyBidAd *ad = [[HyBidAd alloc] initWithData:adModel withZoneID: self.signalDataModel.tagid];
                
                [[HyBidAdCache sharedInstance] putAdToCache:ad withZoneID: self.signalDataModel.tagid];
                [responseAdArray addObject:ad];
                switch (ad.assetGroupID.integerValue) {
                    case VAST_INTERSTITIAL:
                    case VAST_MRECT: {
                        HyBidVideoAdProcessor *videoAdProcessor = [[HyBidVideoAdProcessor alloc] init];
                        [videoAdProcessor processVASTString:ad.vast completion:^(HyBidVASTModel *vastModel, NSError *error) {
                            if (!vastModel) {
                                [self invokeDidFail:error];
                            } else {
                                HyBidVideoAdCacheItem *videoAdCacheItem = [[HyBidVideoAdCacheItem alloc] init];
                                videoAdCacheItem.vastModel = vastModel;
                                [[HyBidVideoAdCache sharedInstance] putVideoAdCacheItemToCache:videoAdCacheItem withZoneID: self.signalDataModel.tagid];
                                [self invokeDidLoad:ad];
                            }
                        }];
                        break;
                    }
                    default:
                        if (responseAdArray.count > 0) {
                            [self invokeDidLoad:responseAdArray.firstObject];
                        } else {
                            NSError *error = [NSError hyBidNoFill];
                            [self invokeDidFail:error];
                        }
                        break;
                }
            }
            
            if (responseAdArray.count <= 0) {
                NSError *error = [NSError hyBidNoFill];
                [self invokeDidFail:error];
            }
            
        } else {
            NSError *responseError = [NSError hyBidServerErrorWithMessage: response.errorMessage];
            [self invokeDidFail:responseError];
        }
    }
}

#pragma mark PNLiteHttpRequestDelegate

- (void)request:(PNLiteHttpRequest *)request didFinishWithData:(NSData *)data statusCode:(NSInteger)statusCode {
    if(HyBidSignalDataResponseStatusOK == statusCode ||
       HyBidSignalDataResponseStatusRequestMalformed == statusCode) {
        
        NSString *responseString;
        if ([self createDictionaryFromData:data]) {
                responseString = [NSString stringWithFormat:@"%@", [self createDictionaryFromData:data]];
        } else {
                responseString = [NSString stringWithFormat:@"Error while creating a JSON Object with the response. Here is the raw data: \r\r%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        }
        [self processResponseWithData:data];
    } else {
        [self invokeDidFail:[NSError hyBidServerError]];
    }
}

- (void)request:(PNLiteHttpRequest *)request didFailWithError:(NSError *)error {
    [self invokeDidFail:error];
}

@end
