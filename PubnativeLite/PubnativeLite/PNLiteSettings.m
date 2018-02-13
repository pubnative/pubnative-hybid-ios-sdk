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

#import "PNLiteSettings.h"
#import "PNLiteLocationManager.h"

@implementation PNLiteSettings

- (void)dealloc
{
    self.targeting = nil;
    self.appToken = nil;
}

+ (PNLiteSettings *)sharedInstance
{
    static PNLiteSettings *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[PNLiteSettings alloc] init];
    });
    return _instance;
}

- (NSString *)advertisingId
{
    NSString *result = nil;
    if(!self.coppa && NSClassFromString(@"ASIdentifierManager")){
        if([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]){
            result = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        }
    }
    return result;
}

- (CLLocation *)location
{
    CLLocation *result = nil;
    if(!self.coppa) {
        result = [PNLiteLocationManager getLocation];
    }
    return result;
}

- (NSString *)os
{
    UIDevice *currentDevice = [UIDevice currentDevice];
    return currentDevice.systemName;
}

- (NSString *)osVersion
{
    UIDevice *currentDevice = [UIDevice currentDevice];
    return currentDevice.systemVersion;
}

- (NSString *)deviceName
{
    UIDevice *currentDevice = [UIDevice currentDevice];
    return currentDevice.model;
}

- (NSString *)locale
{
    return [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
}

- (NSString *)appVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

- (NSString *)appBundleID
{
    return [[NSBundle mainBundle] bundleIdentifier];
}

@end
