// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVGIDevice.h"
#import "HyBidVGIMacros.h"

@implementation HyBidVGIDevice

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
    self.manufacture = json[@"manufacture"];
    self.brand = json[@"brand"];
    self.model = json[@"model"];
    
    self.battery = [[HyBidVGIBattery alloc] initWithJSON:json[@"battery"]];
    self.OS = [[HyBidVGIOS alloc] initWithJSON:json[@"os"]];
}

- (NSDictionary *)dictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:NSNullIfEmpty(self.ID), @"id", NSNullIfDictionaryEmpty(self.OS.dictionary), @"os", NSNullIfEmpty(self.manufacture), @"manufacture", NSNullIfEmpty(self.model), @"model", NSNullIfEmpty(self.brand), @"brand", NSNullIfDictionaryEmpty(self.battery.dictionary), @"battery", nil];
}

@end
