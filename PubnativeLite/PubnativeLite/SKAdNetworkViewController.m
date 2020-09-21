//
//  SKAdNetworkViewController.m
//  HyBid
//
//  Created by Orkhan Alizada on 21.09.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import "SKAdNetworkViewController.h"

@implementation SKAdNetworkViewController

- (id)initWithProductParameters:(NSDictionary*)data {
    self = [super init];
    self->productParameters = data;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadProductWithParameters:self->productParameters completionBlock:^(BOOL result, NSError * _Nullable error) {
        if (error || !result){
            NSLog(@"Loading the ad failed, try to load another ad or retry the current ad.");
        }
    }];
}

@end
