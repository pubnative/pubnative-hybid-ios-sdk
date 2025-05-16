// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

static NSString* PNLiteMRAIDSupportsSMS = @"sms";
static NSString* PNLiteMRAIDSupportsTel = @"tel";
static NSString* PNLiteMRAIDSupportsStorePicture = @"storePicture";
static NSString* PNLiteMRAIDSupportsInlineVideo = @"inlineVideo";
static NSString* PNLiteMRAIDSupportsLocation = @"location";


// A delegate for MRAIDView/MRAIDInterstitial to listen for notifications when the following events
// are triggered from a creative: SMS, Telephone call, Play Video (external) and
// saving pictures. If you don't implement this protocol, the default for
// supporting these features for creative will be FALSE.

@protocol HyBidMRAIDServiceDelegate <NSObject>

@optional

// These callbacks are to request other services.
- (void)mraidServicePlayVideoWithUrlString:(NSString *)urlString;
- (void)mraidServiceOpenBrowserWithUrlString:(NSString *)urlString;
- (void)mraidServiceStorePictureWithUrlString:(NSString *)urlString;
- (void)mraidServiceSendSMSWithUrlString:(NSString *)urlString;
- (void)mraidServiceCallNumberWithUrlString:(NSString *)urlString;
- (void)mraidServiceTrackingEndcardWithUrlString:(NSString *)urlString;

@end
