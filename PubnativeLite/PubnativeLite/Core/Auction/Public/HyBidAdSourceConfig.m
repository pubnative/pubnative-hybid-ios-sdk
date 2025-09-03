//// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidAdSourceConfig.h"
#import "AdSourceConfigParameter.h"

@implementation HyBidAdSourceConfig

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            self.eCPM = [dictionary[AdSourceConfigParameter.eCPM] doubleValue];
            self.enabled = [dictionary[AdSourceConfigParameter.enabled] boolValue];
            
            if ([[dictionary objectForKey:AdSourceConfigParameter.name] respondsToSelector:@selector(stringValue)]) {
                self.name = [dictionary[AdSourceConfigParameter.name] stringValue];
            }
            else {
                self.name = dictionary[AdSourceConfigParameter.name];
            }
            
            if ([[dictionary objectForKey:AdSourceConfigParameter.vastTagUrl] respondsToSelector:@selector(stringValue)]) {
                self.vastTagUrl = [dictionary[AdSourceConfigParameter.vastTagUrl] stringValue];
            }
            else {
                self.vastTagUrl = dictionary[AdSourceConfigParameter.vastTagUrl];
            }
            
            if ([[dictionary objectForKey:AdSourceConfigParameter.type] respondsToSelector:@selector(stringValue)]) {
                self.type = [dictionary[AdSourceConfigParameter.type] stringValue];
            }
            else {
                self.type = dictionary[AdSourceConfigParameter.type];
            }
        }
    }
    return self;
}

@end
