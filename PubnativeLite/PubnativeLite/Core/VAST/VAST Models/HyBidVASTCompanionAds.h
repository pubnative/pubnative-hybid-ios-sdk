// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidVASTCompanion.h"
#import "HyBidXMLElementEx.h"

typedef enum {
    /**
         The video player must attempt to display the contents for all <Companion> elemens provided;
         if all Companion creative cannot be displayed, the Ad should be disregarded and the ad server should be notified using the <Error> element.
         */
    HyBidVASTCompanionAdRequirement_ALL,
    /**
         The video player must attempt to display content from at least one of the <Companion> elements provided
         (i.e. display the one with dimensions that best fit the page); if none of the Companion creative can be displayed, the Ad should be disregarded
         and the ad server should be notified using the <Error> element.
         */
    HyBidVASTCompanionAdRequirement_ANY,
    /**
         The video player may choose to not display any of the Companion creative, but is not restricted from doing so; The ad server may
         use this option when the advertiser prefers that the master ad be displayed with or without the Companion creative.
         */
    HyBidVASTCompanionAdRequirement_NONE
} HyBidVASTCompanionAdRequirement;

@interface HyBidVASTCompanionAds : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithCompanionAdsXMLElement:(HyBidXMLElementEx *)companionAdsXMLElement;

- (HyBidVASTCompanionAdRequirement)required;

- (NSArray<HyBidVASTCompanion *> *)companions;

@end
