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

#import "HyBidRemoteConfigManager.h"
#import "HyBidRemoteConfigRequest.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

#define kRemoteConfigTimestampKey @"remoteConfigTimestamp"

@interface HyBidRemoteConfigManager() <HyBidRemoteConfigRequestDelegate>

@property (nonatomic, copy) RemoteConfigManagerCompletionBlock completionBlock;

@end

@implementation HyBidRemoteConfigManager

- (void)dealloc {
    self.remoteConfigModel = nil;
}

+ (instancetype)sharedInstance {
    static HyBidRemoteConfigManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HyBidRemoteConfigManager alloc] init];
    });
    return sharedInstance;
}

- (void)initializeRemoteConfigWithCompletion:(RemoteConfigManagerCompletionBlock)completion {
    [self fetchRemoteConfigWithCompletion:completion];
}

-(void)refreshRemoteConfig {
    if ([self isConfigOutdated]) {
        [self fetchRemoteConfigWithCompletion:^(BOOL success, HyBidRemoteConfigModel *remoteConfigModel) {
            if (success) {
                [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Config refreshed."];
            } else {
                [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Config refresh failed."];
            }
        }];
    }
}

- (void)fetchRemoteConfigWithCompletion:(RemoteConfigManagerCompletionBlock)completion {
    self.completionBlock = completion;
    HyBidRemoteConfigRequest *remoteConfigRequest = [[HyBidRemoteConfigRequest alloc] init];
    [remoteConfigRequest doConfigRequestWithDelegate:self withAppToken:[HyBidSDKConfig sharedConfig].appToken];
}

- (void)storeConfigTimestamp {
    NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
    [[NSUserDefaults standardUserDefaults] setFloat:currentTimeInterval forKey:kRemoteConfigTimestampKey];
}

- (void)storeAPIVersionFrom:(HyBidRemoteConfigModel *)model
 {
     BOOL isUsingOpenRTB = NO;
     if (model.appConfig != nil) {
         isUsingOpenRTB = model.appConfig.apiType == HyBidApiOpenRTB;
     }
     [[NSUserDefaults standardUserDefaults] setBool:isUsingOpenRTB forKey:kIsUsingOpenRTB];
     [[NSUserDefaults standardUserDefaults] synchronize];
 }

- (BOOL)isConfigOutdated {
    long long tttInMillis = [[NSNumber numberWithInteger:self.remoteConfigModel.ttl * 1000.0] longLongValue];
    long long configTimeStamp = (long long)([[NSUserDefaults standardUserDefaults] floatForKey:kRemoteConfigTimestampKey] * 1000.0);
    long long timeToUpdate = tttInMillis + configTimeStamp;
    long long currentTimestamp = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    return currentTimestamp >= timeToUpdate;
}

- (HyBidRemoteFeatureResolver *)featureResolver
{
    HyBidRemoteFeatureResolver *resolver = [[HyBidRemoteFeatureResolver alloc] initWithRemoteConfigModel:self.remoteConfigModel];
    return resolver;
}

#pragma mark HyBidRemoteConfigRequestDelegate

- (void)remoteConfigRequestSuccess:(HyBidRemoteConfigModel *)model {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Remote Config Request finished."];
    if (model) {
        [self storeConfigTimestamp];
        [self storeAPIVersionFrom:model];
        self.remoteConfigModel = model;
        self.completionBlock(YES, model);
    } else {
        [self remoteConfigRequestFail:[NSError errorWithDomain:@"The server returned an empty config file."
                                                          code:0
                                                      userInfo:nil]];
    }
}

- (void)remoteConfigRequestFail:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Remote Config Request failed with error: %@",error.localizedDescription]];
    self.completionBlock(NO, nil);
}

@end
