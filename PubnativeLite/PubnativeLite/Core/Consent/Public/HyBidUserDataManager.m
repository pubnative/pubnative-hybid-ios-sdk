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
#import "UIApplication+PNLiteTopViewController.h"
#import "PNLiteConsentPageViewController.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

#define kCCPAPrivacyKey @"CCPA_Privacy"
#define kGDPRConsentKey @"GDPR_Consent"
#define kGDPRAppliesKey @"IABTCF_gdprApplies"
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

@interface HyBidUserDataManager () <PNLiteConsentPageViewControllerDelegate>

@property (nonatomic, assign) NSInteger consentState;
@property (nonatomic, copy) UserDataManagerCompletionBlock completionBlock;
@property (nonatomic, strong, nullable) PNLiteConsentPageViewController * consentPageViewController;
@property (nonatomic, copy) void (^consentPageDidDismissCompletionBlock)(void);

@end

@implementation HyBidUserDataManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.consentState = PNLiteConsentStateDenied;
        [self setIABUSPrivacyStringFromPublicKey];
        [self setIABGDPRConsentStringFromPublicKey];
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
}

- (void)notifyConsentDenied {
    [self saveGDPRConsentState];
}

- (BOOL)GDPRApplies {
    NSNumber *gdprApplies;
    id gdprValue = [[NSUserDefaults standardUserDefaults] valueForKey:kGDPRAppliesKey];
    
    if ([gdprValue isKindOfClass:[NSString class]]) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        gdprApplies = [formatter numberFromString:gdprValue];
    } else if ([gdprValue isKindOfClass:[NSNumber class]]) {
        gdprApplies = gdprValue;
    } else {
        gdprApplies = @0;
    }
    
    return [gdprApplies isEqual: @1];
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

- (void)setIABGDPRConsentString:(NSString *)consentString {
    [[NSUserDefaults standardUserDefaults] setObject:consentString forKey:kGDPRConsentKey];
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

- (void)setIABGDPRConsentStringFromPublicKey {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kGDPRPublicConsentV2Key] &&
        [[[NSUserDefaults standardUserDefaults] objectForKey:kGDPRPublicConsentV2Key] isKindOfClass:[NSString class]] &&
        [NSString stringWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kGDPRPublicConsentV2Key]].length != 0) {
        [self setIABGDPRConsentString:[[NSUserDefaults standardUserDefaults] objectForKey:kGDPRPublicConsentV2Key]];
    } else if ([[NSUserDefaults standardUserDefaults] objectForKey:kGDPRPublicConsentKey] &&
               [[[NSUserDefaults standardUserDefaults] objectForKey:kGDPRPublicConsentKey] isKindOfClass:[NSString class]] &&
               [NSString stringWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kGDPRPublicConsentKey]].length != 0) {
        [self setIABGDPRConsentString:[[NSUserDefaults standardUserDefaults] objectForKey:kGDPRPublicConsentKey]];
    } else {
        [self setIABGDPRConsentString:@""];
    }
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

- (void)setIABUSPrivacyStringFromPublicKey {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kCCPAPublicPrivacyKey] &&
        [[[NSUserDefaults standardUserDefaults] objectForKey:kCCPAPublicPrivacyKey] isKindOfClass:[NSString class]] &&
        [NSString stringWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kCCPAPublicPrivacyKey]].length != 0) {
        [self setIABUSPrivacyString:[[NSUserDefaults standardUserDefaults] objectForKey:kCCPAPublicPrivacyKey]];
    } else {
        [self setIABUSPrivacyString:@""];
    }
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

- (BOOL)isConsentDenied {
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

@end
