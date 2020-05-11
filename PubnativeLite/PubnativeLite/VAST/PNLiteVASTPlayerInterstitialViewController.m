//
//  Copyright © 2018 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "PNLiteVASTPlayerInterstitialViewController.h"
#import "PNLiteVASTPlayerViewController.h"

@interface PNLiteVASTPlayerInterstitialViewController () <PNLiteVASTPlayerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *playerContainer;
@property (nonatomic, strong) PNLiteVASTPlayerViewController *player;
@property (nonatomic, strong) HyBidInterstitialPresenter *presenter;
@property (nonatomic, strong) HyBidAd *adModel;

@end

@implementation PNLiteVASTPlayerInterstitialViewController

- (void)dealloc {
    [self.player stop];
    self.player = nil;
    self.presenter = nil;
    self.adModel = nil;
}

- (instancetype)init {
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:currentBundle];
    self.view = [currentBundle loadNibNamed:NSStringFromClass([self class])
                                      owner:self
                                    options:nil][0];;
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.player play];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.player stop];
}

- (void)loadFullScreenPlayerWithPresenter:(HyBidInterstitialPresenter *)interstitialPresenter withAd:(HyBidAd *)ad {
    self.presenter = interstitialPresenter;
    self.adModel = ad;
    self.player = [[PNLiteVASTPlayerViewController alloc] initPlayerWithContentInfo:self.adModel.contentInfo isInterstital:YES];
    self.player.delegate = self;
    NSString *vastString = self.adModel.vast;
    vastString = [vastString stringByReplacingOccurrencesOfString:@"</InLine></Ad></VAST>" withString:@"<Extensions> <Extension type=\"AdVerifications\"> <AdVerifications> <Verification vendor=\"company.com-omid\"> <JavaScriptResource apiFramework=\"omid\" browserOptional=\"true\"> <![CDATA[ https://company.com/omid.js ]]> </JavaScriptResource> <TrackingEvents> <Tracking event=\"verificationNotExecuted\"> <![CDATA[ https://company.com/pixel.jpg?error=[REASON] ]]> </Tracking> </TrackingEvents> <VerificationParameters> <![CDATA[ parameter1=value1&parameter2=value2&parameter3=value3 ]]> </VerificationParameters> </Verification> <Verification vendor=\"company.com-can\"> <JavaScriptResource apiFramework=\"omid\" browserOptional=\"true\"> <![CDATA[ https://company.com/can.js ]]> </JavaScriptResource> <TrackingEvents> <Tracking event=\"verificationNotExecuted\"> <![CDATA[ https://company.com/pixel.jpg?error=[REASON] ]]> </Tracking> </TrackingEvents> <VerificationParameters> <![CDATA[ parameter4=value4&parameter5=value5&parameter6=value6 ]]> </VerificationParameters> </Verification> </AdVerifications> </Extension> </Extensions> </InLine> </Ad> </VAST>"];

    [self.player loadWithVastString:vastString];
//    [self.player loadWithVastString:self.adModel.vast];
//    [self.player loadWithVastString:@"<VAST version=\"2.0\"> <Ad id=\"preroll-1\"> <InLine> <AdSystem>2.0</AdSystem> <AdTitle>5748406</AdTitle> <Extensions> <Extension type=\"AdVerifications\"> <AdVerifications> <Verification vendor=\"company.com-omid\"> <JavaScriptResource apiFramework=\"omid\" browserOptional=\"true\"> <![CDATA[ https://company.com/omid.js ]]> </JavaScriptResource> <TrackingEvents> <Tracking event=\"verificationNotExecuted\"> <![CDATA[ https://company.com/pixel.jpg?error=[REASON] ]]> </Tracking> </TrackingEvents> <VerificationParameters> <![CDATA[ parameter1=value1&parameter2=value2&parameter3=value3 ]]> </VerificationParameters> </Verification> <Verification vendor=\"company.com-can\"> <JavaScriptResource apiFramework=\"omid\" browserOptional=\"true\"> <![CDATA[ https://company.com/can.js ]]> </JavaScriptResource> <TrackingEvents> <Tracking event=\"verificationNotExecuted\"> <![CDATA[ https://company.com/pixel.jpg?error=[REASON] ]]> </Tracking> </TrackingEvents> <VerificationParameters> <![CDATA[ parameter4=value4&parameter5=value5&parameter6=value6 ]]> </VerificationParameters> </Verification> </AdVerifications> </Extension> </Extensions> </InLine> </Ad> </VAST>"];
    
}

#pragma mark PNLiteVASTPlayerViewControllerDelegate

- (void)vastPlayerDidFinishLoading:(PNLiteVASTPlayerViewController *)vastPlayer {
    self.player = vastPlayer;
    self.player.view.frame = self.playerContainer.bounds;
    [self.playerContainer addSubview:self.player.view];
    [self.presenter.delegate interstitialPresenterDidLoad:self.presenter];
}

- (void)vastPlayer:(PNLiteVASTPlayerViewController *)vastPlayer didFailLoadingWithError:(NSError *)error {
    [self.presenter.delegate interstitialPresenter:self.presenter didFailWithError:error];
}

- (void)vastPlayerDidStartPlaying:(PNLiteVASTPlayerViewController *)vastPlayer {
    [self.presenter.delegate interstitialPresenterDidShow:self.presenter];
}

- (void)vastPlayerDidPause:(PNLiteVASTPlayerViewController *)vastPlayer {
    
}

- (void)vastPlayerDidComplete:(PNLiteVASTPlayerViewController *)vastPlayer {
    
}

- (void)vastPlayerDidOpenOffer:(PNLiteVASTPlayerViewController *)vastPlayer {
    [self.presenter.delegate interstitialPresenterDidClick:self.presenter];
}

- (void)vastPlayerDidClose:(PNLiteVASTPlayerViewController *)vastPlayer {
    [self.presenter hide];
    [self.presenter.delegate interstitialPresenterDidDismiss:self.presenter];
}

@end
