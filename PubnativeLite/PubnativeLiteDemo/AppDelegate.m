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

#import "AppDelegate.h"
#import "PNLiteDemoSettings.h"
#import <CoreLocation/CoreLocation.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
//#import "IronSource/IronSource.h"
#import <AppLovinSDK/AppLovinSDK.h>

@import GoogleMobileAds;
@import Firebase;

@interface AppDelegate ()

#if __has_include(<ATOM/ATOM.h>)
@property (nonatomic, strong) ATOMRemoteConfigVoyager *voyager;
#endif

@end

@implementation AppDelegate

CLLocationManager *locationManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [HyBidLogger setLogLevel:HyBidLogLevelDebug];
    [PNLiteDemoSettings sharedInstance];
    [HyBid initWithAppToken:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoAppTokenKey] completion:nil];
    
#if __has_include(<ATOM/ATOM.h>)
    [[HyBidRemoteConfigManager sharedInstance] initializeRemoteConfigWithCompletion:^(BOOL remoteConfigSuccess, HyBidRemoteConfigModel *remoteConfig) {
        self.voyager = [[ATOMRemoteConfigVoyager alloc] initWithDictionary:remoteConfig.dictionary[@"voyager"]];
        
        [ATOM setTestMode:YES];
        [ATOM setSessionTestMode:YES];
        
        [ATOM initWithAppToken:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoAppTokenKey] andWithRemoteConfig:self.voyager completion:^(BOOL completion) {
            ATOMAudienceController* audienceController = [[ATOMAudienceController alloc] init];
            [audienceController refreshAudience];
            
            ATOMAudienceData *audienceData = [audienceController lastKnownAudience];
            NSString* audienceText = [NSString stringWithFormat:@"Ethnicity: %@\nIncome: %@\nGender: %@\nChildren: %f\nMale: %f\nFemale: %f\nAge: %ld", audienceData.predominantEthnicity, audienceData.predominantIncome, audienceData.gender, audienceData.parentWithChildren, audienceData.male, audienceData.female, audienceData.age];
            [HyBidLogger infoLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat: @"ATOM Audience is: %@", audienceText]];
        }];
    }];
#endif
    
    // Configure Firebase app
    [FIRApp configure];
    
    [PNLiteDemoSettings sharedInstance];
    locationManager = [[CLLocationManager alloc] init];
    [locationManager requestWhenInUseAuthorization];
    // setLocationTracking: Allowing SDK to track location, default is true.
    [HyBid setLocationTracking:YES];
    // setLocationUpdates: Allowing SDK to update location, default is false.
    [HyBid setLocationUpdates:NO];
    
    if (@available(iOS 14.5, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler: ^(ATTrackingManagerAuthorizationStatus status) {
            switch (status) {
                case ATTrackingManagerAuthorizationStatusAuthorized:
                    NSLog(@"IDFA Tracking authorized.");
                    break;
                case ATTrackingManagerAuthorizationStatusDenied:
                    NSLog(@"IDFA Tracking denied.");
                    break;
                case ATTrackingManagerAuthorizationStatusRestricted:
                    NSLog(@"IDFA Tracking restricted.");
                    break;
                case ATTrackingManagerAuthorizationStatusNotDetermined:
                    NSLog(@"IDFA Tracking permission not determined.");
                    break;
                default:
                    break;
            }
        }];
    }
    
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    //[IronSource initWithAppKey:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidISAppIDKey]];
    
    [ALSdk shared].mediationProvider = @"max";
    [[ALSdk shared] initializeSdkWithCompletionHandler:^(ALSdkConfiguration *configuration) {}];
    
    [HyBid setAppStoreAppID:kHyBidDemoAppID];
    
    [HyBid setInterstitialActionBehaviour:HB_CREATIVE];
    [HyBid setVideoInterstitialSkipOffset:8];
    [HyBid setHTMLInterstitialSkipOffset:2];
    [HyBid setEndCardCloseOffset:@5];
    [HyBid setVideoAudioStatus:HyBidAudioStatusDefault];
    [HyBid setInterstitialSKOverlay:YES];
    [HyBid setRewardedSKOverlay:YES];
    
    [HyBid getCustomRequestSignalData];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
