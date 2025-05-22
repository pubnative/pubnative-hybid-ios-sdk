// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <UIKit/UIKit.h>

@class PNLiteConsentPageViewController;

@protocol PNLiteConsentPageViewControllerDelegate<NSObject>

@optional

- (void)consentPageViewControllerWillDisappear:(PNLiteConsentPageViewController * _Nonnull)consentDialogViewController;
- (void)consentPageViewControllerDidDismiss:(PNLiteConsentPageViewController * _Nonnull)consentDialogViewController;

@end

@interface PNLiteConsentPageViewController : UIViewController

@property (nonatomic, weak) id<PNLiteConsentPageViewControllerDelegate> _Nullable delegate;

- (instancetype _Nullable)initWithConsentPageURL:(NSString * _Nonnull)consentPageURL NS_DESIGNATED_INITIALIZER;
- (void)loadConsentPageWithCompletion:(void (^_Nullable)(BOOL success, NSError * _Nullable error))completion;

/**
 These initializers are not available
 */
- (instancetype _Nullable)init NS_UNAVAILABLE;
- (instancetype _Nullable)initWithCoder:(NSCoder *_Nullable)aDecoder NS_UNAVAILABLE;
- (instancetype _Nonnull)initWithNibName:(NSString * _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil NS_UNAVAILABLE;

@end
