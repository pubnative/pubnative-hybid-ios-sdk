// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>

@class HyBidAdTrackerRequest;

@protocol HyBidAdTrackerRequestDelegate <NSObject>

- (void)requestDidStart:(HyBidAdTrackerRequest *)request;
- (void)requestDidFinish:(HyBidAdTrackerRequest *)request;
- (void)request:(HyBidAdTrackerRequest *)request didFailWithError:(NSError *)error;

@end

@interface HyBidAdTrackerRequest : NSObject

@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSString *trackingType;

- (void)trackAdWithDelegate:(NSObject<HyBidAdTrackerRequestDelegate> *)delegate
                    withURL:(NSString *)url
           withTrackingType:(NSString *)trackingType;

@end
