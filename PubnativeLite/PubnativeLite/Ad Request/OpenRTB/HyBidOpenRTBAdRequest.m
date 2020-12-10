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

#import "HyBidOpenRTBAdRequest.h"
#import "PNLiteOpenRTBHttpRequest.h"
#import "PNLiteOpenRTBAdFactory.h"
#import "PNLiteAdRequestModel.h"
#import "PNLiteOpenRTBResponseModel.h"
#import "HyBidAdModel.h"
#import "HyBidAdCache.h"
#import "PNLiteRequestInspector.h"
#import "HyBidLogger.h"
#import "HyBidSettings.h"
#import "PNLiteAssetGroupType.h"
#import "HyBidVideoAdProcessor.h"
#import "HyBidVideoAdCacheItem.h"
#import "HyBidVideoAdCache.h"
#import "HyBidMarkupUtils.h"
#import "HyBidRemoteConfigManager.h"

NSString *const PNLiteOpenRTBResponseOK = @"ok";
NSString *const PNLiteOpenRTBResponseError = @"error";
NSInteger const PNLiteOpenRTBResponseStatusOK = 200;
NSInteger const PNLiteOpenRTBResponseStatusRequestMalformed = 422;

@interface HyBidOpenRTBAdRequest () <PNLiteHttpRequestDelegate>

@property (nonatomic, weak) NSObject <HyBidOpenRTBAdRequestDelegate> *delegate;
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, strong) NSString *zoneID;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSURL *requestURL;
@property (nonatomic, strong) PNLiteAdRequestModel *adRequestModel;
@property (nonatomic, assign) BOOL isSetIntegrationTypeCalled;
@property (nonatomic, strong) PNLiteOpenRTBAdFactory *adFactory;

@end

@implementation HyBidOpenRTBAdRequest

- (void)dealloc {
    self.zoneID = nil;
    self.startTime = nil;
    self.requestURL = nil;
    self.delegate = nil;
    self.adFactory = nil;
    self.adSize = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.adFactory = [[PNLiteOpenRTBAdFactory alloc] init];
        self.adSize = HyBidAdSize.SIZE_320x50;
    }
    return self;
}

- (NSArray<NSString *> *)supportedAPIFrameworks {
    return [NSArray arrayWithObjects:@"5", @"7", nil];
}

- (void)setIntegrationType:(IntegrationType)integrationType withZoneID:(NSString *)zoneID {
    self.zoneID = zoneID;
    self.adRequestModel = [self createAdRequestModelWithIntegrationType:integrationType];
    self.requestURL = [self requestURLFromAdRequestModel:self.adRequestModel];
    self.isSetIntegrationTypeCalled = YES;
}

- (void)requestAdWithDelegate:(NSObject<HyBidOpenRTBAdRequestDelegate> *)delegate withZoneID:(NSString *)zoneID {
    if (self.isRunning) {
        NSError *runningError = [NSError errorWithDomain:@"Request is currently running, droping this call." code:0 userInfo:nil];
        [self invokeDidFail:runningError];
    } else if(!delegate) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Given delegate is nil and required, droping this call."];
    } else if(!zoneID || zoneID.length == 0) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Zone ID nil or empty, droping this call."];
    }
    else {
        [[HyBidRemoteConfigManager sharedInstance] refreshRemoteConfig];
        self.startTime = [NSDate date];
        self.delegate = delegate;
        self.zoneID = zoneID;
        self.isRunning = YES;
        [self invokeDidStart];
        
        if (!self.isSetIntegrationTypeCalled) {
            [self setIntegrationType:HEADER_BIDDING withZoneID:zoneID];
        }
        
        [[PNLiteOpenRTBHttpRequest alloc] startWithUrlString:self.requestURL.absoluteString withMethod:@"POST" withAdRequestModel:self.adRequestModel delegate:self];
//        [[PNLiteHttpRequest alloc] startWithUrlString:self.requestURL.absoluteString withMethod:@"POST" delegate:self];
    }
}

- (void)requestVideoTagFrom:(NSString *)url andWithDelegate:(NSObject<HyBidOpenRTBAdRequestDelegate> *)delegate
{
    self.delegate = delegate;
    [[PNLiteOpenRTBHttpRequest alloc] startWithUrlString:url withMethod:@"POST" withAdRequestModel:self.adRequestModel delegate:self];
//    [[PNLiteHttpRequest alloc] startWithUrlString:url withMethod:@"GET" delegate:self];
}

- (PNLiteAdRequestModel *)createAdRequestModelWithIntegrationType:(IntegrationType)integrationType {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"%@",[self requestURLFromAdRequestModel: [self.adFactory createAdRequestWithZoneID:self.zoneID
                                                                                                                                                                                                                         withAdSize:[self adSize]
                                                                                                                                                                                                         withSupportedAPIFrameworks:[self supportedAPIFrameworks]
                                                                                                                                                                                                                withIntegrationType:integrationType
                                                                                                                                                                                                                         isRewarded:[self isRewarded]]].absoluteString]];
    return [self.adFactory createAdRequestWithZoneID:self.zoneID
                                          withAdSize:[self adSize]
                          withSupportedAPIFrameworks:[self supportedAPIFrameworks]
                                 withIntegrationType:integrationType
                                          isRewarded:[self isRewarded]];
}

- (NSURL*)requestURLFromAdRequestModel:(PNLiteAdRequestModel *)adRequestModel {
    NSURLComponents *components = [NSURLComponents componentsWithString:[HyBidSettings sharedInstance].openRtbApiURL];
    components.path = @"/bid/v1/request";
//    if (adRequestModel.requestParameters) {
//        NSMutableArray *query = [NSMutableArray array];
//        NSDictionary *parametersDictionary = adRequestModel.requestParameters;
//        for (id key in parametersDictionary) {
//            [query addObject:[NSURLQueryItem queryItemWithName:key value:parametersDictionary[key]]];
//        }
//        components.queryItems = query;
//    }
    if (adRequestModel.requestParameters) {
        NSMutableArray *query = [NSMutableArray array];
        NSDictionary *parametersDictionary = adRequestModel.requestParameters;
        for (id key in parametersDictionary) {
            if ([key  isEqual: @"apptoken"] || [key  isEqual: @"zoneid"]) {
                [query addObject:[NSURLQueryItem queryItemWithName:key value:parametersDictionary[key]]];
            }
        }
        components.queryItems = query;
    }
    
    return components.URL;
}

- (void)invokeDidStart {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestDidStart:)]) {
            [self.delegate requestDidStart:self];
        }
    });
}

- (void)invokeDidLoad:(HyBidAd *)ad {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isRunning = NO;
        if (self.delegate && [self.delegate respondsToSelector:@selector(request:didLoadWithAd:)]) {
            [self.delegate request:self didLoadWithAd:ad];
        }
        self.delegate = nil;
    });
}

- (void)invokeDidFail:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isRunning = NO;
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];
        if(self.delegate && [self.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
            [self.delegate request:self didFailWithError:error];
        }
        self.delegate = nil;
    });
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

- (void)processVASTTagResponseFrom:(NSString *)adContent
{
    if ([adContent length] != 0) {
        if ([HyBidMarkupUtils isVastXml:adContent]) {
            HyBidVideoAdProcessor *videoAdProcessor = [[HyBidVideoAdProcessor alloc] init];
            [videoAdProcessor processVASTString:adContent completion:^(PNLiteVASTModel *vastModel, NSError *error) {
                if (!vastModel) {
                    [self invokeDidFail:error];
                } else {
                    NSString *zoneID = @"4";
                    NSInteger assetGroupID = 15;
                    NSInteger type = kHyBidAdTypeVideo;
                    
                    HyBidVideoAdCacheItem *videoAdCacheItem = [[HyBidVideoAdCacheItem alloc] init];
                    videoAdCacheItem.vastModel = vastModel;
                    [[HyBidVideoAdCache sharedInstance] putVideoAdCacheItemToCache:videoAdCacheItem withZoneID:zoneID];
                    HyBidAd *ad = [[HyBidAd alloc] initWithAssetGroup:assetGroupID withAdContent:adContent withAdType:type];
                    [self invokeDidLoad:ad];
                }
            }];
        } else {
            NSInteger assetGroupID = 21;
            NSInteger type = kHyBidAdTypeHTML;
            
            HyBidAd *ad = [[HyBidAd alloc] initWithAssetGroup:assetGroupID withAdContent:adContent withAdType:type];
            [self invokeDidLoad:ad];
        }
    } else {
        NSError *error = [NSError errorWithDomain:@"The server has returned an invalid ad asset" code:0 userInfo:nil];
        [self invokeDidFail:error];
    }
}

- (void)processResponseWithData:(NSData *)data {
    NSDictionary *jsonDictonary = [self createDictionaryFromData:data];
    if (jsonDictonary) {
        PNLiteOpenRTBResponseModel *response = [[PNLiteOpenRTBResponseModel alloc] initWithDictionary:jsonDictonary];
        if(!response) {
            NSError *error = [NSError errorWithDomain:@"Can't parse JSON from server"
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
        }
//        else if ([PNLiteOpenRTBResponseOK isEqualToString:response.status]) {
        else {
            NSMutableArray *responseAdArray = [[NSArray array] mutableCopy];
            for (HyBidAdModel *adModel in response.bids) {
                HyBidAd *ad = [[HyBidAd alloc] initWithData:adModel withZoneID:self.zoneID];
                [[HyBidAdCache sharedInstance] putAdToCache:ad withZoneID:self.zoneID];
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
                                [[HyBidVideoAdCache sharedInstance] putVideoAdCacheItemToCache:videoAdCacheItem withZoneID:self.zoneID];
                                [self invokeDidLoad:ad];
                            }
                        }];
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
            
//        } else {
//            NSString *errorMessage = [NSString stringWithFormat:@"HyBidOpenRTBAdRequest - %@", response.errorMessage];
//            NSError *responseError = [NSError errorWithDomain:errorMessage
//                                                         code:0
//                                                     userInfo:nil];
//            [self invokeDidFail:responseError];
        }
    }
}

#pragma mark PNLiteHttpRequestDelegate

- (void)request:(PNLiteOpenRTBHttpRequest *)request didFinishWithData:(NSData *)data statusCode:(NSInteger)statusCode {
    if(PNLiteOpenRTBResponseStatusOK == statusCode ||
       PNLiteOpenRTBResponseStatusRequestMalformed == statusCode) {
        
        NSString *responseString;
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (![HyBidMarkupUtils isVastXml:dataString]) {
            if ([self createDictionaryFromData:data]) {
                responseString = [NSString stringWithFormat:@"%@",[self createDictionaryFromData:data]];
            } else {
                responseString = [NSString stringWithFormat:@"Error while creating a JSON Object with the response. Here is the raw data: \r\r%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
            }
            
            [[PNLiteRequestInspector sharedInstance] setLastRequestInspectorWithURL:self.requestURL.absoluteString
                                                                       withResponse:responseString
                                                                        withLatency:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSinceDate:self.startTime] * 1000.0]];
            [self processResponseWithData:data];
        } else {
            [self processVASTTagResponseFrom:dataString];
        }
    } else {
        NSError *statusError = [NSError errorWithDomain:@"PNLiteHttpRequestDelegate - Server error: status code" code:statusCode userInfo:nil];
        [self invokeDidFail:statusError];
    }
}

- (void)request:(PNLiteOpenRTBHttpRequest *)request didFailWithError:(NSError *)error {
    [[PNLiteRequestInspector sharedInstance] setLastRequestInspectorWithURL:self.requestURL.absoluteString
                                                               withResponse:error.localizedDescription
                                                                withLatency:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSinceDate:self.startTime] * 1000.0]];
    [self invokeDidFail:error];
}

@end
