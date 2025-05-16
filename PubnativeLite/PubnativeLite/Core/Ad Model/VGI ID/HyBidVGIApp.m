// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVGIApp.h"
#import "HyBidVGIAppUser.h"
#import "HyBidVGIPrivacy.h"
#import "HyBidVGIMacros.h"

@implementation HyBidVGIApp

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
    self.bundleID = json[@"bundle_id"];
    self.privacy = [[HyBidVGIPrivacy alloc] initWithJSON:json[@"privacy"]];
    
    NSMutableArray *newUsers = [[NSMutableArray alloc] init];
    for (id user in json[@"users"]) {
        HyBidVGIAppUser *newUser = [[HyBidVGIAppUser alloc] initWithJSON:user];
        [newUsers addObject:newUser];
    }
    self.users = newUsers;
}

- (NSDictionary *)dictionary
{
    NSMutableArray *usersDict = [[NSMutableArray alloc] init];
    for (HyBidVGIAppUser *user in self.users) {
        [usersDict addObject:user.dictionary];
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:NSNullIfEmpty(self.bundleID), @"bundle_id", usersDict, @"users", NSNullIfDictionaryEmpty(self.privacy.dictionary), @"privacy", nil];
}


@end
