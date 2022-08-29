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

- (instancetype)initWithData:(HyBidAdModel *)data withZoneID:(NSString *)zoneID;
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
