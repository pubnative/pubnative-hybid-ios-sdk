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
#import "HyBidLogger.h"

#define kCCPAPrivacyKey @"CCPA_Privacy"
#define kGDPRConsentKey @"GDPR_Consent"
#define kCCPAPublicPrivacyKey @"IABUSPrivacy_String"
#define kGDPRPublicConsentKey @"IABConsent_ConsentString"
#define kGDPRPublicConsentV2Key @"IABTCF_TCString"

NSString *const PNLiteDeviceIDType = @"idfa";
NSString *const PNLiteGDPRConsentStateKey = @"gdpr_consent_state";
NSString *const PNLiteGDPRAdvertisingIDKey = @"gdpr_advertising_id";
NSString *const PNLitePrivacyPolicyUrl = @"https://pubnative.net/privacy-notice/";
NSString *const PNLiteVendorListUrl = @"https://pubnative.net/monetization-partners/";
NSString *const PNLiteConsentPageUrl = @"https://cdn.pubnative.net/static/consent/consent.html";
NSInteger const PNLiteConsentStateAccepted = 1;
NSInteger const PNLiteConsentStateDenied = 0;

@interface HyBidUserDataManager () <HyBidGeoIPRequestDelegate, PNLiteUserConsentRequestDelegate, PNLiteCheckConsentRequestDelegate, PNLiteConsentPageViewControllerDelegate>

@property (nonatomic, assign) BOOL inGDPRZone;
@property (nonatomic, assign) NSInteger consentState;
@property (nonatomic, copy) UserDataManagerCompletionBlock completionBlock;
@property (nonatomic, strong, nullable) PNLiteConsentPageViewController * consentPageViewController;
@property (nonatomic, copy) void (^consentPageDidDismissCompletionBlock)(void);

@end

@implementation HyBidUserDataManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.inGDPRZone = NO;
        self.consentState = PNLiteConsentStateDenied;
        [[NSUserDefaults standardUserDefaults] addObserver:self
                                                forKeyPath:kCCPAPublicPrivacyKey options:NSKeyValueObservingOptionNew
                                                   context:NULL];
        [[NSUserDefaults standardUserDefaults] addObserver:self
                                                forKeyPath:kGDPRPublicConsentKey options:NSKeyValueObservingOptionNew
                                                   context:NULL];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static HyBidUserDataManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HyBidUserDataManager alloc] init];
    });
    return sharedInstance;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    NSDictionary *safeChange = [NSDictionary dictionaryWithDictionary:change];
    if ([keyPath isEqualToString:kCCPAPublicPrivacyKey]) {
        if ([[safeChange objectForKey:NSKeyValueChangeNewKey] isEqual:[NSNull null]]) {
            return;
        } else {
            NSString *privacyString = [safeChange objectForKey:@"new"];
            if (privacyString.length != 0) {
                [self setIABUSPrivacyString:privacyString];
            } else {
                [self removeIABUSPrivacyString];
            }
        }
    } else if ([keyPath isEqualToString:kGDPRPublicConsentKey]) {
        if ([[safeChange objectForKey:NSKeyValueChangeNewKey] isEqual:[NSNull null]]) {
            return;
        } else {
            NSString *consentString = [safeChange objectForKey:@"new"];
            if (consentString.length != 0) {
                [self setIABGDPRConsentString:consentString];
            } else {
                [self removeIABGDPRConsentString];
            }
        }
    } else if ([keyPath isEqualToString:kGDPRPublicConsentV2Key]) {
        if ([[safeChange objectForKey:NSKeyValueChangeNewKey] isEqual:[NSNull null]]) {
            return;
        } else {
            NSString *consentString = [safeChange objectForKey:@"new"];
            if (consentString.length != 0) {
                [self setIABGDPRConsentString:consentString];
            } else {
                [self removeIABGDPRConsentString];
            }
        }
    }
}

- (void)createUserDataManagerWithCompletion:(UserDataManagerCompletionBlock)completion {
    self.completionBlock = completion;
    [self determineUserZone];
}

- (NSString *)consentPageLink {
    return PNLiteConsentPageUrl;
}

- (NSString *)privacyPolicyLink {
    return PNLitePrivacyPolicyUrl;
}

- (NSString *)vendorListLink {
    return PNLiteVendorListUrl;
}

- (BOOL)canCollectData {
    if ([self GDPRApplies]) {
        if ([self GDPRConsentAsked]) {
            switch ([[NSUserDefaults standardUserDefaults] integerForKey:PNLiteGDPRConsentStateKey]) {
                case PNLiteConsentStateAccepted:
                    return YES;
                    break;
                case PNLiteConsentStateDenied:
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

- (BOOL)shouldAskConsent {
    return [self GDPRApplies] && ![self GDPRConsentAsked] && [HyBidSettings sharedInstance].advertisingId;
}

- (void)grantConsent {
    self.consentState = PNLiteConsentStateAccepted;
    [self notifyConsentGiven];
}

- (void)denyConsent {
    self.consentState = PNLiteConsentStateDenied;
    [self notifyConsentDenied];
}

- (void)notifyConsentGiven {
    [self saveGDPRConsentState];
    
    PNLiteUserConsentRequestModel *requestModel = [[PNLiteUserConsentRequestModel alloc] initWithDeviceID:[HyBidSettings sharedInstance].advertisingId
                                                                                         withDeviceIDType:PNLiteDeviceIDType
                                                                                              withConsent:YES];
    
    PNLiteUserConsentRequest *request = [[PNLiteUserConsentRequest alloc] init];
    [request doConsentRequestWithDelegate:self withRequest:requestModel withAppToken:[HyBidSettings sharedInstance].appToken];
}

- (void)notifyConsentDenied {
    [self saveGDPRConsentState];
    
    PNLiteUserConsentRequestModel *requestModel = [[PNLiteUserConsentRequestModel alloc] initWithDeviceID:[HyBidSettings sharedInstance].advertisingId
                                                                                    withDeviceIDType:PNLiteDeviceIDType
                                                                                         withConsent:NO];
    PNLiteUserConsentRequest *request = [[PNLiteUserConsentRequest alloc] init];
    [request doConsentRequestWithDelegate:self withRequest:requestModel withAppToken:[HyBidSettings sharedInstance].appToken];
}

- (void)determineUserZone {
    HyBidGeoIPRequest *request = [[HyBidGeoIPRequest alloc] init];
    [request requestGeoIPWithDelegate:self];
}

- (void)checkConsentGiven {
    PNLiteCheckConsentRequest * request = [[PNLiteCheckConsentRequest alloc] init];
    request.delegate = self;
    [request checkConsentRequestWithDelegate:self
                                withAppToken:[HyBidSettings sharedInstance].appToken
                                withDeviceID:[HyBidSettings sharedInstance].advertisingId];
}

- (BOOL)GDPRApplies {
    return self.inGDPRZone;
}

- (BOOL)GDPRConsentAsked {
    BOOL askedForConsent = [[NSUserDefaults standardUserDefaults] objectForKey:PNLiteGDPRConsentStateKey];
    if (askedForConsent) {
        NSString *IDFA = [[NSUserDefaults standardUserDefaults] stringForKey:PNLiteGDPRAdvertisingIDKey];
        if (IDFA != nil && IDFA.length > 0 && ![IDFA  isEqual: @"00000000-0000-0000-0000-000000000000"] && ![IDFA isEqualToString:[HyBidSettings sharedInstance].advertisingId]) {
            askedForConsent = NO;
        }
    }
    return askedForConsent;
}

- (void)saveGDPRConsentState {
    [[NSUserDefaults standardUserDefaults] setInteger:self.consentState forKey:PNLiteGDPRConsentStateKey];
    [[NSUserDefaults standardUserDefaults] setObject:[HyBidSettings sharedInstance].advertisingId forKey:PNLiteGDPRAdvertisingIDKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - GDPR Consent String

- (void)setIABGDPRConsentString:(NSString *)privacyString {
    [[NSUserDefaults standardUserDefaults] setObject:privacyString forKey:kGDPRConsentKey];
}

- (NSString *)getIABGDPRConsentString {
    NSString *consentString = [[NSUserDefaults standardUserDefaults] objectForKey:kGDPRConsentKey];
    if (!consentString || consentString.length == 0) {
        consentString = [[NSUserDefaults standardUserDefaults] objectForKey:kGDPRPublicConsentV2Key];
        if (!consentString || consentString.length == 0) {
            consentString = [[NSUserDefaults standardUserDefaults] objectForKey:kGDPRPublicConsentKey];
        }
    }
    return consentString;
}

- (void)removeIABGDPRConsentString {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kGDPRConsentKey];
}

#pragma mark - U.S. Privacy String (CCPA)

- (void)setIABUSPrivacyString:(NSString *)privacyString {
    [[NSUserDefaults standardUserDefaults] setObject:privacyString forKey:kCCPAPrivacyKey];
}

- (NSString *)getIABUSPrivacyString {
    NSString *privacyString = [[NSUserDefaults standardUserDefaults] objectForKey:kCCPAPrivacyKey];
    if (!privacyString || privacyString.length == 0) {
        privacyString = [[NSUserDefaults standardUserDefaults] objectForKey:kCCPAPublicPrivacyKey];
    }
    return privacyString;
}

- (void)removeIABUSPrivacyString {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCCPAPrivacyKey];
}

- (NSString *)getFormattedAndPercentEncodedIABUSPrivacyString {
    return [[self getFormattedIABUSPrivacyString] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];;
}

- (NSString *)getFormattedIABUSPrivacyString {
    NSString *privacyString = [self getIABUSPrivacyString];
    privacyString = [privacyString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([privacyString isEqualToString:@"null"]) {
        privacyString = @"";
    }
    
    return privacyString;
}

- (BOOL)isCCPAOptOut {
    NSString *privacyString = [self getFormattedIABUSPrivacyString];
    
    if ([privacyString length] >= 3) {
        NSString *thirdComponent = [privacyString substringWithRange:NSMakeRange(2, 1)];
        if ([[thirdComponent uppercaseString] isEqualToString:@"Y"]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        // There is no valid privacy string set, assuming there is no opt out
        return  NO;
    }
}

- (BOOL)isConsentDenied
{
    id consentKeyValue = [[NSUserDefaults standardUserDefaults] objectForKey:PNLiteGDPRConsentStateKey];
    return (consentKeyValue != nil) && ([consentKeyValue integerValue] == PNLiteConsentStateDenied);
}

#pragma mark Consent Dialog

- (BOOL)isConsentPageLoaded {
    return self.consentPageViewController != nil;
}

- (void)loadConsentPageWithCompletion:(void (^)(NSError * _Nullable))completion {
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
    [viewController setModalPresentationStyle: UIModalPresentationFullScreen];
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

- (void)showConsentPage:(void (^)(void))didShow didDismiss:(void (^)(void))didDismiss {
    if (self.isConsentPageLoaded) {
        UIViewController *viewController = [UIApplication sharedApplication].topViewController;
        [viewController presentViewController:self.consentPageViewController
                                     animated:YES
                                   completion:didShow];
        self.consentPageDidDismissCompletionBlock = didDismiss;
    }
}

#pragma mark PNLiteConsentPageViewControllerDelegate

- (void)consentPageViewControllerWillDisappear:(PNLiteConsentPageViewController *)consentDialogViewController {
    self.consentPageViewController = nil;
}

- (void)consentPageViewControllerDidDismiss:(PNLiteConsentPageViewController *)consentDialogViewController {
    if (self.consentPageDidDismissCompletionBlock) {
        self.consentPageDidDismissCompletionBlock();
        self.consentPageDidDismissCompletionBlock = nil;
    }
}

#pragma mark PNLiteCheckConsentRequestDelegate

- (void)checkConsentRequestSuccess:(PNLiteUserConsentResponseModel *)model {
    BOOL hasValidConsentResponse = [model.status isEqualToString:[PNLiteUserConsentResponseStatus ok]];
    if (hasValidConsentResponse) {
        if (model.consent.consented) {
            [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Positive user consent has been notified"];
        } else {
            [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Negative user consent has been notified"];
        }
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Check Consent Request finished."];
    }
    self.completionBlock(hasValidConsentResponse);
}

- (void)checkConsentRequestFail:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Check Consent Request failed with error: %@",error.localizedDescription]];
    self.completionBlock(NO);
}

#pragma mark PNLiteUserConsentRequestDelegate

- (void)userConsentRequestSuccess:(PNLiteUserConsentResponseModel *)model {
    if ([model.status isEqualToString:[PNLiteUserConsentResponseStatus ok]]) {
        [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"User Consent Request finished."];
        if ([NSNumber numberWithInteger:self.consentState] != nil) {
            [self saveGDPRConsentState];
        }
    }
}

- (void)userConsentRequestFail:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"User Consent Request failed with error: %@",error.localizedDescription]];
}

#pragma mark HyBidGeoIPRequestDelegate

- (void)requestDidStart:(HyBidGeoIPRequest *)request {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Geo IP Request %@ started:",request]];
}

- (void)request:(HyBidGeoIPRequest *)request didLoadWithCountryCode:(NSString *)countryCode {
    if ([countryCode length] == 0) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"No country code was obtained. The default value will be used, therefore no user data consent will be required."];
        self.inGDPRZone = NO;
        self.completionBlock(NO);
    } else {
        self.inGDPRZone = [PNLiteCountryUtils isGDPRCountry:countryCode];
        if (self.inGDPRZone && ![self GDPRConsentAsked]) {
            [self checkConsentGiven];
        } else {
            [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Geo IP Request %@ finished:",request]];
            self.completionBlock(YES);
        }
    }
}

- (void)request:(HyBidGeoIPRequest *)request didFailWithError:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Geo IP Request %@ failed with error: %@",request, error.localizedDescription]];
    self.completionBlock(NO);
}

@end
