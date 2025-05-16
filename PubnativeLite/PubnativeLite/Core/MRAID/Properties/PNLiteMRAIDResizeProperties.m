// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "PNLiteMRAIDResizeProperties.h"

@implementation PNLiteMRAIDResizeProperties

- (id)init {
    self = [super init];
    if (self) {
        _width = 0;
        _height = 0;
        _offsetX = 0;
        _offsetY = 0;
        _customClosePosition = PNLiteMRAIDCustomClosePositionTopRight;
        _allowOffscreen = YES;
    }
    return self;
}

+ (PNLiteMRAIDCustomClosePosition)MRAIDCustomClosePositionFromString:(NSString *)s {
    NSArray *names = @[
                       @"top-left",
                       @"top-center",
                       @"top-right",
                       @"center",
                       @"bottom-left",
                       @"bottom-center",
                       @"bottom-right"
                       ];
    NSUInteger i = [names indexOfObject:s];
    if (i != NSNotFound) {
        return (PNLiteMRAIDCustomClosePosition)i;
    }
    // Use top-right for the default value
    return PNLiteMRAIDCustomClosePositionTopRight;;
}

@end
