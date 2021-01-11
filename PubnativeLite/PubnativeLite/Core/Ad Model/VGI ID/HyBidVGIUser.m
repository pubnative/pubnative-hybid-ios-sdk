//
//  Copyright © 2020 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
