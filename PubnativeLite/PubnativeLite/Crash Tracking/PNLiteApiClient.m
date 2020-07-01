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

#import "PNLiteApiClient.h"
#import "PNLiteConfiguration.h"
#import "PNLiteCrashTracker.h"
#import "PNLiteKeys.h"
#import "PNLiteCrashLogger.h"

@interface PNLiteDelayOperation : NSOperation
@end

@interface PNLiteApiClient()
@property (nonatomic) NSURLSession *generatedSession;
@end

@implementation PNLiteApiClient

- (instancetype)initWithConfig:(PNLiteConfiguration *)configuration
                     queueName:(NSString *)queueName {
    if (self = [super init]) {
        _sendQueue = [NSOperationQueue new];
        _sendQueue.maxConcurrentOperationCount = 1;
        _config = configuration;

        if ([_sendQueue respondsToSelector:@selector(qualityOfService)]) {
            _sendQueue.qualityOfService = NSQualityOfServiceUtility;
        }
        _sendQueue.name = queueName;
    }
    return self;
}

- (void)flushPendingData {
    [self.sendQueue cancelAllOperations];
    PNLiteDelayOperation *delay = [PNLiteDelayOperation new];
    NSOperation *deliver = [self deliveryOperation];
    [deliver addDependency:delay];
    [self.sendQueue addOperations:@[delay, deliver] waitUntilFinished:NO];
}

- (NSOperation *)deliveryOperation {
    pnlite_log_err(@"Should override deliveryOperation in super class");
    return [NSOperation new];
}

#pragma mark - Delivery


- (void)sendData:(id)data
     withPayload:(NSDictionary *)payload
           toURL:(NSURL *)url
         headers:(NSDictionary *)headers
    onCompletion:(PNLiteRequestCompletion)onCompletion {

    @try {
        NSError *error = nil;
        NSData *jsonData =
                [NSJSONSerialization dataWithJSONObject:payload
                                                options:NSJSONWritingPrettyPrinted
                                                  error:&error];

        if (jsonData == nil) {
            if (onCompletion) {
                onCompletion(data, NO, error);
            }
            return;
        }
        NSMutableURLRequest *request = [self prepareRequest:url headers:headers];

        if ([NSURLSession class]) {
            NSURLSession *session = [self prepareSession];
            NSURLSessionTask *task = [session
                    uploadTaskWithRequest:request
                                 fromData:jsonData
                        completionHandler:^(NSData *_Nullable responseBody,
                                NSURLResponse *_Nullable response,
                                NSError *_Nullable requestErr) {
                            if (onCompletion) {
                                onCompletion(data, requestErr == nil, requestErr);
                            }
                        }];
            [task resume];
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            NSURLResponse *response = nil;
            request.HTTPBody = jsonData;
            [NSURLConnection sendSynchronousRequest:request
                                  returningResponse:&response
                                              error:&error];
            if (onCompletion) {
                onCompletion(data, error == nil, error);
            }
#pragma clang diagnostic pop
        }
    } @catch (NSException *exception) {
        if (onCompletion) {
            onCompletion(data, NO,
                    [NSError            errorWithDomain:exception.reason
                                        code:420
                                    userInfo:@{PNLiteKeyException: exception}]);
        }
    }
}

- (NSURLSession *)prepareSession {
    NSURLSession *session = [PNLiteCrashTracker configuration].session;
    if (session) {
        return session;
    } else {
        if (self.generatedSession) {
            _generatedSession = [NSURLSession
                    sessionWithConfiguration:[NSURLSessionConfiguration
                            defaultSessionConfiguration]];
        }
        return self.generatedSession;
    }
}

- (NSMutableURLRequest *)prepareRequest:(NSURL *)url
                                headers:(NSDictionary *)headers {
    NSMutableURLRequest *request = [NSMutableURLRequest
            requestWithURL:url
               cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
           timeoutInterval:15];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    for (NSString *key in [headers allKeys]) {
        [request setValue:headers[key] forHTTPHeaderField:key];
    }
    return request;
}

@end

@implementation PNLiteDelayOperation
const NSTimeInterval PNLITE_SEND_DELAY_SECS = 1;

- (void)main {
    [NSThread sleepForTimeInterval:PNLITE_SEND_DELAY_SECS];
}

@end