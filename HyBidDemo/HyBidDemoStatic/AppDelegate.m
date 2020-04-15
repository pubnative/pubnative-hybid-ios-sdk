//
//  AppDelegate.m
//  HyBidDemoStatic
//
//  Created by Fares Ben Hamouda on 15.04.20.
//  Copyright © 2020 Fares Ben Hamouda. All rights reserved.
//

#import "AppDelegate.h"
#import <HyBidStatic/HyBid.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [HyBid initWithAppToken:@"543027b8e954474cbcd9a98481622a3b" completion:^(BOOL success) {
        if (success) {
            [HyBidLogger setLogLevel:HyBidLogLevelDebug];
            NSLog(@"HyBid initialisation completed");
        }
    }];
    HyBidTargetingModel *targetingModel = [[HyBidTargetingModel alloc] init];
    targetingModel.age = [NSNumber numberWithInt:29];
    targetingModel.gender = @"m";
    [HyBid setTargeting: targetingModel];
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
