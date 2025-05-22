// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVGIApl.h"
#import "HyBidVGIMacros.h"

@implementation HyBidVGIApl

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
    self.IDFA = json[@"IDFA"];
    self.IDFV = json[@"IDFV"];
}

- (NSDictionary *)dictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:NSNullIfEmpty(self.IDFA), @"IDFA", NSNullIfEmpty(self.IDFV), @"IDFV", nil];
}

@end
