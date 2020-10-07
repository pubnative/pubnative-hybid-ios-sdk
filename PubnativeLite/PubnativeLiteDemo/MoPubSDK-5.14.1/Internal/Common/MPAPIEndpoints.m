//
//  MPAPIEndpoints.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAPIEndpoints.h"
#import "MPConstants.h"
#import "MPDeviceInformation.h"

// URL scheme constants
static NSString * const kUrlSchemeHttp = @"http";
static NSString * const kUrlSchemeHttps = @"https";

// Base URL constant
static NSString * const kMoPubBaseHostname = @"ads.mopub.com";

// Callback URL constant
static NSString * const kCallbackBaseHostname = @"cb.mopub.com";

@implementation MPAPIEndpoints

#pragma mark - setUsesHTTPS

static BOOL sUsesHTTPS = YES;
+ (void)setUsesHTTPS:(BOOL)usesHTTPS
{
    sUsesHTTPS = usesHTTPS;
}

#pragma mark - ads.mopub.com Base URL

static NSString * _baseHostname = nil;
+ (void)setBaseHostname:(NSString *)baseHostname {
    _baseHostname = baseHostname;
}

+ (NSString *)baseHostname {
    if (_baseHostname == nil || [_baseHostname isEqualToString:@""]) {
        return kMoPubBaseHostname;
    }
    
    return _baseHostname;
}

+ (NSURL *)baseURL
{
    return [self urlWithHostname:self.baseHostname];
}

+ (NSURLComponents *)baseURLComponentsWithPath:(NSString *)path
{
    return [self urlComponentsWithHostname:self.baseHostname path:path];
}

#pragma mark - cb.mopub.com Callback URL

+ (NSString *)callbackBaseHostname
{
    return kCallbackBaseHostname;
}

+ (NSURLComponents *)callbackBaseURLComponentsWithPath:(NSString *)path
{
    return [self urlComponentsWithHostname:self.callbackBaseHostname path:path];
}

#pragma mark - Helper

+ (NSURL *)urlWithHostname:(NSString *)hostname
{
    NSURLComponents * components = [[NSURLComponents alloc] init];
    // Note:
    // If the baseURL is HTTPS, all elements loaded into the web view using this
    // baseURL must also be HTTPS. Ad creatives do not always have 100% HTTPS
    // resources, so this must be HTTP when ATS is not enabled.
    components.scheme = MPDeviceInformation.appTransportSecuritySettings == MPATSSettingEnabled ? kUrlSchemeHttps : kUrlSchemeHttp;
    components.host = hostname;
    return components.URL;
}

+ (NSURLComponents *)urlComponentsWithHostname:(NSString *)hostname path:(NSString *)path
{
    NSURLComponents * components = [[NSURLComponents alloc] init];
    components.scheme = (sUsesHTTPS ? kUrlSchemeHttps : kUrlSchemeHttp);
    components.host = hostname;
    components.path = path;
    
    return components;
}

@end
