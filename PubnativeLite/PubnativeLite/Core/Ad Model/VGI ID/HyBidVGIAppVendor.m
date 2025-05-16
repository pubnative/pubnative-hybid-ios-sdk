// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVGIAppVendor.h"
#import "HyBidVGIMacros.h"

@implementation HyBidVGIAppVendor

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
    self.LR = [[HyBidVGILr alloc] initWithJSON:json[@"LR"]];
    self.TTD = [[HyBidVGITtd alloc] initWithJSON:json[@"TTD"]];
}

- (NSDictionary *)dictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:NSNullIfDictionaryEmpty(self.APL.dictionary), @"APL", NSNullIfDictionaryEmpty(self.LR.dictionary), @"LR", NSNullIfDictionaryEmpty(self.TTD.dictionary), @"TTD", nil];
}

@end
