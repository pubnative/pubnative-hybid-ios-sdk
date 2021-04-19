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

#import "HyBidAdRequest.h"
#import "PNLiteHttpRequest.h"
#import "PNLiteAdFactory.h"
#import "PNLiteAdRequestModel.h"
#import "PNLiteResponseModel.h"
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

NSString *const PNLiteResponseOK = @"ok";
NSString *const PNLiteResponseError = @"error";
NSInteger const PNLiteResponseStatusOK = 200;
NSInteger const PNLiteResponseStatusRequestMalformed = 422;

@interface HyBidAdRequest () <PNLiteHttpRequestDelegate>

@property (nonatomic, weak) NSObject <HyBidAdRequestDelegate> *delegate;
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, strong) NSString *zoneID;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSURL *requestURL;
@property (nonatomic, strong) PNLiteAdRequestModel *adRequestModel;
@property (nonatomic, assign) BOOL isSetIntegrationTypeCalled;
@property (nonatomic, strong) PNLiteAdFactory *adFactory;
@property (nonatomic, assign) BOOL isUsingOpenRTB;

@end

@implementation HyBidAdRequest

- (void)dealloc {
    self.zoneID = nil;
    self.startTime = nil;
    self.requestURL = nil;
    self.delegate = nil;
    self.adFactory = nil;
    self.adSize = nil;
    self.adRequestModel = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isUsingOpenRTB = ([[NSUserDefaults standardUserDefaults] objectForKey:kIsUsingOpenRTB] != nil)
            ? [[NSUserDefaults standardUserDefaults] boolForKey:kIsUsingOpenRTB]
            : NO;
        
        self.adFactory = [[PNLiteAdFactory alloc] init];
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
    self.requestURL = [self requestURLFromAdRequestModel:[self createAdRequestModelWithIntegrationType:integrationType]];
    self.isSetIntegrationTypeCalled = YES;
}

- (void)requestAdWithDelegate:(NSObject<HyBidAdRequestDelegate> *)delegate withZoneID:(NSString *)zoneID {
    if (self.isRunning) {
        NSError *runningError = [NSError errorWithDomain:@"Request is currently running, droping this call." code:0 userInfo:nil];
        [self invokeDidFail:runningError];
    } else if(!delegate) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Given delegate is nil and required, droping this call."];
    } else if(!zoneID || zoneID.length == 0) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Zone ID nil or empty, droping this call."];
    }
    else {
//        [[HyBidRemoteConfigManager sharedInstance] refreshRemoteConfig];
        self.startTime = [NSDate date];
        self.delegate = delegate;
        self.zoneID = zoneID;
        self.isRunning = YES;
        [self invokeDidStart];
        
        if (!self.isSetIntegrationTypeCalled) {
            [self setIntegrationType:HEADER_BIDDING withZoneID:zoneID];
        }
        
        PNLiteHttpRequest *request = [[PNLiteHttpRequest alloc] init];
        request.isUsingOpenRTB = self.isUsingOpenRTB;
        request.adRequestModel = self.adRequestModel;
        request.openRTBAdType = self.openRTBAdType;
        NSString *method = self.isUsingOpenRTB ? @"POST" : @"GET";
        [request startWithUrlString:self.requestURL.absoluteString withMethod:method delegate:self];
    }
}

- (void)requestVideoTagFrom:(NSString *)url andWithDelegate:(NSObject<HyBidAdRequestDelegate> *)delegate
{
    self.delegate = delegate;
    [[PNLiteHttpRequest alloc] startWithUrlString:url withMethod:@"GET" delegate:self];
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
    if (!self.isUsingOpenRTB) {
        if ([HyBidSettings sharedInstance].apiURL) {
            NSURLComponents *components = [NSURLComponents componentsWithString:[HyBidSettings sharedInstance].apiURL];
            components.path = @"/api/v3/native";
            if (adRequestModel.requestParameters) {
                NSMutableArray *query = [NSMutableArray array];
                NSDictionary *parametersDictionary = adRequestModel.requestParameters;
                for (id key in parametersDictionary) {
                    [query addObject:[NSURLQueryItem queryItemWithName:key value:parametersDictionary[key]]];
                }
                components.queryItems = query;
            }
            return components.URL;
        } else {
            [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"HyBid iOS SDK was not initalized, droping this call. Check out https://github.com/pubnative/pubnative-hybid-ios-sdk/wiki/Setup-HyBid for the setup process."];
            return nil;
        }
    } else {
        if ([HyBidSettings sharedInstance].openRtbApiURL) {
            NSURLComponents *components = [NSURLComponents componentsWithString:[HyBidSettings sharedInstance].openRtbApiURL];
            components.path = @"/bid/v1/request";
            
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
        } else {
            [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"HyBid iOS SDK was not initalized, droping this call. Check out https://github.com/pubnative/pubnative-hybid-ios-sdk/wiki/Setup-HyBid for the setup process."];
            return nil;
        }
    }
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
        if (self.isUsingOpenRTB) {
            NSData *jsonData = [adContent dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
            NSDictionary *seatBid = [jsonObject[@"seatbid"] firstObject];
            NSDictionary *bid = [seatBid[@"bid"] firstObject];
            NSString *vastString = bid[@"adm"];
            adContent = vastString;
        }
        
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
                    ad.isUsingOpenRTB = self.isUsingOpenRTB;
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
        PNLiteResponseModel *response = nil;
        PNLiteOpenRTBResponseModel *openRTBResponse = nil;
        
        if (self.isUsingOpenRTB) {
            openRTBResponse = [[PNLiteOpenRTBResponseModel alloc] initWithDictionary:jsonDictonary];
        } else {
            response = [[PNLiteResponseModel alloc] initWithDictionary:jsonDictonary];
        }
        
        if(!response) {
            NSError *error = [NSError errorWithDomain:@"Can't parse JSON from server"
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
        } else if ([PNLiteResponseOK isEqualToString:response.status] || self.isUsingOpenRTB) {
            NSMutableArray *responseAdArray = [[NSArray array] mutableCopy];
            for (HyBidAdModel *adModel in (self.isUsingOpenRTB ? openRTBResponse.bids : response.ads)) {
                HyBidAd *ad = nil;
                if (self.isUsingOpenRTB) {
                    ad = [[HyBidAd alloc] initOpenRTBWithData:adModel withZoneID:self.zoneID];
                } else {
                    ad = [[HyBidAd alloc] initWithData:adModel withZoneID:self.zoneID];
                }
                
                ad.isUsingOpenRTB = self.isUsingOpenRTB;
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
            
        } else {
            NSString *errorMessage = [NSString stringWithFormat:@"HyBidAdRequest - %@", response.errorMessage];
            NSError *responseError = [NSError errorWithDomain:errorMessage
                                                         code:0
                                                     userInfo:nil];
            [self invokeDidFail:responseError];
        }
    }
}

#pragma mark PNLiteHttpRequestDelegate

- (void)request:(PNLiteHttpRequest *)request didFinishWithData:(NSData *)data statusCode:(NSInteger)statusCode {
    if(PNLiteResponseStatusOK == statusCode ||
       PNLiteResponseStatusRequestMalformed == statusCode) {
        
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

- (void)request:(PNLiteHttpRequest *)request didFailWithError:(NSError *)error {
    [[PNLiteRequestInspector sharedInstance] setLastRequestInspectorWithURL:self.requestURL.absoluteString
                                                               withResponse:error.localizedDescription
                                                                withLatency:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSinceDate:self.startTime] * 1000.0]];
    [self invokeDidFail:error];
}

@end
