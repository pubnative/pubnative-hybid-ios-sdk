//
//  VrvAdFactory.m
//  HyBid
//
//  Created by Eros Garcia Ponte on 23.03.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import "VrvAdFactory.h"
#import "HyBidSettings.h"

@implementation VrvAdFactory

- (VrvAdRequestModel *)createVrvAdRequestWithZoneID:(NSString *)zoneID withAdSize:(HyBidAdSize)adSize {
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
    }
    
    if (![adSize.adLayoutSize isEqualToString:@"native"]) {
        if (adSize.width != 0 && adSize.height != 0) {
            adRequestModel.requestParameters[@"size"] = [NSString stringWithFormat:@"%ldx%ld", adSize.width, adSize.height];
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
