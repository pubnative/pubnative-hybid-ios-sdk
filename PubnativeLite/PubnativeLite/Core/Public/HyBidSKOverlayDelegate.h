// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

typedef enum : NSUInteger {
    HyBidSKOverlayAutomaticCLickVideo = 1 << 0,
    HyBidSKOverlayAutomaticCLickDefaultEndCard = 1 << 1,
    HyBidSKOverlayAutomaticCLickCustomEndCard = 1 << 2
} HyBidSKOverlayAutomaticCLickType;

@protocol HyBidSKOverlayDelegate <NSObject>
@optional
- (void)skoverlayDidShowOnCreative:(BOOL)isFirstPresentation;
@end
