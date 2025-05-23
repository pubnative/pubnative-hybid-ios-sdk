// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HyBidAdModel.h"
#import "HyBidContentInfoView.h"
#import "HyBidSkAdNetworkModel.h"
#import "HyBidOpenRTBDataModel.h"
#import "HyBidVASTEndCard.h"

#define kHyBidAdTypeHTML 0
#define kHyBidAdTypeVideo 1
#define kHyBidAdTypeUnsupported 2

typedef struct {
    int fidelity;
    char *signature;
    char *nonce;
    char *timestamp;
} SKANObject;

typedef enum {
    HyBidDemoAppPlacementBanner = 0,
    HyBidDemoAppPlacementMRect = 1,
    HyBidDemoAppPlacementLeaderboard = 2,
    HyBidDemoAppPlacementInterstitial = 3,
    HyBidDemoAppPlacementRewarded = 4
} HyBidMarkupPlacement;

typedef enum : NSUInteger {
    HyBidStorekitAutomaticClickVideo = 1 << 0,
    HyBidStorekitAutomaticClickDefaultEndCard = 1 << 1,
    HyBidStorekitAutomaticClickCustomEndCard = 1 << 2
} HyBidStorekitAutomaticClickType;

@interface HyBidAd : NSObject

@property (nonatomic, readonly) NSString *vast;
@property (nonatomic, readonly) NSString *openRtbVast;
@property (nonatomic, readonly) NSString *htmlUrl;
@property (nonatomic, readonly) NSString *htmlData;
@property (nonatomic, readonly) NSString *customEndCardData;
@property (nonatomic, readonly) NSString *link;
@property (nonatomic, readonly) NSString *impressionID;
@property (nonatomic, readonly) NSString *creativeID;
@property (nonatomic, readonly) NSString *campaignID;
@property (nonatomic, readonly) NSString *openRTBCreativeID;
@property (nonatomic, readonly) NSString *zoneID;
@property (nonatomic, readonly) NSString *bundleID;
@property (nonatomic, readonly) NSString *adExperience;

#if __has_include(<ATOM/ATOM-Swift.h>)
@property (nonatomic, readonly) NSArray<NSString *> *cohorts;
#endif
@property (nonatomic, strong) HyBidVASTEndCard *customEndCard;
@property (nonatomic, readonly) NSNumber *assetGroupID;
@property (nonatomic, readonly) NSNumber *openRTBAssetGroupID;
@property (nonatomic, readonly) NSNumber *eCPM;
@property (nonatomic, readonly) NSNumber *width;
@property (nonatomic, readonly) NSNumber *height;
@property (nonatomic, readonly) NSArray<HyBidDataModel*> *beacons;
@property (nonatomic, readonly) HyBidContentInfoView *contentInfo;
@property (nonatomic) NSInteger adType;
@property (nonatomic, assign) BOOL isUsingOpenRTB;
@property (nonatomic, assign) BOOL hasEndCard;
@property (nonatomic, assign) BOOL hasCustomEndCard;
@property (nonatomic, assign) BOOL isEndcard;
@property (nonatomic, readonly) NSString *audioState;
@property (nonatomic, readonly) NSString *contentInfoURL;
@property (nonatomic, readonly) NSString *contentInfoIconURL;
@property (nonatomic, readonly) NSString *contentInfoIconClickAction;
@property (nonatomic, readonly) NSString *contentInfoDisplay;
@property (nonatomic, readonly) NSString *contentInfoText;
//@property (nonatomic, readonly) NSString *contentInfoHorizontalPosition;
//@property (nonatomic, readonly) NSString *contentInfoVeritcalPosition;
@property (nonatomic, readonly) NSNumber *interstitialHtmlSkipOffset;
@property (nonatomic, readonly) NSNumber *pcInterstitialHtmlSkipOffset;
@property (nonatomic, readonly) NSNumber *videoSkipOffset;
@property (nonatomic, readonly) NSNumber *pcVideoSkipOffset;
@property (nonatomic, readonly) NSNumber *bcVideoSkipOffset;
@property (nonatomic, readonly) NSNumber *rewardedHtmlSkipOffset;
@property (nonatomic, readonly) NSNumber *pcRewardedHtmlSkipOffset;
@property (nonatomic, readonly) NSNumber *rewardedVideoSkipOffset;
@property (nonatomic, readonly) NSNumber *pcRewardedVideoSkipOffset;
@property (nonatomic, readonly) NSNumber *bcRewardedVideoSkipOffset;
@property (nonatomic, readonly) NSNumber *endcardCloseDelay;
@property (nonatomic, readonly) NSNumber *pcEndcardCloseDelay;
@property (nonatomic, readonly) NSNumber *bcEndcardCloseDelay;
@property (nonatomic, readonly) NSNumber *nativeCloseButtonDelay;
@property (nonatomic, readonly) NSNumber *minVisibleTime;
@property (nonatomic, readonly) NSNumber *minVisiblePercent;
@property (nonatomic, readonly) NSString *impressionTrackingMethod;
@property (nonatomic, readonly) NSString *customEndcardDisplay;
@property (nonatomic, readonly) NSNumber *customCtaDelay;
@property (nonatomic, readonly) NSString *customCtaIconURL;
@property (nonatomic, readonly) NSString *customCtaInputValue;
@property (nonatomic, readonly) NSNumber *sdkAutoStorekitDelay;
@property (nonatomic, readonly) NSDictionary *skAdNetworkModelInputValue;
@property (nonatomic, readonly) NSString *itunesIdValue;
@property (nonatomic, assign) BOOL iconSizeReduced;
@property (nonatomic, assign) BOOL hideControls;
@property (nonatomic, assign) BOOL isBrandCompatible;
@property (nonatomic, readonly) NSString *navigationMode;
@property (nonatomic, assign) BOOL landingPage;

// The following 15 properties are created as NSNumber instead of BOOL beacuse it'll be important whether they have a value or not when we'll decide which setting to use.
@property (nonatomic, readonly) NSNumber *endcardEnabled;
@property (nonatomic, readonly) NSNumber *pcEndcardEnabled;
@property (nonatomic, readonly) NSNumber *customEndcardEnabled;
@property (nonatomic, readonly) NSString *customEndCardInputValue;
@property (nonatomic, readonly) NSNumber *skoverlayEnabled;
@property (nonatomic, readonly) NSNumber *pcSKoverlayEnabled;
@property (nonatomic, readonly) NSNumber *closeInterstitialAfterFinish;
@property (nonatomic, readonly) NSNumber *closeRewardedAfterFinish;
@property (nonatomic, readonly) NSNumber *fullscreenClickability;
@property (nonatomic, readonly) NSNumber *mraidExpand;
@property (nonatomic, readonly) NSNumber *creativeAutoStorekitEnabled;
@property (nonatomic, readonly) NSNumber *customCtaEnabled;
@property (nonatomic, readonly) NSNumber *sdkAutoStorekitEnabled;
@property (nonatomic, readonly) NSNumber *pcSDKAutoStorekitEnabled;
@property (nonatomic, readonly) NSNumber *atomEnabled;

// Reporting Properties:
@property (nonatomic, assign) BOOL shouldReportCustomEndcardImpression;

- (instancetype)initWithData:(HyBidAdModel *)data withZoneID:(NSString *)zoneID;

#if __has_include(<ATOM/ATOM-Swift.h>)
- (instancetype)initWithData:(HyBidAdModel *)data withZoneID:(NSString *)zoneID withCohorts:(NSArray<NSString *> *)cohorts;
- (instancetype)initOpenRTBWithData:(HyBidAdModel *)data withZoneID:(NSString *)zoneID withCohorts:(NSArray<NSString *> *)cohorts;
#endif

- (instancetype)initOpenRTBWithData:(HyBidAdModel *)data withZoneID:(NSString *)zoneID;
- (instancetype)initWithAssetGroup:(NSInteger)assetGroup withAdContent:(NSString *)adContent withAdType:(NSInteger)adType;
- (instancetype)initWithAssetGroupForOpenRTB:(NSInteger)assetGroup withAdContent:(NSString *)adContent withAdType:(NSInteger)adType withBidObject:(NSDictionary *)bidObject;
- (HyBidDataModel *)assetDataWithType:(NSString *)type;
- (HyBidOpenRTBDataModel *)openRTBAssetDataWithType:(NSString *)type;
- (HyBidDataModel *)metaDataWithType:(NSString *)type;
- (NSArray *)beaconsDataWithType:(NSString *)type;
- (HyBidSkAdNetworkModel *)getSkAdNetworkModel;
- (HyBidSkAdNetworkModel *)getOpenRTBSkAdNetworkModel;
- (HyBidContentInfoView *)getContentInfoView;
- (HyBidContentInfoView *)getContentInfoViewFrom:(HyBidContentInfoView *)infoView;

@end
