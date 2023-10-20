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
#define kGPPPublicString @"IABGPP_HDR_GppString"
#define kGPPPublicID @"IABGPP_GppSID"
#define kGPPString @"gpp_string"
#define kGPPID @"gpp_id"

NSString *const PNLiteDeviceIDType = @"idfa";
NSString *const PNLiteGDPRConsentStateKey = @"gdpr_consent_state";
NSString *const PNLiteGDPRAdvertisingIDKey = @"gdpr_advertising_id";
NSString *const PNLitePrivacyPolicyUrl = @"https://pubnative.net/privacy-notice/";
NSString *const PNLiteVendorListUrl = @"https://pubnative.net/monetization-partners/";
NSString *const PNLiteConsentPageUrl = @"https://cdn.pubnative.net/static/consent/consent.html";
NSInteger const PNLiteConsentStateAccepted = 1;
NSInteger const PNLiteConsentStateDenied = 0;
NSArray *HyBidUserDataManagerPublicPrivacyKeys;

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
        [self setInternalGPPStringFromPublicKey];
        [self setInternalGPPSIDFromPublicKey];
        HyBidUserDataManagerPublicPrivacyKeys = [NSArray arrayWithObjects: kCCPAPublicPrivacyKey,kGDPRPublicConsentKey,kGDPRPublicConsentV2Key,kGPPPublicString,kGPPPublicID, nil];
        [self addObservers];
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    [self removeObservers];
}

- (void)addObservers {
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:kCCPAPublicPrivacyKey options:NSKeyValueObservingOptionNew
                                               context:NULL];
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:kGDPRPublicConsentKey options:NSKeyValueObservingOptionNew
                                               context:NULL];
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:kGPPPublicString options:NSKeyValueObservingOptionNew
                                               context:NULL];
    [[NSUserDefaults standardUserDefaults] addObserver:self
                                            forKeyPath:kGPPPublicID options:NSKeyValueObservingOptionNew
                                               context:NULL];
}

- (void)removeObservers {
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:kCCPAPublicPrivacyKey];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:kGDPRPublicConsentKey];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:kGPPPublicString];
    [[NSUserDefaults standardUserDefaults] removeObserver:self forKeyPath:kGPPPublicID];
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
    [self verifyPrivacyKeyWithKeyPath:keyPath withChange:change];
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

- (void)verifyPrivacyKeyWithKeyPath:(NSString *)keyPath withChange:(NSDictionary *)change {
    if (keyPath && [HyBidUserDataManagerPublicPrivacyKeys containsObject:keyPath]) {
        NSDictionary *safeChange = [NSDictionary dictionaryWithDictionary:change];
        NSString *key = [self getUserDataPrivateKeyWithUserDataPublicKey:keyPath];
        
        if (key == nil){
            return;
        }
        
        NSString *value = [safeChange objectForKey:NSKeyValueChangeNewKey];
        if (![value isEqual: [NSNull null]] && value.length != 0) {
            [self setUserDataWithKey:key withValue:value];
        } else {
            [self removeUserDataWithKey:key];
        }
        
        [self.delegate gppValuesDidChange];
    }
}

- (NSString *)getUserDataPrivateKeyWithUserDataPublicKey:(NSString *)publicKey {
    if (publicKey && [publicKey isEqualToString:kCCPAPublicPrivacyKey]) {
        return kCCPAPrivacyKey;
    }
    
    if (publicKey && [publicKey isEqualToString:kGDPRPublicConsentKey]) {
        return kGDPRConsentKey;
    }
    
    if (publicKey && [publicKey isEqualToString:kGDPRPublicConsentV2Key]) {
        return kGDPRConsentKey;
    }
    
    if (publicKey && [publicKey isEqualToString:kGPPPublicString]) {
        return kGPPString;
    }
    
    if (publicKey && [publicKey isEqualToString:kGPPPublicID]) {
        return kGPPID;
    }
    return nil;
}

- (NSString *)getUserDataWithKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void)setUserDataWithKey:(NSString *)key withValue:(NSString *) value {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
}

- (void)removeUserDataWithKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
}

#pragma mark - GDPR Consent String

- (void)setIABGDPRConsentString:(NSString *)consentString {
    [self setUserDataWithKey:consentString withValue:kGDPRConsentKey];
}

- (NSString *)getIABGDPRConsentString {
    NSString *consentString = [self getUserDataWithKey:kGDPRConsentKey];
    if (!consentString || consentString.length == 0) {
        consentString = [self getUserDataWithKey:kGDPRPublicConsentV2Key];
        if (!consentString || consentString.length == 0) {
            consentString = [self getUserDataWithKey:kGDPRPublicConsentKey];
        }
    }
    return consentString;
}

- (void)setIABGDPRConsentStringFromPublicKey {
    if ([self getUserDataWithKey:kGDPRPublicConsentV2Key] &&
        [[self getUserDataWithKey:kGDPRPublicConsentV2Key] isKindOfClass:[NSString class]] &&
        [NSString stringWithString:[self getUserDataWithKey:kGDPRPublicConsentV2Key]].length != 0) {
        [self setIABGDPRConsentString:[self getUserDataWithKey:kGDPRPublicConsentV2Key]];
    } else if ([self getUserDataWithKey:kGDPRPublicConsentKey] &&
               [[self getUserDataWithKey:kGDPRPublicConsentKey] isKindOfClass:[NSString class]] &&
               [NSString stringWithString:[self getUserDataWithKey:kGDPRPublicConsentKey]].length != 0) {
        [self setIABGDPRConsentString:[self getUserDataWithKey:kGDPRPublicConsentKey]];
    } else {
        [self setIABGDPRConsentString:@""];
    }
}

- (void)removeIABGDPRConsentString {
    [self removeUserDataWithKey:kGDPRConsentKey];
}

#pragma mark - U.S. Privacy String (CCPA)

- (void)setIABUSPrivacyString:(NSString *)privacyString {
    [self setUserDataWithKey:privacyString withValue:kCCPAPrivacyKey];
}

- (NSString *)getIABUSPrivacyString {
    NSString *privacyString = [self getUserDataWithKey:kCCPAPrivacyKey];
    if (!privacyString || privacyString.length == 0) {
        privacyString = [self getUserDataWithKey:kCCPAPublicPrivacyKey];
    }
    return privacyString;
}

- (void)setIABUSPrivacyStringFromPublicKey {
    if ([self getUserDataWithKey:kCCPAPublicPrivacyKey] &&
        [[self getUserDataWithKey:kCCPAPublicPrivacyKey] isKindOfClass:[NSString class]] &&
        [NSString stringWithString:[self getUserDataWithKey:kCCPAPublicPrivacyKey]].length != 0) {
        [self setUserDataWithKey:kCCPAPrivacyKey withValue:[self getUserDataWithKey:kCCPAPublicPrivacyKey]];
    } else {
        [self setUserDataWithKey:kCCPAPrivacyKey withValue:@""];
    }
}

- (void)removeIABUSPrivacyString {
    [self removeUserDataWithKey:kCCPAPrivacyKey];
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

#pragma mark GPP String and ID

- (void)setInternalGPPString:(NSString *)gppString {
    [self setUserDataWithKey:kGPPString withValue:gppString];
}

- (void)setInternalGPPSID:(NSString *)gppSID {
    [self setUserDataWithKey:kGPPID withValue:gppSID];
}

- (void)setInternalGPPStringFromPublicKey {
    NSString *gppString = [self getUserDataWithKey:kGPPPublicString];
    if (gppString && [gppString isKindOfClass:[NSString class]] && gppString.length != 0) {
        [self setUserDataWithKey:kGPPString withValue:gppString];
    }
}

- (void)setInternalGPPSIDFromPublicKey {
    NSString *gppSID = [self getUserDataWithKey:kGPPPublicID];
    if (gppSID && [gppSID isKindOfClass:[NSString class]] && gppSID.length != 0) {
        [self setUserDataWithKey:kGPPID withValue:gppSID];
    }
}

- (void)setPublicGPPString:(NSString *)gppString {
    [self setUserDataWithKey:kGPPPublicString withValue:gppString];
}

- (void)setPublicGPPSID:(NSString *)gppSID {
    [self setUserDataWithKey:kGPPPublicID withValue:gppSID];
}

- (NSString *)getInternalGPPString {
    return [self getUserDataWithKey:kGPPString];
}
- (NSString *)getInternalGPPSID {
    return [self getUserDataWithKey:kGPPID];
}

- (NSString *)getPublicGPPString {
    return [self getUserDataWithKey:kGPPPublicString];
}
- (NSString *)getPublicGPPSID {
    return [self getUserDataWithKey:kGPPPublicID];
}

- (void)removeInternalGPPString {
    [self removeUserDataWithKey:kGPPString];
}

- (void)removeInternalGPPSID {
    [self removeUserDataWithKey:kGPPID];
}

- (void)removePublicGPPString {
    [self removeUserDataWithKey:kGPPPublicString];
}

- (void)removePublicGPPSID {
    [self removeUserDataWithKey:kGPPPublicID];
}

- (void)removeGPPInternalData {
    [self removeInternalGPPString];
    [self removeInternalGPPSID];
}

- (void)removeGPPData {
    [self removePublicGPPString];
    [self removePublicGPPSID];
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
