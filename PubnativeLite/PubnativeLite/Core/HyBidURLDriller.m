// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidURLDriller.h"
#import "HyBidWebBrowserUserAgentInfo.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

NSTimeInterval const kHyBidURLDrillerTimeout = 5; // seconds

@interface HyBidURLDriller () <NSURLSessionTaskDelegate>

@property (nonatomic, weak) NSObject<HyBidURLDrillerDelegate> *delegate;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURL *lastURL;
@property (nonatomic, strong) NSString *trackingType;

@end

@implementation HyBidURLDriller

- (void)dealloc {
    self.delegate = nil;
    self.url = nil;
    self.lastURL = nil;
    self.trackingType = nil;
}

- (void)startDrillWithURLString:(NSString *)urlString
                       delegate:(NSObject<HyBidURLDrillerDelegate> *)delegate
               withTrackingType:(NSString *)trackingType {
    self.trackingType = trackingType;
    [self startDrillWithURLString:urlString delegate:delegate];
}

- (void)startDrillWithURLString:(NSString *)urlString delegate:(NSObject<HyBidURLDrillerDelegate>*)delegate {
    if(delegate == nil) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"HyBidURLDrillerDelegate is nil and required, dropping this call."];
    } else if (urlString == nil || urlString.length == 0) {
        [HyBidLogger warningLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:@"URL String is nil and required, dropping this call."];
    } else {
        self.delegate = delegate;
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *escapedPath = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                self.url = [NSURL URLWithString:escapedPath];
                [self invokeDidStartWithURL:self.url];
                if ([self isFinalURL:self.url]) {
                    [self invokeDidFinishWithURL:self.url];
                } else {
                    [self startDrill];
                }
            });
        });
    }
}

- (void)startDrill {
    self.lastURL = self.url;
    NSString *className = NSStringFromClass([self class]);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:kHyBidURLDrillerTimeout];
        
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSDictionary *additionalHeadersDict = @{ @"User-Agent": HyBidWebBrowserUserAgentInfo.hyBidUserAgent };
    [sessionConfiguration setHTTPAdditionalHeaders:additionalHeadersDict];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            [self invokeDidFailWithURL:self.lastURL andError:error];
            if ([HyBidSDKConfig sharedConfig].reporting) {
                HyBidReportingEvent* reportingEvent = [[HyBidReportingEvent alloc]initWith:HyBidReportingEventType.ERROR errorMessage: error.localizedDescription properties:nil];
                [[HyBid reportingManager] reportEventFor:reportingEvent];
            }
        } else {
            [self invokeDidFinishWithURL:response.URL];
            [HyBidLogger debugLogFromClass:className fromMethod:NSStringFromSelector(_cmd) withMessage:[NSString stringWithFormat:@"Tracking url: %@", response.URL]];
        }
    }];
    
    [task resume];
    
}

- (BOOL)isFinalURL:(NSURL*)url {
    BOOL result = NO;
    NSString *scheme = nil;
    if (url) {
        scheme = url.scheme;
    }
    if ([scheme isEqualToString:@"http"]
        || [scheme isEqualToString:@"itmss"]
        || [scheme isEqualToString:@"itms-apps"]
        || [scheme isEqualToString:@"itms-appss"]) {
        result = YES;
    }
    return result;
}

- (void)invokeDidFinishWithURL:(NSURL*)url {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(didFinishWithURL:trackingType:)]){
            [self.delegate didFinishWithURL:url trackingType:self.trackingType];
        }
    });
}

- (void)invokeDidFailWithURL:(NSURL*)url andError:(NSError*)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(didFailWithURL:andError:)]){
            [self.delegate didFailWithURL:url andError:error];
        }
    });
}

- (void)invokeDidRedirectWithURL:(NSURL*)url {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(didRedirectWithURL:)]){
            [self.delegate didRedirectWithURL:url];
        }
    });
}

- (void)invokeDidStartWithURL:(NSURL*)url {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(didStartWithURL:)]){
            [self.delegate didStartWithURL:url];
        }
    });
}

#pragma mark NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler {
    [self invokeDidRedirectWithURL:request.URL];
    if ([self isFinalURL:request.URL]) {
        [self invokeDidFinishWithURL:request.URL];
    } else {
        completionHandler(request);
    }
}

@end
