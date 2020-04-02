//
//  Copyright © 2018 PubNative. All rights reserved.
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

#import "VrvAdFactory.h"
#import "HyBidSettings.h"
#import "LocationEncoding.h"

@implementation VrvAdFactory

- (VrvAdRequestModel *)createVrvAdRequestWithZoneID:(NSString *) zoneID withAdSize:(HyBidAdSize*) adSize {
    VrvAdRequestModel *adRequestModel = [[VrvAdRequestModel alloc] init];
    // Portal keyword
    NSString *portalKeyword = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"ipad" : @"iphn";
    adRequestModel.requestParameters[@"p"] = portalKeyword;
    // Category: Default News and Information (97)
    adRequestModel.requestParameters[@"c"] = @"97";
    // Remove iframe wrapping
    adRequestModel.requestParameters[@"iframe"] = @"false";
    // Partner keyword
    adRequestModel.requestParameters[@"b"] = [HyBidSettings sharedInstance].partnerKeyword;
    
    adRequestModel.requestParameters[@"model"] = [HyBidSettings sharedInstance].deviceName;
    adRequestModel.requestParameters[@"appid"] = [HyBidSettings sharedInstance].appBundleID;
    
    [self setIDFA:adRequestModel];
    
    if (![HyBidSettings sharedInstance].coppa) {
        adRequestModel.requestParameters[@"age"] = [[HyBidSettings sharedInstance].targeting.age stringValue];
        adRequestModel.requestParameters[@"gender"] = [HyBidSettings sharedInstance].targeting.gender;
        
        //location params
        CLLocation* location = [HyBidSettings sharedInstance].location;
        NSString* lat = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
        NSString* longi = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
        
        adRequestModel.requestParameters[@"lat"] = lat;
        adRequestModel.requestParameters[@"long"] = longi;
        adRequestModel.requestParameters[@"latlong"] = [NSString stringWithFormat:@"%@,%@", lat, longi];
        adRequestModel.requestParameters[@"ll"] =  [LocationEncoding encodeLocation: location];
    }
    
    if (![adSize.layoutSize isEqualToString:@"native"]) {
        if (adSize.width != 0 && adSize.height != 0) {
            adRequestModel.requestParameters[@"size"] = [NSString stringWithFormat:@"%ldx%ld", (long)adSize.width, (long)adSize.height];
        }
    }
    
    return adRequestModel;
}

- (void)setIDFA:(VrvAdRequestModel *)adRequestModel {
    NSString *advertisingId = [HyBidSettings sharedInstance].advertisingId;
    if (!advertisingId || advertisingId.length == 0) {
        
    } else {
        adRequestModel.requestParameters[@"ui"] = advertisingId;
        adRequestModel.requestParameters[@"uis"] = @"a";
    }
}

@end
