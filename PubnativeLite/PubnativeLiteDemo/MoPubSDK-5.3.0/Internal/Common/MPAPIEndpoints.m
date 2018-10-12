//
//  MPAPIEndpoints.m
//  MoPub
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPAPIEndpoints.h"
#import "MPConstants.h"
#import "MPCoreInstanceProvider.h"

// URL scheme constants
static NSString * const kUrlSchemeHttp = @"http";
static NSString * const kUrlSchemeHttps = @"https";

@implementation MPAPIEndpoints

static BOOL sUsesHTTPS = YES;

+ (void)setUsesHTTPS:(BOOL)usesHTTPS
{
    sUsesHTTPS = usesHTTPS;
}

+ (NSString *)baseURL
{
    if ([[MPCoreInstanceProvider sharedProvider] appTransportSecuritySettings] == MPATSSettingEnabled) {
        return [@"https://" stringByAppendingString:MOPUB_BASE_HOSTNAME];
    }

    return [@"http://" stringByAppendingString:MOPUB_BASE_HOSTNAME];
}

+ (NSURLComponents *)baseURLComponentsWithPath:(NSString *)path
{
    NSURLComponents * components = [[NSURLComponents alloc] init];
    components.scheme = (sUsesHTTPS ? kUrlSchemeHttps : kUrlSchemeHttp);
    components.host = MOPUB_BASE_HOSTNAME;
    components.path = path;

    return components;
}

@end
