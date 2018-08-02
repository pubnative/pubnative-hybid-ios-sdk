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
#import "PNLiteCrashTracker.h"
#import "PNLiteCollections.h"
#import "PNLiteKeys.h"
#import "PNLiteConfiguration.h"
#import "PNLiteCrashLogger.h"

#define PLATFORM_WORD_SIZE sizeof(void*)*8

NSDictionary *PNLiteParseDevice(NSDictionary *report) {
    NSMutableDictionary *device =
    [[report valueForKeyPath:@"user.state.deviceState"] mutableCopy];
    
    [device addEntriesFromDictionary:PNLiteParseDeviceState(report[@"system"])];
    
    PNLiteDictSetSafeObject(device, [[NSLocale currentLocale] localeIdentifier],
                         @"locale");
    
    PNLiteDictSetSafeObject(device, [report valueForKeyPath:@"system.time_zone"], @"timezone");
    PNLiteDictSetSafeObject(device, [report valueForKeyPath:@"system.memory.usable"],
                         @"totalMemory");
    
    PNLiteDictSetSafeObject(device,
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
        pnlite_log_warn(@"Failed to read free disk space: %@", error);
    }
    
    NSNumber *freeBytes = [fileSystemAttrs objectForKey:NSFileSystemFreeSize];
    PNLiteDictSetSafeObject(device, freeBytes, @"freeDisk");
    PNLiteDictSetSafeObject(device, report[@"system"][@"device_app_hash"], @"id");

#if TARGET_OS_SIMULATOR
    PNLiteDictSetSafeObject(device, @YES, @"simulator");
#elif TARGET_OS_IPHONE || TARGET_OS_TV
    PNLiteDictSetSafeObject(device, @NO, @"simulator");
#endif

    return device;
}

NSDictionary *PNLiteParseApp(NSDictionary *report) {
    NSMutableDictionary *appState = [NSMutableDictionary dictionary];
    
    NSDictionary *stats = report[@"application_stats"];
    
    NSInteger activeTimeSinceLaunch =
    [stats[@"active_time_since_launch"] doubleValue] * 1000.0;
    NSInteger backgroundTimeSinceLaunch =
    [stats[@"background_time_since_launch"] doubleValue] * 1000.0;
    
    PNLiteDictSetSafeObject(appState, @(activeTimeSinceLaunch),
                         @"durationInForeground");

    PNLiteDictSetSafeObject(appState, report[PNLiteKeyExecutableName], PNLiteKeyName);
    PNLiteDictSetSafeObject(appState,
                         @(activeTimeSinceLaunch + backgroundTimeSinceLaunch),
                         @"duration");
    PNLiteDictSetSafeObject(appState, stats[@"application_in_foreground"],
                         @"inForeground");
    PNLiteDictSetSafeObject(appState, report[@"CFBundleIdentifier"], PNLiteKeyId);
    return appState;
}

NSDictionary *PNLiteParseAppState(NSDictionary *report) {
    NSMutableDictionary *app = [NSMutableDictionary dictionary];

    PNLiteDictSetSafeObject(app, report[@"CFBundleVersion"], @"bundleVersion");
    PNLiteDictSetSafeObject(app, [PNLiteCrashTracker configuration].releaseStage,
                         PNLiteKeyReleaseStage);
    PNLiteDictSetSafeObject(app, report[@"CFBundleShortVersionString"], PNLiteKeyVersion);
    
    PNLiteDictSetSafeObject(app, [PNLiteCrashTracker configuration].codeBundleId, @"codeBundleId");
    
    NSString *notifierType;
#if TARGET_OS_TV
    notifierType = @"tvOS";
#elif TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    notifierType = @"iOS";
#elif TARGET_OS_MAC
    notifierType = @"macOS";
#endif
    
    if ([PNLiteCrashTracker configuration].notifierType) {
        notifierType = [PNLiteCrashTracker configuration].notifierType;
    }
    PNLiteDictSetSafeObject(app, notifierType, @"type");
    return app;
}

NSDictionary *PNLiteParseDeviceState(NSDictionary *report) {
    NSMutableDictionary *deviceState = [NSMutableDictionary new];
    PNLiteDictSetSafeObject(deviceState, report[@"model"], @"modelNumber");
    PNLiteDictSetSafeObject(deviceState, report[@"machine"], @"model");
    PNLiteDictSetSafeObject(deviceState, report[@"system_name"], @"osName");
    PNLiteDictSetSafeObject(deviceState, report[@"system_version"], @"osVersion");
    PNLiteDictSetSafeObject(deviceState, @(PLATFORM_WORD_SIZE), @"wordSize");
    PNLiteDictSetSafeObject(deviceState, @"Apple", @"manufacturer");
    PNLiteDictSetSafeObject(deviceState, report[@"jailbroken"], @"jailbroken");
    return deviceState;
}

