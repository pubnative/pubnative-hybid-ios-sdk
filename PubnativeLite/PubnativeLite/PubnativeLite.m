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

#import "PubnativeLite.h"
#import "PNLiteSettings.h"
#import "PNLiteCrashTracker.h"

@implementation PubnativeLite

+ (void)setCoppa:(BOOL)enabled
{
    [PNLiteSettings sharedInstance].coppa = enabled;
}

+ (void)setTargeting:(PNLiteTargetingModel *)targeting
{
    [PNLiteSettings sharedInstance].targeting = targeting;
}

+ (void)setTestMode:(BOOL)enabled
{
    [PNLiteSettings sharedInstance].test = enabled;
}

+ (void)initWithAppToken:(NSString *)appToken
{
    if (appToken == nil || appToken.length == 0) {
        NSLog(@"PubNative Lite - App Token is nil or empty and required.");
    } else {
        [PNLiteSettings sharedInstance].appToken = appToken;
        [PNLiteCrashTracker startBugsnagWithApiKey:@"07efad4c0a722959dd14de963bf409ce"];
    }
}

@end
