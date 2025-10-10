// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
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

typedef enum : NSUInteger {
    HyBidSKOverlayWillStartPresentation,
    HyBidSKOverlayDidFinishPresentation,
    HyBidSKOverlayWillStartDismissal,
} HyBidSKOverlaySimulateMethod;

@interface HyBidSKOverlay() <SKOverlayDelegate, HyBidInterruptionDelegate>

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
@property (nonatomic, assign) BOOL hasBeenPresented;

@property (nonatomic, assign) BOOL endCardDelayPerformsDefaultBehaviour;
@property (nonatomic, assign) NSInteger endCardDelayOffset;
@property (nonatomic, strong) NSTimer *endCardDelayTimer;
@property (nonatomic, assign) NSInteger endCardDelayTimeRemaining;
@property (nonatomic, assign) BOOL endCardDelayTimerCompleted;
@property (nonatomic, assign) BOOL endCardReadyToShow;

@property (nonatomic, assign) BOOL isRewarded;
@property (nonatomic, assign) BOOL impressionEventFired;

@property (nonatomic, strong) NSObject <HyBidSKOverlayDelegate> *delegate;
@property (nonatomic, assign) HyBidOnTopOfType onTopOf;

@property (nonatomic, assign) BOOL simulateSKOverlayDismissal;
@property (nonatomic, assign) BOOL isSKOverlayPresentationStarted;
@end

@implementation HyBidSKOverlay

- (void)dealloc {
    self.ad = nil;
    self.delegate = nil;
    if (@available(iOS 14.0, *)) {
        if (self.overlay) {
            self.overlay = nil;
        }
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"SKOverlay is available from iOS 14.0"];
    }
}

- (instancetype)initWithAd:(HyBidAd *)ad isRewarded:(BOOL)isRewarded delegate:(NSObject <HyBidSKOverlayDelegate> *)delegate {
    self = [super init];
    if (self) {
        if (@available(iOS 14.0, *)) {
            self.ad = ad;
            self.isRewarded = isRewarded;
            self.delegate = delegate;
            HyBidSkAdNetworkModel* skAdNetworkModel = self.ad.isUsingOpenRTB ? [self.ad getOpenRTBSkAdNetworkModel] : [self.ad getSkAdNetworkModel];
            SKOverlayPosition position = SKOverlayPositionBottom;
            BOOL userDismissible = YES;
            self.onTopOf = HyBidOnTopOfTypeDISPLAY;
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
                
                
                if (@available(iOS 15.0, *)) {
                    NSString *productPageId = [skAdNetworkModel.productParameters objectForKey:HyBidSKAdNetworkParameter.productPageId];
                    if (productPageId && productPageId.length > 0) {
                        configuration.customProductPageIdentifier = productPageId;
                    }
                }
                
                if (@available(iOS 17.4, *)) {
                    [[[HyBidAdAttributionSKOverlayManager alloc] init] getAppConfigurationWithAppIdentifier:appIdentifier position:position userDismissible:userDismissible ad:self.ad adFormat:isRewarded ? HyBidReportingAdFormat.REWARDED : HyBidReportingAdFormat.FULLSCREEN completionHandler:^(SKOverlayAppConfiguration * _Nullable appConfiguration) {
                                                
                        [self startSKOverlayAndDelaysWithConfiguration:appConfiguration ? appConfiguration : configuration
                                                              delegate:self
                                                      skAdNetworkModel:skAdNetworkModel];
                    }];
                } else {
                    [self startSKOverlayAndDelaysWithConfiguration:configuration delegate:self skAdNetworkModel:skAdNetworkModel];
                }
            }
        } else {
            [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"SKOverlay is available from iOS 14.0"];
        }
    }
    return self;
}

- (void)startSKOverlayAndDelaysWithConfiguration:(SKOverlayAppConfiguration *)configuration delegate:(id <SKOverlayDelegate>)delegate skAdNetworkModel:(HyBidSkAdNetworkModel *)skAdNetworkModel API_AVAILABLE(ios(14.0)){
    self.overlay = [[SKOverlay alloc] initWithConfiguration:configuration];
    self.overlay.delegate = delegate;
    [self determineAutoCloseOffsetAndBehaviour:skAdNetworkModel];
    [self determineDelayOffsetAndBehaviour:skAdNetworkModel];
    [self determineEndCardDelayOffsetAndBehaviour:skAdNetworkModel];
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
    HyBidInterruptionHandler.shared.overlappingElementDelegate = self;
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    HyBidInterruptionHandler.shared.overlappingElementDelegate = nil;
}

#pragma mark SKOverlay Manipulations

- (void)presentWithAd:(HyBidAd *)ad {
    self.isSecondViewPrepared = NO;
    if (ad.skOverlayEnabled) {
        if ([ad.skOverlayEnabled boolValue]) {
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
                        if (self.simulateSKOverlayDismissal) {
                            [self simulateSKOverlayMethod: HyBidSKOverlayWillStartPresentation];
                            [self simulateSKOverlayMethod: HyBidSKOverlayDidFinishPresentation];
                        } else {
                            if (!self.isSKOverlayPresentationStarted) {
                                UIViewController * topViewController = [self getTopViewControllerRemovingStoreKitView:YES];
                                [self.overlay presentInScene:topViewController.view.window.windowScene];
                                self.isSKOverlayPresentationStarted = YES;
                            }
                        }
                    } else {
                        [self updateTimerStateWithRemainingSeconds:[self getRemainingTimeForTimerType:HyBidSKOverlayTimerType_Delay]
                                                    withTimerState:HyBidTimerState_Start
                                                      forTimerType:HyBidSKOverlayTimerType_Delay];
                    }
                }
                
                if(self.endCardReadyToShow) {
                    if(self.endCardDelayTimerCompleted || self.endCardDelayPerformsDefaultBehaviour) {
                        if (self.simulateSKOverlayDismissal) {
                            [self simulateSKOverlayMethod: HyBidSKOverlayWillStartPresentation];
                            [self simulateSKOverlayMethod: HyBidSKOverlayDidFinishPresentation];
                        } else {
                            UIViewController * topViewController = [self getTopViewControllerRemovingStoreKitView:YES];
                            [self.overlay presentInScene:topViewController.view.window.windowScene];
                        }
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

- (UIViewController *)getTopViewControllerRemovingStoreKitView:(BOOL)removeStoreKitView {
    UIViewController * topViewController = [UIApplication sharedApplication].topViewController;
    if ([topViewController isMemberOfClass:[SKStoreProductViewController class]] && topViewController.presentingViewController) {
        UIViewController * presentingViewController = topViewController.presentingViewController;
        
        if (removeStoreKitView) {
            [topViewController dismissViewControllerAnimated:NO completion:nil];
            topViewController = nil;
        }
        
        topViewController = presentingViewController;

    }
    return topViewController;
}

- (void)dismissEntirely:(BOOL)completed withAd:(HyBidAd *)ad causedByAutoCloseTimerCompletion:(BOOL)autoCloseTimerCompleted {
    if (ad.skOverlayEnabled) {
        if ([ad.skOverlayEnabled boolValue]) {
            [self checkSKOverlayAvailabilityAndDismiss:completed causedByAutoCloseTimerCompletion:autoCloseTimerCompleted];
        }
    } 
}

- (void)checkSKOverlayAvailabilityAndDismiss:(BOOL)isSKOverlayDismissedEntirely causedByAutoCloseTimerCompletion:(BOOL)autoCloseTimerCompleted {
    if (@available(iOS 14.0, *)) {
        if (self.overlay) {
            if (self.simulateSKOverlayDismissal) {
                [self simulateSKOverlayMethod: HyBidSKOverlayWillStartDismissal];
            } else {
                UIViewController * topViewController = [self getTopViewControllerRemovingStoreKitView:NO];
                [SKOverlay dismissOverlayInScene:topViewController.view.window.windowScene];
            }
            if (isSKOverlayDismissedEntirely) {
                self.overlay = nil;
                [self removeObservers];
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
    if (@available(iOS 14.0, *)) {
        if (self.overlay) {
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
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"SKOverlay is available from iOS 14.0"];
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
    if (!self.isSecondViewPrepared) {
        if(!self.autoCloseTimerCompleted && !self.autoClosePerformsDefaultBehaviour) {
            self.autoCloseTimerNeeded = YES;
            [self updateTimerStateWithRemainingSeconds:[self getRemainingTimeForTimerType:HyBidSKOverlayTimerType_AutoClose]
                                        withTimerState:HyBidTimerState_Start
                                          forTimerType:HyBidSKOverlayTimerType_AutoClose];
        }
        if ([overlay isEqual:self.overlay]) {
            self.isOverlayShown = YES;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(skOverlayDidShowOnCreative:)]){
            [self.delegate skOverlayDidShowOnCreative:!self.hasBeenPresented];
            self.hasBeenPresented = YES;
        }
    }
}

- (void)storeOverlay:(SKOverlay *)overlay didFinishPresentation:(SKOverlayTransitionContext *)transitionContext  API_AVAILABLE(ios(14.0)){
    HyBidInterruptionHandler.shared.overlappingElementDelegate = self;
    self.isSKOverlayPresentationStarted = NO;
    
    if(self.autoCloseTimerNeeded && !self.autoCloseTimerCompleted && !self.autoClosePerformsDefaultBehaviour) {
        [self updateTimerStateWithRemainingSeconds:[self getRemainingTimeForTimerType:HyBidSKOverlayTimerType_AutoClose]
                                    withTimerState:HyBidTimerState_Start
                                      forTimerType:HyBidSKOverlayTimerType_AutoClose];
    }
    
    if ([HyBidInterruptionHandler.shared hasOnlyAppLifeCycleInterruption]) { [self adHasNoFocus]; }
    
    if (!self.impressionEventFired) {
        if ([HyBidSDKConfig sharedConfig].reporting) {
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
        }
        
        [[HyBidVASTEventBeaconsManager shared] reportVASTEventWithType:HyBidReportingEventType.SKOVERLAY_IMPRESSION
                                                                    ad:self.ad
                                                               onTopOf:self.onTopOf];
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

- (void)storeOverlay:(SKOverlay *)overlay didFinishDismissal:(SKOverlayTransitionContext *)transitionContext  API_AVAILABLE(ios(14.0)){
    if ([overlay isEqual:self.overlay]) {
        self.isOverlayShown = NO;
    }
}
- (void)storeOverlay:(SKOverlay *)overlay didFailToLoadWithError:(NSError *)error  API_AVAILABLE(ios(14.0)){
    self.isSKOverlayPresentationStarted = NO;
    [[HyBidVASTEventBeaconsManager shared] reportVASTEventWithType:HyBidReportingEventType.SKOVERLAY_IMPRESSION_ERROR
                                                                ad:self.ad
                                                           onTopOf:self.onTopOf
                                                         errorCode:error.code];
    HyBidInterruptionHandler.shared.overlappingElementDelegate = nil;
    
    if ([overlay isEqual:self.overlay]) {
        self.isOverlayShown = NO;
    }
}

// Simulating presenting/dismiss methods to load SKOverlay inmediatly after background mode and avoid its delay. SKOverlayTransitionContext is never use on our logic (no need to create an object of it)
- (void)simulateSKOverlayMethod:(HyBidSKOverlaySimulateMethod) method {
    if (@available(iOS 14.0, *)) {
        if (!self.overlay || !self.overlay.delegate) { return; }
        switch (method) {
            case HyBidSKOverlayWillStartPresentation:
                [self.overlay.delegate storeOverlay:self.overlay willStartPresentation: [SKOverlayTransitionContext alloc]];
                break;
            case HyBidSKOverlayDidFinishPresentation:
                [self.overlay.delegate storeOverlay:self.overlay didFinishPresentation: [SKOverlayTransitionContext alloc]];
                break;
            case HyBidSKOverlayWillStartDismissal:
                [self.overlay.delegate storeOverlay:self.overlay willStartDismissal: [SKOverlayTransitionContext alloc]];
                break;
        }
    }
}

#pragma mark HyBidSKOverlayDelegate

- (void)changeDelegateFor:(NSObject <HyBidSKOverlayDelegate> *)delegate {
    self.delegate = delegate;
}

#pragma mark HyBidInterruptionDelegate

- (void)adHasFocus {
    [self presentWithAd:self.ad];
    self.simulateSKOverlayDismissal = NO;
}

- (void)adHasNoFocus {
    if (![HyBidInterruptionHandler.shared hasOnlyAppLifeCycleInterruption]){
        self.isSecondViewPrepared = YES;
    } else {
        self.simulateSKOverlayDismissal = YES;
    }
    [self dismissEntirely:NO withAd:self.ad causedByAutoCloseTimerCompletion:NO];
}

- (void)endCardWillShow {
    self.endCardReadyToShow = YES;
    self.onTopOf = HyBidOnTopOfTypeCOMPANION_AD;
    [self updateTimerStateWithRemainingSeconds:[self getRemainingTimeForTimerType:HyBidSKOverlayTimerType_EndCardDelay]
                                withTimerState:HyBidTimerState_Start
                                  forTimerType:HyBidSKOverlayTimerType_EndCardDelay];
}

- (void)customEndCardWillShow {
    self.endCardReadyToShow = YES;
    self.onTopOf = HyBidOnTopOfTypeCUSTOM_ENDCARD;
    [self updateTimerStateWithRemainingSeconds:[self getRemainingTimeForTimerType:HyBidSKOverlayTimerType_EndCardDelay]
                                withTimerState:HyBidTimerState_Start
                                  forTimerType:HyBidSKOverlayTimerType_EndCardDelay];
}

- (void)productViewControllerDidFinish {
    if ([HyBidInterruptionHandler.shared hasOnlyAppLifeCycleInterruption]) { [self adHasFocus]; }
}

- (void)productViewControllerWillShow {
    [self adHasNoFocus];
}

- (void)feedbackViewWillShow {
    [self adHasNoFocus];
}

@end
