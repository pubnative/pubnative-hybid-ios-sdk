//
//  PNLiteVASTRewardedPresenter.h
//  HyBid
//
//  Created by Orkhan Alizada on 16.10.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import "HyBidRewardedPresenter.h"

@interface PNLiteVASTRewardedPresenter : HyBidRewardedPresenter

- (instancetype)initWithAd:(HyBidAd *)ad withSkipOffset: (NSInteger)skipOffset;

@property (nonatomic, readwrite, assign) NSInteger skipOffset;

@end
