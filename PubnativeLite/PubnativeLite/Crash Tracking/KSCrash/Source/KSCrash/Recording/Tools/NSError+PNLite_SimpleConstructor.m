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

#import "NSError+PNLite_SimpleConstructor.h"

@implementation NSError (PNLite_SimpleConstructor)

+ (NSError *)bsg_errorWithDomain:(NSString *)domain
                            code:(NSInteger)code
                     description:(NSString *)fmt, ... {
    va_list args;
    va_start(args, fmt);

    NSString *desc = [[NSString alloc] initWithFormat:fmt arguments:args];
    va_end(args);

    return [NSError
            errorWithDomain:domain
                       code:code
                   userInfo:@{NSLocalizedDescriptionKey: desc}];
}

+ (BOOL)bsg_fillError:(NSError *__autoreleasing *)error
           withDomain:(NSString *)domain
                 code:(NSInteger)code
          description:(NSString *)fmt, ... {
    if (error != nil) {
        va_list args;
        va_start(args, fmt);

        NSString *desc = [[NSString alloc] initWithFormat:fmt arguments:args];
        va_end(args);

        *error = [NSError
                errorWithDomain:domain
                           code:code
                       userInfo:
                               @{NSLocalizedDescriptionKey: desc}];
    }
    return NO;
}

@end
