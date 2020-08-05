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

#import "PNLiteDemoPNLiteMRectViewController.h"
#import <HyBid/HyBid.h>
#import "PNLiteDemoSettings.h"
#import "Quote.h"
#import "QuoteTableViewCell.h"

@interface PNLiteDemoPNLiteMRectViewController () <HyBidAdViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *mRectLoaderIndicator;
@property (weak, nonatomic) IBOutlet HyBidMRectAdView *mRectAdView;
@property (weak, nonatomic) IBOutlet UIButton *inspectRequestButton;
@property (weak, nonatomic) IBOutlet UITableView *quotesTableView;

@end

@implementation PNLiteDemoPNLiteMRectViewController

NSArray *quotes;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"HyBid MRect";
    
    [self populateQuotes];

    self.quotesTableView.delegate = self;
    self.quotesTableView.dataSource = self;
}

- (IBAction)requestMRectTouchUpInside:(id)sender {
    [self requestAd];
}

- (void)requestAd {
    [self clearLastInspectedRequest];
    self.mRectAdView.hidden = YES;
    self.inspectRequestButton.hidden = YES;
    [self.mRectLoaderIndicator startAnimating];
    [self.mRectAdView loadWithZoneID:[[NSUserDefaults standardUserDefaults] stringForKey:kHyBidDemoZoneIDKey] andWithDelegate:self];
}

#pragma mark - HyBidAdViewDelegate

- (void)adViewDidLoad:(HyBidAdView *)adView {
    NSLog(@"MRect Ad View did load:");
    self.mRectAdView.hidden = NO;
    self.inspectRequestButton.hidden = NO;
    [self.mRectLoaderIndicator stopAnimating];
    [self.quotesTableView reloadData];
}

- (void)adView:(HyBidAdView *)adView didFailWithError:(NSError *)error {
    NSLog(@"MRect Ad View did fail with error: %@",error.localizedDescription);
    self.inspectRequestButton.hidden = NO;
    [self.mRectLoaderIndicator stopAnimating];
    [self showAlertControllerWithMessage:error.localizedDescription];
}

- (void)adViewDidTrackClick:(HyBidAdView *)adView {
    NSLog(@"MRect Ad View did track click:");
}

- (void)adViewDidTrackImpression:(HyBidAdView *)adView {
    NSLog(@"MRect Ad View did track impression:");
}

#pragma mark - UITableViewDatasource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    QuoteTableViewCell *cell = (QuoteTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"quoteCell"];
    
    NSInteger row = indexPath.row;
    Quote *quote = quotes[row];
    
    cell.quoteTextLabel.text = quote.quoteText;
    cell.quoteAutorLabel.text = quote.quoteAuthor;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return quotes.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


#pragma mark - Utils

- (void)populateQuotes {
    quotes = [[NSArray alloc]initWithObjects:
                       [[Quote alloc]initWithText:@"Our world is built on biology and once we begin to understand it, it then becomes a technology" andAuthor:@"Ryan Bethencourt"],
                       [[Quote alloc]initWithText:@"Happiness is not an ideal of reason but of imagination" andAuthor:@"Immanuel Kant"],
                       [[Quote alloc]initWithText:@"Science and technology revolutionize our lives, but memory, tradition and myth frame our response." andAuthor:@"Arthur M. Schlesinger"],
                       [[Quote alloc]initWithText:@"It's not a faith in technology. It's faith in people" andAuthor:@"Steve Jobs"],
                       [[Quote alloc]initWithText:@"We can't blame the technology when we make mistakes." andAuthor:@"Tim Berners-Lee"],
                       [[Quote alloc]initWithText:@"Life must be understood backward. But it must be lived forward." andAuthor:@"Søren Kierkegaard"],
                       [[Quote alloc]initWithText:@"Happiness can be found, even in the darkest of times, if one only remembers to turn on the light." andAuthor:@"Albus Dumbledore"],
                       [[Quote alloc]initWithText:@"To live a creative life, we must lose our fear of being wrong." andAuthor:@"Joseph Chilton Pearce"],
                       [[Quote alloc]initWithText:@"It is undesirable to believe a proposition when there is no ground whatever for supposing it true." andAuthor:@"Bertrand Russell"],
                       [[Quote alloc]initWithText:@"There's always a bigger fish." andAuthor:@"Qui-Gon Jinn"],
                       [[Quote alloc]initWithText:@"A wizard is never late. Nor is he early. He arrives precisely when he means to." andAuthor:@"Gandalf"],
                       [[Quote alloc]initWithText:@"Moonlight drowns out all but the brightest stars." andAuthor:@"J. R. R. Tolkien, The Lord of the Rings"],
                       [[Quote alloc]initWithText:@"A hunted man sometimes wearies of distrust and longs for friendship." andAuthor:@"J. R. R. Tolkien, The Lord of the Rings"],
                       nil];
}

@end
