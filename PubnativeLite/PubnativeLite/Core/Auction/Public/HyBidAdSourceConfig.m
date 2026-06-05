//// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidAdSourceConfig.h"
#import "HyBidAdSourceConfigParameter.h"

@implementation HyBidAdSourceConfig

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            self.eCPM = [dictionary[HyBidAdSourceConfigParameter.eCPM] doubleValue];
            self.enabled = [dictionary[HyBidAdSourceConfigParameter.enabled] boolValue];
            
            if ([[dictionary objectForKey:HyBidAdSourceConfigParameter.name] respondsToSelector:@selector(stringValue)]) {
                self.name = [dictionary[HyBidAdSourceConfigParameter.name] stringValue];
            }
            else {
                self.name = dictionary[HyBidAdSourceConfigParameter.name];
            }
            
            if ([[dictionary objectForKey:HyBidAdSourceConfigParameter.vastTagUrl] respondsToSelector:@selector(stringValue)]) {
                self.vastTagUrl = [dictionary[HyBidAdSourceConfigParameter.vastTagUrl] stringValue];
            }
            else {
                self.vastTagUrl = dictionary[HyBidAdSourceConfigParameter.vastTagUrl];
            }
            
            if ([[dictionary objectForKey:HyBidAdSourceConfigParameter.type] respondsToSelector:@selector(stringValue)]) {
                self.type = [dictionary[HyBidAdSourceConfigParameter.type] stringValue];
            }
            else {
                self.type = dictionary[HyBidAdSourceConfigParameter.type];
            }
        }
    }
    return self;
}

@end
