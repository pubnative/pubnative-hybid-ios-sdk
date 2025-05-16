// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidVASTTrackingEvents.h"
#import "HyBidSKOverlayDelegate.h"

typedef enum {
    HyBidEndCardType_STATIC,
    HyBidEndCardType_HTML,
    HyBidEndCardType_IFRAME,
} HyBidVASTEndCardType;

@interface HyBidVASTEndCard : NSObject

@property (nonatomic) HyBidVASTEndCardType type;

@property (nonatomic, strong) NSString *content;

@property (nonatomic, strong) NSString *clickThrough;

@property (nonatomic, strong) NSArray<NSString *> *clickTrackings;

@property (nonatomic, strong) HyBidVASTTrackingEvents *events;

@property (nonatomic, assign) BOOL isCustomEndCard;

@property (nonatomic, assign) BOOL isCustomEndCardClicked;
@end
