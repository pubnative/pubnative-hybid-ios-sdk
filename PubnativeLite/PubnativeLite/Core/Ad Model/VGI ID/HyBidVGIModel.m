// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVGIModel.h"
#import "HyBidVGIMacros.h"

@implementation HyBidVGIModel

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
    NSArray *apps = [json objectForKey:@"apps"];
    NSMutableArray *newApps = [[NSMutableArray alloc] init];
    for (id app in apps) {
        HyBidVGIApp *newApp = [[HyBidVGIApp alloc] initWithJSON:app];
        [newApps addObject:newApp];
    }
    self.apps = newApps;
    
    id device = [json objectForKey:@"device"];
    HyBidVGIDevice *newDevice= [[HyBidVGIDevice alloc] initWithJSON:device];
    self.device = newDevice;
    
    NSArray *users = [json objectForKey:@"users"];
    NSMutableArray *newUsers = [[NSMutableArray alloc] init];
    for (id user in users) {
        HyBidVGIUser *newUser = [[HyBidVGIUser alloc] initWithJSON:user];
        [newUsers addObject:newUser];
    }
    self.users = newUsers;
}

- (NSDictionary *)dictionary
{
    NSMutableArray *appsDict = [[NSMutableArray alloc] init];
    for (HyBidVGIApp *app in self.apps) {
        [appsDict addObject:app.dictionary];
    }
    
    NSMutableArray *usersDict = [[NSMutableArray alloc] init];
    for (HyBidVGIUser *user in self.users) {
        [usersDict addObject:user.dictionary];
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:NSNullIfDictionaryEmpty(appsDict), @"apps", NSNullIfDictionaryEmpty(usersDict), @"users", NSNullIfDictionaryEmpty(self.device.dictionary), @"device", nil];
}

@end
