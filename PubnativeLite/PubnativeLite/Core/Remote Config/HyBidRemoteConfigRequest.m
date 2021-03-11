//
//  Copyright © 2020 PubNative. All rights reserved.
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

#import "HyBidRemoteConfigRequest.h"
#import "PNLiteHttpRequest.h"
#import "HyBidRemoteConfigEndpoints.h"
#import "HyBidLogger.h"
#import "HyBidEncryption.h"

@interface HyBidRemoteConfigRequest() <PNLiteHttpRequestDelegate>

@property (nonatomic, weak) NSObject <HyBidRemoteConfigRequestDelegate> *delegate;

@end

@implementation HyBidRemoteConfigRequest

- (void)dealloc {
    self.delegate = nil;
}

- (void)doConsentRequestWithDelegate:(NSObject<HyBidRemoteConfigRequestDelegate> *)delegate
                        withAppToken:(NSString *)appToken {
    if (!delegate) {
        [self invokeDidFail:[NSError errorWithDomain:@"Given delegate is nil and required, droping this call." code:0 userInfo:nil]];
    } else {
        self.delegate = delegate;
        NSString *url = [HyBidRemoteConfigEndpoints remoteConfigURL];
        NSDictionary *headerDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"application/json",@"Content-Type",[NSString stringWithFormat:@"Bearer %@",appToken],@"Authorization", nil];
        PNLiteHttpRequest *request = [[PNLiteHttpRequest alloc] init];
        request.header = headerDictionary;
        [request startWithUrlString:url withMethod:@"GET" delegate:self];
    }
}

- (void)invokeDidLoad:(HyBidRemoteConfigModel *)model {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(remoteConfigRequestSuccess:)]) {
            [self.delegate remoteConfigRequestSuccess:model];
        }
        self.delegate = nil;
    });
}

- (void)invokeDidFail:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [HyBidLogger errorLogFromClass:NSStringFromClass([self class]) fromMethod:NSStringFromSelector(_cmd) withMessage:error.localizedDescription];
        if(self.delegate && [self.delegate respondsToSelector:@selector(remoteConfigRequestFail:)]) {
            [self.delegate remoteConfigRequestFail:error];
        }
        self.delegate = nil;
    });
}

- (NSData *)decryptRemoteConfigsData:(NSData *)data withKey:(NSString *)key andWithIV:(NSString *)iv
{
    if (key != nil && iv != nil) {
    NSString *encryptedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return [[HyBidEncryption decrypt:encryptedString withKey:key andWithIV:iv] dataUsingEncoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (void)processResponseWithData:(NSData *)data {
    NSData *decryptedData = [self decryptRemoteConfigsData:data withKey:[HyBidSettings sharedInstance].appToken andWithIV:[@"" stringByPaddingToLength:16 withString:@"0" startingAtIndex:0]];

    if (decryptedData != nil) {
        NSError *parseError;
        NSDictionary *jsonDictonary = [NSJSONSerialization JSONObjectWithData:decryptedData
                                                                           options:NSJSONReadingMutableContainers
                                                                             error:&parseError];
        if (parseError) {
            [self invokeDidFail:parseError];
        } else {
            HyBidRemoteConfigModel *remoteConfig = [[HyBidRemoteConfigModel alloc] initWithDictionary:jsonDictonary];
            if (!remoteConfig) {
                NSError *error = [NSError errorWithDomain:@"Can't parse JSON from server."
                                                          code:0
                                                      userInfo:nil];
                [self invokeDidFail:error];
            } else {
                [self invokeDidLoad:remoteConfig];
            }
        }
    } else {
        NSError *error = [NSError errorWithDomain:@"Could not decrypt the response data."
                                                  code:0
                                              userInfo:nil];
        [self invokeDidFail:error];
    }
}

#pragma mark PNLiteHttpRequestDelegate

- (void)request:(PNLiteHttpRequest *)request didFinishWithData:(NSData *)data statusCode:(NSInteger)statusCode {
    [self processResponseWithData:data];
}

- (void)request:(PNLiteHttpRequest *)request didFailWithError:(NSError *)error {
    [self invokeDidFail:error];
}

@end
