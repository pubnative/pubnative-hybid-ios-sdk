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

#import "PNLiteUserDataManager.h"
#import "PNLiteSettings.h"
#import "PNLiteGeoIPRequest.h"
#import "PNLiteCountryUtils.h"
#import "UIApplication+PNLiteTopViewController.h"
#import "PNLiteConsentPageViewController.h"

NSString *const kPNLiteGDPRConsentUUIDKey = @"gdpr_consent_uuid";
NSString *const kPNLiteGDPRConsentStateKey = @"gdpr_consent_state";
NSString *const kPNLitePrivacyPolicyUrl = @"https://pubnative.net/privacy-policy/";
NSString *const kPNLiteVendorListUrl = @"https://pubnative.net/vendor-list/";
NSString *const kPNLiteConsentPageUrl = @"https://pubnative.net/personalize-your-experience/";
NSInteger const kPNLiteConsentStateAccepted = 1;
NSInteger const kPNLiteConsentStateDenied = 0;

@interface PNLiteUserDataManager () <PNLiteGeoIPRequestDelegate>

@property (nonatomic, assign) BOOL inGDPRZone;
@property (nonatomic, assign) BOOL initialisedSuccessfully;
@property (nonatomic, assign) NSInteger consentState;
@property (nonatomic, strong) NSString *UUID;
@property (nonatomic, copy) UserDataManagerCompletionBlock completionBlock;

@end

@implementation PNLiteUserDataManager

- (void)dealloc
{
    self.UUID = nil;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.inGDPRZone = NO;
        self.initialisedSuccessfully = NO;
        self.consentState = kPNLiteConsentStateDenied;
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static PNLiteUserDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PNLiteUserDataManager alloc] init];
    });
    return sharedInstance;
}

- (void)createUserDataManagerWithAppToken:(NSString *)appToken completion:(UserDataManagerCompletionBlock)completion
{
    self.completionBlock = completion;
    [self determineUserZone];
}

- (void)determineUserZone
{
    PNLiteGeoIPRequest *request = [[PNLiteGeoIPRequest alloc] init];
    [request requestGeoIPWithDelegate:self];
}

- (void)showConsentRequestScreen
{
    UIViewController *viewController = [UIApplication sharedApplication].topViewController;
    [viewController presentViewController:[[PNLiteConsentPageViewController alloc] initWithNibName:NSStringFromClass([PNLiteConsentPageViewController class]) bundle:[NSBundle bundleForClass:[self class]]] animated:YES completion:nil];
}

- (NSString *)privacyPolicyLink
{
    return kPNLitePrivacyPolicyUrl;
}

- (NSString *)vendorListLink
{
    return kPNLiteVendorListUrl;
}

- (NSString *)consentPageLink
{
    return kPNLiteConsentPageUrl;
}

- (BOOL)shouldAskConsent
{
    return [self GDPRApplies] && ![self GDPRConsentAsked];
}

- (void)grantConsent
{
    self.consentState = kPNLiteConsentStateAccepted;
    [self saveGDPRConsentState];
    
    //TODO sync with API
}

- (void)denyConsent
{
    self.consentState = kPNLiteConsentStateDenied;
    [self saveGDPRConsentState];
    
    //TODO sync with API
}

- (void)revokeConsent
{
    self.consentState = kPNLiteConsentStateDenied;
    [self saveGDPRConsentState];
    
    //TODO sync with API
}

- (void)saveGDPRConsentState
{
    [[NSUserDefaults standardUserDefaults] setInteger:self.consentState forKey:kPNLiteGDPRConsentStateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveGDPRConsentUUID
{
    [[NSUserDefaults standardUserDefaults] setObject:self.UUID forKey:kPNLiteGDPRConsentUUIDKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)GDPRApplies
{
    return self.inGDPRZone;
}

- (BOOL)GDPRConsentAsked
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kPNLiteGDPRConsentStateKey];
}

#pragma mark PNLiteGeoIPRequestDelegate

- (void)requestDidStart:(PNLiteGeoIPRequest *)request
{
    NSLog(@"PNLiteGeoIPRequestDelegate: Request %@ started:",request);
}

- (void)request:(PNLiteGeoIPRequest *)request didLoadWithGeoIP:(PNLiteGeoIPModel *)geoIP
{
    if ([geoIP.countryCode length] == 0) {
        NSLog(@"No country code was obtained. The default value will be used, therefore no user data consent will be required.");
        self.inGDPRZone = NO;
        self.initialisedSuccessfully = NO;
    } else {
        self.inGDPRZone = [PNLiteCountryUtils isGDPRCountry:geoIP.countryCode];
        self.initialisedSuccessfully = YES;
        self.completionBlock(self.initialisedSuccessfully);
        self.completionBlock = nil;
    }
}

- (void)request:(PNLiteGeoIPRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"PNLiteGeoIPRequestDelegate: Request %@ failed with error: %@",request,error.localizedDescription);
}

@end
