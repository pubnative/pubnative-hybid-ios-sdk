#import <Foundation/Foundation.h>
#import "VWContentCategory.h"

/**
 Represents request for creating an ad.
 */
@interface VWAdRequest : NSObject

/*!
 * Creates new request with default category (News and Information).
 */
+ (nonnull instancetype)request;

/*!
 * Creates new request.
 * Consult VWContentCategory.h for all possible categories.
 *
 * @param contentCategory Content category ID.
 */
+ (nonnull instancetype)requestWithContentCategoryID:(VWContentCategory)contentCategory;

/*!
 * Creates new request.
 *
 * @param contentCategoryIDs Array of NSNumbers with content category IDs.
 *
 * Example: [VWAdRequest requestWithContentCategoryIDs:@[@(VWContentCategoryArtsAndEntertainment), @(VWContentCategoryIndex)]]
 */
+ (nonnull instancetype)requestWithContentCategoryIDs:(nullable NSArray *)contentCategoryIDs;

/*!
 * Creates new request.
 *
 * @param contentCategory Content category ID.
 * @param displayBlock Display block ID.
 */
+ (nonnull instancetype)requestWithContentCategoryID:(VWContentCategory)contentCategory displayBlockID:(NSInteger)displayBlock;

/*!
 * Creates new request.
 *
 * @param contentCategoryIDs Array of NSNumbers with content category IDs.
 * @param displayBlock Display block ID.
 */
+ (nonnull instancetype)requestWithContentCategoryIDs:(nullable NSArray *)contentCategoryIDs displayBlockID:(NSInteger)displayBlock;

/*!
 * Creates new request.
 *
 * @param contentCategory Content category ID.
 * @param displayBlock Display block ID. Assigned by Verve if needed.
 * @param partnerModule Partner module ID. Assigned by Verve if needed.
 */
+ (nonnull instancetype)requestWithContentCategoryID:(VWContentCategory)contentCategory displayBlockID:(NSInteger)displayBlock partnerModuleID:(NSInteger)partnerModule;

/*!
 * Creates new request.
 *
 * @param contentCategoryIDs Array of NSNumbers with content category IDs.
 * @param displayBlock Display block ID. Assigned by Verve if needed.
 * @param partnerModule Partner module ID. Assigned by Verve if needed.
 */
+ (nonnull instancetype)requestWithContentCategoryIDs:(nullable NSArray *)contentCategoryIDs displayBlockID:(NSInteger)displayBlock partnerModuleID:(NSInteger)partnerModule;

/*!
 * Sets custom key-value parameter for ad request.
 *
 * @param key Parameter key.
 * @param value Parameter value. Pass nil to remove previously set parameter.
 *
 * @return Boolean value indicating whether operation was successful. Operation fails when you try to set parameter for Verve reserverd key.
 */
- (BOOL)setCustomParameterForKey:(nonnull NSString *)key value:(nullable NSString *)value;


@end
