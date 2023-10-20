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

@end
