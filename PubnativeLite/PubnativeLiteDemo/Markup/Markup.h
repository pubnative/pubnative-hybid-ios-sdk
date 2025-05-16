// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidAd.h"

@interface Markup : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic) HyBidMarkupPlacement placement;

- (instancetype)initWithMarkupText:(NSString *)markupText withAdPlacement:(HyBidMarkupPlacement)placement;

@end
