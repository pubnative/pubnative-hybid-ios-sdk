// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <WebKit/WebKit.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HyBidNavigatorGeolocation : NSObject

-(void)assignWebView:(WKWebView*) externalwebView;

-(NSString*) getJavaScriptToEvaluate;

@end

NS_ASSUME_NONNULL_END
