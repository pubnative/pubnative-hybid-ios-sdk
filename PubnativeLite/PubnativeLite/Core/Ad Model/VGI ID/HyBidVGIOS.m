// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVGIOS.h"
#import "HyBidVGIMacros.h"

@implementation HyBidVGIOS

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
    self.buildSignature = json[@"build_signature"];
    self.name = json[@"name"];
    self.version = json[@"version"];
}

- (NSDictionary *)dictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:NSNullIfEmpty(self.buildSignature), @"build_signature", NSNullIfEmpty(self.name), @"name", NSNullIfEmpty(self.version), @"version", nil];
}

@end
