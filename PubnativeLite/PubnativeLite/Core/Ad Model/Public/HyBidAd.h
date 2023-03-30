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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HyBidAdModel.h"
#import "HyBidContentInfoView.h"
#import "HyBidSkAdNetworkModel.h"
#import "HyBidOpenRTBDataModel.h"

#define kHyBidAdTypeHTML 0
#define kHyBidAdTypeVideo 1
#define kHyBidAdTypeUnsupported 2

typedef struct {
    int fidelity;
    char *signature;
    char *nonce;
    char *timestamp;
} SKANObject;

@interface HyBidAd : NSObject

@property (nonatomic, readonly) NSString *vast;
@property (nonatomic, readonly) NSString *openRtbVast;
@property (nonatomic, readonly) NSString *htmlUrl;
@property (nonatomic, readonly) NSString *htmlData;
@property (nonatomic, readonly) NSString *link;
@property (nonatomic, readonly) NSString *impressionID;
@property (nonatomic, readonly) NSString *creativeID;
@property (nonatomic, readonly) NSString *zoneID;

#if __has_include(<ATOM/ATOM-Swift.h>)
@property (nonatomic, readonly) NSArray<NSString *> *cohorts;
#endif

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
@property (nonatomic, readonly) NSString *audioState;
@property (nonatomic, readonly) NSString *contentInfoURL;
@property (nonatomic, readonly) NSString *contentInfoIconURL;
@property (nonatomic, readonly) NSString *contentInfoIconClickAction;
@property (nonatomic, readonly) NSString *contentInfoDisplay;
@property (nonatomic, readonly) NSString *contentInfoText;
@property (nonatomic, readonly) NSString *contentInfoHorizontalPosition;
@property (nonatomic, readonly) NSString *contentInfoVeritcalPosition;
@property (nonatomic, readonly) NSNumber *interstitialHtmlSkipOffset;
@property (nonatomic, readonly) NSNumber *rewardedHtmlSkipOffset;
@property (nonatomic, readonly) NSNumber *videoSkipOffset;
@property (nonatomic, readonly) NSNumber *endcardCloseDelay;
@property (nonatomic, readonly) NSNumber *minVisibleTime;
@property (nonatomic, readonly) NSNumber *minVisiblePercent;
@property (nonatomic, readonly) NSString *impressionTrackingMethod;
// The following 6 properties are created as NSNumber instead of BOOL beacuse it'll be important whether they have a value or not when we'll decide which setting to use.
@property (nonatomic, readonly) NSNumber *endcardEnabled;
@property (nonatomic, readonly) NSNumber *skoverlayEnabled;
@property (nonatomic, readonly) NSNumber *closeInterstitialAfterFinish;
@property (nonatomic, readonly) NSNumber *closeRewardedAfterFinish;
@property (nonatomic, readonly) NSNumber *fullscreenClickability;
@property (nonatomic, readonly) NSNumber *mraidExpand;

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
