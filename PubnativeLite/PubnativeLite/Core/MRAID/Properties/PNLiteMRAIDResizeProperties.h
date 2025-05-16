// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

typedef enum {
    PNLiteMRAIDCustomClosePositionTopLeft,
    PNLiteMRAIDCustomClosePositionTopCenter,
    PNLiteMRAIDCustomClosePositionTopRight,
    PNLiteMRAIDCustomClosePositionCenter,
    PNLiteMRAIDCustomClosePositionBottomLeft,
    PNLiteMRAIDCustomClosePositionBottomCenter,
    PNLiteMRAIDCustomClosePositionBottomRight
} PNLiteMRAIDCustomClosePosition;

@interface PNLiteMRAIDResizeProperties : NSObject

@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) int offsetX;
@property (nonatomic, assign) int offsetY;
@property (nonatomic, assign) PNLiteMRAIDCustomClosePosition customClosePosition;
@property (nonatomic, assign) BOOL allowOffscreen;

+ (PNLiteMRAIDCustomClosePosition)MRAIDCustomClosePositionFromString:(NSString *)s;

@end
