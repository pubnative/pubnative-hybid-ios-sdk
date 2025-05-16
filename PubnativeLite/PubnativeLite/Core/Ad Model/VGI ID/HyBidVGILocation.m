// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVGILocation.h"
#import "HyBidVGIMacros.h"

@implementation HyBidVGILocation

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
    self.accuracy = json[@"accuracy"];
    self.lat = json[@"lat"];
    self.lon = json[@"long"];
    self.ts = json[@"ts"];
}

- (NSDictionary *)dictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:NSNullIfEmpty(self.accuracy), @"accuracy", NSNullIfEmpty(self.lat), @"lat", NSNullIfEmpty(self.lon), @"long", NSNullIfEmpty(self.ts), @"ts", nil];
}

@end
