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
#import "HyBidError.h"
#import "HyBidRemoteConfigFeature.h"
#import "HyBidRewardedAdRequest.h"
#import "HyBidNativeAdRequest.h"
#import "HyBidInterstitialAdRequest.h"
#import "HyBidError.h"

NSString *const PNLiteResponseOK = @"ok";
NSString *const PNLiteResponseError = @"error";
NSInteger const PNLiteResponseStatusOK = 200;
NSInteger const PNLiteResponseStatusRequestMalformed = 422;

@interface HyBidAdRequest () <PNLiteHttpRequestDelegate>

@property (nonatomic, weak) NSObject <HyBidAdRequestDelegate> *delegate;
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, strong) NSString *zoneID;
@property (nonatomic, strong) NSString *appToken;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSURL *requestURL;
@property (nonatomic, strong) PNLiteAdRequestModel *adRequestModel;
@property (nonatomic, assign) BOOL isSetIntegrationTypeCalled;
@property (nonatomic, strong) PNLiteAdFactory *adFactory;
@property (nonatomic, assign) BOOL isUsingOpenRTB;
@property (nonatomic, assign) IntegrationType requestIntegrationType;
@property (nonatomic, assign) NSTimeInterval initialCacheTimestamp;
@property (nonatomic, assign) NSTimeInterval initialAdResponseTimestamp;
@property (nonatomic, strong) NSMutableDictionary *cacheReportingProperties;
@property (nonatomic, strong) NSMutableDictionary *adResponseReportingProperties;
@property (nonatomic, strong) NSMutableDictionary *requestReportingProperties;
@property (nonatomic, assign) BOOL adCached;

@end

@implementation HyBidAdRequest

- (void)dealloc {
    self.zoneID = nil;
    self.appToken = nil;
    self.startTime = nil;
    self.requestURL = nil;
    self.delegate = nil;
    self.adFactory = nil;
    self.adSize = nil;
    self.adRequestModel = nil;
    self.cacheReportingProperties = nil;
    self.adResponseReportingProperties = nil;
    self.requestReportingProperties = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isUsingOpenRTB = ([[NSUserDefaults standardUserDefaults] objectForKey:kIsUsingOpenRTB] != nil)
        ? [[NSUserDefaults standardUserDefaults] boolForKey:kIsUsingOpenRTB]
        : NO;
        
        self.adFactory = [[PNLiteAdFactory alloc] init];
        self.adSize = HyBidAdSize.SIZE_320x50;
        self.isAutoCacheOnLoad = YES;
        self.cacheReportingProperties = [NSMutableDictionary new];
        self.adResponseReportingProperties = [NSMutableDictionary new];
        self.requestReportingProperties = [NSMutableDictionary new];
    }
    return self;
}

- (NSArray<NSString *> *)supportedAPIFrameworks {
    return [NSArray arrayWithObjects:@"5", @"7", nil];
}

- (IntegrationType)integrationType {
    return self.requestIntegrationType;
}

- (void)setIntegrationType:(IntegrationType)integrationType withZoneID:(NSString *)zoneID {
    [self setIntegrationType:integrationType withZoneID:zoneID withAppToken:nil];
}

- (void)setIntegrationType:(IntegrationType)integrationType withZoneID:(NSString *)zoneID withAppToken:(NSString *)appToken {
    self.zoneID = zoneID;
    self.appToken = appToken;
    self.requestIntegrationType = integrationType;
    self.adRequestModel = [self createAdRequestModelWithIntegrationType:integrationType];
    self.requestURL = [self requestURLFromAdRequestModel:[self createAdRequestModelWithIntegrationType:integrationType]];
    self.isSetIntegrationTypeCalled = YES;
}

- (void)requestAdWithDelegate:(NSObject<HyBidAdRequestDelegate> *)delegate withZoneID:(NSString *)zoneID {
    [self requestAdWithDelegate:delegate withZoneID:zoneID withAppToken:nil];
}

- (void)requestAdWithDelegate:(NSObject<HyBidAdRequestDelegate> *)delegate withZoneID:(NSString *)zoneID withAppToken:(NSString *)appToken {
    if (self.isRunning) {
        NSError *runningError = [NSError errorWithDomain:@"Request is currently running, droping this call." code:HyBidErrorCodeInternal userInfo:nil];
        [self invokeDidFail:runningError];
    } else if(!delegate) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Given delegate is nil and required, droping this call."];
    } else if(!zoneID || zoneID.length == 0) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Zone ID nil or empty, droping this call."];
    } else {
        //        [[HyBidRemoteConfigManager sharedInstance] refreshRemoteConfig];
        self.delegate = delegate;
        if (![self isFormatEnabled]) {
            [self invokeDidFail:[NSError hyBidDisabledFormatError]];
        } else {
            self.startTime = [NSDate date];
            self.zoneID = zoneID;
            self.appToken = appToken;
            self.isRunning = YES;
            self.adCached = NO;
            [self invokeDidStart];
            
            if (!self.isSetIntegrationTypeCalled) {
                [self setIntegrationType:HEADER_BIDDING withZoneID:zoneID];
            }
            
            PNLiteHttpRequest *request = [[PNLiteHttpRequest alloc] init];
            request.isUsingOpenRTB = self.isUsingOpenRTB;
            request.adRequestModel = self.adRequestModel;
            request.openRTBAdType = self.openRTBAdType;
            NSString *method = self.isUsingOpenRTB ? @"POST" : @"GET";
            self.initialAdResponseTimestamp = [[NSDate date] timeIntervalSince1970];
            [request startWithUrlString:self.requestURL.absoluteString withMethod:method delegate:self];
            [self addCommonPropertiesToReportingDictionary:self.requestReportingProperties];
            [self reportEvent:HyBidReportingEventType.REQUEST withProperties:self.requestReportingProperties];
        }
    }
}

- (BOOL)isFormatEnabled {
    if ([self isMemberOfClass:[HyBidAdRequest class]]) {
        return [[[HyBidRemoteConfigManager sharedInstance] featureResolver] isAdFormatEnabled:[HyBidRemoteConfigFeature hyBidRemoteAdFormatToString:HyBidRemoteAdFormat_BANNER]];
    } else if ([self isMemberOfClass:[HyBidInterstitialAdRequest class]]) {
        return [[[HyBidRemoteConfigManager sharedInstance] featureResolver] isAdFormatEnabled:[HyBidRemoteConfigFeature hyBidRemoteAdFormatToString:HyBidRemoteAdFormat_INTERSTITIAL]];
    } else if ([self isMemberOfClass:[HyBidRewardedAdRequest class]]) {
        return [[[HyBidRemoteConfigManager sharedInstance] featureResolver] isAdFormatEnabled:[HyBidRemoteConfigFeature hyBidRemoteAdFormatToString:HyBidRemoteAdFormat_REWARDED]];
    } else if ([self isMemberOfClass:[HyBidNativeAdRequest class]]) {
        return [[[HyBidRemoteConfigManager sharedInstance] featureResolver] isAdFormatEnabled:[HyBidRemoteConfigFeature hyBidRemoteAdFormatToString:HyBidRemoteAdFormat_NATIVE]];
    }
    else {
        return YES;
    }
}

- (void)requestVideoTagFrom:(NSString *)url andWithDelegate:(NSObject<HyBidAdRequestDelegate> *)delegate
{
    self.delegate = delegate;
    [[PNLiteHttpRequest alloc] startWithUrlString:url withMethod:@"GET" delegate:self];
}

- (void)processCustomMarkupFrom:(NSString *)markup andWithDelegate:(NSObject<HyBidAdRequestDelegate> *)delegate {
    self.delegate = delegate;
    [self processVASTTagResponseFrom:markup];
}

- (PNLiteAdRequestModel *)createAdRequestModelWithIntegrationType:(IntegrationType)integrationType {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"%@",[self requestURLFromAdRequestModel: [self.adFactory createAdRequestWithZoneID:self.zoneID
                                                                                                                                                                                                                       withAppToken:self.appToken
                                                                                                                                                                                                                         withAdSize:[self adSize]
                                                                                                                                                                                                         withSupportedAPIFrameworks:[self supportedAPIFrameworks]
                                                                                                                                                                                                                withIntegrationType:integrationType
                                                                                                                                                                                                                         isRewarded:[self isRewarded]
                                                                                                                                                                                                                mediationVendorName:nil]].absoluteString]];
    return [self.adFactory createAdRequestWithZoneID:self.zoneID
                                        withAppToken:self.appToken
                                          withAdSize:[self adSize]
                          withSupportedAPIFrameworks:[self supportedAPIFrameworks]
                                 withIntegrationType:integrationType
                                          isRewarded:[self isRewarded]
                                 mediationVendorName:nil];
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
        return nil;
    } else {
        return jsonDictonary;
    }
}

- (void)processVASTTagResponseFrom:(NSString *)vastAdContent
{
    __block NSString *adContent = vastAdContent;
    
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
            [self.cacheReportingProperties setObject:@"VAST" forKey:HyBidReportingCommon.AD_TYPE];
            
            if (adContent != nil) {
                [self.cacheReportingProperties setObject:adContent forKey:HyBidReportingCommon.CREATIVE];
            }
            
            self.initialCacheTimestamp = [[NSDate date] timeIntervalSince1970];
            HyBidVideoAdProcessor *videoAdProcessor = [[HyBidVideoAdProcessor alloc] init];
            [videoAdProcessor processVASTString:adContent completion:^(HyBidVASTModel *vastModel, NSError *error) {
                adContent = vastModel.vastString;
                if (!vastModel) {
                    [self invokeDidFail:error];
                } else {
                    [self.cacheReportingProperties setObject:[NSString stringWithFormat:@"%f", [self elapsedTimeSince:self.initialCacheTimestamp]] forKey:HyBidReportingCommon.CACHE_TIME];
                    NSString *zoneID = @"4";
                    NSInteger assetGroupID = 15;
                    NSInteger type = kHyBidAdTypeVideo;
                    
                    HyBidVideoAdCacheItem *videoAdCacheItem = [[HyBidVideoAdCacheItem alloc] init];
                    videoAdCacheItem.vastModel = vastModel;
                    [[HyBidVideoAdCache sharedInstance] putVideoAdCacheItemToCache:videoAdCacheItem withZoneID:zoneID];
                    HyBidAd *ad = [[HyBidAd alloc] initWithAssetGroup:assetGroupID withAdContent:adContent withAdType:type];
                    ad.isUsingOpenRTB = self.isUsingOpenRTB;
                    [self invokeDidLoad:ad];
                    [self addCommonPropertiesToReportingDictionary:self.cacheReportingProperties];
                    [self reportEvent:HyBidReportingEventType.CACHE withProperties:self.cacheReportingProperties];
                }
            }];
        } else {
            NSInteger assetGroupID = 21;
            NSInteger type = kHyBidAdTypeHTML;
            
            HyBidAd *ad = [[HyBidAd alloc] initWithAssetGroup:assetGroupID withAdContent:adContent withAdType:type];
            [self invokeDidLoad:ad];
        }
    } else {
        NSError *error = [NSError hyBidInvalidAsset];
        [self invokeDidFail:error];
    }
}

- (void)processResponseWithData:(NSData *)data {
    NSDictionary *jsonDictonary = [self createDictionaryFromData:data];
    if (!jsonDictonary) {
        [self invokeDidFail: NSError.hyBidNullAd];
        return;
    }
        PNLiteResponseModel *response = nil;
        PNLiteOpenRTBResponseModel *openRTBResponse = nil;
        
        if (self.isUsingOpenRTB) {
            openRTBResponse = [[PNLiteOpenRTBResponseModel alloc] initWithDictionary:jsonDictonary];
        } else {
            response = [[PNLiteResponseModel alloc] initWithDictionary:jsonDictonary];
        }
        
        if(!response && !openRTBResponse) {
            NSError *error = [NSError hyBidParseError];
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
                        if (self.isAutoCacheOnLoad == YES) {
                            [self cacheAd:ad];
                        } else {
                            [self invokeDidLoad:ad];
                        }
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

- (void)cacheAd:(HyBidAd *)ad {
    if (self.adCached) {
        return;
    } else {
        [self.cacheReportingProperties setObject:@"VAST" forKey:HyBidReportingCommon.AD_TYPE];
        
        if (ad.vast != nil) {
            [self.cacheReportingProperties setObject:ad.vast forKey:HyBidReportingCommon.CREATIVE];
        }
        self.initialCacheTimestamp = [[NSDate date] timeIntervalSince1970];
        HyBidVideoAdProcessor *videoAdProcessor = [[HyBidVideoAdProcessor alloc] init];
        [videoAdProcessor processVASTString:ad.vast completion:^(HyBidVASTModel *vastModel, NSError *error) {
            if (!vastModel) {
                [self invokeDidFail:error];
            } else {
                [self.cacheReportingProperties setObject:[NSString stringWithFormat:@"%f", [self elapsedTimeSince:self.initialCacheTimestamp]] forKey:HyBidReportingCommon.CACHE_TIME];
                HyBidVideoAdCacheItem *videoAdCacheItem = [[HyBidVideoAdCacheItem alloc] init];
                videoAdCacheItem.vastModel = vastModel;
                [[HyBidVideoAdCache sharedInstance] putVideoAdCacheItemToCache:videoAdCacheItem withZoneID:self.zoneID];
                [self invokeDidLoad:ad];
                [self addCommonPropertiesToReportingDictionary:self.cacheReportingProperties];
                [self reportEvent:HyBidReportingEventType.CACHE withProperties:self.cacheReportingProperties];
                self.adCached = YES;
            }
        }];
    }
}

- (void)setMediationVendor:(NSString *)mediationVendor
{
    if (self.adFactory != nil) {
        [self.adFactory setMediationVendor:mediationVendor];
        
        if (mediationVendor != nil && mediationVendor.length > 0) {
            [self.adResponseReportingProperties setObject:mediationVendor forKey:HyBidReportingCommon.KEY_MEDIATION_VENDOR];
        }
    }
}

- (void)addCommonPropertiesToReportingDictionary:(NSMutableDictionary *)reportingDictionary {
    if ([HyBidSettings sharedInstance].appToken != nil && [HyBidSettings sharedInstance].appToken.length > 0) {
        [reportingDictionary setObject:[HyBidSettings sharedInstance].appToken forKey:HyBidReportingCommon.APPTOKEN];
    }
    if (self.zoneID != nil && self.zoneID.length > 0) {
        [reportingDictionary setObject:self.zoneID forKey:HyBidReportingCommon.ZONE_ID];
    }
    if ([HyBidIntegrationType integrationTypeToString:self.integrationType] != nil && [HyBidIntegrationType integrationTypeToString:self.integrationType].length > 0) {
        [reportingDictionary setObject:[HyBidIntegrationType integrationTypeToString:self.integrationType] forKey:HyBidReportingCommon.INTEGRATION_TYPE];
    }
    if (self.requestURL != nil && self.requestURL.absoluteString.length > 0) {
        [reportingDictionary setObject:self.requestURL.absoluteString forKey:HyBidReportingCommon.AD_REQUEST];
    }
}

- (void)reportEvent:(NSString *)eventType withProperties:(NSMutableDictionary *)properties {
    NSString *adFormat;
    if ([self isRewarded]) {
        adFormat = HyBidReportingAdFormat.REWARDED;
    } else {
        if ([[self adSize] isEqualTo:HyBidAdSize.SIZE_INTERSTITIAL]) {
            adFormat = HyBidReportingAdFormat.FULLSCREEN;
        } else if ([[self adSize] isEqualTo:HyBidAdSize.SIZE_NATIVE]) {
            adFormat = HyBidReportingAdFormat.NATIVE;
        } else {
            adFormat = HyBidReportingAdFormat.BANNER;
            if ([self adSize].description.length > 0) {
                [properties setObject:[self adSize].description forKey:HyBidReportingCommon.AD_SIZE];
            }
        }
    }
    HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc] initWith:eventType
                                                                       adFormat:adFormat
                                                                     properties:properties];
    [[HyBid reportingManager] reportEventFor:reportingEvent];
}

- (NSTimeInterval)elapsedTimeSince:(NSTimeInterval)timestamp {
    return [[NSDate date] timeIntervalSince1970] - timestamp;
}

#pragma mark PNLiteHttpRequestDelegate

- (void)request:(PNLiteHttpRequest *)request didFinishWithData:(NSData *)data statusCode:(NSInteger)statusCode {
    [self.adResponseReportingProperties setObject:[NSString stringWithFormat:@"%f", [self elapsedTimeSince:self.initialAdResponseTimestamp]] forKey:HyBidReportingCommon.RESPONSE_TIME];
    if(PNLiteResponseStatusOK == statusCode ||
       PNLiteResponseStatusRequestMalformed == statusCode) {
        NSString *responseString;
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (dataString) {
            if (![HyBidMarkupUtils isVastXml:dataString]) {
                if ([self createDictionaryFromData:data]) {
                    responseString = [NSString stringWithFormat:@"%@",[self createDictionaryFromData:data]];
                } else {
                    responseString = [NSString stringWithFormat:@"Error while creating a JSON Object with the response. Here is the raw data: \r\r%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
                }
                
                if (responseString != nil) {
                    [self.adResponseReportingProperties setObject:responseString forKey:HyBidReportingCommon.AD_RESPONSE];
                }
                
                [self addCommonPropertiesToReportingDictionary:self.adResponseReportingProperties];
                [self reportEvent:HyBidReportingEventType.RESPONSE withProperties:self.adResponseReportingProperties];
                [[PNLiteRequestInspector sharedInstance] setLastRequestInspectorWithURL:self.requestURL.absoluteString
                                                                           withResponse:responseString
                                                                            withLatency:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSinceDate:self.startTime] * 1000.0]];
                [self processResponseWithData:data];
            } else {
                [self processVASTTagResponseFrom:dataString];
            }
        } else {
            [self invokeDidFail:[NSError hyBidNullAd]];
        }
        
    } else {
        NSError *statusError = [NSError hyBidServerError];
        [self invokeDidFail:statusError];
    }
}

- (void)request:(PNLiteHttpRequest *)request didFailWithError:(NSError *)error {
    [self.adResponseReportingProperties setObject:[NSString stringWithFormat:@"%f", [self elapsedTimeSince:self.initialAdResponseTimestamp]] forKey:HyBidReportingCommon.RESPONSE_TIME];
    if (error != nil && error.debugDescription != nil && error.debugDescription.length > 0) {
        [self.adResponseReportingProperties setObject:error.debugDescription forKey:HyBidReportingCommon.AD_RESPONSE];
    }
    [self addCommonPropertiesToReportingDictionary:self.adResponseReportingProperties];
    [self reportEvent:HyBidReportingEventType.RESPONSE withProperties:self.adResponseReportingProperties];
    [[PNLiteRequestInspector sharedInstance] setLastRequestInspectorWithURL:self.requestURL.absoluteString
                                                               withResponse:error.localizedDescription
                                                                withLatency:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSinceDate:self.startTime] * 1000.0]];
    [self invokeDidFail:error];
}

@end
