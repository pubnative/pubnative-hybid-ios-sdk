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

#import "HyBidUserDataManager.h"
#import "HyBidSettings.h"
#import "HyBidGeoIPRequest.h"
#import "PNLiteCountryUtils.h"
#import "UIApplication+PNLiteTopViewController.h"
#import "PNLiteConsentPageViewController.h"
#import "PNLiteUserConsentRequest.h"
#import "PNLiteUserConsentRequestModel.h"
#import "PNLiteUserConsentResponseStatus.h"
#import "PNLiteCheckConsentRequest.h"

NSString *const kPNLiteDeviceIDType = @"idfa";
NSString *const kPNLiteGDPRConsentStateKey = @"gdpr_consent_state";
NSString *const kPNLiteGDPRAdvertisingIDKey = @"gdpr_advertising_id";
NSString *const kPNLitePrivacyPolicyUrl = @"https://pubnative.net/privacy-notice/";
NSString *const kPNLiteVendorListUrl = @"https://pubnative.net/monetization-partners/";
NSString *const kPNLiteConsentPageUrl = @"https://pubnative.net/personalize-your-experience/";
NSInteger const kPNLiteConsentStateAccepted = 1;
NSInteger const kPNLiteConsentStateDenied = 0;

@interface HyBidUserDataManager () <HyBidGeoIPRequestDelegate, PNLiteUserConsentRequestDelegate, PNLiteCheckConsentRequestDelegate, PNLiteConsentPageViewControllerDelegate>

@property (nonatomic, assign) BOOL inGDPRZone;
@property (nonatomic, assign) NSInteger consentState;
@property (nonatomic, copy) UserDataManagerCompletionBlock completionBlock;
@property (nonatomic, strong, nullable) PNLiteConsentPageViewController * consentPageViewController;
@property (nonatomic, copy) void (^consentPageDidDismissCompletionBlock)(void);

@end

@implementation HyBidUserDataManager

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
    static HyBidUserDataManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HyBidUserDataManager alloc] init];
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

- (BOOL)canCollectData
{
    if ([self GDPRApplies]) {
        if ([self GDPRConsentAsked]) {
            switch ([[NSUserDefaults standardUserDefaults] integerForKey:kPNLiteGDPRConsentStateKey]) {
                case kPNLiteConsentStateAccepted:
                    return YES;
                    break;
                case kPNLiteConsentStateDenied:
                    return NO;
                    break;
                default:
                    return NO;
                    break;
            }
        } else {
            return NO;
        }
    } else {
        return YES;
    }
}

- (BOOL)shouldAskConsent
{
    return [self GDPRApplies] && ![self GDPRConsentAsked];
}

- (void)grantConsent
{
    self.consentState = kPNLiteConsentStateAccepted;
    [self notifyConsentGiven];
}

- (void)denyConsent
{
    self.consentState = kPNLiteConsentStateDenied;
    [self notifyConsentDenied];
}

- (void)notifyConsentGiven
{
    PNLiteUserConsentRequestModel *requestModel = [[PNLiteUserConsentRequestModel alloc] initWithDeviceID:[HyBidSettings sharedInstance].advertisingId
                                                                                         withDeviceIDType:kPNLiteDeviceIDType
                                                                                              withConsent:YES];
    
    PNLiteUserConsentRequest *request = [[PNLiteUserConsentRequest alloc] init];
    [request doConsentRequestWithDelegate:self withRequest:requestModel withAppToken:[HyBidSettings sharedInstance].appToken];
}

- (void)notifyConsentDenied
{
    PNLiteUserConsentRequestModel *requestModel = [[PNLiteUserConsentRequestModel alloc] initWithDeviceID:[HyBidSettings sharedInstance].advertisingId
                                                                                    withDeviceIDType:kPNLiteDeviceIDType
                                                                                         withConsent:NO];
    PNLiteUserConsentRequest *request = [[PNLiteUserConsentRequest alloc] init];
    [request doConsentRequestWithDelegate:self withRequest:requestModel withAppToken:[HyBidSettings sharedInstance].appToken];
}

- (void)determineUserZone
{
    HyBidGeoIPRequest *request = [[HyBidGeoIPRequest alloc] init];
    [request requestGeoIPWithDelegate:self];
}

- (void)checkConsentGiven
{
    PNLiteCheckConsentRequest * request = [[PNLiteCheckConsentRequest alloc] init];
    [request checkConsentRequestWithDelegate:self
                                withAppToken:[HyBidSettings sharedInstance].appToken
                                withDeviceID:[HyBidSettings sharedInstance].advertisingId];
}

- (BOOL)GDPRApplies
{
    return self.inGDPRZone;
}

- (BOOL)GDPRConsentAsked
{
    BOOL askedForConsent = [[NSUserDefaults standardUserDefaults] objectForKey:kPNLiteGDPRConsentStateKey];
    if (askedForConsent) {
        NSString *IDFA = [[NSUserDefaults standardUserDefaults] stringForKey:kPNLiteGDPRAdvertisingIDKey];
        if (IDFA != nil && IDFA.length > 0 && ![IDFA isEqualToString:[HyBidSettings sharedInstance].advertisingId]) {
            askedForConsent = NO;
        }
    }
    return askedForConsent;
}

- (void)saveGDPRConsentState
{
    [[NSUserDefaults standardUserDefaults] setInteger:self.consentState forKey:kPNLiteGDPRConsentStateKey];
    [[NSUserDefaults standardUserDefaults] setObject:[HyBidSettings sharedInstance].advertisingId forKey:kPNLiteGDPRAdvertisingIDKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Consent Dialog

- (BOOL)isConsentPageLoaded
{
    return self.consentPageViewController != nil;
}

- (void)loadConsentPageWithCompletion:(void (^)(NSError * _Nullable))completion
{
    // Helper block to call completion if not nil
    void (^callCompletion)(NSError *error) = ^(NSError *error) {
        if (completion != nil) {
            completion(error);
        }
    };
    
    // If a view controller is already loaded, don't load another.
    if (self.consentPageViewController) {
        callCompletion(nil);
        return;
    }
    
    // Weak self reference for blocks
    __weak __typeof__(self) weakSelf = self;
    
    PNLiteConsentPageViewController *viewController = [[PNLiteConsentPageViewController alloc] initWithConsentPageURL:self.consentPageLink];
    viewController.delegate = weakSelf;
    [viewController loadConsentPageWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            weakSelf.consentPageViewController = viewController;
            callCompletion(nil);
        } else {
            weakSelf.consentPageViewController = nil;
            callCompletion(error);
        }
    }];
}

- (void)showConsentPage:(void (^)(void))didShow didDismiss:(void (^)(void))didDismiss
{
    if (self.isConsentPageLoaded) {
        UIViewController *viewController = [UIApplication sharedApplication].topViewController;
        [viewController presentViewController:self.consentPageViewController
                                     animated:YES
                                   completion:didShow];
        self.consentPageDidDismissCompletionBlock = didDismiss;
    }
}

#pragma mark PNLiteConsentPageViewControllerDelegate

- (void)consentPageViewControllerWillDisappear:(PNLiteConsentPageViewController *)consentDialogViewController
{
    self.consentPageViewController = nil;
}

- (void)consentPageViewControllerDidDismiss:(PNLiteConsentPageViewController *)consentDialogViewController
{
    if (self.consentPageDidDismissCompletionBlock) {
        self.consentPageDidDismissCompletionBlock();
        self.consentPageDidDismissCompletionBlock = nil;
    }
}

#pragma mark PNLiteCheckConsentRequestDelegate

- (void)checkConsentRequestSuccess:(PNLiteUserConsentResponseModel *)model
{
    if ([model.status isEqualToString:[PNLiteUserConsentResponseStatus ok]]) {
        if (model.consent != nil) {
            if (model.consent.consented) {
                self.consentState = kPNLiteConsentStateAccepted;
                [self saveGDPRConsentState];
            } else {
                self.consentState = kPNLiteConsentStateDenied;
                [self saveGDPRConsentState];
            }
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
        if ([NSNumber numberWithInteger:self.consentState] != nil) {
            [self saveGDPRConsentState];
        }
    }
}

- (void)userConsentRequestFail:(NSError *)error
{
    NSLog(@"PNLiteUserConsentRequestDelegate: Request failed with error: %@",error.localizedDescription);
}

#pragma mark HyBidGeoIPRequestDelegate

- (void)requestDidStart:(HyBidGeoIPRequest *)request
{
    NSLog(@"HyBidGeoIPRequestDelegate: Request %@ started:",request);
}

- (void)request:(HyBidGeoIPRequest *)request didLoadWithGeoIP:(PNLiteGeoIPModel *)geoIP
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

- (void)request:(HyBidGeoIPRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"HyBidGeoIPRequestDelegate: Request %@ failed with error: %@",request,error.localizedDescription);
    self.completionBlock(NO);
}

@end
