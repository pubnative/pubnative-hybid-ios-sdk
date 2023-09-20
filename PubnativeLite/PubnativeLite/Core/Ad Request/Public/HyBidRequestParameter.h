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

@interface HyBidRequestParameter : NSObject

+ (NSString *)appToken;
+ (NSString *)os;
+ (NSString *)osVersion;
+ (NSString *)deviceOsVersion;
+ (NSString *)deviceModel;
+ (NSString *)deviceWidth;
+ (NSString *)deviceHeight;
+ (NSString *)orientation;
+ (NSString *)dnt;
+ (NSString *)locale;
+ (NSString *)adCount;
+ (NSString *)zoneId;
+ (NSString *)deviceModelIdentifier;
+ (NSString *)deviceMake;
+ (NSString *)deviceType;
+ (NSString *)screenWidthInPixels;
+ (NSString *)screenHeightInPixels;
+ (NSString *)pxRatio;
+ (NSString *)geoFetch;
+ (NSString *)js;
+ (NSString *)language;
+ (NSString *)langb;
+ (NSString *)carrier;
+ (NSString *)carrierMCCMNC;
+ (NSString *)connectiontype;
+ (NSString *)lat;
+ (NSString *)lon;
+ (NSString *)gender;
+ (NSString *)age;
+ (NSString *)keywords;
+ (NSString *)appVersion;
+ (NSString *)test;
+ (NSString *)video;
+ (NSString *)metaField;
+ (NSString *)assetsField;
+ (NSString *)idfa;
+ (NSString *)idfamd5;
+ (NSString *)idfasha1;
+ (NSString *)coppa;
+ (NSString *)assetLayout;
+ (NSString *)bundleId;
+ (NSString *)displayManager;
+ (NSString *)displayManagerVersion;
+ (NSString *)width;
+ (NSString *)height;
+ (NSString *)usprivacy;
+ (NSString *)userconsent;
+ (NSString *)supportedAPIFrameworks;
+ (NSString *)identifierOfOMSDKIntegration;
+ (NSString *)versionOfOMSDKIntegration;
+ (NSString *)identifierForVendor;
+ (NSString *)rewardedVideo;
+ (NSString *)protocol;
+ (NSString *)api;
+ (NSString *)appTrackingTransparency;
+ (NSString *)sessionDuration;
+ (NSString *)impressionDepth;
+ (NSString *)ageOfApp;
+ (NSString *)accuracy;
+ (NSString *)utcoffset;
+ (NSString *)charging;
+ (NSString *)batteryLevel;
+ (NSString *)batterySaver;
+ (NSString *)interstitial;
+ (NSString *)clickbrowser;
+ (NSString *)topframe;
+ (NSString *)mimes;
+ (NSString *)expandDirection;
+ (NSString *)pos;
+ (NSString *)videomimes;
+ (NSString *)placement;
+ (NSString *)placementSubtype;
+ (NSString *)linearity;
+ (NSString *)boxingallowed;
+ (NSString *)playbackmethod;
+ (NSString *)playbackend;
+ (NSString *)clickType;
+ (NSString *)delivery;
+ (NSString *)videoPosition;
+ (NSString *)mraidendcard;
+ (NSString *)darkmode;
+ (NSString *)airplaneMode;

#pragma mark - SKAdNetwork parameters
+ (NSString *)skAdNetworkVersion;
+ (NSString *)skAdNetworkAppID;
+ (NSString *)skAdNetworkAdNetworkIDs;

#pragma mark - OpenRTB API
+ (NSString *)ip;

#pragma mark - Voyager parameters
+ (NSString *)vg;

@end
