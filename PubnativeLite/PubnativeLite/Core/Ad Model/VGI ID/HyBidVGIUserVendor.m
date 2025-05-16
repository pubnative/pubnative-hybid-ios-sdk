// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVGIUserVendor.h"
#import "HyBidVGIMacros.h"

@implementation HyBidVGIUserVendor

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
    self.APL = [[HyBidVGIApl alloc] initWithJSON:json[@"APL"]];
    self.GGL = [[HyBidVGIGgl alloc] initWithJSON:json[@"GGL"]];
}

- (NSDictionary *)dictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:NSNullIfDictionaryEmpty(self.APL.dictionary), @"APL", NSNullIfDictionaryEmpty(self.GGL.dictionary), @"GGL", nil];
}

@end
