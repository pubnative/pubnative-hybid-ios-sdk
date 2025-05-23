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

- (void)getVASTIconFrom:(NSString *)adContent completion:(vastIconCompletionBlock)block
{
    HyBidVideoAdProcessor *videoAdProcessor = [[HyBidVideoAdProcessor alloc] init];
    [videoAdProcessor processVASTString:adContent completion:^(HyBidVASTModel *vastModel, HyBidVASTParserError *error) {
        NSOrderedSet *vastSet = [[NSOrderedSet alloc] initWithArray:vastModel.vastArray];
        NSMutableArray* vastArray = [[NSMutableArray alloc] initWithArray:[vastSet array]];
        if (error) {
            HyBidVASTEventProcessor *vastEventProcessor = [[HyBidVASTEventProcessor alloc] init];
            [vastEventProcessor sendVASTUrls: error.errorTagURLs withType:HyBidVASTParserErrorURL];
            block(nil, error);
        } else {
            NSArray<HyBidVASTIcon *> *icons;
            for (NSData *vast in vastArray){
                NSString *xml = [[NSString alloc] initWithData:vast encoding:NSUTF8StringEncoding];
                HyBidXMLEx *parser = [HyBidXMLEx parserWithXML:xml];
                NSArray *result = [[parser rootElement] query:@"Ad"];
                for (int i = 0; i < [result count]; i++) {
                    HyBidVASTAd * ad;
                    HyBidVASTCreative *adCreative;
                    if (result[i]) {
                        ad = [[HyBidVASTAd alloc] initWithXMLElement:result[i]];
                    }
                    if ([ad wrapper] != nil){
                        for (HyBidVASTCreative *creative in [[ad wrapper] creatives]) {
                            [self retrieveIconsFrom:&adCreative block:block creative:creative icons:&icons];
                        }
                    }else if ([ad inLine]!=nil){
                        for (HyBidVASTCreative *creative in [[ad inLine] creatives]) {
                            [self retrieveIconsFrom:&adCreative block:block creative:creative icons:&icons];
                        }
                    }
                }
                if (vast == [vastArray lastObject] && (icons.count == 0 || icons == nil)) {
                    block(icons, nil);
                }
            }
        }
    }];
}

- (HyBidContentInfoView *)parseContentInfo:(HyBidVASTIcon *)icon
{
    if (!icon) {
        return nil;
    }
    
    HyBidContentInfoView *contentInfoView = [[HyBidContentInfoView alloc] init];
    contentInfoView.icon = [[[icon staticResources] firstObject] content];
    contentInfoView.link = [[[icon iconClicks] iconClickThrough] content];
    contentInfoView.viewTrackers = [icon iconViewTracking];
    contentInfoView.text = @"Learn about this ad";

    return contentInfoView;
}

@end
