// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^UserDataManagerCompletionBlock)(BOOL);

@protocol HyBidUserDataManagerDelegate <NSObject>
- (void)gppValuesDidChange;
@end

@interface HyBidUserDataManager : NSObject

@property (nonatomic, readonly) BOOL isConsentPageLoaded;
@property (nonatomic) NSObject<HyBidUserDataManagerDelegate> * _Nullable delegate;

+ (instancetype _Nonnull )sharedInstance;
- (void)createUserDataManagerWithCompletion:(UserDataManagerCompletionBlock _Nonnull)completion;
- (void)loadConsentPageWithCompletion:(void (^ _Nullable)(NSError * _Nullable error))completion;
- (void)showConsentPage:(void (^ _Nullable)(void))didShow didDismiss:(void (^ _Nullable)(void))didDismiss;
- (NSString * _Nonnull)privacyPolicyLink;
- (NSString * _Nonnull)vendorListLink;
- (NSString *_Nonnull)consentPageLink;
- (BOOL)canCollectData;
- (BOOL)shouldAskConsent;
- (void)grantConsent;
- (void)denyConsent;

- (void)setIABUSPrivacyString:(NSString *_Nullable)privacyString;
- (NSString *_Nullable)getIABUSPrivacyString;
- (void)removeIABUSPrivacyString;
- (BOOL)isCCPAOptOut;
- (BOOL)isConsentDenied;

- (void)setIABGDPRConsentString:(NSString *_Nullable)consentString;
- (NSString *_Nullable)getIABGDPRConsentString;
- (void)removeIABGDPRConsentString;

- (NSString *_Nullable)getInternalGPPString;
- (NSString *_Nullable)getInternalGPPSID;
- (NSString *_Nullable)getPublicGPPString;
- (NSString *_Nullable)getPublicGPPSID;
- (void)setInternalGPPString:(NSString *_Nonnull)gppString;
- (void)setInternalGPPSID:(NSString *_Nonnull)gppSID;
- (void)setPublicGPPString:(NSString *_Nonnull)gppString;
- (void)setPublicGPPSID:(NSString *_Nonnull)gppSID;
- (void)removeInternalGPPString;
- (void)removeInternalGPPSID;
- (void)removeGPPInternalData;
- (void)removeGPPData;
- (void)removePublicGPPString;
- (void)removePublicGPPSID;
- (BOOL)hasLGPD;
- (void)setHasLGPD:(BOOL)hasLGPD;

- (NSArray<NSString *> * _Nonnull)keyPathsForGDPRObservers;
@end
