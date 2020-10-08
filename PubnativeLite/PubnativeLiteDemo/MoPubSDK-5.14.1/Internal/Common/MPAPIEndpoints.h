//
//  MPAPIEndpoints.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

@interface MPAPIEndpoints : NSObject

#pragma mark - setUsesHTTPS

/**
 Sets whether HTTPS is used for methods returning @c NSURLComponents.
 Note that this does not affect @c baseURL.
 
 This setting defaults to @c YES.
 
 @param usesHTTPS send @c YES if HTTPS should be used, @c NO for HTTP
 */
+ (void)setUsesHTTPS:(BOOL)usesHTTPS;

#pragma mark - MoPub ads URL

/**
 URL path for ad request. To be used with the MoPub ads URL.
 */
#define MOPUB_API_PATH_AD_REQUEST           @"/m/ad"

/**
 URL path for native ad positioning request. To be used with the MoPub ads URL.
 */
#define MOPUB_API_PATH_NATIVE_POSITIONING   @"/m/pos"

/**
 URL path for open request. To be used with the MoPub ads URL.
 */
#define MOPUB_API_PATH_OPEN                 @"/m/open"

/**
 URL path for the GDPR consent dialog. To be used with the MoPub ads URL.
 */
#define MOPUB_API_PATH_CONSENT_DIALOG       @"/m/gdpr_consent_dialog"

/**
 URL path for GDPR sync request. To be used with the MoPub ads URL.
 */
#define MOPUB_API_PATH_CONSENT_SYNC         @"/m/gdpr_sync"

/**
 Returns the base hostname string for the MoPub ads URL.
 */
@property (nonatomic, copy, class) NSString * baseHostname;

/**
 Returns a URL containing the base hostname string for the MoPub ads URL.
 
 Uses HTTP for the scheme when App Transport Security is disabled for web view
 content or in general. Uses HTTPS when App Transport Security is enabled.
 This is because this URL is specifically used as the base URL when loading HTML markup
 into a web view, and web views don't like it when you load HTTP resources with an HTTPS
 base URL. It is not guaranteed that any given ad will have all secure resources.
 */
@property (nonatomic, copy, readonly, class) NSURL * baseURL;

/**
 Returns an @c NSURLComponents instance with the ads URL base hostname string and the given
 path. Relies on the @c setUsesHTTPS setting above to determine scheme. Defaults to HTTPS
 scheme.
 
 @param path the path component of the URL
 @return the @c NSURLComponents instance with the given path
 */
+ (NSURLComponents *)baseURLComponentsWithPath:(NSString *)path;

#pragma mark - MoPub callback URL

/**
 URL path for SKAdNetwork synchronization. To be used with the MoPub callback URL.
 */
#define MOPUB_CALLBACK_API_PATH_SKADNETWORK_SYNC @"/supported_ad_partners"

/**
 Returns the base hostname string for the MoPub callback URL.
 */
@property (nonatomic, copy, readonly, class) NSString * callbackBaseHostname;

/**
 Returns an @c NSURLComponents instance with the callback URL base hostname string and the
 given path. Relies on the @c setUsesHTTPS: setting above to determine scheme. Defaults to
 HTTPS scheme.
 
 @param path the path component of the URL
 @return the @c NSURLComponents instance with the given path
 */
+ (NSURLComponents *)callbackBaseURLComponentsWithPath:(NSString *)path;

@end
