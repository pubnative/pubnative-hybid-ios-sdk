//
// 
// HyBid SDK License
//
// https://github.com/pubnative/pubnative-hybid-ios-sdk/blob/main/LICENSE
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "HyBidEndCardView.h"

// Swift tests needed methods.
// Not public methods in HyBidEndCardView.h

@interface HyBidEndCardView (Testing)

@property (nonatomic, weak) id<HyBidEndCardViewDelegate> delegate;

- (void)navigationToURL:(NSString *)url
      shouldOpenBrowser:(BOOL)shouldOpenBrowser
         navigationType:(NSString *)navigationType;

- (void)setHorizontalConstraints;
- (void)setVerticalConstraints;
- (void)addCloseButton;
- (void)setupUI;
- (void)resumeCloseButtonTimer;
- (void)resumeStorekitDelayTimer;
- (void)adHasFocus;
- (void)adHasNoFocus;
- (void)determineStorekitDelayOffsetAndBehaviour;
- (void)configureCTAWebViewWith:(HyBidVASTCTAButton *)ctaButton;
- (void)addVerticalConstraintsInRelationToView:(UIView *)view;
- (void)addHorizontalConstraintsInRelationToView:(UIView *)view;
- (void)displayImageViewWithURL:(NSString *)url withView:(UIView *)view;
- (void)displayMRAIDWithContent:(NSString *)content withBaseURL:(NSURL *)baseURL;
- (void)trackEndCardImpression;

@end

