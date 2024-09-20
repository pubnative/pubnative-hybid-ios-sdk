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
#import "HyBidXMLEx.h"
#import "HyBidAdModel.h"
#import "HyBidAdCache.h"
#import "PNLiteRequestInspector.h"
#import "HyBidVideoAdProcessor.h"
#import "HyBidVideoAdCacheItem.h"
#import "HyBidVideoAdCache.h"
#import "HyBidMarkupUtils.h"
#import "HyBidError.h"
#import "HyBidRewardedAdRequest.h"
#import "HyBidNativeAdRequest.h"
#import "HyBidInterstitialAdRequest.h"
#import "HyBidError.h"
#import "HyBidAdFeedbackParameters.h"
#import "HyBidVASTEndCardManager.h"
#import "HyBidVASTEventProcessor.h"
#import "HyBidVASTParserError.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif


NSString *const PNLiteResponseOK = @"ok";
NSString *const PNLiteResponseError = @"error";
NSInteger const PNLiteResponseStatusOK = 200;

@interface HyBidAdRequest () <PNLiteHttpRequestDelegate>

@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, strong) NSString *zoneID;
@property (nonatomic, strong) NSString *appToken;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSURL *requestURL;
@property (nonatomic, strong) PNLiteAdRequestModel *adRequestModel;
@property (nonatomic, assign) BOOL isSetIntegrationTypeCalled;
@property (nonatomic, strong) PNLiteAdFactory *adFactory;
@property (nonatomic, assign) IntegrationType requestIntegrationType;
@property (nonatomic, assign) NSTimeInterval initialCacheTimestamp;
@property (nonatomic, assign) NSTimeInterval initialAdResponseTimestamp;
@property (nonatomic, strong) NSMutableDictionary *cacheReportingProperties;
@property (nonatomic, strong) NSMutableDictionary *adResponseReportingProperties;
@property (nonatomic, strong) NSMutableDictionary *requestReportingProperties;
@property (nonatomic, assign) BOOL adCached;
@property (nonatomic, strong) HyBidVASTEndCardManager *endCardManager;
@property (nonatomic, strong) NSData *body;
@property (nonatomic, strong) HyBidVASTEventProcessor *vastEventProcessor;

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
    self.isUsingOpenRTB = NO;
    self.vastEventProcessor = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.adFactory = [[PNLiteAdFactory alloc] init];
        self.adSize = HyBidAdSize.SIZE_320x50;
        self.isAutoCacheOnLoad = YES;
        self.cacheReportingProperties = [NSMutableDictionary new];
        self.adResponseReportingProperties = [NSMutableDictionary new];
        self.requestReportingProperties = [NSMutableDictionary new];
        self.endCardManager = [[HyBidVASTEndCardManager alloc] init];
        self.vastEventProcessor = [[HyBidVASTEventProcessor alloc] init];
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
    self.requestURL = [self requestURLFromAdRequestModel: self.adRequestModel];
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
        [PNLiteRequestInspector sharedInstance].lastInspectedRequest = nil;
        self.delegate = delegate;
        
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
        if(self.requestReportingProperties) {
            [self.requestReportingProperties addEntriesFromDictionary:[[HyBid reportingManager] addCommonPropertiesForAd:nil withRequest:self]];
            [self reportEvent:HyBidReportingEventType.REQUEST withProperties:self.requestReportingProperties];
        }
        self.body = request.body;
    }
}

- (void)requestVideoTagFrom:(NSString *)url andWithDelegate:(NSObject<HyBidAdRequestDelegate> *)delegate
{
    self.delegate = delegate;
    [[PNLiteHttpRequest alloc] startWithUrlString:url withMethod:@"GET" delegate:self];
}

- (void)processCustomMarkupFrom:(NSString *)markup withPlacement: (HyBidMarkupPlacement)placement andWithDelegate:(NSObject<HyBidAdRequestDelegate> *)delegate {
    self.delegate = delegate;
    self.placement = placement;
    [self processVASTTagResponseFrom:markup];
}

- (PNLiteAdRequestModel *)createAdRequestModelWithIntegrationType:(IntegrationType)integrationType {
    PNLiteAdRequestModel * requestModel = [self.adFactory createAdRequestWithZoneID:self.zoneID
                                                                       withAppToken:self.appToken
                                                                         withAdSize:[self adSize]
                                                         withSupportedAPIFrameworks:[self supportedAPIFrameworks]
                                                                withIntegrationType:integrationType
                                                                         isRewarded:[self isRewarded]
                                                                     isUsingOpenRTB:[self isUsingOpenRTB]
                                                                mediationVendorName:nil];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"%@",[self requestURLFromAdRequestModel: requestModel].absoluteString]];
    return requestModel;
}

- (NSURL*)requestURLFromAdRequestModel:(PNLiteAdRequestModel *)adRequestModel {
    NSURLComponents *components;

    if (!self.isUsingOpenRTB) {
        if ([HyBidSDKConfig sharedConfig].apiURL) {
            components = [NSURLComponents componentsWithString:[HyBidSDKConfig sharedConfig].apiURL];
            components.path = @"/api/v3/native";
            
            if (adRequestModel.requestParameters) {
                NSMutableArray *query = [NSMutableArray array];
                NSDictionary *parametersDictionary = adRequestModel.requestParameters;
                for (id key in parametersDictionary) {
                    id value = parametersDictionary[key];
                    [query addObject:[NSURLQueryItem queryItemWithName:key value:value]];
                }
                components.queryItems = query;
            }
        }
    } else {
        if ([HyBidSDKConfig sharedConfig].openRtbApiURL) {
            components = [NSURLComponents componentsWithString:[HyBidSDKConfig sharedConfig].openRtbApiURL];
            components.path = @"/bid/v1/request";
            
            if (adRequestModel.requestParameters) {
                NSMutableArray *query = [NSMutableArray array];
                NSDictionary *parametersDictionary = adRequestModel.requestParameters;
                for (id key in parametersDictionary) {
                    id value = parametersDictionary[key];
                    if ([key isEqual:@"apptoken"] || [key isEqual:@"zoneid"]) {
                        [query addObject:[NSURLQueryItem queryItemWithName:key value:value]];
                    }
                }
                components.queryItems = query;
            }
        }
    }

    if (!components) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"HyBid iOS SDK was not initialized, dropping this call. Check out the setup process."];
        return nil;
    }
    
    if (!components.URL) {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Failed to create a valid URL."];
        return nil;
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
    if (self.zoneID) {
        [[HyBidAdFeedbackParameters sharedInstance] cacheAd:ad andAdRequest:self withZoneID:self.zoneID];
    }
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
    NSDictionary *bid;
    if (self.isUsingOpenRTB) {
        NSData *jsonData = [adContent dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        NSDictionary *seatBid = [jsonObject[@"seatbid"] firstObject];
        bid = [seatBid[@"bid"] firstObject];
        NSString *vastString = bid[@"adm"];
        adContent = vastString;
    }
    
    if ([adContent length] != 0) {
        [HyBidMarkupUtils isVastXml:adContent completion:^(BOOL isVAST, HyBidVASTParserError* error) {
            if (error) {
                [self invokeDidFail:error];
                [self.vastEventProcessor sendVASTUrls:error.errorTagURLs];
                return;
            }
            
            if (isVAST) {
                [self.cacheReportingProperties setObject:@"VAST" forKey:HyBidReportingCommon.AD_TYPE];
                
                if (adContent != nil) {
                    [self.cacheReportingProperties setObject:adContent forKey:HyBidReportingCommon.CREATIVE];
                }
                self.initialCacheTimestamp = [[NSDate date] timeIntervalSince1970];
                HyBidVideoAdProcessor *videoAdProcessor = [[HyBidVideoAdProcessor alloc] init];
                [videoAdProcessor processVASTString:adContent completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError *error) {
                    adContent = vastModel.vastString;
                    if (!vastModel) {
                        [self invokeDidFail:error];
                        [self.vastEventProcessor sendVASTUrls: error.errorTagURLs];
                    } else {
                        [self.cacheReportingProperties setObject:[NSString stringWithFormat:@"%f", [self elapsedTimeSince:self.initialCacheTimestamp]] forKey:HyBidReportingCommon.CACHE_TIME];
                        NSInteger assetGroupID = (self.placement == HyBidDemoAppPlacementMRect) ? 4 : 15;
                        NSString *zoneID = @"4";
                        NSInteger type = kHyBidAdTypeVideo;
                        if (self.openRTBAdType == HyBidOpenRTBAdVideo &&
                            self.zoneID != nil &&
                            ![self.zoneID isEqualToString:@"4"] &&
                            ![self.zoneID isEqualToString:@"6"] &&
                            ![self.zoneID isEqualToString:@"legacy_api_tester"]) {
                            assetGroupID = 4;
                        }
                        HyBidVideoAdCacheItem *videoAdCacheItem = [[HyBidVideoAdCacheItem alloc] init];
                        videoAdCacheItem.vastModel = vastModel;
                        [[HyBidVideoAdCache sharedInstance] putVideoAdCacheItemToCache:videoAdCacheItem withZoneID:zoneID];
                        
                        HyBidAd *ad;
                        if (self.isUsingOpenRTB) {
                            ad = [[HyBidAd alloc] initWithAssetGroupForOpenRTB:assetGroupID withAdContent:adContent withAdType:type withBidObject:bid];
                        } else {
                            ad = [[HyBidAd alloc] initWithAssetGroup:assetGroupID withAdContent:adContent withAdType:type];
                        }
                        ad.isUsingOpenRTB = self.isUsingOpenRTB;
                        
                        NSArray *endCards = [self fetchEndCardsFromVastAd:vastModel.vastArray];
                        if ([ad.endcardEnabled boolValue] || (ad.endcardEnabled == nil && HyBidConstants.showEndCard)) {
                            if ([endCards count] > 0) {
                                [ad setHasEndCard:YES];
                                if ([ad.customEndcardEnabled boolValue] || (ad.customEndcardEnabled == nil && HyBidConstants.showCustomEndCard)) {
                                    if ([self customEndcardDisplayBehaviourFromString:ad.customEndcardDisplay] == HyBidCustomEndcardDisplayExtention || (ad.customEndcardDisplay == nil && HyBidConstants.customEndcardDisplay == HyBidCustomEndcardDisplayExtention)) {
                                        if (ad.customEndCardData && ad.customEndCardData.length > 0) {
                                            [ad setHasCustomEndCard:YES];
                                        }
                                    }
                                }
                            } else if ([endCards count] == 0) {
                                if ([ad.customEndcardEnabled boolValue] || (ad.customEndcardEnabled == nil && HyBidConstants.showCustomEndCard)){
                                    if (ad.customEndCardData && ad.customEndCardData.length > 0) {
                                        [ad setHasCustomEndCard:YES];
                                    }
                                }
                            }
                        } else if (ad.endcardEnabled != nil || (ad.endcardEnabled == nil && !HyBidConstants.showEndCard)) {
                            if ([ad.customEndcardEnabled boolValue] || (ad.customEndcardEnabled == nil && HyBidConstants.showCustomEndCard)) {
                                if (ad.customEndCardData && ad.customEndCardData.length > 0) {
                                    [ad setHasCustomEndCard:YES];
                                }
                            }
                        }
                        [self invokeDidLoad:ad];
                        if (self.cacheReportingProperties) {
                            [self.cacheReportingProperties addEntriesFromDictionary:[[HyBid reportingManager] addCommonPropertiesForAd:ad withRequest:self]];
                            [self reportEvent:HyBidReportingEventType.CACHE withProperties:self.cacheReportingProperties];
                        }
                    }
                }];
            } else {
                NSInteger assetGroupID = 21;
                NSInteger type = kHyBidAdTypeHTML;
                
                HyBidAd *ad = [[HyBidAd alloc] initWithAssetGroup:assetGroupID withAdContent:adContent withAdType:type];
                [self invokeDidLoad:ad];
            }
        }];
    } else {
        NSError *error = [NSError hyBidInvalidAsset];
        [self invokeDidFail:error];
    }
}

- (void)processResponseWithJSON:(NSString*)adReponse {
    self.zoneID = @"legacy_api_tester";
    if (self.isUsingOpenRTB && self.openRTBAdType == HyBidOpenRTBAdVideo) {
        [self processVASTTagResponseFrom:adReponse];
    } else {
        NSData *adReponseData = [adReponse dataUsingEncoding:NSUTF8StringEncoding];
        [self processResponseWithData:adReponseData];
    }
}

- (void)processResponseWithData:(NSData *)data {
    __block NSString *adContent = data.description;
    NSDictionary *bid;
    if (self.isUsingOpenRTB) {
        NSError *error;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSDictionary *seatBid = [jsonObject[@"seatbid"] firstObject];
        bid = [seatBid[@"bid"] firstObject];
        NSString *adModel = bid[@"adm"];
        if (adModel != nil) {
            adContent = adModel;
        }
    }
    
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
                    NSInteger assetGroupID = 21;
                    NSInteger type = kHyBidAdTypeHTML;
                    if (self.openRTBAdType == HyBidOpenRTBAdNative){
                        #if __has_include(<ATOM/ATOM-Swift.h>)
                        NSArray<NSString *> *cohorts = [self getCohortsFromRequestURL];
                        ad = [[HyBidAd alloc] initOpenRTBWithData:adModel withZoneID:self.zoneID withCohorts:cohorts];
                        #else
                        ad = [[HyBidAd alloc] initOpenRTBWithData:adModel withZoneID:self.zoneID];
                        #endif
                    } else if (self.openRTBAdType == HyBidOpenRTBAdBanner){
                        #if __has_include(<ATOM/ATOM-Swift.h>)
                        ad = [[HyBidAd alloc] initWithAssetGroupForOpenRTB:assetGroupID withAdContent: adContent withAdType:type withBidObject:bid];
                        #else
                        ad = [[HyBidAd alloc]initWithAssetGroupForOpenRTB:assetGroupID withAdContent:adContent withAdType:type withBidObject:bid];
                        #endif
                    }
                   
                } else {
                    #if __has_include(<ATOM/ATOM-Swift.h>)
                    NSArray<NSString *> *cohorts = [self getCohortsFromRequestURL];
                    ad = [[HyBidAd alloc] initWithData:adModel withZoneID:self.zoneID withCohorts:cohorts];
                    #else
                    ad = [[HyBidAd alloc] initWithData:adModel withZoneID:self.zoneID];
                    #endif
                }
                
                ad.isUsingOpenRTB = self.isUsingOpenRTB;
                [[HyBidAdCache sharedInstance] putAdToCache:ad withZoneID:self.zoneID];
                [responseAdArray addObject:ad];
                
                NSNumber *assetGroupID;
                if (ad.isUsingOpenRTB) {
                    assetGroupID = ad.openRTBAssetGroupID;
                } else {
                    assetGroupID = ad.assetGroupID;
                }
                switch ([assetGroupID intValue]) {
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
            NSError *responseError = (response.errorMessage != nil) ? [NSError hyBidServerErrorWithMessage:response.errorMessage] : [NSError hyBidServerError];
            [self invokeDidFail:responseError];
        }
}

#if __has_include(<ATOM/ATOM-Swift.h>)
- (NSArray<NSString *> *)getCohortsFromRequestURL
{
    NSMutableArray<NSString *> *cohorts = [NSMutableArray new];
    NSString *vgParameter;
    
    if (self.requestURL != nil && [self.requestURL.absoluteString length] > 0) {
        NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:self.requestURL.absoluteString];
        NSArray<NSURLQueryItem *> *queryItems = urlComponents.queryItems;
        
        for (NSURLQueryItem *item in queryItems) {
            if ([item.name isEqualToString:@"vg"]) {
                vgParameter = item.value;
                break;
            }
        }
        
        if (vgParameter != nil && [vgParameter length] > 0) {
            NSString *decodedVgParameterString = nil;
            
            while (decodedVgParameterString == nil || [decodedVgParameterString isEqualToString:@""]) {
                NSData *decodedVgParameterData = [[NSData alloc] initWithBase64EncodedString:vgParameter options:0];
                decodedVgParameterString = [[NSString alloc] initWithData:decodedVgParameterData encoding:NSUTF8StringEncoding];
                
                // appending here `=` characters as
                // according to BaseURL protocol, we trimmed all paddings(`=` characters)
                // before setting the `vg` parameter, to avoid the conversion of
                // paddings(`=`) into `%3D` during URL encoding part.
                vgParameter = [vgParameter stringByAppendingString:@"="];
            }
            
            // removing `[` and `]` as we get an array in `decodedVgParameterString`
            if ([decodedVgParameterString length] > 1) {
                decodedVgParameterString = [decodedVgParameterString substringFromIndex:1];
                decodedVgParameterString = [decodedVgParameterString substringToIndex:[decodedVgParameterString length] - 1];
            }
            
            decodedVgParameterString = [decodedVgParameterString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if (![decodedVgParameterString isEqualToString:@""]) {
                [cohorts addObjectsFromArray: [decodedVgParameterString componentsSeparatedByString:@","]];
            }
        }
    }
    
    return cohorts;
}
#endif

- (void)cacheAd:(HyBidAd *)ad {
    if (self.adCached) {
        return;
    } else {
        [self.cacheReportingProperties setObject:@"VAST" forKey:HyBidReportingCommon.AD_TYPE];
        
        NSString *vast = ad.isUsingOpenRTB
        ? ad.openRtbVast
        : ad.vast;
        if (vast != nil) {
            [self.cacheReportingProperties setObject:vast forKey:HyBidReportingCommon.CREATIVE];
        }
        self.initialCacheTimestamp = [[NSDate date] timeIntervalSince1970];
        HyBidVideoAdProcessor *videoAdProcessor = [[HyBidVideoAdProcessor alloc] init];
        [videoAdProcessor processVASTString:vast completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError *error) {
            if (!vastModel) {
                [self invokeDidFail:error];
                [self.vastEventProcessor sendVASTUrls: error.errorTagURLs];
            } else {
                [self.cacheReportingProperties setObject:[NSString stringWithFormat:@"%f", [self elapsedTimeSince:self.initialCacheTimestamp]] forKey:HyBidReportingCommon.CACHE_TIME];
                HyBidVideoAdCacheItem *videoAdCacheItem = [[HyBidVideoAdCacheItem alloc] init];
                videoAdCacheItem.vastModel = vastModel;
                [[HyBidVideoAdCache sharedInstance] putVideoAdCacheItemToCache:videoAdCacheItem withZoneID:self.zoneID];
                
                NSArray *endCards = [self fetchEndCardsFromVastAd:vastModel.vastArray];
                if ([ad.endcardEnabled boolValue] || (ad.endcardEnabled == nil && HyBidConstants.showEndCard)) {
                    if ([endCards count] > 0) {
                        [ad setHasEndCard:YES];
                        if ([ad.customEndcardEnabled boolValue] || (ad.customEndcardEnabled == nil && HyBidConstants.showCustomEndCard)) {
                            if ([self customEndcardDisplayBehaviourFromString:ad.customEndcardDisplay] == HyBidCustomEndcardDisplayExtention || (ad.customEndcardDisplay == nil && HyBidConstants.customEndcardDisplay == HyBidCustomEndcardDisplayExtention)) {
                                if (ad.customEndCardData && ad.customEndCardData.length > 0) {
                                    [ad setHasCustomEndCard:YES];
                                }
                            }
                        }
                    } else if ([endCards count] == 0) {
                        if ([ad.customEndcardEnabled boolValue] || (ad.customEndcardEnabled == nil && HyBidConstants.showCustomEndCard)){
                            if (ad.customEndCardData && ad.customEndCardData.length > 0) {
                                [ad setHasCustomEndCard:YES];
                            }
                        }
                    }
                } else if (ad.endcardEnabled != nil || (ad.endcardEnabled == nil && !HyBidConstants.showEndCard)) {
                    if ([ad.customEndcardEnabled boolValue] || (ad.customEndcardEnabled == nil && HyBidConstants.showCustomEndCard)) {
                        if (ad.customEndCardData && ad.customEndCardData.length > 0) {
                            [ad setHasCustomEndCard:YES];
                        }
                    }
                }
                [self invokeDidLoad:ad];
                if(self.cacheReportingProperties) {
                    [self.cacheReportingProperties addEntriesFromDictionary:[[HyBid reportingManager] addCommonPropertiesForAd:ad withRequest:self]];
                    [self reportEvent:HyBidReportingEventType.CACHE withProperties:self.cacheReportingProperties];
                }
                self.adCached = YES;
            }
        }];
    }
}

- (HyBidCustomEndcardDisplayBehaviour)customEndcardDisplayBehaviourFromString:(NSString *)customEndcardDisplayBehaviour {
    if([customEndcardDisplayBehaviour isKindOfClass:[NSString class]]) {
        if ([customEndcardDisplayBehaviour isEqualToString:HyBidCustomEndcardDisplayFallbackValue]) {
            return HyBidCustomEndcardDisplayFallback;
        } else if ([customEndcardDisplayBehaviour isEqualToString:HyBidCustomEndcardDisplayExtentionValue]) {
            return HyBidCustomEndcardDisplayExtention;
        } else {
            return HyBidCustomEndcardDisplayFallback;
        }
    } else {
        return HyBidCustomEndcardDisplayFallback;
    }
}

- (NSArray<HyBidVASTEndCard *> *)fetchEndCardsFromVastAd:(NSArray *)vastModel {
    HyBidVASTCompanionAds *companionAds;
    NSOrderedSet *vastSet = [[NSOrderedSet alloc] initWithArray:vastModel];
    NSArray *vastArray = [[NSMutableArray alloc] initWithArray:[vastSet array]];
    for (NSData *vast in vastArray){
        NSString *xml = [[NSString alloc] initWithData:vast encoding:NSUTF8StringEncoding];
        HyBidXMLEx *parser = [HyBidXMLEx parserWithXML:xml];
        NSArray *result = [[parser rootElement] query:@"Ad"];
        for (int i = 0; i < [result count]; i++) {
            HyBidVASTAd * ad;
            if (result[i]) {
                ad = [[HyBidVASTAd alloc] initWithXMLElement:result[i]];
            }
            if ([ad wrapper] != nil){
                NSArray<HyBidVASTCreative *> *creatives = [[ad wrapper] creatives];
                for (HyBidVASTCreative *creative in creatives) {
                    if ([creative companionAds] != nil) {
                        companionAds = [creative companionAds];
                        for (HyBidVASTCompanion *companion in [companionAds companions]) {
                            [self.endCardManager addCompanion:companion];
                        }
                    }
                }
            }else if ([ad inLine]!=nil){
                NSArray<HyBidVASTCreative *> *creatives = [[ad inLine] creatives];
                for (HyBidVASTCreative *creative in creatives) {
                    if ([creative companionAds] != nil) {
                        companionAds = [creative companionAds];
                        for (HyBidVASTCompanion *companion in [companionAds companions]) {
                            [self.endCardManager addCompanion:companion];
                        }
                    }
                }
            }
        }
    }
    
    NSArray<HyBidVASTEndCard *> *endCards = [[NSArray alloc] initWithArray:[self.endCardManager endCards]];
    return endCards;
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
    if (self.requestURL != nil && self.requestURL.absoluteString.length > 0) {
        [properties setObject:self.requestURL.absoluteString forKey:HyBidReportingCommon.AD_REQUEST];
    }
    if ([HyBidSDKConfig sharedConfig].reporting) {
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc] initWith:eventType
                                                                           adFormat:adFormat
                                                                         properties:[NSDictionary dictionaryWithDictionary: properties]];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
    }
}

- (NSTimeInterval)elapsedTimeSince:(NSTimeInterval)timestamp {
    return [[NSDate date] timeIntervalSince1970] - timestamp;
}

#pragma mark PNLiteHttpRequestDelegate

- (void)request:(PNLiteHttpRequest *)request didFinishWithData:(NSData *)data statusCode:(NSInteger)statusCode {
    [self.adResponseReportingProperties setObject:[NSString stringWithFormat:@"%f", [self elapsedTimeSince:self.initialAdResponseTimestamp]] forKey:HyBidReportingCommon.RESPONSE_TIME];

    if(PNLiteResponseStatusOK == statusCode) {
        __block NSString *responseString;
        __block NSString *responseStringJson;
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (dataString) {
            if (self.isUsingOpenRTB && (self.openRTBAdType == HyBidOpenRTBAdVideo)) {
                [self processVASTTagResponseFrom:dataString];
                [self.adResponseReportingProperties setObject:@"ortb" forKey:HyBidReportingCommon.REQUEST_TYPE];
                if (self.adResponseReportingProperties) {
                    [self.adResponseReportingProperties addEntriesFromDictionary:[[HyBid reportingManager] addCommonPropertiesForAd:nil withRequest:self]];
                    [self reportEvent:HyBidReportingEventType.RESPONSE withProperties:self.adResponseReportingProperties];
                }
                [[PNLiteRequestInspector sharedInstance] setLastRequestInspectorWithURL:self.requestURL.absoluteString
                                                        withResponse:dataString
                                                        withLatency:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSinceDate:self.startTime] * 1000.0]
                                                                        withRequestBody:self.body];
            } else {
                [HyBidMarkupUtils isVastXml:dataString completion:^(BOOL isVAST, HyBidVASTParserError* error) {
                    if (error) {
                        [self invokeDidFail:error];
                        [self.vastEventProcessor sendVASTUrls:error.errorTagURLs];
                        return;
                    }
                    if (!isVAST) {
                        if ([self createDictionaryFromData:data]) {
                            responseString = [NSString stringWithFormat:@"%@",[self createDictionaryFromData:data]];
                            responseStringJson =  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        } else {
                            responseString = [NSString stringWithFormat:@"Error while creating a JSON Object with the response. Here is the raw data: \r\r%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
                            responseStringJson = responseString;
                        }
                        if (self.isUsingOpenRTB){
                            [self.adResponseReportingProperties setObject:@"ortb" forKey:HyBidReportingCommon.REQUEST_TYPE];
                        } else {
                            [self.adResponseReportingProperties setObject:@"apiv3" forKey:HyBidReportingCommon.REQUEST_TYPE];
                        }
                        if(self.adResponseReportingProperties) {
                            [self.adResponseReportingProperties addEntriesFromDictionary:[[HyBid reportingManager] addCommonPropertiesForAd:nil withRequest:self]];
                            [self reportEvent:HyBidReportingEventType.RESPONSE withProperties:self.adResponseReportingProperties];
                        }
                        [[PNLiteRequestInspector sharedInstance] setLastRequestInspectorWithURL:self.requestURL.absoluteString
                                                                                   withResponse:responseStringJson
                                                                                    withLatency:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSinceDate:self.startTime] * 1000.0]
                                                                                withRequestBody:self.isUsingOpenRTB ? self.body : nil];
                        
                        [self processResponseWithData:data];
                    } else {
                        [self processVASTTagResponseFrom:dataString];
                    }
                }];
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
    if (self.adResponseReportingProperties){
        [self.adResponseReportingProperties addEntriesFromDictionary:[[HyBid reportingManager] addCommonPropertiesForAd:nil withRequest:self]];
        [self reportEvent:HyBidReportingEventType.RESPONSE withProperties:self.adResponseReportingProperties];
    }
    [[PNLiteRequestInspector sharedInstance] setLastRequestInspectorWithURL:self.requestURL.absoluteString
                                                               withResponse:error.localizedDescription
                                                                withLatency:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSinceDate:self.startTime] * 1000.0]
                                                            withRequestBody:nil];
    [self invokeDidFail:error];
}

@end
