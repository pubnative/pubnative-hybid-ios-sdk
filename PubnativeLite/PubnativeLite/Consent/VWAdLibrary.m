//
//  VWAdLibrary.m
//  HyBid
//
//  Created by Fares Ben Hamouda on 20.04.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//


//
//  VWAdLibrary.m
//  VWAdLibrary
//
//  Created by Srđan Rašić on 12/03/14.
//  Copyright © 2019 Verve Wireless, Inc. All rights reserved.
//


#import "VWAdLibrary.h"
#import "HyBidSettings.h"

@implementation VWAdLibrary

static VWAdLibrary *instance = nil;

+ (nonnull NSString *)sdkVersion
{
    return [HyBidSettings sharedInstance].sdkVersion;
}

+ (VWAdLibrary *)shared
{
    @synchronized(instance) {
        if (instance == nil) {
            instance = [[VWAdLibrary alloc] init];
        }
    }
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    return self;
}

- (void)dealloc
{
    
}

#pragma mark - U.S. Privacy String

- (void)setIABUSPrivacyString:(NSString *)privacyString
{
    [[NSUserDefaults standardUserDefaults] setObject:privacyString forKey:kUSPrivacyKey];
}

- (NSString *)getIABUSPrivacyString
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUSPrivacyKey];
}

- (void)removeIABUSPrivacyString
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUSPrivacyKey];
}

- (NSString *)getFormattedIABUSPrivacyString
{
    return [[self getFormattedIABUSPrivacyString] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];;
}

- (NSString *)getFormattedAndPercentEncodedIABUSPrivacyString
{
    NSString *privacyString = [self getIABUSPrivacyString];
    privacyString = [privacyString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([privacyString isEqualToString:@"null"]) {
        privacyString = @"";
    }
    
    return privacyString;
}

@end
