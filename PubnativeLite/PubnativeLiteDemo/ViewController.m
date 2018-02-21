//
//  ViewController.m
//  PubnativeLiteDemo
//
//  Created by Can Soykarafakili on 06.02.18.
//  Copyright © 2018 Can Soykarafakili. All rights reserved.
//

#import "ViewController.h"
#import <PubnativeLite/PubnativeLite.h>

@interface ViewController ()<PNLiteAdRequestDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    PNLiteBannerAdRequest *bannerAdRequest = [[PNLiteBannerAdRequest alloc] init];
    [bannerAdRequest requestAdWithDelegate:self withZoneID:@"2"];
}

- (void)requestDidStart:(PNLiteAdRequest *)request
{
    NSLog(@"Request %@ started:",request);
}

- (void)request:(PNLiteAdRequest *)request didLoadWithAd:(PNLiteAd *)ad
{
    NSLog(@"Request loaded with ad: %@",ad);
}

- (void)request:(PNLiteAdRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Request %@ failed with error: %@",request,error.localizedDescription);
}

@end
