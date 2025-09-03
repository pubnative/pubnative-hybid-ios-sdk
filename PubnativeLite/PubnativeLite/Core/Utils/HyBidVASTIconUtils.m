// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//

#import "HyBidVASTIconUtils.h"
#import "HyBidVideoAdProcessor.h"
#import "HyBidVASTAd.h"
#import "HyBidXMLEx.h"
#import "HyBidVASTEventProcessor.h"
#import "HyBidVASTParserError.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@implementation HyBidVASTIconUtils

- (void)retrieveIconsFrom:(HyBidVASTCreative **)adCreative block:(vastIconCompletionBlock)block creative:(HyBidVASTCreative *)creative icons:(NSArray<HyBidVASTIcon *> **)icons {
    if ([creative linear] != nil && [[creative linear] icons].count != 0) {
        *adCreative = creative;
        HyBidVASTLinear *linear = [*adCreative linear];
        *icons = [linear icons];
        block(*icons, nil);
    }
}

- (void)getVASTIconFrom:(NSArray *)vastArray vastString:(NSString *)vast completion:(vastIconCompletionBlock)block {
    if (vastArray != nil && vastArray.count > 0) {
        [self extractIconsFromVASTArray:vastArray usingBlock:block];
    } else {
        HyBidVideoAdProcessor *videoAdProcessor = [[HyBidVideoAdProcessor alloc] init];
        [videoAdProcessor processVASTString:vast completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError *error) {
            NSOrderedSet *vastSet = [[NSOrderedSet alloc] initWithArray:vastModel.vastArray];
            NSMutableArray* vastArray = [[NSMutableArray alloc] initWithArray:[vastSet array]];
            if (error) {
                HyBidVASTEventProcessor *vastEventProcessor = [[HyBidVASTEventProcessor alloc] init];
                [vastEventProcessor sendVASTUrls: error.errorTagURLs withType:HyBidVASTParserErrorURL];
                block(nil, error);
            } else {
                __block BOOL isBlockCalled = NO;
                [self extractIconsFromVASTArray:vastArray usingBlock:^(NSArray<HyBidVASTIcon *> *icons, NSError *error) {
                    if (!isBlockCalled) {
                        isBlockCalled = YES;
                        block(icons, error);
                    }
                }];
            }
        }];
    }
}

- (NSArray<HyBidVASTIcon *> *)extractIconsFromVASTArray:(NSArray<NSData *> *)vastArray usingBlock:(vastIconCompletionBlock)block {
    NSArray<HyBidVASTIcon *> *icons;
    for (NSData *vast in vastArray) {
        NSString *xml = [[NSString alloc] initWithData:vast encoding:NSUTF8StringEncoding];
        HyBidXMLEx *parser = [HyBidXMLEx parserWithXML:xml];
        NSArray *result = [[parser rootElement] query:@"Ad"];
        for (int i = 0; i < [result count]; i++) {
            HyBidVASTAd *ad;
            HyBidVASTCreative *adCreative;
            if (result[i]) {
                ad = [[HyBidVASTAd alloc] initWithXMLElement:result[i]];
            }
            if ([ad wrapper] != nil) {
                for (HyBidVASTCreative *creative in [[ad wrapper] creatives]) {
                    [self retrieveIconsFrom:&adCreative block:block creative:creative icons:&icons];
                }
            } else if ([ad inLine] != nil) {
                for (HyBidVASTCreative *creative in [[ad inLine] creatives]) {
                    [self retrieveIconsFrom:&adCreative block:block creative:creative icons:&icons];
                }
            }
        }
    }
    if (!icons || icons.count == 0) {
        block(nil, nil);
    }
    return icons;
}

- (HyBidContentInfoView *)parseContentInfo:(HyBidVASTIcon *)icon display: (HyBidContentInfoDisplay) displayValue clickAction: (HyBidContentInfoClickAction) clickAction
{
    if (!icon) {
        return nil;
    }
    
    HyBidContentInfoView *contentInfoView = [[HyBidContentInfoView alloc] init];
    contentInfoView.icon = [[[icon staticResources] firstObject] content];
    contentInfoView.isCustom = contentInfoView.icon ? YES : NO;
    contentInfoView.link = [[[icon iconClicks] iconClickThrough] content];
    contentInfoView.viewTrackers = [icon iconViewTracking];
    contentInfoView.clickTrackers = [[icon iconClicks] iconClickTracking];
    contentInfoView.text = @"Learn about this ad";
    contentInfoView.display = displayValue;
    contentInfoView.clickAction = clickAction;

    return contentInfoView;
}

@end
