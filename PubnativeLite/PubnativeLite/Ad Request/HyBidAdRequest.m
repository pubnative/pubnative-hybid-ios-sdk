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
#import "VrvAdFactory.h"
#import "PNLiteAdRequestModel.h"
#import "VrvAdRequestModel.h"
#import "PNLiteResponseModel.h"
#import "VrvResponseModel.h"
#import "HyBidAdModel.h"
#import "HyBidAdCache.h"
#import "PNLiteRequestInspector.h"
#import "HyBidLogger.h"
#import "HyBidSettings.h"
#import "XMLDictionary.h"

NSString *const PNLiteResponseOK = @"ok";
NSString *const PNLiteResponseError = @"error";
NSInteger const PNLiteResponseStatusOK = 200;
NSInteger const PNLiteResponseStatusRequestMalformed = 422;

NSInteger const kRequestBothPending = 3000;
NSInteger const kRequestVerveResponded = 3001;
NSInteger const kRequestPubNativeResponded = 3002;
NSInteger const kRequestWinnerPicked = 3003;

NSInteger const kDefaultMRectZoneId = 5;
NSInteger const kDefaultBannerZoneId = 2;

@interface HyBidAdRequest () <PNLiteHttpRequestDelegate>

@property (nonatomic, weak) NSObject <HyBidAdRequestDelegate> *delegate;
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, strong) NSString *zoneID;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSURL *requestURL;
@property (nonatomic, strong) NSURL *vrvRequestURL;
@property (nonatomic, assign) BOOL isSetIntegrationTypeCalled;
@property (nonatomic, strong) PNLiteAdFactory *adFactory;
@property (nonatomic, strong) VrvAdFactory *vrvAdFactory;
@property (nonatomic, assign) NSInteger requestStatus;

@end

@implementation HyBidAdRequest

- (void)dealloc {
    self.zoneID = nil;
    self.startTime = nil;
    self.requestURL = nil;
    self.vrvRequestURL = nil;
    self.delegate = nil;
    self.adFactory = nil;
    self.vrvAdFactory = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.adFactory = [[PNLiteAdFactory alloc] init];
        self.vrvAdFactory = [[VrvAdFactory alloc] init];
        self.adSize = SIZE_320x50;
    }
    return self;
}

- (void)setIntegrationType:(IntegrationType)integrationType withZoneID:(NSString *)zoneID {
    self.zoneID = zoneID;
    self.requestURL = [self requestURLFromAdRequestModel:[self createAdRequestModelWithIntegrationType:integrationType]];
    self.vrvRequestURL = [self vrvRequestURLFromAdRequestModel:[self createVrvAdRequestModelWithIntegrationType:integrationType]];
    self.isSetIntegrationTypeCalled = YES;
}

- (void)setIntegrationType: (IntegrationType)integrationType {
    
    // This should be improved
    if ((self.adSize.width == 320 && self.adSize.height == 50) || (self.adSize.width == 320 && self.adSize.height == 100)) {
        self.zoneID = [@(kDefaultBannerZoneId) stringValue];
    } else if ((self.adSize.width == 300 && self.adSize.height == 250) || (self.adSize.width == 728 && self.adSize.height == 90)) {
        self.zoneID = [@(kDefaultMRectZoneId) stringValue];
    } else {
        self.zoneID = [@(kDefaultBannerZoneId) stringValue];
    }
    
    self.requestURL = [self requestURLFromAdRequestModel:[self createAdRequestModelWithIntegrationType:integrationType]];
    self.vrvRequestURL = [self vrvRequestURLFromAdRequestModel:[self createVrvAdRequestModelWithIntegrationType:integrationType]];
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
        self.startTime = [NSDate date];
        self.delegate = delegate;
        self.zoneID = zoneID;
        self.isRunning = YES;
        [self invokeDidStart];
        
        if (!self.isSetIntegrationTypeCalled) {
            [self setIntegrationType:HEADER_BIDDING withZoneID:zoneID];
        }

        self.requestStatus = kRequestBothPending;
        [[PNLiteHttpRequest alloc] startWithUrlString:self.requestURL.absoluteString withMethod:@"GET" delegate:self];
        
        [[PNLiteHttpRequest alloc] startWithUrlString:self.vrvRequestURL.absoluteString withMethod:@"GET" delegate:self];
    }
}

- (void)requestAdWithDelegate:(NSObject<HyBidAdRequestDelegate> *)delegate {
    if (self.isRunning) {
        NSError *runningError = [NSError errorWithDomain:@"Request is currently running, droping this call." code:0 userInfo:nil];
        [self invokeDidFail:runningError];
    } else if(!delegate) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Given delegate is nil and required, droping this call."];
    }
    
    else {
        self.startTime = [NSDate date];
        self.delegate = delegate;
        // This should be improved
        if ((self.adSize.width == 320 && self.adSize.height == 50) || (self.adSize.width == 320 && self.adSize.height == 100)) {
            self.zoneID = [@(kDefaultBannerZoneId) stringValue];
        } else if ((self.adSize.width == 300 && self.adSize.height == 250) || (self.adSize.width == 728 && self.adSize.height == 90)) {
            self.zoneID = [@(kDefaultMRectZoneId) stringValue];
        } else {
            self.zoneID = [@(kDefaultBannerZoneId) stringValue];
        }
        
        self.isRunning = YES;
        [self invokeDidStart];
        
        if (!self.isSetIntegrationTypeCalled) {
            [self setIntegrationType:HEADER_BIDDING withZoneID:self.zoneID];
        }

        self.requestStatus = kRequestBothPending;
        [[PNLiteHttpRequest alloc] startWithUrlString:self.requestURL.absoluteString withMethod:@"GET" delegate:self];
        
        [[PNLiteHttpRequest alloc] startWithUrlString:self.vrvRequestURL.absoluteString withMethod:@"GET" delegate:self];
    }
}

- (PNLiteAdRequestModel *)createAdRequestModelWithIntegrationType:(IntegrationType)integrationType {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"%@",[self requestURLFromAdRequestModel: [self.adFactory createAdRequestWithZoneID:self.zoneID
                                                                                                                                                                                                                      andWithAdSize:[self adSize]
                                                                                                                                                                                                             andWithIntegrationType:integrationType]].absoluteString]];
    return [self.adFactory createAdRequestWithZoneID:self.zoneID
                                       andWithAdSize:[self adSize]
                              andWithIntegrationType:integrationType];
}

- (VrvAdRequestModel *)createVrvAdRequestModelWithIntegrationType:(IntegrationType)integrationType {
    VrvAdRequestModel *vrvRequestModel = [self.vrvAdFactory createVrvAdRequestWithZoneID:self.zoneID
    withAdSize:[self adSize]];
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"%@",[self vrvRequestURLFromAdRequestModel: vrvRequestModel].absoluteString]];
    return vrvRequestModel;
}

- (NSURL*)requestURLFromAdRequestModel:(PNLiteAdRequestModel *)adRequestModel {
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
}

- (NSURL*)vrvRequestURLFromAdRequestModel:(VrvAdRequestModel *)adRequestModel {
    NSURLComponents *components = [NSURLComponents componentsWithString:@"https://adcel.vrvm.com"];
    components.path = @"/banner";
    if (adRequestModel.requestParameters) {
        NSMutableArray *query = [NSMutableArray array];
        NSDictionary *parametersDictionary = adRequestModel.requestParameters;
        for (id key in parametersDictionary) {
            [query addObject:[NSURLQueryItem queryItemWithName:key value:parametersDictionary[key]]];
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

- (NSDictionary *)createXmlFromData:(NSData *)data {
    NSDictionary *jsonDictonary = [NSDictionary dictionaryWithXMLData:data];
    return jsonDictonary;
}

- (void)processResponseWithData:(NSData *)data {
    NSDictionary *jsonDictonary = [self createDictionaryFromData:data];
    if (jsonDictonary) {
        PNLiteResponseModel *response = [[PNLiteResponseModel alloc] initWithDictionary:jsonDictonary];
        if(!response) {
            NSError *error = [NSError errorWithDomain:@"Can't parse JSON from server"
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
        } else if ([PNLiteResponseOK isEqualToString:response.status]) {
            NSMutableArray *responseAdArray = [[NSArray array] mutableCopy];
            for (HyBidAdModel *adModel in response.ads) {
                HyBidAd *ad = [[HyBidAd alloc] initWithData:adModel];
                [[HyBidAdCache sharedInstance] putAdToCache:ad withZoneID:self.zoneID];
                [responseAdArray addObject:ad];
            }
            if (responseAdArray.count > 0) {
                [self invokeDidLoad:responseAdArray.firstObject];
            } else {
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

- (void)processXmlResponseWithData:(NSData *)data {
    NSDictionary *xmlDictonary = [self createXmlFromData:data];
    if (xmlDictonary) {
        VrvResponseModel *response = [[VrvResponseModel alloc] initWithXml:xmlDictonary];
        if(!response) {
            NSError *error = [NSError errorWithDomain:@"Can't parse XML from server"
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
        } else if ([PNLiteResponseOK isEqualToString:response.status]) {
            NSMutableArray *responseAdArray = [[NSArray array] mutableCopy];
            
            HyBidAd *ad = [[HyBidAd alloc] initWithVrvXml:xmlDictonary];
            [[HyBidAdCache sharedInstance] putAdToCache:ad withZoneID:self.zoneID];
            [responseAdArray addObject:ad];
            
            if (responseAdArray.count > 0) {
                [self invokeDidLoad:responseAdArray.firstObject];
            } else {
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
    if (request.urlString == self.requestURL.absoluteString) {
        if(PNLiteResponseStatusOK == statusCode || PNLiteResponseStatusRequestMalformed == statusCode) {
        
            if (self.requestStatus == kRequestWinnerPicked) {
                NSLog(@"PAPI responded but VAPI was faster.");
                return;
            }
            
            self.requestStatus = kRequestWinnerPicked;
            NSString *responseString;
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
            NSError *statusError = [NSError errorWithDomain:@"PNLiteHttpRequestDelegate - Server error: status code" code:statusCode userInfo:nil];
            if (self.requestStatus == kRequestWinnerPicked) {
                NSLog(@"PApi has failure but VAPI was faster.");
                return;
            }

            if (self.requestStatus == kRequestBothPending) {
                self.requestStatus = kRequestPubNativeResponded;
            } else {
                [self invokeDidFail:statusError];
            }
        }
    } else if (request.urlString == self.vrvRequestURL.absoluteString) {
        // Repeat this condition because Adcel API has different response codes
        if(PNLiteResponseStatusOK == statusCode || PNLiteResponseStatusRequestMalformed == statusCode) {
            if (self.requestStatus == kRequestWinnerPicked) {
                NSLog(@"VAPI has response but PAPI was faster.");
                return;
            }
            
            self.requestStatus = kRequestWinnerPicked;
            
            NSString *responseString;
            if ([self createDictionaryFromData:data]) {
                responseString = [NSString stringWithFormat:@"%@",[self createXmlFromData:data]];
            } else {
                responseString = [NSString stringWithFormat:@"Error while creating a XML Object with the response. Here is the raw data: \r\r%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
            }
            
            [self processXmlResponseWithData:data];
        } else {
            NSError *statusError = [NSError errorWithDomain:@"PNLiteHttpRequestDelegate - Server error: status code" code:statusCode userInfo:nil];
            if (self.requestStatus == kRequestWinnerPicked) {
                NSLog(@"VAPI has failure but PAPI was faster.");
                return;
            }

            if (self.requestStatus == kRequestBothPending) {
                self.requestStatus = kRequestVerveResponded;
            } else {
                [self invokeDidFail:statusError];
            }
        }
    }
}

- (void)request:(PNLiteHttpRequest *)request didFailWithError:(NSError *)error {
    if (request.urlString == self.requestURL.absoluteString) {
        [[PNLiteRequestInspector sharedInstance] setLastRequestInspectorWithURL:self.requestURL.absoluteString
                                                               withResponse:error.localizedDescription
                                                                withLatency:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSinceDate:self.startTime] * 1000.0]];
        if (self.requestStatus == kRequestWinnerPicked) {
            NSLog(@"PApi has failure but VAPI was faster.");
            return;
        }

        if (self.requestStatus == kRequestBothPending) {
            self.requestStatus = kRequestPubNativeResponded;
        } else {
            [self invokeDidFail:error];
        }
    } else if (request.urlString == self.vrvRequestURL.absoluteString) {
        if (self.requestStatus == kRequestWinnerPicked) {
            NSLog(@"VAPI has failure but PAPI was faster.");
            return;
        }

        if (self.requestStatus == kRequestBothPending) {
            self.requestStatus = kRequestVerveResponded;
        } else {
            [self invokeDidFail:error];
        }
    }
}

@end
