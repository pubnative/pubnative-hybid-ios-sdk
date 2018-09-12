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
#import "PNLiteAdModel.h"
#import "HyBidAdCache.h"
#import "PNLiteRequestInspector.h"

NSString *const kPNLiteRequestBaseUrl = @"https://api.pubnative.net/api/v3/native";
NSString *const kPNLiteResponseOK = @"ok";
NSString *const kPNLiteResponseError = @"error";
NSInteger const kPNLiteResponseStatusOK = 200;
NSInteger const kPNLiteResponseStatusRequestMalformed = 422;

@interface HyBidAdRequest () <PNLiteHttpRequestDelegate>

@property (nonatomic, weak) NSObject <HyBidAdRequestDelegate> *delegate;
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, strong) NSString *zoneID;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSURL *requestURL;

@end

@implementation HyBidAdRequest

- (void)dealloc
{
    self.zoneID = nil;
    self.startTime = nil;
    self.requestURL = nil;
}

- (NSString *)adSize
{
    return nil;
}

- (void)requestAdWithDelegate:(NSObject<HyBidAdRequestDelegate> *)delegate withZoneID:(NSString *)zoneID
{
    if (self.isRunning) {
        NSError *runningError = [NSError errorWithDomain:@"HyBidAdRequest - Request is currently running, droping this call" code:0 userInfo:nil];
        [self invokeDidFail:runningError];
    } else if(delegate == nil){
        NSLog(@"HyBidAdRequest - Given delegate is nil and required, droping this call");
    } else if(zoneID == nil || zoneID.length == 0){
        NSLog(@"HyBidAdRequest - Zone ID nil or empty, droping this call");
    }
    else {
        self.startTime = [NSDate date];
        self.delegate = delegate;
        self.zoneID = zoneID;
        self.isRunning = YES;
        [self invokeDidStart];
        PNLiteAdFactory *adFactory = [[PNLiteAdFactory alloc] init];
        NSLog(@"%@",[self requestURLFromAdRequestModel: [adFactory createAdRequestWithZoneID:self.zoneID
                                                                               andWithAdSize:[self adSize]]].absoluteString);
        self.requestURL = [self requestURLFromAdRequestModel: [adFactory createAdRequestWithZoneID:self.zoneID
                                                                                     andWithAdSize:[self adSize]]];
        [[PNLiteHttpRequest alloc] startWithUrlString:self.requestURL.absoluteString withMethod:@"GET" delegate:self];
    }
}

- (NSURL*)requestURLFromAdRequestModel:(PNLiteAdRequestModel *)adRequestModel
{
    NSURLComponents *components = [NSURLComponents componentsWithString:kPNLiteRequestBaseUrl];
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

- (void)invokeDidStart
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestDidStart:)]) {
            [self.delegate requestDidStart:self];
        }
    });
}

- (void)invokeDidLoad:(PNLiteAd *)ad
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isRunning = NO;
        if (self.delegate && [self.delegate respondsToSelector:@selector(request:didLoadWithAd:)]) {
            [self.delegate request:self didLoadWithAd:ad];
        }
        self.delegate = nil;
    });
}

- (void)invokeDidFail:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isRunning = NO;
        if(self.delegate && [self.delegate respondsToSelector:@selector(request:didFailWithError:)]){
            [self.delegate request:self didFailWithError:error];
        }
        self.delegate = nil;
    });
}

- (NSDictionary *)createDictionaryFromData:(NSData *)data
{
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

- (void)processResponseWithData:(NSData *)data
{
    NSDictionary *jsonDictonary = [self createDictionaryFromData:data];
    if (jsonDictonary) {
        PNLiteResponseModel *response = [[PNLiteResponseModel alloc] initWithDictionary:jsonDictonary];
        if(response == nil) {
            NSError *error = [NSError errorWithDomain:@"Error: Can't parse JSON from server"
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
        } else if ([kPNLiteResponseOK isEqualToString:response.status]) {
            NSMutableArray *responseAdArray = [[NSArray array] mutableCopy];
            for (PNLiteAdModel *adModel in response.ads) {
                PNLiteAd *ad = [[PNLiteAd alloc] initWithData:adModel];
                [[HyBidAdCache sharedInstance] putAdToCache:ad withZoneID:self.zoneID];
                [responseAdArray addObject:ad];
            }
            if (responseAdArray.count > 0) {
                [self invokeDidLoad:responseAdArray.firstObject];
            } else {
                NSError *error = [NSError errorWithDomain:@"Error: No fill"
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

- (void)request:(PNLiteHttpRequest *)request didFinishWithData:(NSData *)data statusCode:(NSInteger)statusCode
{
    if(kPNLiteResponseStatusOK == statusCode ||
       kPNLiteResponseStatusRequestMalformed == statusCode) {
        
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
        [self invokeDidFail:statusError];
    }
}

- (void)request:(PNLiteHttpRequest *)request didFailWithError:(NSError *)error
{
    [[PNLiteRequestInspector sharedInstance] setLastRequestInspectorWithURL:self.requestURL.absoluteString
                                                               withResponse:error.localizedDescription
                                                                withLatency:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSinceDate:self.startTime] * 1000.0]];
    [self invokeDidFail:error];
}

@end
