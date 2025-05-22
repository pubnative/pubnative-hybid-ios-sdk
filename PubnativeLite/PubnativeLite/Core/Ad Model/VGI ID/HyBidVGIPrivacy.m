// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVGIPrivacy.h"
#import "HyBidVGIMacros.h"

@implementation HyBidVGIPrivacy

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
    self.iabCCPA = json[@"iab_ccpa"];
    self.lat = json[@"lat"];
    self.TCFv1 = json[@"tcfv1"];
    self.TCFv2 = json[@"tcfv2"];
}

- (NSDictionary *)dictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:NSNullIfEmpty(self.TCFv1), @"tcfv1", NSNullIfEmpty(self.TCFv2), @"tcfv2", NSNullIfEmpty(self.iabCCPA), @"iab_ccpa", NSNullIfEmpty(self.lat), @"lat", nil];
}

@end
