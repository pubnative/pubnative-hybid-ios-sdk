//
//  HyBidRewardedAd.m
//  HyBid
//
//  Created by Orkhan Alizada on 16.10.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import "HyBidRewardedAd.h"
#import "HyBidRewardedAdRequest.h"
#import "HyBidRewardedPresenter.h"
#import "HyBidRewardedPresenterFactory.h"
#import "HyBidLogger.h"
#import "HyBidIntegrationType.h"

@interface HyBidRewardedAd() <HyBidRewardedPresenterDelegate, HyBidAdRequestDelegate>

@property (nonatomic, strong) NSString *zoneID;
@property (nonatomic, weak) NSObject<HyBidRewardedAdDelegate> *delegate;
@property (nonatomic, strong) HyBidRewardedPresenter *rewardedPresenter;
@property (nonatomic, strong) HyBidRewardedAdRequest *rewardedAdRequest;

@end

@implementation HyBidRewardedAd

- (void)dealloc {
    self.ad = nil;
    self.zoneID = nil;
    self.delegate = nil;
    self.rewardedPresenter = nil;
    self.rewardedAdRequest = nil;
}

- (void)cleanUp {
    self.ad = nil;
}

- (instancetype)initWithZoneID:(NSString *)zoneID andWithDelegate:(NSObject<HyBidRewardedAdDelegate> *)delegate {
    self = [super init];
    if (self) {
        self.rewardedAdRequest = [[HyBidRewardedAdRequest alloc] init];
        self.zoneID = zoneID;
        self.delegate = delegate;
    }
    return self;
}

- (instancetype)initWithDelegate:(NSObject<HyBidRewardedAdDelegate> *)delegate {
    self = [super init];
    if (self) {
        self.zoneID = @"";
        self.delegate = delegate;
    }
    return self;
}

- (void)load {
    [self cleanUp];
    if (!self.zoneID || self.zoneID.length == 0) {
        [self invokeDidFailWithError:[NSError errorWithDomain:@"Invalid Zone ID provided." code:0 userInfo:nil]];
    } else {
        self.isReady = NO;
        [self.rewardedAdRequest setIntegrationType: self.isMediation ? MEDIATION : STANDALONE withZoneID: self.zoneID];
        [self.rewardedAdRequest requestAdWithDelegate:self withZoneID:self.zoneID];
    }
}

- (void)prepareAdWithContent:(NSString *)adContent {
    if (adContent && [adContent length] != 0) {
        [self processAdContent:adContent];
    } else {
        [self invokeDidFailWithError:[NSError errorWithDomain:@"The server has returned an invalid ad asset" code:0 userInfo:nil]];
    }
}

- (void)processAdContent:(NSString *)adContent {
    HyBidSignalDataProcessor *signalDataProcessor = [[HyBidSignalDataProcessor alloc] init];
    signalDataProcessor.delegate = self;
    [signalDataProcessor processSignalData:adContent withZoneID:self.zoneID];
}

- (void)show {
    if (self.isReady) {
        [self.rewardedPresenter show];
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Can't display ad. Rewarded not ready."];
    }
}

- (void)showFromViewController:(UIViewController *)viewController {
    if (self.isReady) {
        [self.rewardedPresenter showFromViewController:viewController];
    } else {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Can't display ad. Rewarded not ready."];
    }
}

- (void)hide {
    [self.rewardedPresenter hide];
}

- (void)renderAd:(HyBidAd *)ad {
    HyBidRewardedPresenterFactory *interstitalPresenterFactory = [[HyBidRewardedPresenterFactory alloc] init];
    self.rewardedPresenter = [interstitalPresenterFactory createInterstitalPresenterWithAd:ad withDelegate:self];
    if (!self.rewardedPresenter) {
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"Could not create valid rewarded presenter."];
        [self invokeDidFailWithError:[NSError errorWithDomain:@"The server has returned an unsupported ad asset." code:0 userInfo:nil]];
        return;
    } else {
        [self.rewardedPresenter load];
    }
}

- (void)invokeDidLoad {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedDidLoad)]) {
        [self.delegate rewardedDidLoad];
    }
}

- (void)invokeDidFailWithError:(NSError *)error {
    [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedDidFailWithError:)]) {
        [self.delegate rewardedDidFailWithError:error];
    }
}

- (void)invokeDidTrackImpression {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedDidTrackImpression)]) {
        [self.delegate rewardedDidTrackImpression];
    }
}

- (HyBidSkAdNetworkModel *)skAdNetworkModel {
    HyBidSkAdNetworkModel *result = nil;
    if (self.ad) {
        result = [self.ad getSkAdNetworkModel];
    }
    return result;
}

- (void)invokeDidTrackClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedDidTrackClick)]) {
        [self.delegate rewardedDidTrackClick];
    }
}

- (void)invokeDidDismiss {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedDidDismiss)]) {
        [self.delegate rewardedDidDismiss];
    }
}

#pragma mark HyBidAdRequestDelegate

- (void)requestDidStart:(HyBidAdRequest *)request {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ started:",request]];
}

- (void)request:(HyBidAdRequest *)request didLoadWithAd:(HyBidAd *)ad {
    [HyBidLogger debugLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Ad Request %@ loaded with ad: %@",request, ad]];
    if (!ad) {
        [self invokeDidFailWithError:[NSError errorWithDomain:@"Server returned nil ad." code:0 userInfo:nil]];
    } else {
        self.ad = ad;
        [self renderAd:ad];
    }
}

- (void)request:(HyBidAdRequest *)request didFailWithError:(NSError *)error {
    [self invokeDidFailWithError:error];
}

#pragma mark HyBidRewardedPresenterDelegate

- (void)rewardedPresenterDidLoad:(HyBidRewardedPresenter *)rewardedPresenter {
    self.isReady = YES;
    [self invokeDidLoad];
}

- (void)rewardedPresenter:(HyBidRewardedPresenter *)rewardedPresenter didFailWithError:(NSError *)error {
    [self invokeDidFailWithError:error];
}

- (void)rewardedPresenterDidShow:(HyBidRewardedPresenter *)rewardedPresenter {
    [self invokeDidTrackImpression];
}

- (void)rewardedPresenterDidClick:(HyBidRewardedPresenter *)rewardedPresenter {
    [self invokeDidTrackClick];
}

- (void)rewardedPresenterDidDismiss:(HyBidRewardedPresenter *)rewardedPresenter {
    [self invokeDidDismiss];
}

#pragma mark - HyBidSignalDataProcessorDelegate

- (void)signalDataDidFinishWithAd:(HyBidAd *)ad {
    self.ad = ad;
    [self renderAd:self.ad];
}

- (void)signalDataDidFailWithError:(NSError *)error {
    [self invokeDidFailWithError:error];
}

@end
