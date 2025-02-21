//
//  Copyright © 2021 PubNative. All rights reserved.
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

#import "HyBidConfigManager.h"
#import "PNLiteHttpRequest.h"
#import "HyBidConfigResponseModel.h"
#import "HyBidError.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

NSString *const HyBidConfigResponseOK = @"ok";
NSString *const HyBidConfigResponseError = @"error";
NSInteger const HyBidConfigResponseStatusOK = 200;
NSInteger const HyBidConfigResponseStatusRequestMalformed = 422;
NSString *const HyBidConfigProductionURL = @"https://sdkc.vervegroupinc.net/config?app_token=";

@interface HyBidConfigManager () <PNLiteHttpRequestDelegate>

@property (nonatomic, copy) ConfigManagerCompletionBlock completionBlock;
@property (nonatomic, strong) NSString *HyBidConfigURL;

@end

@implementation HyBidConfigManager

- (void)dealloc {
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

+ (instancetype)sharedManager {
    static HyBidConfigManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HyBidConfigManager alloc] init];
    });
    return instance;
}

- (void)setHyBidConfigURLToProduction {
    self.HyBidConfigURL = [NSString stringWithFormat:@"%@%@",HyBidConfigProductionURL, [HyBidSDKConfig sharedConfig].appToken];
}

- (void)setHyBidConfigURLToTestingWithURL:(NSString *)url {
    self.HyBidConfigURL = url;
}

- (void)requestConfigWithCompletion:(ConfigManagerCompletionBlock)completion {
    self.completionBlock = completion;
    if (self.HyBidConfigURL == nil || self.HyBidConfigURL.length == 0) {
        [self setHyBidConfigURLToProduction];
    }
    [[PNLiteHttpRequest alloc] startWithUrlString:self.HyBidConfigURL withMethod:@"GET" delegate:self];
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

- (void)processResponse:(HyBidConfigResponseModel *)response {
    HyBidConfigModel *configModel = [[HyBidConfigModel alloc] initWithDictionary:response.configs];
    HyBidConfig *config = [[HyBidConfig alloc] initWithData:configModel];
    self.completionBlock(config, nil);
}

#pragma mark PNLiteHttpRequestDelegate

- (void)request:(PNLiteHttpRequest *)request didFailWithError:(NSError *)error {
    self.completionBlock(nil, error);
}

- (void)request:(PNLiteHttpRequest *)request didFinishWithData:(NSData *)data statusCode:(NSInteger)statusCode {
    if(HyBidConfigResponseStatusOK == statusCode || HyBidConfigResponseStatusRequestMalformed == statusCode) {
        NSDictionary *jsonDictonary = [self createDictionaryFromData:data];
        if (jsonDictonary) {
            HyBidConfigResponseModel *response = [[HyBidConfigResponseModel alloc] initWithDictionary:jsonDictonary];
            if ([response.status isEqualToString:HyBidConfigResponseError]) {
                NSError *responseError = [NSError errorWithDomain:response.errorMessage code:HyBidErrorCodeInternal userInfo:nil];
                self.completionBlock(nil, responseError);
            } else {
                [self processResponse:response];
            }
        } else {
            self.completionBlock(nil, [NSError hyBidInvalidRemoteConfigData]);
        }
    } else {
        self.completionBlock(nil, [NSError hyBidServerError]);
    }
}

@end
