// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import <Foundation/Foundation.h>
#import "HyBidVASTIcon.h"
#import "HyBidContentInfoView.h"
#import "HyBidVASTAd.h"
#import "HyBidXMLEx.h"

typedef void (^vastIconCompletionBlock)(NSArray<HyBidVASTIcon *> *, NSError *);

@interface HyBidVASTIconUtils : NSObject

- (void)getVASTIconFrom:(NSString *)adContent completion:(vastIconCompletionBlock)block;

- (HyBidContentInfoView *)parseContentInfo:(HyBidVASTIcon *)icon;

@end
