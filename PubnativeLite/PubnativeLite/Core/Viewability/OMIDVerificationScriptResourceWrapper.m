//
//  Copyright © 2021 PubNative. All rights reserved.
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

#import "OMIDVerificationScriptResourceWrapper.h"
#import "HyBid.h"

#if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
#import <OMSDK_Pubnativenet/OMIDImports.h>
#endif

#if __has_include(<OMSDK_Smaato/OMIDImports.h>)
#import <OMSDK_Smaato/OMIDImports.h>
#endif

@implementation OMIDVerificationScriptResourceWrapper

- (instancetype)initWithURL:(NSURL *)url vendorKey:(NSString *)vendorKey parameters:(NSString *)parameters {
    self = [super init];
    if (self) {
        if ([HyBid getIntegrationType] == SDKIntegrationTypeHyBid) {
            #if __has_include(<OMSDK_Pubnativenet/OMIDImports.h>)
            _verificationScriptResource = [[OMIDPubnativenetVerificationScriptResource alloc] initWithURL:url vendorKey:vendorKey parameters:parameters];
            #endif
        } else if ([HyBid getIntegrationType] == SDKIntegrationTypeSmaato) {
            #if __has_include(<OMSDK_Smaato/OMIDImports.h>)
            _verificationScriptResource = [[OMIDSmaatoVerificationScriptResource alloc] initWithURL:url vendorKey:vendorKey parameters:parameters];
            #endif
        }
    }
    return self;
}

@end

