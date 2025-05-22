// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidAdTrackerRequest.h"
#import "PNLiteHttpRequest.h"
#import "HyBidError.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

NSInteger const PNLiteResponseStatusRequestNotFound = 404;

@interface HyBidAdTrackerRequest() <PNLiteHttpRequestDelegate>

@property (nonatomic, weak) NSObject <HyBidAdTrackerRequestDelegate> *delegate;

@end

@implementation HyBidAdTrackerRequest

- (void)dealloc {
    self.delegate = nil;
    self.urlString = nil;
    self.trackingType = nil;
}

- (void)trackAdWithDelegate:(NSObject<HyBidAdTrackerRequestDelegate> *)delegate
                    withURL:(NSString *)url
           withTrackingType:(NSString *)trackingType{
    if(!delegate) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd)withMessage:@"Given delegate is nil and required, droping this call."];
    } else if(!url || url.length == 0) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd)withMessage:@"URL nil or empty, droping this call."];
    } else {
        self.delegate = delegate;
        self.urlString = url;
        self.trackingType = trackingType;
        [self invokeDidStart];
        [[PNLiteHttpRequest alloc] startWithUrlString:url withMethod:@"GET" delegate:self withTrackingType:trackingType];
    }
}

- (void)invokeDidStart {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestDidStart:)]) {
            [self.delegate requestDidStart:self];
        }
    });
}

- (void)invokeDidLoad {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestDidFinish:)]) {
            [self.delegate requestDidFinish:self];
        }
    });
}

- (void)invokeDidFail:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd)withMessage:error.localizedDescription];
        if(self.delegate && [self.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
            [self.delegate request:self didFailWithError:error];
        }
    });
}

#pragma mark PNLiteHttpRequestDelegate

- (void)request:(PNLiteHttpRequest *)request didFinishWithData:(NSData *)data statusCode:(NSInteger)statusCode {
    self.urlString = request.urlString;
    self.trackingType = request.trackingType;
    if(PNLiteResponseStatusRequestNotFound == statusCode) {
        NSError *statusError = [NSError hyBidServerError];
        [self invokeDidFail:statusError];
    } else {
        [self invokeDidLoad];
    }
}

- (void)request:(PNLiteHttpRequest *)request didFailWithError:(NSError *)error {
    self.urlString = request.urlString;
    self.trackingType = request.trackingType;
    [self invokeDidFail:error];
}

@end
