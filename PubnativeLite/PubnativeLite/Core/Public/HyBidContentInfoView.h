// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <UIKit/UIKit.h>
#import "HyBidVASTIconViewTracking.h"
#import "HyBidVASTIconClickTracking.h"

@class HyBidContentInfoView;

typedef enum {
    HyBidContentInfoClickActionExpand,
    HyBidContentInfoClickActionOpen
} HyBidContentInfoClickAction;

typedef enum {
    HyBidContentInfoDisplayInApp,
    HyBidContentInfoDisplaySystem
} HyBidContentInfoDisplay;

typedef enum {
    HyBidContentInfoHorizontalPositionLeft,
    HyBidContentInfoHorizontalPositionRight
} HyBidContentInfoHorizontalPosition;

typedef enum {
    HyBidContentInfoVerticalPositionTop,
    HyBidContentInfoVerticalPositionBottom
} HyBidContentInfoVerticalPosition;

@protocol HyBidContentInfoViewDelegate<NSObject>

- (void)contentInfoViewWidthNeedsUpdate:(NSNumber *)width;

@end

@interface HyBidContentInfoView : UIView

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *zoneID;
@property (nonatomic) BOOL isCustom;
@property (nonatomic, strong) NSArray<HyBidVASTIconViewTracking *> *viewTrackers;
@property (nonatomic, strong) NSArray<HyBidVASTIconClickTracking *> *clickTrackers;
@property (nonatomic, weak) NSObject <HyBidContentInfoViewDelegate> *delegate;
@property (nonatomic) HyBidContentInfoClickAction clickAction;
@property (nonatomic) HyBidContentInfoDisplay display;
@property (nonatomic) HyBidContentInfoHorizontalPosition horizontalPosition;
@property (nonatomic) HyBidContentInfoVerticalPosition verticalPosition;

- (void)setIconSize:(CGSize) size;
- (void)setElementsOrientation:(HyBidContentInfoHorizontalPosition) orientation;
- (CGSize)getValidIconSizeWith:(CGSize)size;

@end
