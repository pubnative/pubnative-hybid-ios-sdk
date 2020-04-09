//
//  AdSdkDemoSettings.h
//  HyBidDemoObjc
//
//  Created by Fares Ben Hamouda on 09.04.20.
//  Copyright © 2020 Fares Ben Hamouda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HyBid/HyBid.h>

@interface AdSdkDemoSettings : NSObject

@property (nonatomic, strong) NSString *appToken;
@property (nonatomic, strong) NSString *partnerKeyword;

+ (AdSdkDemoSettings *)sharedInstance;

@end
