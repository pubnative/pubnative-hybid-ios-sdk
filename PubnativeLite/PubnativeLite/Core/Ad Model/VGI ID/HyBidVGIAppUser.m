// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVGIAppUser.h"
#import "HyBidVGIMacros.h"

@implementation HyBidVGIAppUser

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
    self.AUID = json[@"AUID"];
    self.SUID = json[@"SUID"];
    self.vendor = [[HyBidVGIAppVendor alloc] initWithJSON:json[@"vendors"]];
}

- (NSDictionary *)dictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:NSNullIfEmpty(self.AUID), @"AUID", NSNullIfEmpty(self.SUID), @"SUID", NSNullIfDictionaryEmpty(self.vendor.dictionary), @"vendors", nil];
}

@end
