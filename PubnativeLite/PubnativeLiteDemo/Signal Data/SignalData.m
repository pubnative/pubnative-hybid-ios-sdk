// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "SignalData.h"
#import "NSString+UnescapingString.h"

@implementation SignalData

- (instancetype)initWithSignalDataText:(NSString *)signalDataText withAdPlacement:(NSNumber *)placement {
    self = [super init];
    if (self) {
        self.text = signalDataText;
        self.placement = placement;
    }
    return self;
}

@end
