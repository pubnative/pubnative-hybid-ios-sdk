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

#import "HyBidLogger.h"

// Default setting is HyBidLogLevelInfo.
static HyBidLogLevel logLevel = HyBidLogLevelInfo;

@implementation HyBidLogger

+ (void)setLogLevel:(HyBidLogLevel)level {
    NSArray *levelNames = @[
                            @"None",
                            @"Error",
                            @"Warning",
                            @"Info",
                            @"Debug",
                            ];
    
    NSString *levelName = levelNames[level];
    NSLog(@"HyBid Logger: Log level set to '%@'", levelName);
    logLevel = level;
}

+ (void)errorLogFromClass:(NSString *)className fromMethod:(NSString *)methodName withMessage:(NSString *)message {
    if (logLevel >= HyBidLogLevelError) {
        NSLog(@"\n ----------------------- \n [LOG TYPE]: Error\n [CLASS]: %@\n [METHOD]: %@ \n [MESSAGE]: %@\n -----------------------", className, methodName, message);
    }
}

+ (void)warningLogFromClass:(NSString *)className fromMethod:(NSString *)methodName withMessage:(NSString *)message {
    if (logLevel >= HyBidLogLevelWarning) {
        NSLog(@"\n ----------------------- \n [LOG TYPE]: Warning\n [CLASS]: %@\n [METHOD]: %@ \n [MESSAGE]: %@\n -----------------------", className, methodName, message);
    }
}

+ (void)infoLogFromClass:(NSString *)className fromMethod:(NSString *)methodName withMessage:(NSString *)message {
    if (logLevel >= HyBidLogLevelInfo) {
        NSLog(@"\n ----------------------- \n [LOG TYPE]: Info\n [CLASS]: %@\n [METHOD]: %@ \n [MESSAGE]: %@\n -----------------------", className, methodName, message);
    }
}

+ (void)debugLogFromClass:(NSString *)className fromMethod:(NSString *)methodName withMessage:(NSString *)message {
    if (logLevel >= HyBidLogLevelDebug) {
        NSLog(@"\n ----------------------- \n [LOG TYPE]: Debug\n [CLASS]: %@\n [METHOD]: %@ \n [MESSAGE]: %@\n -----------------------", className, methodName, message);
    }
}

@end
