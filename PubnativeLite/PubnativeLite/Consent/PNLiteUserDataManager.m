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
#import "PNLiteUserConsentRequest.h"
#import "PNLiteUserConsentRequestModel.h"
#import "PNLiteUserConsentResponseStatus.h"
#import "PNLiteCheckConsentRequest.h"
#import "PNLiteRevokeConsentRequest.h"

NSString *const kPNLiteDeviceIDType = @"idfa";
NSString *const kPNLiteGDPRConsentStateKey = @"gdpr_consent_state";
NSString *const kPNLitePrivacyPolicyUrl = @"https://pubnative.net/privacy-notice/";
NSString *const kPNLiteVendorListUrl = @"https://pubnative.net/monetization-partners/";
NSString *const kPNLiteConsentPageUrl = @"https://pubnative.net/personalize-your-experience/";
NSInteger const kPNLiteConsentStateAccepted = 1;
NSInteger const kPNLiteConsentStateDenied = 0;

@interface PNLiteUserDataManager () <PNLiteGeoIPRequestDelegate, PNLiteUserConsentRequestDelegate, PNLiteCheckConsentRequestDelegate, PNLiteRevokeConsentRequestDelegate>

@property (nonatomic, assign) BOOL inGDPRZone;
@property (nonatomic, assign) NSInteger consentState;
@property (nonatomic, strong) NSString *IDFA;
@property (nonatomic, copy) UserDataManagerCompletionBlock completionBlock;

@end

@implementation PNLiteUserDataManager

- (void)dealloc
{
    self.IDFA = nil;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.inGDPRZone = NO;
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

- (NSString *)consentPageLink
{
    return kPNLiteConsentPageUrl;
}

- (NSString *)privacyPolicyLink
{
    return kPNLitePrivacyPolicyUrl;
}

- (NSString *)vendorListLink
{
    return kPNLiteVendorListUrl;
}

- (BOOL)shouldAskConsent
{
    return [self GDPRApplies] && ![self GDPRConsentAsked];
}

- (void)grantConsent
{
    [self notifyConsentGiven];
}

- (void)denyConsent
{
    self.consentState = kPNLiteConsentStateDenied;
    [self saveGDPRConsentState];
}

- (void)revokeConsent
{
    [self notifyConsentRevoked];
}

- (void)notifyConsentGiven
{
    PNLiteUserConsentRequestModel *requestModel = [[PNLiteUserConsentRequestModel alloc] initWithDeviceID:[PNLiteSettings sharedInstance].advertisingId
                                                                                         withDeviceIDType:kPNLiteDeviceIDType];
    
    PNLiteUserConsentRequest *request = [[PNLiteUserConsentRequest alloc] init];
    [request doConsentRequestWithDelegate:self withRequest:requestModel withAppToken:[PNLiteSettings sharedInstance].appToken];
}

- (void)notifyConsentRevoked
{
    PNLiteRevokeConsentRequest *request = [[PNLiteRevokeConsentRequest alloc] init];
    [request revokeConsentRequestWithDelegate:self
                                 withAppToken:[PNLiteSettings sharedInstance].appToken
                                 withDeviceID:[PNLiteSettings sharedInstance].advertisingId
                             withDeviceIDType:kPNLiteDeviceIDType];
}

- (void)determineUserZone
{
    PNLiteGeoIPRequest *request = [[PNLiteGeoIPRequest alloc] init];
    [request requestGeoIPWithDelegate:self];
}

- (void)checkConsentGiven
{
    PNLiteCheckConsentRequest * request = [[PNLiteCheckConsentRequest alloc] init];
    [request checkConsentRequestWithDelegate:self withAppToken:[PNLiteSettings sharedInstance].appToken
                                withDeviceID:[PNLiteSettings sharedInstance].advertisingId
                            withDeviceIDType:kPNLiteDeviceIDType];
}

- (BOOL)GDPRApplies
{
    return self.inGDPRZone;
}

- (BOOL)GDPRConsentAsked
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kPNLiteGDPRConsentStateKey] != nil) {
        return YES;
    } else {
        return NO;
    }
}

- (void)showConsentRequestScreen
{
    UIViewController *viewController = [UIApplication sharedApplication].topViewController;
    [viewController presentViewController:[[PNLiteConsentPageViewController alloc] initWithNibName:NSStringFromClass([PNLiteConsentPageViewController class]) bundle:[NSBundle bundleForClass:[self class]]] animated:YES completion:nil];
}

- (void)saveGDPRConsentState
{
    [[NSUserDefaults standardUserDefaults] setInteger:self.consentState forKey:kPNLiteGDPRConsentStateKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark PNLiteRevokeConsentRequestDelegate

- (void)revokeConsentRequestSuccess:(PNLiteUserConsentResponseModel *)model
{
    if ([model.status isEqualToString:[PNLiteUserConsentResponseStatus ok]]) {
        self.consentState = kPNLiteConsentStateDenied;
        [self saveGDPRConsentState];
    }
}

- (void)revokeConsentRequestFail:(NSError *)error
{
    NSLog(@"PNLiteRevokeConsentRequestDelegate: Request failed with error: %@",error.localizedDescription);
}

#pragma mark PNLiteCheckConsentRequestDelegate

- (void)checkConsentRequestSuccess:(PNLiteUserConsentResponseModel *)model
{
    if ([model.status isEqualToString:[PNLiteUserConsentResponseStatus ok]]) {
        if (model.consent != nil && model.consent.consented) {
            self.consentState = kPNLiteConsentStateAccepted;
            [self saveGDPRConsentState];
        }
        self.completionBlock(YES);
    }
}

- (void)checkConsentRequestFail:(NSError *)error
{
    NSLog(@"PNLiteCheckConsentRequestDelegate: Request failed with error: %@",error.localizedDescription);
    self.completionBlock(NO);

}

#pragma mark PNLiteUserConsentRequestDelegate

- (void)userConsentRequestSuccess:(PNLiteUserConsentResponseModel *)model
{
    if ([model.status isEqualToString:[PNLiteUserConsentResponseStatus ok]]) {
        self.consentState = kPNLiteConsentStateAccepted;
        [self saveGDPRConsentState];
    }
}

- (void)userConsentRequestFail:(NSError *)error
{
    NSLog(@"PNLiteUserConsentRequestDelegate: Request failed with error: %@",error.localizedDescription);
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
        self.completionBlock(NO);
    } else {
        self.inGDPRZone = [PNLiteCountryUtils isGDPRCountry:geoIP.countryCode];
        if (self.inGDPRZone && ![self GDPRConsentAsked]) {
            [self checkConsentGiven];
        } else {
            self.completionBlock(YES);
        }
    }
}

- (void)request:(PNLiteGeoIPRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"PNLiteGeoIPRequestDelegate: Request %@ failed with error: %@",request,error.localizedDescription);
    self.completionBlock(NO);
}

@end
