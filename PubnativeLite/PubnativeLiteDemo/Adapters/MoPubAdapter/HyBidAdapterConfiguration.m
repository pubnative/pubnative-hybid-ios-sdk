//
//  Copyright © 2019 PubNative. All rights reserved.
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

#import "HyBidAdapterConfiguration.h"
#import "HyBidRemoteConfigManager.h"
#import "HyBidLogger.h"

#if __has_include(<ATOM/ATOM.h>)
    #import <ATOM/ATOM.h>
#endif

NSString *const HyBidAdapterConfigurationNetworkName = @"pubnative";
NSString *const HyBidAdapterConfigurationAdapterVersion = @"2.12.2.0";
NSString *const HyBidAdapterConfigurationNetworkSDKVersion = @"2.12.2";
NSString *const HyBidAdapterConfigurationAppTokenKey = @"pubnative_appToken";

@interface HyBidAdapterConfiguration ()

#if __has_include(<ATOM/ATOM.h>)
@property (nonatomic, strong) ATOMRemoteConfigVoyager *voyager;
#endif

@end

@implementation HyBidAdapterConfiguration

- (NSString *)adapterVersion {
    return HyBidAdapterConfigurationAdapterVersion;
}

- (NSString *)biddingToken {
    return nil;
}

- (NSString *)moPubNetworkName {
    return HyBidAdapterConfigurationNetworkName;

}

- (NSString *)networkSdkVersion {
    return HyBidAdapterConfigurationNetworkSDKVersion;
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *,id> *)configuration
                                  complete:(void (^)(NSError * _Nullable))complete {
    if (configuration && [configuration objectForKey:HyBidAdapterConfigurationAppTokenKey]) {
        NSString *appToken = [configuration objectForKey:HyBidAdapterConfigurationAppTokenKey];
        [HyBid initWithAppToken:appToken completion:^(BOOL success) {
            complete(nil);
        }];
        
        #if __has_include(<ATOM/ATOM.h>)
        [[HyBidRemoteConfigManager sharedInstance] initializeRemoteConfigWithCompletion:^(BOOL remoteConfigSuccess, HyBidRemoteConfigModel *remoteConfig) {
            self.voyager = [[ATOMRemoteConfigVoyager alloc] initWithDictionary:remoteConfig.dictionary[@"voyager"]];
            
            [ATOM setTestMode:YES];
            [ATOM setSessionTestMode:YES];
            
            [ATOM initWithAppToken:appToken andWithRemoteConfig:self.voyager completion:^(BOOL completion) {
                ATOMAudienceController* audienceController = [[ATOMAudienceController alloc] init];
                [audienceController refreshAudience];
                
                ATOMAudienceData *audienceData = [audienceController lastKnownAudience];
                
                NSString* audienceText = [NSString stringWithFormat:@"Ethnicity: %@\nIncome: %@\nGender: %@\nChildren: %f\nMale: %f\nFemale: %f\nAge: %ld", audienceData.predominantEthnicity, audienceData.predominantIncome, audienceData.gender, audienceData.parentWithChildren, audienceData.male, audienceData.female, audienceData.age];
                
                [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"ATOM Audience is: %@", audienceText]];
            }];
        }];
        #endif
    } else {
        NSError *error = [NSError errorWithDomain:@"Native Network or Custom Event adapter was configured incorrectly."
                                             code:0
                                         userInfo:nil];
        complete(error);
    }
    
}

@end
