// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVGIUser.h"
#import "HyBidVGIMacros.h"

@implementation HyBidVGIUser

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
    self.SUID = json[@"SUID"];
    
    NSArray *audiences = [json objectForKey:@"audiences"];
    NSMutableArray *newAudiences = [[NSMutableArray alloc] init];
    for (id audience in audiences) {
        HyBidVGIAudience *newAudience = [[HyBidVGIAudience alloc] initWithJSON:audience];
        [newAudiences addObject:newAudience];
    }
    self.audiences = newAudiences;
    
    NSArray *emails = [json objectForKey:@"emails"];
    NSMutableArray *newEmails = [[NSMutableArray alloc] init];
    for (id email in emails) {
        HyBidVGIEmail *newEmail = [[HyBidVGIEmail alloc] initWithJSON:email];
        [newEmails addObject:newEmail];
    }
    self.emails = newEmails;
    
    NSArray *locations = [json objectForKey:@"locations"];
    NSMutableArray *newLocations = [[NSMutableArray alloc] init];
    for (id location in locations) {
        HyBidVGILocation *newLocation = [[HyBidVGILocation alloc] initWithJSON:location];
        [newLocations addObject:newLocation];
    }
    self.locations = newLocations;
    
    self.vendor = [[HyBidVGIUserVendor alloc] initWithJSON:json[@"vendors"]];
}

- (NSDictionary *)dictionary
{
    NSMutableArray *emailsDict = [[NSMutableArray alloc] init];
    for (HyBidVGIEmail *email in self.emails) {
        [emailsDict addObject:email.dictionary];
    }
    
    NSMutableArray *locationsDict = [[NSMutableArray alloc] init];
    for (HyBidVGILocation *location in self.locations) {
        [locationsDict addObject:location.dictionary];
    }
    
    NSMutableArray *audiencesDict = [[NSMutableArray alloc] init];
    for (HyBidVGIAudience *audience in self.audiences) {
        [audiencesDict addObject:audience.dictionary];
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:NSNullIfEmpty(self.SUID), @"SUID", NSNullIfDictionaryEmpty(emailsDict), @"emails", NSNullIfDictionaryEmpty(locationsDict), @"locations", NSNullIfDictionaryEmpty(audiencesDict), @"audiences", NSNullIfDictionaryEmpty(self.vendor.dictionary), @"vendors", nil];
}

@end
