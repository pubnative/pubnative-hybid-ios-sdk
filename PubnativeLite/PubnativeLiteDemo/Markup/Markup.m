// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "Markup.h"
#import "NSString+UnescapingString.h"

@implementation Markup

- (instancetype)initWithMarkupText:(NSString *)markupText withAdPlacement:(HyBidMarkupPlacement)placement
{
    self = [super init];
    if (self) {
        self.text = markupText;
        self.placement = placement;
    }
    return self;
}

@end
