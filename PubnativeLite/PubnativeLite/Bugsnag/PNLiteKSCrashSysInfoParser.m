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

#import "PNLiteKSCrashSysInfoParser.h"
#import "Bugsnag.h"
#import "BugsnagCollections.h"
#import "BugsnagKeys.h"
#import "BugsnagConfiguration.h"
#import "BugsnagLogger.h"

#define PLATFORM_WORD_SIZE sizeof(void*)*8

NSDictionary *BSGParseDevice(NSDictionary *report) {
    NSMutableDictionary *device =
    [[report valueForKeyPath:@"user.state.deviceState"] mutableCopy];
    
    [device addEntriesFromDictionary:BSGParseDeviceState(report[@"system"])];
    
    BSGDictSetSafeObject(device, [[NSLocale currentLocale] localeIdentifier],
                         @"locale");
    
    BSGDictSetSafeObject(device, [report valueForKeyPath:@"system.time_zone"], @"timezone");
    BSGDictSetSafeObject(device, [report valueForKeyPath:@"system.memory.usable"],
                         @"totalMemory");
    
    BSGDictSetSafeObject(device,
                         [report valueForKeyPath:@"system.memory.free"],
                         @"freeMemory");
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(
                                                               NSDocumentDirectory, NSUserDomainMask, true);
    NSString *path = [searchPaths lastObject];
    
    NSError *error;
    NSDictionary *fileSystemAttrs =
    [fileManager attributesOfFileSystemForPath:path error:&error];
    
    if (error) {
        bsg_log_warn(@"Failed to read free disk space: %@", error);
    }
    
    NSNumber *freeBytes = [fileSystemAttrs objectForKey:NSFileSystemFreeSize];
    BSGDictSetSafeObject(device, freeBytes, @"freeDisk");
    BSGDictSetSafeObject(device, report[@"system"][@"device_app_hash"], @"id");

#if TARGET_OS_SIMULATOR
    BSGDictSetSafeObject(device, @YES, @"simulator");
#elif TARGET_OS_IPHONE || TARGET_OS_TV
    BSGDictSetSafeObject(device, @NO, @"simulator");
#endif

    return device;
}

NSDictionary *BSGParseApp(NSDictionary *report) {
    NSMutableDictionary *appState = [NSMutableDictionary dictionary];
    
    NSDictionary *stats = report[@"application_stats"];
    
    NSInteger activeTimeSinceLaunch =
    [stats[@"active_time_since_launch"] doubleValue] * 1000.0;
    NSInteger backgroundTimeSinceLaunch =
    [stats[@"background_time_since_launch"] doubleValue] * 1000.0;
    
    BSGDictSetSafeObject(appState, @(activeTimeSinceLaunch),
                         @"durationInForeground");

    BSGDictSetSafeObject(appState, report[BSGKeyExecutableName], BSGKeyName);
    BSGDictSetSafeObject(appState,
                         @(activeTimeSinceLaunch + backgroundTimeSinceLaunch),
                         @"duration");
    BSGDictSetSafeObject(appState, stats[@"application_in_foreground"],
                         @"inForeground");
    BSGDictSetSafeObject(appState, report[@"CFBundleIdentifier"], BSGKeyId);
    return appState;
}

NSDictionary *BSGParseAppState(NSDictionary *report) {
    NSMutableDictionary *app = [NSMutableDictionary dictionary];

    BSGDictSetSafeObject(app, report[@"CFBundleVersion"], @"bundleVersion");
    BSGDictSetSafeObject(app, [Bugsnag configuration].releaseStage,
                         BSGKeyReleaseStage);
    BSGDictSetSafeObject(app, report[@"CFBundleShortVersionString"], BSGKeyVersion);
    
    BSGDictSetSafeObject(app, [Bugsnag configuration].codeBundleId, @"codeBundleId");
    
    NSString *notifierType;
#if TARGET_OS_TV
    notifierType = @"tvOS";
#elif TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    notifierType = @"iOS";
#elif TARGET_OS_MAC
    notifierType = @"macOS";
#endif
    
    if ([Bugsnag configuration].notifierType) {
        notifierType = [Bugsnag configuration].notifierType;
    }
    BSGDictSetSafeObject(app, notifierType, @"type");
    return app;
}

NSDictionary *BSGParseDeviceState(NSDictionary *report) {
    NSMutableDictionary *deviceState = [NSMutableDictionary new];
    BSGDictSetSafeObject(deviceState, report[@"model"], @"modelNumber");
    BSGDictSetSafeObject(deviceState, report[@"machine"], @"model");
    BSGDictSetSafeObject(deviceState, report[@"system_name"], @"osName");
    BSGDictSetSafeObject(deviceState, report[@"system_version"], @"osVersion");
    BSGDictSetSafeObject(deviceState, @(PLATFORM_WORD_SIZE), @"wordSize");
    BSGDictSetSafeObject(deviceState, @"Apple", @"manufacturer");
    BSGDictSetSafeObject(deviceState, report[@"jailbroken"], @"jailbroken");
    return deviceState;
}

