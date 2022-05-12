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

#import "HyBidVASTMediaFiles.h"
#import "HyBidVASTMediaFile.h"

@interface HyBidVASTMediaFiles ()

@property (nonatomic, strong)HyBidXMLElementEx *mediaFilesXMLElement;

@end

@implementation HyBidVASTMediaFiles

- (instancetype)initWithMediaFilesXMLElement:(HyBidXMLElementEx *)mediaFilesXMLElement
{
    if (mediaFilesXMLElement == nil) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.mediaFilesXMLElement = mediaFilesXMLElement;
    }
    return self;
}

- (NSArray<HyBidVASTMediaFile *> *)mediaFiles
{
    NSString *query = @"/MediaFile";
    NSArray<HyBidXMLElementEx *> *result = [self.mediaFilesXMLElement query:query];
    NSMutableArray<HyBidVASTMediaFile *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTMediaFile *mediaFile = [[HyBidVASTMediaFile alloc] initWithMediaFileXMLElement:result[i]];
        [array addObject:mediaFile];
    }
    
    return array;
}

- (NSArray<HyBidVASTInteractiveCreativeFile *> *)interactiveCreativeFiles
{
    NSString *query = @"/InteractiveCreativeFile";
    NSArray<HyBidXMLElementEx *> *result = [self.mediaFilesXMLElement query:query];
    NSMutableArray<HyBidVASTInteractiveCreativeFile *> *array = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [result count]; i++) {
        HyBidVASTInteractiveCreativeFile *interactiveCreativeFile = [[HyBidVASTInteractiveCreativeFile alloc] initWithInteractiveCreativeFileXMLElement:result[i]];
        [array addObject:interactiveCreativeFile];
    }
    
    return array;
}

@end
