#import "VWAdRequest.h"

@implementation VWAdRequest

+ (nonnull instancetype)request {
    return [[[self class] alloc] init];
}

+ (nonnull instancetype)requestWithContentCategoryID:(VWContentCategory)contentCategory {
    return [[[self class] alloc] init];
}

+ (nonnull instancetype)requestWithContentCategoryIDs:(nullable NSArray *)contentCategoryIDs {
    return [[[self class] alloc] init];
}

+ (nonnull instancetype)requestWithContentCategoryID:(VWContentCategory)contentCategory displayBlockID:(NSInteger)displayBlock {
    return [[[self class] alloc] init];
}

+ (nonnull instancetype)requestWithContentCategoryIDs:(nullable NSArray *)contentCategoryIDs displayBlockID:(NSInteger)displayBlock {
    return [[[self class] alloc] init];
}

+ (nonnull instancetype)requestWithContentCategoryID:(VWContentCategory)contentCategory displayBlockID:(NSInteger)displayBlock partnerModuleID:(NSInteger)partnerModule {
    return [[[self class] alloc] init];
}

+ (nonnull instancetype)requestWithContentCategoryIDs:(nullable NSArray *)contentCategoryIDs displayBlockID:(NSInteger)displayBlock partnerModuleID:(NSInteger)partnerModule {
    return [[[self class] alloc] init];
}

- (BOOL)setCustomParameterForKey:(nonnull NSString *)key value:(nullable NSString *)value {
    return YES;
}

@end

