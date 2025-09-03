// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@interface HyBidRequestParameter : NSObject

+ (NSString * _Nonnull)appToken;
+ (NSString * _Nonnull)os;
+ (NSString * _Nonnull)osVersion;
+ (NSString * _Nonnull)deviceModel;
+ (NSString * _Nonnull)deviceWidth;
+ (NSString * _Nonnull)deviceHeight;
+ (NSString * _Nonnull)orientation;
+ (NSString * _Nonnull)dnt;
+ (NSString * _Nonnull)locale;
+ (NSString * _Nonnull)adCount;
+ (NSString * _Nonnull)zoneId;
+ (NSString * _Nonnull)deviceModelIdentifier;
+ (NSString * _Nonnull)deviceMake;
+ (NSString * _Nonnull)deviceType;
+ (NSString * _Nonnull)screenWidthInPixels;
+ (NSString * _Nonnull)screenHeightInPixels;
+ (NSString * _Nonnull)pxRatio;
+ (NSString * _Nonnull)geoFetch;
+ (NSString * _Nonnull)js;
+ (NSString * _Nonnull)language;
+ (NSString * _Nonnull)langb;
+ (NSString * _Nonnull)carrier;
+ (NSString * _Nonnull)carrierMCCMNC;
+ (NSString * _Nonnull)connectiontype;
+ (NSString * _Nonnull)lat;
+ (NSString * _Nonnull)lon;
+ (NSString * _Nonnull)gender;
+ (NSString * _Nonnull)age;
+ (NSString * _Nonnull)keywords;
+ (NSString * _Nonnull)appVersion;
+ (NSString * _Nonnull)test;
+ (NSString * _Nonnull)video;
+ (NSString * _Nonnull)metaField;
+ (NSString * _Nonnull)assetsField;
+ (NSString * _Nonnull)idfa;
+ (NSString * _Nonnull)idfamd5;
+ (NSString * _Nonnull)idfasha1;
+ (NSString * _Nonnull)coppa;
+ (NSString * _Nonnull)assetLayout;
+ (NSString * _Nonnull)bundleId;
+ (NSString * _Nonnull)displayManager;
+ (NSString * _Nonnull)displayManagerVersion;
+ (NSString * _Nonnull)width;
+ (NSString * _Nonnull)height;
+ (NSString * _Nonnull)usprivacy;
+ (NSString * _Nonnull)userconsent;
+ (NSString * _Nonnull)gppstring;
+ (NSString * _Nonnull)gppsid;
+ (NSString * _Nonnull)supportedAPIFrameworks;
+ (NSString * _Nonnull)identifierOfOMSDKIntegration;
+ (NSString * _Nonnull)versionOfOMSDKIntegration;
+ (NSString * _Nonnull)identifierForVendor;
+ (NSString * _Nonnull)rewardedVideo;
+ (NSString * _Nonnull)protocol;
+ (NSString * _Nonnull)api;
+ (NSString * _Nonnull)appTrackingTransparency;
+ (NSString * _Nonnull)sessionDuration;
+ (NSString * _Nonnull)impressionDepth;
+ (NSString * _Nonnull)ageOfApp;
+ (NSString * _Nonnull)accuracy;
+ (NSString * _Nonnull)utcoffset;
+ (NSString * _Nonnull)charging;
+ (NSString * _Nonnull)batteryLevel;
+ (NSString * _Nonnull)batterySaver;
+ (NSString * _Nonnull)interstitial;
+ (NSString * _Nonnull)clickbrowser;
+ (NSString * _Nonnull)topframe;
+ (NSString * _Nonnull)mimes;
+ (NSString * _Nonnull)expandDirection;
+ (NSString * _Nonnull)pos;
+ (NSString * _Nonnull)videomimes;
+ (NSString * _Nonnull)placement;
+ (NSString * _Nonnull)placementSubtype;
+ (NSString * _Nonnull)linearity;
+ (NSString * _Nonnull)boxingallowed;
+ (NSString * _Nonnull)playbackmethod;
+ (NSString * _Nonnull)playbackend;
+ (NSString * _Nonnull)clickType;
+ (NSString * _Nonnull)delivery;
+ (NSString * _Nonnull)videoPosition;
+ (NSString * _Nonnull)mraidendcard;
+ (NSString * _Nonnull)darkmode;
+ (NSString * _Nonnull)airplaneMode;
+ (NSString * _Nonnull)btype;
+ (NSString * _Nonnull)hver;

#pragma mark - SKAdNetwork parameters
+ (NSString * _Nonnull)skAdNetworkVersion;
+ (NSString * _Nonnull)skAdNetworkAppID;
+ (NSString * _Nonnull)skAdNetworkAdNetworkIDs;

#pragma mark - OpenRTB API
+ (NSString * _Nonnull)ip;
+ (NSString * _Nonnull)userAgent;
+ (NSString * _Nonnull)uuid;
+ (NSString * _Nonnull)app;
+ (NSString * _Nonnull)device;
+ (NSString * _Nonnull)imp;
+ (NSString * _Nonnull)extension;
+ (NSString * _Nonnull)geolocation;

#pragma mark - Voyager parameters
+ (NSString * _Nonnull)vg;

#pragma mark - DSPv1 / OpenRTB parameters
+ (NSString * _Nonnull)openRTBgdpr;
+ (NSString * _Nonnull)openRTBgpp;
+ (NSString * _Nonnull)openRTBgpp_sid;
+ (NSString * _Nonnull)openRTBus_privacy;
@end
