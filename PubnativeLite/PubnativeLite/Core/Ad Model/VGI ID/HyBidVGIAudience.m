// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVGIAudience.h"
#import "HyBidVGIMacros.h"

@implementation HyBidVGIAudience

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
    self.ID = json[@"id"];
    self.ts = json[@"ts"];
    self.type = json[@"type"];
}

- (NSDictionary *)dictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:NSNullIfEmpty(self.ID), @"id", NSNullIfEmpty(self.ts), @"ts", NSNullIfEmpty(self.type), @"type", nil];
}

@end
