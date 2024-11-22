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
#import <AppLovinSDK/AppLovinSDK.h>
#import <HyBidDemo-Swift.h>
#import <ChartboostSDK/Chartboost.h>

#if __has_include(<ATOM/ATOM-Swift.h>)
    #import <ATOM/ATOM-Swift.h>
#endif

#define kATOM_API_KEY @"39a34d8d-dd1d-4fbf-aa96-fdc5f0329451"

@import GoogleMobileAds;
@import Firebase;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [HyBidLogger setLogLevel:HyBidLogLevelDebug];
    [PNLiteDemoSettings sharedInstance];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:kHyBidDemoPublisherModeKey]) {
        [HyBid initWithAppToken:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoAppTokenKey] completion:nil];
    } else {
        //The following UIAlertController & SDK initialisation sequence is just for QA purposes. In real life, there's no such flow for SDK initialisation.
        [self.window makeKeyAndVisible];
        
        //Setting the appToken param here for HyBidConfigManager methods can use it.
        //Those methods are getting called before initWithAppToken: hence, no appToken to be used beforehand.
        [HyBidSDKConfig sharedConfig].appToken = [[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoAppTokenKey];
        UIAlertController *sdkConfigURLAlert = [UIAlertController alertControllerWithTitle:kHyBidSDKConfigAlertTitle
                                                                                   message:@""
                                                                            preferredStyle:UIAlertControllerStyleAlert];
        [sdkConfigURLAlert setValue:[[NSAttributedString alloc] initWithString:[PNLiteDemoSettings sharedInstance].sdkConfigAlertMessage
                                                                    attributes:[PNLiteDemoSettings sharedInstance].sdkConfigAlertAttributes]
                             forKey:@"attributedMessage"];
        
        [sdkConfigURLAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.keyboardType = UIKeyboardTypeASCIICapable;
            textField.placeholder = kHyBidSDKConfigAlertTextFieldPlaceholder;
        }];
        
        __weak UITextField *weakTextField = [sdkConfigURLAlert.textFields firstObject];
        UIAlertAction *testingURL = [UIAlertAction actionWithTitle:kHyBidSDKConfigAlertActionTitleForTesting
                                                             style:UIAlertActionStyleDestructive
                                                           handler:^(UIAlertAction *action) {
            [[HyBidConfigManager sharedManager] setHyBidConfigURLToTestingWithURL:weakTextField.text];
            [HyBid initWithAppToken:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoAppTokenKey] completion:nil];
        }];
        UIAlertAction *productionURL = [UIAlertAction actionWithTitle:kHyBidSDKConfigAlertActionTitleForProduction
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction *action) {
            [[HyBidConfigManager sharedManager] setHyBidConfigURLToProduction];
            [HyBid initWithAppToken:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoAppTokenKey] completion:nil];
        }];
        [sdkConfigURLAlert addAction:testingURL];
        [sdkConfigURLAlert addAction:productionURL];
        [self.window.rootViewController presentViewController:sdkConfigURLAlert animated:YES completion:nil];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kHyBidDemoReportingKey];
    [HyBid setReporting:YES];
    // Configure Firebase app
    [FIRApp configure];
    
    [PNLiteDemoSettings sharedInstance];
    // setLocationTracking: Allowing SDK to track location, default is true.
    [HyBid setLocationTracking:YES];
    // setLocationUpdates: Allowing SDK to update location, default is false.
    [HyBid setLocationUpdates:NO];
    
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    [Chartboost startWithAppID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidChartboostAppIDKey]
                  appSignature:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidChartboostAppSignatureKey]
                    completion:^(CHBStartError * _Nullable error) {
        if (error) {
            NSLog(@"Chartboost SDK initialization finished with error %@", error);
        } else {
            NSLog(@"Chartboost SDK initialization finished with success");
        }
    }];
    
    [HyBid setAppStoreAppID:kHyBidDemoAppID];
    [HyBid getCustomRequestSignalData];
    // FIXME: Replace OneTrust with UserCentrics
    //    [HyBidGPPSDKInitializer initOneTrustSDK];
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

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
