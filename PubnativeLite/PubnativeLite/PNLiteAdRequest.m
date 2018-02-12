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

#import "PNLiteAdRequest.h"
#import "PNLiteHttpRequest.h"
#import "PNLiteAdFactory.h"
#import "PNLiteAdRequestModel.h"
#import "PNLiteResponseModel.h"
#import "PNLiteAdModel.h"
#import "PNLiteAdCache.h"

NSString * const kPNLiteRequestBaseUrl = @"https://api.pubnative.net/api/v3/native";
NSString * const kPNLiteResponseOK = @"ok";
NSString * const kPNLiteResponseError = @"error";
NSInteger const kPNLiteResponseStatusOK = 200;
NSInteger const kPNLiteResponseStatusRequestMalformed = 422;

@interface PNLiteAdRequest () <PNLiteHttpRequestDelegate>

@property (nonatomic, weak) NSObject <PNLiteAdRequestDelegate> *delegate;
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, strong) NSString *zoneID;
@end

@implementation PNLiteAdRequest

- (void)dealloc
{
    self.zoneID = nil;
}

- (NSString *)adSize
{
    return nil;
}

- (void)requestAdWithDelegate:(NSObject<PNLiteAdRequestDelegate> *)delegate withZoneID:(NSString *)zoneID
{
    if (self.isRunning) {
        NSError *runningError = [NSError errorWithDomain:@"PNLiteAdRequest - Request is currently running, droping this call" code:0 userInfo:nil];
        [self invokeDidFail:runningError];
    } else if(delegate == nil){
        NSLog(@"PNLiteAdRequest - Given delegate is nil and required, droping this call");
    } else if(zoneID == nil || zoneID.length == 0){
        NSLog(@"PNLiteAdRequest - Zone ID nil or empty");
    }
    else {
        self.delegate = delegate;
        self.zoneID = zoneID;
        self.isRunning = YES;
        [self invokeDidStart];
        PNLiteAdFactory *adFactory = [[PNLiteAdFactory alloc] init];
        NSLog(@"%@",[self requestURLFromAdRequestModel: [adFactory createAdRequestWithZoneID:self.zoneID andWithAdSize:@"s"]].absoluteString);
        [[PNLiteHttpRequest alloc] startWithUrlString:[self requestURLFromAdRequestModel: [adFactory createAdRequestWithZoneID:self.zoneID andWithAdSize:@"s"]].absoluteString
                                             delegate:self];
    }
}

- (NSURL*)requestURLFromAdRequestModel:(PNLiteAdRequestModel *)adRequestModel
{
    NSURLComponents *components = [NSURLComponents componentsWithString:kPNLiteRequestBaseUrl];
    if (adRequestModel.requestParameters) {
        NSMutableArray *query = [NSMutableArray array];
        NSDictionary *dict = adRequestModel.requestParameters;
        for (id key in dict) {
            [query addObject:[NSURLQueryItem queryItemWithName:key value:dict[key]]];
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

- (void)invokeDidLoad:(PNLiteAdModel *)ad
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

- (void)processResponseWithData:(NSData *)data
{
    NSError *parseError;
    NSDictionary *jsonDictonary = [NSJSONSerialization JSONObjectWithData:data
                                                                  options:NSJSONReadingMutableContainers
                                                                    error:&parseError];
    if (parseError) {
        [self invokeDidFail:parseError];
    } else {
        
        PNLiteResponseModel *response = [[PNLiteResponseModel alloc] initWithDictionary:jsonDictonary];
        if(response == nil) {
            NSError *error = [NSError errorWithDomain:@"Error: Can't parse JSON from server"
                                                 code:0
                                             userInfo:nil];
            [self invokeDidFail:error];
        } else if ([kPNLiteResponseOK isEqualToString:response.status]) {
            NSMutableArray *responseAdArray = [[NSArray array] mutableCopy];
            for (PNLiteAdModel *ad in response.ads) {
                [[PNLiteAdCache sharedInstance] putAdToCache:ad withZoneID:self.zoneID];
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
            NSString *errorMessage = [NSString stringWithFormat:@"request - %@", response.errorMessage];
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
        [self processResponseWithData:data];
    } else {
        NSError *statusError = [NSError errorWithDomain:@"PNLiteHttpRequestDelegate - Server error: status code" code:statusCode userInfo:nil];
        [self invokeDidFail:statusError];
    }
}

- (void)request:(PNLiteHttpRequest *)request didFailWithError:(NSError *)error
{
    [self invokeDidFail:error];
}

@end
