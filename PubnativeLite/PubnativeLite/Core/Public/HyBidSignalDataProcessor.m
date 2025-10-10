// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidSignalDataProcessor.h"
#import "PNLiteResponseModel.h"
#import "HyBidAd.h"
#import "HyBidAdCache.h"
#import "HyBidVideoAdProcessor.h"
#import "HyBidVideoAdCacheItem.h"
#import "HyBidVideoAdCache.h"
#import "HyBidSignalDataModel.h"
#import "PNLiteHttpRequest.h"
#import "HyBidError.h"
#import "HyBidEndCardManager.h"
#import "HyBidVASTEventProcessor.h"
#import "HyBidVASTParserError.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
#import <UIKit/UIKit.h>
#import <HyBid/HyBid-Swift.h>
#else
#import <UIKit/UIKit.h>
#import "HyBid-Swift.h"
#endif

NSString *const HyBidSignalDataResponseOK = @"ok";
NSString *const HyBidSignalDataResponseSuccess = @"success";
NSString *const HyBidSignalDataResponseError = @"error";
NSInteger const HyBidSignalDataResponseStatusOK = 200;
NSInteger const HyBidSignalDataResponseStatusRequestMalformed = 422;

@interface HyBidSignalDataProcessor() <PNLiteHttpRequestDelegate>

@property (nonatomic, strong) HyBidAd *ad;
@property (nonatomic, strong) HyBidSignalDataModel *signalDataModel;
@property (nonatomic, strong) HyBidEndCardManager *endCardManager;

@end

@implementation HyBidSignalDataProcessor

- (void)dealloc {
    self.ad = nil;
    self.signalDataModel = nil;
    self.delegate = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.endCardManager = [[HyBidEndCardManager alloc] init];
    }
    return self;
}

- (NSDictionary *)createDictionaryFromData:(NSData *)data {
    NSError *parseError;
    if (data) {
        NSDictionary *jsonDictonary = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:NSJSONReadingMutableContainers
                                                                        error:&parseError];
        if (parseError) {
            [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:parseError.localizedDescription];
            return nil;
        } else {
            return jsonDictonary;
        }
    } else {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Received data is either nil or not valid."];
        return nil;
    }
}

- (void)processSignalData:(NSString *)signalDataString {
    NSData *signalData = [signalDataString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDictonary = [self createDictionaryFromData:signalData];
    if (jsonDictonary) {
        self.signalDataModel = [[HyBidSignalDataModel alloc] initWithDictionary:jsonDictonary];
        if(!self.signalDataModel) {
            [self invokeDidFail:[NSError hyBidParseError]];
        } else if ([HyBidSignalDataResponseOK isEqualToString: self.signalDataModel.status] || [HyBidSignalDataResponseSuccess isEqualToString: self.signalDataModel.status]) {
            if (self.signalDataModel.admurl && self.signalDataModel.admurl.length != 0) {
                
                // TODO:
                // 1. Implement URL validation to ensure `self.signalDataModel.admurl` is a well-formed URL before proceeding.
                // 2. Address the issue with URL encoding where "\\u0026" should be replaced with "&".
                NSURL *url = [NSURL URLWithString:self.signalDataModel.admurl];
                if (url) {
                    [[PNLiteHttpRequest alloc] startWithUrlString:self.signalDataModel.admurl withMethod:@"GET" delegate:self];
                } else {
                    [self invokeDidFail:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil]];
                }
            } else if (self.signalDataModel.adm) {
                [self processResponse:self.signalDataModel.adm];
            } else {
                [self invokeDidFail:[NSError hyBidInvalidSignalData]];
            }
        } else {
            NSError *responseError = [NSError hyBidInvalidSignalData];
            [self invokeDidFail:responseError];
        }
    } else {
        [self invokeDidFail:[NSError hyBidInvalidSignalData]];
    }
}

- (void)invokeDidFail:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd)withMessage:error.localizedDescription];
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

- (void)processResponse:(PNLiteResponseModel *)response {
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
                    NSString *vast = ad.isUsingOpenRTB
                    ? ad.openRtbVast
                    : ad.vast;
                    HyBidVideoAdProcessor *videoAdProcessor = [[HyBidVideoAdProcessor alloc] init];
                    [videoAdProcessor processVASTString:vast completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError *error) {
                        if (!vastModel) {
                            [self invokeDidFail: error];
                            HyBidVASTEventProcessor *vastEventProcessor = [[HyBidVASTEventProcessor alloc] init];
                            [vastEventProcessor sendVASTUrls: error.errorTagURLs withType:HyBidVASTParserErrorURL];
                        } else {
                            [self fetchEndCardsFromVastAd:vastModel.ads.firstObject completion:^(NSArray<HyBidEndCard *> *endCards) {
                                if ([ad.endcardEnabled boolValue] || (ad.endcardEnabled == nil && HyBidConstants.showEndCard)) {
                                    if (endCards && [endCards count] > 0) {
                                        [ad setHasEndCard:YES];
                                        if ([ad.customEndcardEnabled boolValue] || (ad.customEndcardEnabled == nil && HyBidConstants.showCustomEndCard)) {
                                            if ([self customEndcardDisplayBehaviourFromString:ad.customEndcardDisplay] == HyBidCustomEndcardDisplayExtention || (ad.customEndcardDisplay == nil && HyBidConstants.customEndcardDisplay == HyBidCustomEndcardDisplayExtention)) {
                                                if (ad.customEndCardData && ad.customEndCardData.length > 0) {
                                                    [ad setHasCustomEndCard:YES];
                                                }
                                            }
                                        }
                                    } else if (!endCards || [endCards count] == 0) {
                                        if ([ad.customEndcardEnabled boolValue] || (ad.customEndcardEnabled == nil && HyBidConstants.showCustomEndCard)) {
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
                                HyBidVideoAdCacheItem *videoAdCacheItem = [[HyBidVideoAdCacheItem alloc] init];
                                videoAdCacheItem.vastModel = vastModel;
                                [[HyBidVideoAdCache sharedInstance] putVideoAdCacheItemToCache:videoAdCacheItem withZoneID: self.signalDataModel.tagid];
                                [self invokeDidLoad:ad];
                                
                            }];
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

- (HyBidCustomEndcardDisplayBehaviour)customEndcardDisplayBehaviourFromString:(NSString *)customEndcardDisplayBehaviour {
    if([customEndcardDisplayBehaviour isMemberOfClass:[NSString class]]) {
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

- (void)fetchEndCardsFromVastAd:(HyBidVASTAd *)ad completion:(void(^)(NSArray<HyBidEndCard *> * _Nullable endCards))completion {
    if (ad == nil) {
        if (completion) completion(nil);
        return;
    }
    
    NSArray<HyBidVASTCreative *> *creatives = [[ad inLine] creatives];
    [self.endCardManager fetchEndCardsFromCreatives:creatives completion:completion];
}

#pragma mark PNLiteHttpRequestDelegate

- (void)request:(PNLiteHttpRequest *)request didFinishWithData:(NSData *)data statusCode:(NSInteger)statusCode {
    if(HyBidSignalDataResponseStatusOK == statusCode || HyBidSignalDataResponseStatusRequestMalformed == statusCode) {
        NSString *responseString;
        if (data && [self createDictionaryFromData:data]) {
            responseString = [NSString stringWithFormat:@"%@", [self createDictionaryFromData:data]];
            NSDictionary *jsonDictonary = [self createDictionaryFromData:data];
            if (jsonDictonary) {
                PNLiteResponseModel *response = [[PNLiteResponseModel alloc] initWithDictionary:jsonDictonary];
                [self processResponse:response];
            } else {
                [self invokeDidFail: [NSError hyBidInvalidSignalData]];
            }
        } else {
            responseString = [NSString stringWithFormat:@"Error while creating a JSON Object with the response. Here is the raw data: \r\r%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
            [self invokeDidFail: [NSError hyBidInvalidSignalData]];
        }
    } else {
        [self invokeDidFail:[NSError hyBidServerError]];
    }
}

- (void)request:(PNLiteHttpRequest *)request didFailWithError:(NSError *)error {
    [self invokeDidFail:error];
}

@end
