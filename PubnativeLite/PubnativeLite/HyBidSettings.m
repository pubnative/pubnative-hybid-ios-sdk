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

#import "HyBidSettings.h"
#import "PNLiteLocationManager.h"
#import <AVFoundation/AVFoundation.h>

@implementation HyBidSettings

- (void)dealloc {
    self.targeting = nil;
    self.appToken = nil;
    self.partnerKeyword = nil;
}

+ (HyBidSettings *)sharedInstance {
    static HyBidSettings *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[HyBidSettings alloc] init];
    });
    return _instance;
}

- (NSString *)advertisingId {
    NSString *result = nil;
    if(!self.coppa && NSClassFromString(@"ASIdentifierManager")) {
        if([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
            result = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        }
    }
    return result;
}

- (CLLocation *)location {
    CLLocation *result = nil;
    if(!self.coppa) {
        result = [PNLiteLocationManager getLocation];
    }
    return result;
}

- (NSString *)os {
    UIDevice *currentDevice = [UIDevice currentDevice];
    return currentDevice.systemName;
}

- (NSString *)osVersion {
    UIDevice *currentDevice = [UIDevice currentDevice];
    return currentDevice.systemVersion;
}

- (NSString *)deviceName {
    UIDevice *currentDevice = [UIDevice currentDevice];
    return currentDevice.model;
}

- (CGSize) getOrientationIndependentScreenSize {
    return CGSizeMake(MIN([UIScreen mainScreen].bounds.size.width,
                          [UIScreen mainScreen].bounds.size.height),
                      MAX([UIScreen mainScreen].bounds.size.width,
                          [UIScreen mainScreen].bounds.size.height));
}

- (NSString *)deviceWidth {
    return [NSString stringWithFormat:@"%.0f", [self getOrientationIndependentScreenSize].width];
}

- (NSString *)deviceHeight {
    return [NSString stringWithFormat:@"%.0f", [self getOrientationIndependentScreenSize].height];
}

- (NSString *)orientation {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            return @"portrait";
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return @"landscape";
            break;
        default:
            return @"none";
            break;
    }
}

- (NSString *)deviceSound {
    if ([AVAudioSession sharedInstance].outputVolume == 0) {
        return @"0";
    } else {
        return @"1";
    }
}

- (NSString *)locale {
    return [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
}

- (NSString *)appVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

- (NSString *)appBundleID {
    return [[NSBundle mainBundle] bundleIdentifier];
}

@end
