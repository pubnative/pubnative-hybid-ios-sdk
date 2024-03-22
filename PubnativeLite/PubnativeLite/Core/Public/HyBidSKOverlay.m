//
//  Copyright © 2021 PubNative. All rights reserved.
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

#import "HyBidSKOverlay.h"
#import "HyBidSKAdNetworkParameter.h"
#import "UIApplication+PNLiteTopViewController.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

#define SKOVERLAY_AUTOCLOSE_MAXIMUM_VALUE 60
#define SKOVERLAY_DELAY_MAXIMUM_VALUE 60
#define SKOVERLAY_ENDCARDDELAY_MAXIMUM_VALUE 60

@interface HyBidSKOverlay() <SKOverlayDelegate>

@property (nonatomic, strong) SKOverlay *overlay API_AVAILABLE(ios(14.0));
@property (nonatomic, assign) BOOL isOverlayShown;
@property (nonatomic, assign) BOOL isSecondViewPrepared;
@property (nonatomic, strong) HyBidAd *ad;

@property (nonatomic, assign) BOOL autoClosePerformsDefaultBehaviour;
@property (nonatomic, assign) NSInteger autoCloseOffset;
@property (nonatomic, strong) NSTimer *autoCloseTimer;
@property (nonatomic, assign) NSInteger autoCloseTimeRemaining;
@property (nonatomic, assign) BOOL autoCloseTimerCompleted;
@property (nonatomic, assign) BOOL autoCloseTimerNeeded;

@property (nonatomic, assign) BOOL delayPerformsDefaultBehaviour;
@property (nonatomic, assign) NSInteger delayOffset;
@property (nonatomic, strong) NSTimer *delayTimer;
@property (nonatomic, assign) NSInteger delayTimeRemaining;
@property (nonatomic, assign) BOOL delayTimerCompleted;
@property (nonatomic, assign) BOOL delayTimerNeeded;

@property (nonatomic, assign) BOOL endCardDelayPerformsDefaultBehaviour;
@property (nonatomic, assign) NSInteger endCardDelayOffset;
@property (nonatomic, strong) NSTimer *endCardDelayTimer;
@property (nonatomic, assign) NSInteger endCardDelayTimeRemaining;
@property (nonatomic, assign) BOOL endCardDelayTimerCompleted;
@property (nonatomic, assign) BOOL endCardReadyToShow;

@property (nonatomic, assign) BOOL isRewarded;
@property (nonatomic, assign) BOOL impressionEventFired;

@end

@implementation HyBidSKOverlay

- (void)dealloc {
    self.ad = nil;
    if (@available(iOS 14.0, *)) {
        if (self.overlay) {
            self.overlay = nil;
        }
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"SKOverlay is available from iOS 14.0"];
    }
}

- (instancetype)initWithAd:(HyBidAd *)ad isRewarded:(BOOL)isRewarded {
    self = [super init];
    if (self) {
        if (@available(iOS 14.0, *)) {
            self.ad = ad;
            self.isRewarded = isRewarded;
            HyBidSkAdNetworkModel* skAdNetworkModel = self.ad.isUsingOpenRTB ? [self.ad getOpenRTBSkAdNetworkModel] : [self.ad getSkAdNetworkModel];
            SKOverlayPosition position = SKOverlayPositionBottom;
            BOOL userDismissible = YES;
            if ([HyBidSKOverlay isValidToCreateSKOverlayWithModel: skAdNetworkModel]) {
                if ([skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.dismissible] != [NSNull null] && [skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.dismissible]) {
                    userDismissible = [[skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.dismissible] boolValue];
                }
                if ([skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.position] != [NSNull null] && [skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.position]) {
                    position = [[skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.position] boolValue] ? SKOverlayPositionBottom : SKOverlayPositionBottomRaised;
                }
                NSString *appIdentifier = [skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.itunesitem];
                SKOverlayAppConfiguration *configuration = [[SKOverlayAppConfiguration alloc]
                                                            initWithAppIdentifier:appIdentifier
                                                            position:position];
                configuration.userDismissible = userDismissible;
                self.overlay = [[SKOverlay alloc] initWithConfiguration:configuration];
                self.overlay.delegate = self;
                [self determineAutoCloseOffsetAndBehaviour:skAdNetworkModel];
                [self determineDelayOffsetAndBehaviour:skAdNetworkModel];
                [self determineEndCardDelayOffsetAndBehaviour:skAdNetworkModel];
            }
        } else {
            [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"SKOverlay is available from iOS 14.0"];
        }
    }
    return self;
}

+ (BOOL)isValidToCreateSKOverlayWithModel:(HyBidSkAdNetworkModel *)skAdNetworkModel {
    if (!skAdNetworkModel) {
        return NO;
    }
    
    NSString *appIdentifier = [skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.itunesitem];
    if ([appIdentifier isKindOfClass:[NSString class]]) {
        if (appIdentifier && appIdentifier.length > 0) {
            if ([skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.present] != [NSNull null] && [skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.present] && ![[skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.present] boolValue]) {
                [HyBidLogger warningLogFromClass:NSStringFromClass([HyBidSKOverlay class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Parameter \"present\" is specifically set to NO, will not create SKOverlay."];
                return NO;
            }
        } else {
            [HyBidLogger warningLogFromClass:NSStringFromClass([HyBidSKOverlay class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Parameter \"itunesitem\" is not valid, can not create SKOverlay."];
            return NO;
        }
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([HyBidSKOverlay class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Parameter \"itunesitem\" is not valid, can not create SKOverlay."];
        return NO;
    }
    
    return YES;
}

- (void)determineAutoCloseOffsetAndBehaviour:(HyBidSkAdNetworkModel *)skAdNetworkModel {
    if ([skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.autoClose] != [NSNull null]) {
        self.autoCloseOffset = [[skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.autoClose] integerValue];
        if (self.autoCloseOffset && self.autoCloseOffset > 0) {
            self.autoClosePerformsDefaultBehaviour = NO;
            if (self.autoCloseOffset > SKOVERLAY_AUTOCLOSE_MAXIMUM_VALUE) {
                self.autoCloseOffset = SKOVERLAY_AUTOCLOSE_MAXIMUM_VALUE;
            }
            self.autoCloseTimeRemaining = self.autoCloseOffset;
            [self updateTimerStateWithRemainingSeconds:self.autoCloseOffset
                                        withTimerState:HyBidTimerState_Pause
                                          forTimerType:HyBidSKOverlayTimerType_AutoClose];
        } else {
            self.autoClosePerformsDefaultBehaviour = YES;
        }
    } else {
        self.autoClosePerformsDefaultBehaviour = YES;
    }
}

- (void)determineDelayOffsetAndBehaviour:(HyBidSkAdNetworkModel *)skAdNetworkModel {
    self.delayTimerNeeded = YES;
    if ([skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.delay] != [NSNull null]) {
        self.delayOffset = [[skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.delay] integerValue];
        if (self.delayOffset && self.delayOffset > 0) {
            self.delayPerformsDefaultBehaviour = NO;
            if (self.delayOffset > SKOVERLAY_DELAY_MAXIMUM_VALUE) {
                self.delayOffset = SKOVERLAY_DELAY_MAXIMUM_VALUE;
            }
            self.delayTimeRemaining = self.delayOffset;
            [self updateTimerStateWithRemainingSeconds:self.delayOffset
                                        withTimerState:HyBidTimerState_Pause
                                          forTimerType:HyBidSKOverlayTimerType_Delay];
        } else {
            self.delayPerformsDefaultBehaviour = YES;
        }
    } else {
        self.delayPerformsDefaultBehaviour = YES;
    }
}

- (void)determineEndCardDelayOffsetAndBehaviour:(HyBidSkAdNetworkModel *)skAdNetworkModel {
    self.endCardReadyToShow = NO;
    if ([skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.endcardDelay] != [NSNull null]) {
        self.endCardDelayOffset = [[skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.endcardDelay] integerValue];
        if (self.endCardDelayOffset && self.endCardDelayOffset == -1) {
            return;
        } else if (self.endCardDelayOffset && (self.endCardDelayOffset > 0 || !(self.endCardDelayOffset < -1))) {
            self.endCardDelayPerformsDefaultBehaviour = NO;
            if (self.endCardDelayOffset > SKOVERLAY_ENDCARDDELAY_MAXIMUM_VALUE) {
                self.endCardDelayOffset = SKOVERLAY_ENDCARDDELAY_MAXIMUM_VALUE;
            }
            self.endCardDelayTimeRemaining = self.endCardDelayOffset;
            [self updateTimerStateWithRemainingSeconds:self.endCardDelayOffset
                                        withTimerState:HyBidTimerState_Pause
                                          forTimerType:HyBidSKOverlayTimerType_EndCardDelay];
        } else {
            self.endCardDelayPerformsDefaultBehaviour = YES;
        }
    } else {
        self.endCardDelayPerformsDefaultBehaviour = YES;
    }
}

#pragma mark Observers

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(vastEndCardWillShow:)
                                                 name:@"VASTEndCardWillShow"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(skStoreProductViewIsReadyToPresent:)
                                                 name:@"SKStoreProductViewIsReadyToPresent"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(skStoreProductViewIsReadyToPresentForSdkStorekit:)
                                                 name:@"SKStoreProductViewIsReadyToPresentForSDKStorekit"
                                               object:nil];
    
   [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(skStoretoreProductViewIsDismissed:)
                                                 name:@"SKStoreProductViewIsDismissed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(feedbackScreenWillShow:)
                                                 name:@"adFeedbackViewWillShow"
                                               object:nil];
            
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(feedbackScreenIsDismissed:)
                                                 name:@"adFeedbackViewIsDismissed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];;
}

#pragma mark HyBidVASTEndCard Notifications

- (void)vastEndCardWillShow:(NSNotification *)notification {
    self.endCardReadyToShow = YES;
    [self updateTimerStateWithRemainingSeconds:[self getRemainingTimeForTimerType:HyBidSKOverlayTimerType_EndCardDelay]
                                withTimerState:HyBidTimerState_Start
                                  forTimerType:HyBidSKOverlayTimerType_EndCardDelay];
}

#pragma mark SKStoreProductView Notifications
- (void)skStoreProductViewIsReadyToPresentForSdkStorekit:(NSNotification *)notification {
    self.isSecondViewPrepared = YES;
    [self dismissEntirely:NO withAd:self.ad causedByAutoCloseTimerCompletion:NO];
}

- (void)skStoreProductViewIsReadyToPresent:(NSNotification *)notification {
    self.isSecondViewPrepared = YES;
    [self dismissEntirely:NO withAd:self.ad causedByAutoCloseTimerCompletion:NO];
}

- (void)skStoretoreProductViewIsDismissed:(NSNotification *)notification {
    HyBidAd *ad = notification.object;
    [self presentWithAd:ad];
}

#pragma mark SKOverlay Manipulations

- (void)presentWithAd:(HyBidAd *)ad {
    self.isSecondViewPrepared = NO;
    if (ad.skoverlayEnabled) {
        if ([ad.skoverlayEnabled boolValue]) {
            [self checkSKOverlayAvailabilityAndPresent];
        }
    }
}

- (void)checkSKOverlayAvailabilityAndPresent {
    if (@available(iOS 14.0, *)) {
        if (self.overlay) {
            if (!self.isOverlayShown) {
                if(self.delayTimerNeeded) {
                    if(self.delayTimerCompleted || self.delayPerformsDefaultBehaviour) {
                        [self.overlay presentInScene:[UIApplication sharedApplication].topViewController.view.window.windowScene];
                    } else {
                        [self updateTimerStateWithRemainingSeconds:[self getRemainingTimeForTimerType:HyBidSKOverlayTimerType_Delay]
                                                    withTimerState:HyBidTimerState_Start
                                                      forTimerType:HyBidSKOverlayTimerType_Delay];
                    }
                }
                if(self.autoCloseTimerNeeded && (!self.autoCloseTimerCompleted && !self.autoClosePerformsDefaultBehaviour)) {
                    [self updateTimerStateWithRemainingSeconds:[self getRemainingTimeForTimerType:HyBidSKOverlayTimerType_AutoClose]
                                                withTimerState:HyBidTimerState_Start
                                                  forTimerType:HyBidSKOverlayTimerType_AutoClose];
                }
                if(self.endCardReadyToShow) {
                    if(self.endCardDelayTimerCompleted || self.endCardDelayPerformsDefaultBehaviour) {
                        [self.overlay presentInScene:[UIApplication sharedApplication].topViewController.view.window.windowScene];
                    } else {
                        [self updateTimerStateWithRemainingSeconds:[self getRemainingTimeForTimerType:HyBidSKOverlayTimerType_EndCardDelay]
                                                    withTimerState:HyBidTimerState_Start
                                                      forTimerType:HyBidSKOverlayTimerType_EndCardDelay];
                    }
                }
            }
        }
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"SKOverlay is available from iOS 14.0"];
    }
}

- (void)dismissEntirely:(BOOL)completed withAd:(HyBidAd *)ad causedByAutoCloseTimerCompletion:(BOOL)autoCloseTimerCompleted {
    if (ad.skoverlayEnabled) {
        if ([ad.skoverlayEnabled boolValue]) {
            [self checkSKOverlayAvailabilityAndDismiss:completed causedByAutoCloseTimerCompletion:autoCloseTimerCompleted];
        }
    } 
}

- (void)checkSKOverlayAvailabilityAndDismiss:(BOOL)isSKOverlayDismissedEntirely causedByAutoCloseTimerCompletion:(BOOL)autoCloseTimerCompleted {
    if (@available(iOS 14.0, *)) {
        if (self.overlay) {
            [SKOverlay dismissOverlayInScene:[UIApplication sharedApplication].topViewController.view.window.windowScene];
            if (isSKOverlayDismissedEntirely) {
                if(self.autoCloseTimer && [self.autoCloseTimer isValid]) {
                    [self.autoCloseTimer invalidate];
                    self.autoCloseTimer = nil;
                    self.autoCloseTimerNeeded = NO;
                }
                if(self.delayTimer && [self.delayTimer isValid]) {
                    [self.delayTimer invalidate];
                    self.delayTimer = nil;
                    self.delayTimerNeeded = NO;
                }
                if(self.endCardDelayTimer && [self.endCardDelayTimer isValid]) {
                    [self.endCardDelayTimer invalidate];
                    self.endCardDelayTimer = nil;
                    self.endCardReadyToShow = NO;
                }
                [self removeObservers];
                self.overlay = nil;
            } else {
                if(self.delayTimerNeeded) {
                    if((self.delayTimer && [self.delayTimer isValid]) && (!self.delayTimerCompleted || !self.delayPerformsDefaultBehaviour)) {
                        [self updateTimerStateWithRemainingSeconds:[self getRemainingTimeForTimerType:HyBidSKOverlayTimerType_Delay]
                                                    withTimerState:HyBidTimerState_Pause
                                                      forTimerType:HyBidSKOverlayTimerType_Delay];
                    }
                }
                if(self.endCardReadyToShow) {
                    if(!autoCloseTimerCompleted && (self.endCardDelayTimer && [self.endCardDelayTimer isValid]) && (!self.endCardDelayTimerCompleted || !self.endCardDelayPerformsDefaultBehaviour)) {
                        [self updateTimerStateWithRemainingSeconds:[self getRemainingTimeForTimerType:HyBidSKOverlayTimerType_EndCardDelay]
                                                    withTimerState:HyBidTimerState_Pause
                                                      forTimerType:HyBidSKOverlayTimerType_EndCardDelay];
                        
                        [self updateTimerStateWithRemainingSeconds:[self getRemainingTimeForTimerType:HyBidSKOverlayTimerType_AutoClose]
                                                    withTimerState:HyBidTimerState_Pause
                                                      forTimerType:HyBidSKOverlayTimerType_AutoClose];
                    }
                }
            }
        }
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"SKOverlay is available from iOS 14.0"];
    }
}

#pragma mark Timer Manipulations

-(void)updateTimerStateWithRemainingSeconds:(NSInteger)seconds
                             withTimerState:(HyBidTimerState)timerState
                               forTimerType:(HyBidSKOverlayTimerType)timerType {
    switch (timerType) {
        case HyBidSKOverlayTimerType_AutoClose:
            if (seconds <= 0 && self.autoCloseTimeRemaining <= 0) {
                [self timerFinishedForType:timerType];
                return;
            }
            break;
        case HyBidSKOverlayTimerType_Delay:
            if (seconds <= 0 && self.delayTimeRemaining <= 0) {
                [self timerFinishedForType:timerType];
                return;
            }
            break;
        case HyBidSKOverlayTimerType_EndCardDelay:
            if (seconds <= 0 && self.endCardDelayTimeRemaining <= 0) {
                [self timerFinishedForType:timerType];
                return;
            }
            break;
    }
    
    switch (timerState) {
        case HyBidTimerState_Start:
            switch (timerType) {
                case HyBidSKOverlayTimerType_AutoClose:
                    if (self.autoCloseTimeRemaining != -1) {
                        __weak typeof(self) weakSelf = self;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.autoCloseTimeRemaining = seconds;
                            if(!weakSelf.autoCloseTimer) {
                                weakSelf.autoCloseTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:weakSelf selector:@selector(autoCloseTimerTicked) userInfo:nil repeats:YES];
                                weakSelf.autoCloseTimerCompleted = NO;
                            }
                        });
                    }
                    break;
                case HyBidSKOverlayTimerType_Delay:
                    if (self.delayTimeRemaining != -1) {
                        __weak typeof(self) weakSelf = self;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.delayTimeRemaining = seconds;
                            if(!weakSelf.delayTimer) {
                                weakSelf.delayTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:weakSelf selector:@selector(delayTimerTicked) userInfo:nil repeats:YES];
                                weakSelf.delayTimerCompleted = NO;
                            }
                        });
                    }
                    break;
                case HyBidSKOverlayTimerType_EndCardDelay:
                    if (self.endCardDelayTimeRemaining != -1) {
                        __weak typeof(self) weakSelf = self;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.endCardDelayTimeRemaining = seconds;
                            if(!weakSelf.endCardDelayTimer) {
                                weakSelf.endCardDelayTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:weakSelf selector:@selector(endCardDelayTimerTicked) userInfo:nil repeats:YES];
                                weakSelf.endCardDelayTimerCompleted = NO;
                            }
                        });
                    }
                    break;
            }
            break;
        case HyBidTimerState_Pause:
            switch (timerType) {
                case HyBidSKOverlayTimerType_AutoClose:
                    if ([self.autoCloseTimer isValid]) {
                        [self invalidateTimerForType:timerType];
                        self.autoCloseTimeRemaining = seconds;
                    }
                    break;
                case HyBidSKOverlayTimerType_Delay:
                    if ([self.delayTimer isValid]) {
                        [self invalidateTimerForType:timerType];
                        self.delayTimeRemaining = seconds;
                    }
                    break;
                case HyBidSKOverlayTimerType_EndCardDelay:
                    if ([self.endCardDelayTimer isValid]) {
                        [self invalidateTimerForType:timerType];
                        self.endCardDelayTimeRemaining = seconds;
                    }
                    break;
            }
            break;
        case HyBidTimerState_Stop:
            switch (timerType) {
                case HyBidSKOverlayTimerType_AutoClose:
                    [self invalidateTimerForType:timerType];
                    self.autoCloseTimeRemaining = -1;
                    break;
                case HyBidSKOverlayTimerType_Delay:
                    [self invalidateTimerForType:timerType];
                    self.delayTimeRemaining = -1;
                    break;
                case HyBidSKOverlayTimerType_EndCardDelay:
                    [self invalidateTimerForType:timerType];
                    self.endCardDelayTimeRemaining = -1;
                    break;
            }
            break;
    }
}

- (NSInteger)getRemainingTimeForTimerType:(HyBidSKOverlayTimerType)timerType {
    switch (timerType) {
        case HyBidSKOverlayTimerType_AutoClose:
            return self.autoCloseTimeRemaining;
            break;
        case HyBidSKOverlayTimerType_Delay:
            return self.delayTimeRemaining;
            break;
        case HyBidSKOverlayTimerType_EndCardDelay:
            return self.endCardDelayTimeRemaining;
            break;
    }
    return -1;
}

- (void)timerFinishedForType:(HyBidSKOverlayTimerType)timerType {
    switch (timerType) {
        case HyBidSKOverlayTimerType_AutoClose:
            [self invalidateTimerForType:timerType];
            self.autoCloseTimeRemaining = -1;
            self.autoCloseTimerCompleted = YES;
            self.delayTimerNeeded = NO;
            if([self getRemainingTimeForTimerType:HyBidSKOverlayTimerType_EndCardDelay] > 0 && [self.endCardDelayTimer isValid]) {
                self.endCardReadyToShow = YES;
            } else {
                self.endCardReadyToShow = NO;
            }
            [self dismissEntirely:NO withAd:self.ad causedByAutoCloseTimerCompletion:YES];
            break;
        case HyBidSKOverlayTimerType_Delay:
            [self invalidateTimerForType:timerType];
            self.delayTimeRemaining = -1;
            self.delayTimerCompleted = YES;
            [self presentWithAd:self.ad];
            break;
        case HyBidSKOverlayTimerType_EndCardDelay:
            [self invalidateTimerForType:timerType];
            self.endCardDelayTimeRemaining = -1;
            self.delayTimerNeeded = NO;
            self.endCardDelayTimerCompleted = YES;
            [self presentWithAd:self.ad];
            break;
    }
}

- (void)invalidateTimerForType:(HyBidSKOverlayTimerType)timerType {
    switch (timerType) {
        case HyBidSKOverlayTimerType_AutoClose:{
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.autoCloseTimer invalidate];
                weakSelf.autoCloseTimer = nil;
            });
            break;
        }
        case HyBidSKOverlayTimerType_Delay: {
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.delayTimer invalidate];
                weakSelf.delayTimer = nil;
            });
            break;
        }
        case HyBidSKOverlayTimerType_EndCardDelay: {
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.endCardDelayTimer invalidate];
                weakSelf.endCardDelayTimer = nil;
            });
            break;
        }
    }
}

- (void)autoCloseTimerTicked {
    self.autoCloseTimeRemaining -= 1;
    if (self.autoCloseTimeRemaining <= 0) {
        [self timerFinishedForType:HyBidSKOverlayTimerType_AutoClose];
    }
}

- (void)delayTimerTicked {
    self.delayTimeRemaining -= 1;
    if (self.delayTimeRemaining <= 0) {
        [self timerFinishedForType:HyBidSKOverlayTimerType_Delay];
    }
}

- (void)endCardDelayTimerTicked {
    self.endCardDelayTimeRemaining -= 1;
    if (self.endCardDelayTimeRemaining <= 0) {
        [self timerFinishedForType:HyBidSKOverlayTimerType_EndCardDelay];
    }
}

#pragma mark SKOverlayDelegate

- (void)storeOverlay:(SKOverlay *)overlay willStartPresentation:(SKOverlayTransitionContext *)transitionContext  API_AVAILABLE(ios(14.0)){
    if(!self.autoCloseTimerCompleted && !self.autoClosePerformsDefaultBehaviour) {
        self.autoCloseTimerNeeded = YES;
        [self updateTimerStateWithRemainingSeconds:[self getRemainingTimeForTimerType:HyBidSKOverlayTimerType_AutoClose]
                                    withTimerState:HyBidTimerState_Start
                                      forTimerType:HyBidSKOverlayTimerType_AutoClose];
    }
    if ([overlay isEqual:self.overlay]) {
        self.isOverlayShown = YES;
    }
}

- (void)storeOverlay:(SKOverlay *)overlay didFinishPresentation:(SKOverlayTransitionContext *)transitionContext  API_AVAILABLE(ios(14.0)){
    if (!self.impressionEventFired) {
        NSMutableDictionary* reportingDictionary = [NSMutableDictionary new];
        if ([HyBidSDKConfig sharedConfig].appToken != nil && [HyBidSDKConfig sharedConfig].appToken.length > 0) {
            [reportingDictionary setObject:[HyBidSDKConfig sharedConfig].appToken forKey:HyBidReportingCommon.APPTOKEN];
        }
        if (self.ad != nil && self.ad.zoneID != nil && self.ad.zoneID.length > 0) {
            [reportingDictionary setObject:self.ad.zoneID forKey:HyBidReportingCommon.ZONE_ID];
        }
        if (self.ad != nil && self.ad.campaignID != nil && self.ad.campaignID.length > 0) {
            [reportingDictionary setObject:self.ad.campaignID forKey:HyBidReportingCommon.CAMPAIGN_ID];
        }
        HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc] initWith:HyBidReportingEventType.SKOVERLAY_IMPRESSION
                                                                           adFormat:self.isRewarded ? HyBidReportingAdFormat.REWARDED : HyBidReportingAdFormat.FULLSCREEN
                                                                         properties:[NSDictionary dictionaryWithDictionary:reportingDictionary]];
        [[HyBid reportingManager] reportEventFor:reportingEvent];
        self.impressionEventFired = YES;
    }
}

- (void)storeOverlay:(SKOverlay *)overlay willStartDismissal:(SKOverlayTransitionContext *)transitionContext  API_AVAILABLE(ios(14.0)){
    if(!self.autoCloseTimerCompleted && !self.autoClosePerformsDefaultBehaviour) {
        [self updateTimerStateWithRemainingSeconds:[self getRemainingTimeForTimerType:HyBidSKOverlayTimerType_AutoClose]
                                    withTimerState:HyBidTimerState_Pause
                                      forTimerType:HyBidSKOverlayTimerType_AutoClose];
    }
    if ([overlay isEqual:self.overlay]) {
        self.isOverlayShown = NO;
    }
}

- (void)storeOverlay:(SKOverlay *)overlay didFinishDismissal:(SKOverlayTransitionContext *)transitionContext  API_AVAILABLE(ios(14.0)){}
- (void)storeOverlay:(SKOverlay *)overlay didFailToLoadWithError:(NSError *)error  API_AVAILABLE(ios(14.0)){}

#pragma mark UIApplication Notifications

- (void)applicationDidEnterBackground:(NSNotification*)notification {
    [self dismissEntirely:NO withAd:self.ad causedByAutoCloseTimerCompletion:NO];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    if(!self.isSecondViewPrepared) {
        [self presentWithAd:self.ad];
    }
}

#pragma mark HyBidAdFeedbackView Notifications

- (void)feedbackScreenWillShow:(NSNotification*)notification {
    self.isSecondViewPrepared = YES;
    [self dismissEntirely:NO withAd:self.ad causedByAutoCloseTimerCompletion:NO];
}

- (void)feedbackScreenIsDismissed:(NSNotification*)notification {
    [self presentWithAd:self.ad];
}

@end
