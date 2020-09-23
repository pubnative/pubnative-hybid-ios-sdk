//
//  MPViewabilityInfoProvider.h
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MPViewabilityAdType) {
    MPViewabilityAdTypeWeb, // non-video web view
    MPViewabilityAdTypeWebVideo, // video web view (MoVideo)
    MPViewabilityAdTypeNativeVideo // VAST
};

@protocol MPViewabilityFriendlyObstructionViewInfoProvider <NSObject>
@property (nonatomic, readonly) NSSet<UIView *> *viewabilityFriendlyObstructionViews;
@end

@protocol MPViewabilityInfoProvider <MPViewabilityFriendlyObstructionViewInfoProvider>
@property (nonatomic, readonly) MPViewabilityAdType viewabilityAdType;
@property (nonatomic, readonly) UIView *adContentView;
@end

NS_ASSUME_NONNULL_END
