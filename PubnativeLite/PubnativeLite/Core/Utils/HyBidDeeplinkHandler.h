//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HyBidDeeplinkHandler : NSObject

@property (nonatomic, strong, readonly, nullable) NSURL *deeplinkURL;
@property (nonatomic, strong, readonly, nullable) NSURL *fallbackURL;
@property (nonatomic, assign, readonly) BOOL isCapable;

- (instancetype)initWithLink:(NSString * _Nullable)link;

- (void)openWithNavigationType:(NSString *)navigationType;

@end

NS_ASSUME_NONNULL_END
