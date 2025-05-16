// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BannerAdViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *bannerAdViewContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bannerAdViewLoaderIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerAdContainerWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bannerAdContainerHeightConstraint;

@end

NS_ASSUME_NONNULL_END
