//
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidBeaconsInspectorHelper.h"
#import "HyBidAd.h"
#import "HyBidAdModel.h"
#import "HyBidDataModel.h"
#import "HyBidVASTAd.h"
#import "HyBidVASTAdInline.h"
#import "HyBidVASTAdWrapper.h"
#import "HyBidVASTClickTracking.h"
#import "HyBidVASTCompanion.h"
#import "HyBidVASTCompanionAds.h"
#import "HyBidVASTCompanionClickThrough.h"
#import "HyBidVASTCreative.h"
#import "HyBidVASTImpression.h"
#import "HyBidVASTLinear.h"
#import "HyBidVASTParser.h"
#import "HyBidVASTParserError.h"
#import "HyBidVASTTracking.h"
#import "HyBidVASTTrackingEvents.h"
#import "HyBidVASTVideoClicks.h"
#import "HyBidXMLEx.h"
#import "PNLiteData.h"
#import "PNLiteRequestInspector.h"
#import "PNLiteRequestInspectorModel.h"
#import "PNLiteResponseModel.h"
#if __has_include(<HyBid/HyBid-Swift.h>)
#import <HyBid/HyBid-Swift.h>
#else
#import "HyBid-Swift.h"
#endif

static NSString *const kBeaconKeyType = @"type";
static NSString *const kBeaconKeyUrl = @"url";
static NSString *const kBeaconKeyJs = @"js";
static NSString *const kVast2Key = @"vast2";
static NSString *const kVASTZoneID = @"6";
static NSString *const kVASTTrackerImpression = @"Impression";
static NSString *const kVASTTrackerClickTracking = @"ClickTracking";
static NSString *const kVASTTrackerCompanionClickThrough =
    @"CompanionClickThrough";

@implementation HyBidBeaconsInspectorHelper

+ (void)adBeaconDictionariesFromLastResponseWithCompletion:
    (void (^)(NSArray<NSDictionary<NSString *, id> *> *))completion {
  if (!completion) {
    return;
  }
  PNLiteRequestInspectorModel *lastRequest =
      [PNLiteRequestInspector sharedInstance].lastInspectedRequest;
  NSString *response = lastRequest.response;
  [self adBeaconDictionariesFromResponse:response completion:completion];
}

+ (void)
    adBeaconDictionariesFromResponse:(NSString *)response
                          completion:
                              (void (^)(NSArray<NSDictionary<NSString *, id> *>
                                            *))completion {
  if (!completion) {
    return;
  }
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
          if (!response || !response.length) {
            dispatch_async(dispatch_get_main_queue(), ^{
              completion(@[]);
            });
            return;
          }
          NSMutableArray<NSDictionary<NSString *, id> *> *items =
              [NSMutableArray array];
          NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
          id json = data ? [NSJSONSerialization
                               JSONObjectWithData:data
                                          options:NSJSONReadingMutableContainers
                                            error:NULL]
                         : nil;

          if ([json isKindOfClass:[NSDictionary class]]) {
            PNLiteResponseModel *responseModel =
                [[PNLiteResponseModel alloc] initWithDictionary:json];
            NSArray *ads = responseModel.ads;
            HyBidAdModel *adModel = [ads firstObject];
            if (adModel) {
              NSArray<HyBidDataModel *> *adBeacons = adModel.beacons;
              if (adBeacons.count) {
                for (HyBidDataModel *dm in adBeacons) {
                  NSString *type = dm.type;
                  if (type.length) {
                    type = [[[type substringToIndex:1] uppercaseString]
                        stringByAppendingString:[type substringFromIndex:1]];
                  } else {
                    type = @"";
                  }
                  [items addObject:@{
                    kBeaconKeyType : type,
                    kBeaconKeyUrl : dm.url ?: [NSNull null],
                    kBeaconKeyJs : dm.js ?: [NSNull null]
                  }];
                }
              }
              NSArray *assets = adModel.assets;
              HyBidDataModel *asset = [assets firstObject];
              NSDictionary *dataDict =
                  [asset.data isKindOfClass:[NSDictionary class]] ? asset.data
                                                                  : nil;
              NSString *vastString = dataDict[kVast2Key];
              if (vastString.length) {
                HyBidAd *ad = [[HyBidAd alloc] initWithData:adModel
                                                 withZoneID:kVASTZoneID];
                [self
                    vastBeaconDictionariesFromVASTString:vastString
                                                      ad:ad
                                              completion:^(
                                                  NSArray<NSDictionary<
                                                      NSString *, id> *>
                                                      *vastItems) {
                                                [items addObjectsFromArray:
                                                           vastItems ?: @[]];
                                                [self sortBeaconDictionaries:
                                                          items];
                                                dispatch_async(
                                                    dispatch_get_main_queue(),
                                                    ^{
                                                      completion([items copy]);
                                                    });
                                              }];
                return;
              }
            }
          } else {
            [self
                vastBeaconDictionariesFromVASTString:response
                                                  ad:nil
                                          completion:^(
                                              NSArray<NSDictionary<NSString *,
                                                                   id> *>
                                                  *vastItems) {
                                            [items
                                                addObjectsFromArray:vastItems
                                                                        ?: @[]];
                                            [self sortBeaconDictionaries:items];
                                            dispatch_async(
                                                dispatch_get_main_queue(), ^{
                                                  completion([items copy]);
                                                });
                                          }];
            return;
          }

          [self sortBeaconDictionaries:items];
          dispatch_async(dispatch_get_main_queue(), ^{
            completion([items copy]);
          });
        } @catch (NSException *exception) {
          dispatch_async(dispatch_get_main_queue(), ^{
            completion(@[]);
          });
        }
      });
}

+ (void)
    vastBeaconDictionariesFromVASTString:(NSString *)vastString
                                      ad:(nullable HyBidAd *)ad
                              completion:
                                  (void (^)(
                                      NSArray<NSDictionary<NSString *, id> *>
                                          *))completion {
  if (!completion) {
    return;
  }
  NSData *vastData = [vastString dataUsingEncoding:NSUTF8StringEncoding];
  if (!vastData.length) {
    completion(@[]);
    return;
  }
  HyBidVASTParser *parser = [[HyBidVASTParser alloc] init];

  [parser
      parseWithData:vastData
         completion:^(HyBidVASTModel *model, HyBidVASTParserError *error) {
           dispatch_async(
               dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                 NSMutableArray<NSDictionary<NSString *, id> *> *items =
                     [NSMutableArray array];
                 NSArray *vastArray = [model.vastArray copy];

                 if (![vastArray isKindOfClass:[NSArray class]] ||
                     vastArray.count == 0) {
                   dispatch_async(dispatch_get_main_queue(), ^{
                     completion([items copy]);
                   });
                   return;
                 }
                 NSOrderedSet *orderedSet =
                     [NSOrderedSet orderedSetWithArray:vastArray];
                 NSArray *orderedArray = orderedSet.array;

                 for (id vastDoc in orderedArray) {
                   if (![vastDoc isKindOfClass:[NSData class]]) {
                     continue;
                   }
                   NSString *xml =
                       [[NSString alloc] initWithData:vastDoc
                                             encoding:NSUTF8StringEncoding];
                   if (!xml.length) {
                     continue;
                   }
                   HyBidXMLEx *xmlParser = [HyBidXMLEx parserWithXML:xml];
                   HyBidXMLElementEx *root = [xmlParser rootElement];
                   NSArray *adResults = [root query:@"Ad"];
                   for (id result in adResults) {
                     if (![result isKindOfClass:[HyBidXMLElementEx class]]) {
                       continue;
                     }
                     HyBidVASTAd *vastAd = [[HyBidVASTAd alloc]
                         initWithXMLElement:(HyBidXMLElementEx *)result];
                     HyBidVASTAdWrapper *wrapper = [vastAd wrapper];
                     HyBidVASTAdInline *inLine = [vastAd inLine];
                     if (wrapper) {
                       [self processCreatives:wrapper.creatives ?: @[]
                                           ad:ad
                                         into:items];
                       for (HyBidVASTImpression *imp in wrapper.impressions
                                ?: @[]) {
                         NSString *url = [imp url];
                         if (url.length) {
                           [items addObject:@{
                             kBeaconKeyType : kVASTTrackerImpression,
                             kBeaconKeyUrl : url,
                             kBeaconKeyJs : [NSNull null]
                           }];
                         }
                       }
                     } else if (inLine) {
                       [self processCreatives:inLine.creatives ?: @[]
                                           ad:ad
                                         into:items];
                       for (HyBidVASTImpression *imp in inLine.impressions
                                ?: @[]) {
                         NSString *url = [imp url];
                         if (url.length) {
                           [items addObject:@{
                             kBeaconKeyType : kVASTTrackerImpression,
                             kBeaconKeyUrl : url,
                             kBeaconKeyJs : [NSNull null]
                           }];
                         }
                       }
                     }
                     NSArray *creatives = wrapper ? (wrapper.creatives ?: @[])
                                                  : (inLine.creatives ?: @[]);
                     [self parseCompanionClickThroughFromCreatives:creatives
                                                              into:items];
                   }
                 }

                 dispatch_async(dispatch_get_main_queue(), ^{
                   completion([items copy]);
                 });
               });
         }];
}

+ (NSString *)firstCapitalizedTypeFromEvent:(NSString *)event {
  if (!event.length) {
    return @"";
  }
  return [[[event substringToIndex:1] uppercaseString]
      stringByAppendingString:[event substringFromIndex:1]];
}

+ (void)processCreatives:(NSArray<HyBidVASTCreative *> *)creatives
                      ad:(nullable HyBidAd *)ad
                    into:(NSMutableArray<NSDictionary<NSString *, id> *> *)
                             items {
  for (HyBidVASTCreative *creative in creatives) {
    HyBidVASTLinear *linear = [creative linear];

    if (linear) {
      HyBidVASTTrackingEvents *trackingObj = [linear trackingEvents];
      NSArray<HyBidVASTTracking *> *events = [trackingObj events];
      if (events.count) {
        for (HyBidVASTTracking *tracking in events) {
          NSString *event = [tracking event];
          NSString *url = [tracking url];
          if (event.length && url.length) {
            [items addObject:@{
              kBeaconKeyType : [self firstCapitalizedTypeFromEvent:event],
              kBeaconKeyUrl : url,
              kBeaconKeyJs : [NSNull null]
            }];
          }
        }
      }
      HyBidVASTVideoClicks *videoClicks = [linear videoClicks];
      if (videoClicks) {
        for (HyBidVASTClickTracking *clickTracking in
             [videoClicks clickTrackings]) {
          NSString *content = [clickTracking content];
          if (content.length) {
            [items addObject:@{
              kBeaconKeyType : kVASTTrackerClickTracking,
              kBeaconKeyUrl : content,
              kBeaconKeyJs : [NSNull null]
            }];
          }
        }
      }
    }

    HyBidVASTCompanionAds *companionAds = [creative companionAds];
    if (companionAds) {
      for (HyBidVASTCompanion *companion in [companionAds companions]) {
        HyBidVASTTrackingEvents *compEvents = [companion trackingEvents];
        NSArray<HyBidVASTTracking *> *compTrackingList = [compEvents events];
        for (HyBidVASTTracking *tracking in compTrackingList) {
          NSString *event = [tracking event];
          NSString *url = [tracking url];
          if (event.length && url.length) {
            [items addObject:@{
              kBeaconKeyType : [self firstCapitalizedTypeFromEvent:event],
              kBeaconKeyUrl : url,
              kBeaconKeyJs : [NSNull null]
            }];
          }
        }
      }
    }
  }
}

+ (void)parseCompanionClickThroughFromCreatives:
            (NSArray<HyBidVASTCreative *> *)creatives
                                           into:
                                               (NSMutableArray<NSDictionary<
                                                    NSString *, id> *> *)items {
  for (HyBidVASTCreative *creative in creatives) {
    HyBidVASTCompanionAds *companionAds = [creative companionAds];
    if (!companionAds) {
      continue;
    }
    for (HyBidVASTCompanion *companion in [companionAds companions]) {
      HyBidVASTCompanionClickThrough *clickThrough =
          [companion companionClickThrough];
      NSString *content = [clickThrough content];
      if (content.length) {
        [items addObject:@{
          kBeaconKeyType : kVASTTrackerCompanionClickThrough,
          kBeaconKeyUrl : content,
          kBeaconKeyJs : [NSNull null]
        }];
      }
    }
  }
}

+ (void)sortBeaconDictionaries:
    (NSMutableArray<NSDictionary<NSString *, id> *> *)items {
  [items sortUsingComparator:^NSComparisonResult(NSDictionary *a,
                                                 NSDictionary *b) {
    NSString *typeA = a[kBeaconKeyType];
    NSString *typeB = b[kBeaconKeyType];
    NSString *contentA = [self contentStringFromBeaconDict:a];
    NSString *contentB = [self contentStringFromBeaconDict:b];
    if (![typeA isEqualToString:typeB]) {
      return [typeA compare:typeB];
    }
    return [contentA compare:contentB];
  }];
}

+ (NSString *)contentStringFromBeaconDict:(NSDictionary<NSString *, id> *)dict {
  id url = dict[kBeaconKeyUrl];
  id js = dict[kBeaconKeyJs];
  if ([url isKindOfClass:[NSString class]] && [(NSString *)url length]) {
    return url;
  }
  if ([js isKindOfClass:[NSString class]] && [(NSString *)js length]) {
    return js;
  }
  return @"";
}

@end
