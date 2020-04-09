//
//  AdSdkDemoSettings.m
//  HyBidDemoObjc
//
//  Created by Fares Ben Hamouda on 09.04.20.
//  Copyright © 2020 Fares Ben Hamouda. All rights reserved.
//

#import "AdSdkDemoSettings.h"

NSString *const DemoAppToken = @"543027b8e954474cbcd9a98481622a3b";
NSString *const DemoPartnerKeyword = @"adsdksponsor";


@implementation AdSdkDemoSettings

- (void)dealloc
{
    self.appToken = nil;
    self.partnerKeyword = nil;
}

+ (AdSdkDemoSettings *)sharedInstance {
    static AdSdkDemoSettings * _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[AdSdkDemoSettings alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.appToken = DemoAppToken;
        self.partnerKeyword = DemoPartnerKeyword;
    }
    return self;
}
@end
