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

#import "VWAdRequest.h"

@implementation VWAdRequest

+ (nonnull instancetype)request {
    return [[[self class] alloc] init];
}

+ (nonnull instancetype)requestWithContentCategoryID:(VWContentCategory)contentCategory {
    return [[self class] requestWithContentCategoryIDs:@[@(contentCategory)] displayBlockID:0 partnerModuleID:0];
}

+ (nonnull instancetype)requestWithContentCategoryIDs:(nullable NSArray *)contentCategoryIDs {
    return [[self class] requestWithContentCategoryIDs:contentCategoryIDs displayBlockID:0 partnerModuleID:0];
}

+ (nonnull instancetype)requestWithContentCategoryID:(VWContentCategory)contentCategory displayBlockID:(NSInteger)displayBlock {
  return [[self class] requestWithContentCategoryIDs:@[@(contentCategory)] displayBlockID:displayBlock partnerModuleID:0];
}

+ (nonnull instancetype)requestWithContentCategoryIDs:(nullable NSArray *)contentCategoryIDs displayBlockID:(NSInteger)displayBlock {
    return [[self class] requestWithContentCategoryIDs:contentCategoryIDs displayBlockID:displayBlock partnerModuleID:0];
}

+ (nonnull instancetype)requestWithContentCategoryID:(VWContentCategory)contentCategory displayBlockID:(NSInteger)displayBlock partnerModuleID:(NSInteger)partnerModule {
     return [[self class] requestWithContentCategoryIDs:@[@(contentCategory)] displayBlockID:displayBlock partnerModuleID:partnerModule];
}

+ (nonnull instancetype)requestWithContentCategoryIDs:(nullable NSArray *)contentCategoryIDs displayBlockID:(NSInteger)displayBlock partnerModuleID:(NSInteger)partnerModule {
    VWAdRequest *request = [[self class] request];
    request.contentCategoryIDs = [contentCategoryIDs mutableCopy];
    return request;
}

- (BOOL)setCustomParameterForKey:(nonnull NSString *)key value:(nullable NSString *)value {
    return YES;
}

@end

