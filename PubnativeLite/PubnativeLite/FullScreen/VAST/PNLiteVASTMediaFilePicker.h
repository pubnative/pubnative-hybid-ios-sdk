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

#import <Foundation/Foundation.h>
#import "PNLiteVASTMediaFile.h"

// An implementation of how to pick media file from one or more in a VAST Document. VASTMediaFilePicker looks for internet first and eliminate entries with mime type which we can't play in the phone. After that, the list is sorted by bit rate (if exists) along with hi or low speed connection + progressive/streaming attribute. Once we have the final list, we end up picking the first from the list. If you have no valid media file to pick, you will get a nil and that will generate an error to the caller.
@interface PNLiteVASTMediaFilePicker : NSObject

+ (PNLiteVASTMediaFile *)pick:(NSArray *)mediaFiles;

@end
