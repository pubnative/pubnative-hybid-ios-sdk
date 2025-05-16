// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HyBidAdRequest.h"
#import "PNLiteAdRequestModel.h"

@class PNLiteHttpRequest;

@protocol PNLiteHttpRequestDelegate <NSObject>

- (void)request:(PNLiteHttpRequest *)request didFinishWithData:(NSData *)data statusCode:(NSInteger)statusCode;
- (void)request:(PNLiteHttpRequest *)request didFailWithError:(NSError *)error;

@end

@interface PNLiteHttpRequest : NSObject

@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSDictionary *header;
@property (nonatomic, strong) NSData *body;
@property (nonatomic, assign) BOOL shouldRetry;
@property (nonatomic, assign) BOOL isUsingOpenRTB;
@property (nonatomic) HyBidOpenRTBAdType openRTBAdType;
@property (nonatomic, strong) PNLiteAdRequestModel *adRequestModel;
@property (nonatomic, strong) NSString *trackingType;

- (void)startWithUrlString:(NSString *)urlString withMethod:(NSString *)method delegate:(NSObject<PNLiteHttpRequestDelegate>*)delegate;
- (void)startWithUrlString:(NSString *)urlString
                withMethod:(NSString *)method
                  delegate:(NSObject<PNLiteHttpRequestDelegate>*)delegate
          withTrackingType:(NSString *)trackingType;


@end
