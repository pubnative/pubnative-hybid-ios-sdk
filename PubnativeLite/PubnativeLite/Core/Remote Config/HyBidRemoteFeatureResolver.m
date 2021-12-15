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

#import "HyBidRemoteFeatureResolver.h"
#import "HyBidRemoteConfigAppFeatures.h"
#import "HyBidRemoteConfigFeature.h"

@interface HyBidRemoteFeatureResolver ()

@property (nonatomic, strong) HyBidRemoteConfigAppFeatures *appFeaturesModel;

@end

@implementation HyBidRemoteFeatureResolver

- (instancetype)initWithRemoteConfigModel:(HyBidRemoteConfigModel *)remoteConfigModel
{
    self = [super init];
    if (self) {
        if (remoteConfigModel != nil && remoteConfigModel.appConfig != nil && remoteConfigModel.appConfig.features != nil) {
            self.appFeaturesModel = remoteConfigModel.appConfig.features;
        } else {
            self.appFeaturesModel = nil;
        }
    }
    return self;
}

- (BOOL)isAdFormatEnabled:(NSString *)feature
{
    if ([feature length] == 0) {
        return NO;
    }
    
    if (self.appFeaturesModel != nil && self.appFeaturesModel.adFormats != nil) {
        return [self.appFeaturesModel.adFormats containsObject:feature];
    } else {
        return YES;
    }
}

- (BOOL)isRenderingSupported:(NSString *)feature
{
    if ([feature length] == 0) {
        return NO;
    }
    
    if (self.appFeaturesModel != nil && self.appFeaturesModel.rendering != nil) {
        return [self.appFeaturesModel.rendering containsObject:feature];
    } else {
        return YES;
    }
}

- (BOOL)isReportingModeEnabled:(NSString *)feature
{
    if ([feature length] == 0) {
        return NO;
    }
    
    if (self.appFeaturesModel != nil && self.appFeaturesModel.reporting != nil) {
        return [self.appFeaturesModel.reporting containsObject:feature];
    } else {
        return ![feature isEqualToString:[HyBidRemoteConfigFeature hyBidRemoteReportingToString:HyBidRemoteReporting_AD_EVENTS]];
    }
}

- (BOOL)isUserConsentSupported:(NSString *)feature
{
    if ([feature length] == 0) {
        return NO;
    }
    
    if (self.appFeaturesModel != nil && self.appFeaturesModel.userConsent != nil) {
        return [self.appFeaturesModel.userConsent containsObject:feature];
    } else {
        return YES;
    }
}
@end
