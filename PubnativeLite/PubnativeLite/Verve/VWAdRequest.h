#import <Foundation/Foundation.h>
#import "VWContentCategory.h"


@interface VWAdRequest : NSObject

+ (nonnull instancetype)request;

+ (nonnull instancetype)requestWithContentCategoryID:(VWContentCategory)contentCategory;

+ (nonnull instancetype)requestWithContentCategoryIDs:(nullable NSArray *)contentCategoryIDs;

+ (nonnull instancetype)requestWithContentCategoryID:(VWContentCategory)contentCategory displayBlockID:(NSInteger)displayBlock;

+ (nonnull instancetype)requestWithContentCategoryIDs:(nullable NSArray *)contentCategoryIDs displayBlockID:(NSInteger)displayBlock;

+ (nonnull instancetype)requestWithContentCategoryID:(VWContentCategory)contentCategory displayBlockID:(NSInteger)displayBlock partnerModuleID:(NSInteger)partnerModule;

+ (nonnull instancetype)requestWithContentCategoryIDs:(nullable NSArray *)contentCategoryIDs displayBlockID:(NSInteger)displayBlock partnerModuleID:(NSInteger)partnerModule;

- (BOOL)setCustomParameterForKey:(nonnull NSString *)key value:(nullable NSString *)value;

@end

