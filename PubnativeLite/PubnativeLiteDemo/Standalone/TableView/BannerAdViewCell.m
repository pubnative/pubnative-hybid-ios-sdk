// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "BannerAdViewCell.h"

@implementation BannerAdViewCell

- (void)layoutSubviews
{
    [self setAccessibilityElements:self.bannerAdViewContainer.subviews];
    [self.bannerAdViewContainer setIsAccessibilityElement:NO];
    [self.bannerAdViewContainer setAccessibilityContainerType:UIAccessibilityContainerTypeSemanticGroup];
}

@end
