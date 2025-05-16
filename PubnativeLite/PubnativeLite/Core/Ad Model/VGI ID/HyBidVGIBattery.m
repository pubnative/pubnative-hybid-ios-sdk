// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVGIBattery.h"
#import "HyBidVGIMacros.h"

@implementation HyBidVGIBattery

- (instancetype)initWithJSON:(id)json
{
    self = [super init];
    if (self) {
        [self bindPropertiesFromJSON:json];
    }
    return self;
}

-(void)bindPropertiesFromJSON:(id)json
{
    self.capacity = json[@"capacity"];
}

- (NSDictionary *)dictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:NSNullIfEmpty(self.capacity), @"capacity", nil];
}

@end
