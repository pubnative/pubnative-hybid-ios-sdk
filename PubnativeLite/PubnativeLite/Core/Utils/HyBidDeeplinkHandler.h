//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HyBidAutomaticClickTrackingUtil.h"

NS_ASSUME_NONNULL_BEGIN

@interface HyBidDeeplinkHandler : NSObject

@property (nonatomic, strong, readonly, nullable) NSURL *deeplinkURL;
@property (nonatomic, strong, readonly, nullable) NSURL *fallbackURL;
@property (nonatomic, assign, readonly) BOOL isCapable;

- (instancetype)initWithLink:(NSString * _Nullable)link;

- (void)openWithNavigationType:(NSString *)navigationType;
- (void)openWithNavigationType:(NSString *)navigationType clickthroughURL:(NSString * _Nullable)clickthroughURL;
- (void)openWithNavigationType:(NSString *)navigationType
               clickthroughURL:(NSString * _Nullable)clickthroughURL
              clickThroughType:(HyBidClickThroughType)clickThroughType;

@end

NS_ASSUME_NONNULL_END
