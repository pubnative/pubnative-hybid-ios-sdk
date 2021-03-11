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
