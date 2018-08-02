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

#import "PNLiteSessionFileStore.h"
#import "PNLite_KSLogger.h"

static NSString *const kPNLiteSessionStoreSuffix = @"-PNLiteSession-";

@implementation PNLiteSessionFileStore

+ (PNLiteSessionFileStore *)storeWithPath:(NSString *)path {
    return [[self alloc] initWithPath:path
                       filenameSuffix:kPNLiteSessionStoreSuffix];
}

- (void)write:(PNLiteSession *)session {
    // serialise session
    NSString *filepath = [self pathToFileWithId:session.sessionId];
    NSDictionary *dict = [session toJson];

    NSError *error;
    NSData *json = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];

    if (error != nil || ![json writeToFile:filepath atomically:YES]) {
        PNLite_KSLOG_ERROR(@"Failed to write session %@", error);
        return;
    }
}


@end
