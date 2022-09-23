//
//  Copyright © 2021 PubNative. All rights reserved.
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

#import "HyBidDemoAdSettingsViewController.h"
#import <UIKit/UIKit.h>
#import "HyBidAdSettingWithSwitchCell.h"
#import "HyBidAdSettingWithTextFieldCell.h"
#import "HyBidAdSettingWithSegmentedControlCell.h"
#import <HyBid/HyBid.h>
#import "PNLiteLocationManager.h"

#if __has_include(<HyBid/HyBid-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <HyBid/HyBid-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "HyBid-Swift.h"
#endif

@interface HyBidDemoAdSettingsViewController () <UITableViewDelegate, UITableViewDataSource, HyBidAdSettingWithSwitchCellDelegate, HyBidAdSettingWithTextFieldCellDelegate, HyBidAdSettingWithSegmentedControlCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSDictionary *dataSource;

@end

@implementation HyBidDemoAdSettingsViewController

typedef NS_ENUM(NSUInteger, HyBidAdSettingsCellType) {
    SWITCH = 0,
    TEXT_FIELD = 1,
    SEGMENTED_CONTROL = 2
};

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self populateDataSource];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
}

- (void)addDoneButtonToKeyboardForTextField:(UITextField *)textField
{
    UIToolbar* keyboardToolbar = [[UIToolbar alloc] init];
    [keyboardToolbar sizeToFit];
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil action:nil];
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self action:@selector(keyboardDoneButtonPressed)];
    keyboardToolbar.items = @[flexBarButton, doneBarButton];
    textField.inputAccessoryView = keyboardToolbar;
}

-(void)keyboardDoneButtonPressed
{
    [self.view endEditing:YES];
}

- (NSDictionary *)getDictionaryForSection:(NSInteger)section
{
    NSArray *keysArray = [self.dataSource.allKeys sortedArrayUsingSelector:@selector(compare:)];
    return self.dataSource[keysArray[section]];
}

#pragma mark - UITableViewDatasource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSDictionary *innerDict = [self getDictionaryForSection:indexPath.section];
    NSString *key = innerDict.allKeys.firstObject;
    
    NSDictionary *value = innerDict[key][indexPath.row];
    NSString *title = [value.allKeys firstObject];
    
    HyBidAdSettingsCellType type;
    
    if ([[value.allValues firstObject] integerValue] == SWITCH) {
        type = SWITCH;
    } else if ([[value.allValues firstObject] integerValue] == TEXT_FIELD) {
        type = TEXT_FIELD;
    } else {
        type = SEGMENTED_CONTROL;
    }
        
    switch (type) {
        case SWITCH: {
            HyBidAdSettingWithSwitchCell *cell = (HyBidAdSettingWithSwitchCell *)[tableView dequeueReusableCellWithIdentifier:@"HyBidAdSettingWithSwitchCell"];
            
            cell.titleLabel.text = title;
            cell.indexPath = indexPath;
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            switch (indexPath.section) {
                case 0: {
                    switch (indexPath.row) {
                        case 0: // Set initial audio state
                            [cell.toggleSwitch setOn:[HyBidSettings sharedInstance].audioStatus == HyBidAudioStatusON];
                            break;
                        case 1: // MRAID expand enabled
                            [cell.toggleSwitch setOn:[HyBidSettings sharedInstance].mraidExpand];
                            break;
                        case 2: // Location tracking enabled
                            [cell.toggleSwitch setOn:[PNLiteLocationManager locationTrackingEnabled]];
                        case 3: // Location updates enabled
                            [cell.toggleSwitch setOn:[PNLiteLocationManager locationUpdatesEnabled]];
                            break;
                        case 4: // Ad Feedback enabled
                            [cell.toggleSwitch setOn:[HyBidSettings sharedInstance].adFeedback];
                            break;
                        case 7: // Show EndCard
                            [cell.toggleSwitch setOn:[HyBidSettings sharedInstance].showEndCard];
                            break;
                    }
                    break;
                }
                case 1: {
                    switch (indexPath.row) {
                        case 2: // Interstitial SKOverlay enabled
                            [cell.toggleSwitch setOn:[HyBidSettings sharedInstance].interstitialSKOverlay];
                            break;
                        case 3: { // Interstitial close after finish
                            [cell.toggleSwitch setOn: [HyBidSettings sharedInstance].interstitialCloseOnFinish];
                            break;
                        }
                    }
                    break;
                }
                case 3: {
                    switch (indexPath.row) {
                        case 0: // Rewarded SKOverlay enabled
                            [cell.toggleSwitch setOn:[HyBidSettings sharedInstance].rewardedSKOverlay];
                            break;
                        case 1: { // Rewarded close after finish
                            [cell.toggleSwitch setOn: [HyBidSettings sharedInstance].rewardedCloseOnFinish];
                            break;
                        }
                    }
                    break;
                }
            }
            
            return cell;
        }
        case TEXT_FIELD: {
            HyBidAdSettingWithTextFieldCell *cell = (HyBidAdSettingWithTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:@"HyBidAdSettingWithTextFieldCell"];
            
            cell.titleLabel.text = title;
            cell.indexPath = indexPath;
            cell.delegate = self;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            switch (indexPath.section) {
                case 0: {
                    switch (indexPath.row) {
                        case 5: { // Content Info URL
                            cell.textField.text = [HyBidSettings sharedInstance].contentInfoURL;
                            [self addDoneButtonToKeyboardForTextField:cell.textField];
                            break;
                        }
                        case 6: // EndCard Close Offset
                            cell.textField.text = [[NSString alloc] initWithFormat:@"%@", [HyBidSettings sharedInstance].endCardCloseOffset.offset.stringValue];
                            [self addDoneButtonToKeyboardForTextField:cell.textField];
                            break;
                    }
                }
                case 1: {
                    switch (indexPath.row) {
                        case 0: { // HTML/MRAID Skip Offset
                            cell.textField.text = [HyBidSettings sharedInstance].htmlSkipOffset.offset.stringValue;
                            [self addDoneButtonToKeyboardForTextField:cell.textField];
                            break;
                        }
                        case 1: // Video Skip Offset
                            cell.textField.text = [HyBidSettings sharedInstance].videoSkipOffset.offset.stringValue;
                            [self addDoneButtonToKeyboardForTextField:cell.textField];
                            break;
                    }
                }
            }
            
            return cell;
        }
        case SEGMENTED_CONTROL: {
            HyBidAdSettingWithSegmentedControlCell *cell = (HyBidAdSettingWithSegmentedControlCell *)[tableView dequeueReusableCellWithIdentifier:@"HyBidAdSettingWithSegmentedControlCell"];
            
            cell.titleLabel.text = title;
            cell.indexPath = indexPath;
            cell.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            switch (indexPath.section) {
                case 2: {
                    switch (indexPath.row) {
                        case 0: { // Click behaviour
                            [cell.segmentedControl setTitle:@"Creative" forSegmentAtIndex:0];
                            [cell.segmentedControl setTitle:@"Action" forSegmentAtIndex:1];
                            cell.segmentedControl.selectedSegmentIndex = ([HyBidSettings sharedInstance].interstitialActionBehaviour) == HB_CREATIVE ? 0 : 1;
                            break;
                        }
                    }
                }
            }

            return cell;
        }
    }
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *innerDict = [self getDictionaryForSection:section];
    NSString *key = innerDict.allKeys.firstObject;
    
    return [innerDict[key] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.allKeys.count;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self getDictionaryForSection:section].allKeys.firstObject;
}

#pragma mark - Utils

- (void)populateDataSource
{
    NSDictionary *dict = @{
        @0 :
            @{@"General": @[
                @{ @"Initial Audio State":                  @(SWITCH) },
                @{ @"MRAID Expand Enabled":                 @(SWITCH) },
                @{ @"Location Tracking Enabled":            @(SWITCH) },
                @{ @"Location updates Enabled":             @(SWITCH) },
                @{ @"Ad Feedback Enabled":                  @(SWITCH) },
                @{ @"Content Info URL":                     @(TEXT_FIELD) },
                @{ @"EndCard Close Offset":                 @(TEXT_FIELD) },
                @{ @"Show EndCard":                         @(SWITCH) }
            ]},
        @1 :
            @{@"Interstitial": @[
                @{ @"HTML/MRAID Skip Offset":                   @(TEXT_FIELD) },
                @{ @"Video Skip Offset":                        @(TEXT_FIELD) },
                @{ @"SKOverlay Enabled":                        @(SWITCH) },
                @{ @"Close After Finish":                       @(SWITCH) }
            ]},
        @2 :
            @{@"Fullscreen": @[
                @{ @"Click behaviour": @(SEGMENTED_CONTROL) }
            ]},
        @3 :
            @{@"Rewarded": @[
                @{ @"SKOverlay Enabled":               @(SWITCH) },
                @{ @"Close After Finish":              @(SWITCH) }
            ]}
    };
    self.dataSource = dict;
}

#pragma mark - HyBidAdSettingWithSwitchCellDelegate

- (void)switchValueChangedAtIndexPath:(NSIndexPath *)indexPath isON:(BOOL)isON;
{
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: { // Set initial audio state
                    isON
                    ? [HyBid setVideoAudioStatus:HyBidAudioStatusON]
                    : [HyBid setVideoAudioStatus:HyBidAudioStatusMuted];
                    break;
                }
                case 1: { // MRAID expand enabled
                    [HyBid setMRAIDExpand:isON];
                    break;
                }
                case 2: { // Location tracking enabled
                    [PNLiteLocationManager setLocationTrackingEnabled:isON];
                    break;
                }
                case 3: { // Location updates enabled
                    [PNLiteLocationManager setLocationUpdatesEnabled:isON];
                    break;
                }
                case 4: { // Ad Feedback enabled
                    [HyBid setAdFeedback:isON];
                    break;
                }
                case 7: { // Show EndCard
                    [[HyBidSettings sharedInstance] setShowEndCard:isON];
                    break;
                }
            }
        }
        case 1: {
            switch (indexPath.row) {
                case 2: { // Interstitial SKOverlay enabled
                    [HyBid setInterstitialSKOverlay:isON];
                    break;
                }
                case 3: { // Close interstitial on finish
                    [HyBid setInterstitialCloseOnFinish:isON];
                    break;
                }
            }
        }
        case 3: {
            switch (indexPath.row) {
                case 0: { // Rewarded SKOverlay enabled
                    [HyBid setRewardedSKOverlay:isON];
                    break;
                }
                case 1: { // Close rewarded on finish
                    [HyBid setRewardedCloseOnFinish:isON];
                    break;
                }
            }
        }
    }
}

- (void)textFieldValueChangedAtIndexPath:(NSIndexPath *)indexPath withValue:(NSString *)value {
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 5: { // Set content info URL
                    [HyBid setContentInfoURL:value];
                    break;
                }
                case 6: { // EndCard Close Offset
                    [HyBid setEndCardCloseOffset:[NSNumber numberWithInt:[value intValue]]];
                    break;
                }
            }
        }
        case 1: {
            switch (indexPath.row) {
                case 0: { // HTML/MRAID Skip Offset
                    [HyBid setHTMLInterstitialSkipOffset:[value intValue]];
                    break;
                }
                case 1: { // Video Skip Offset
                    [HyBid setVideoInterstitialSkipOffset:[value intValue]];
                    break;
                }
            }
        }
    }
}

- (void)segmentedControlValueChangedAtIndexPath:(NSIndexPath *)indexPath withIndexValue:(NSInteger)value {
    switch (indexPath.section) {
        case 2: {
            switch (indexPath.row) {
                case 0: { // Click behaviour
                    HyBidInterstitialActionBehaviour behaviour = value == 0 ? HB_CREATIVE : HB_ACTION_BUTTON;
                    [HyBid setInterstitialActionBehaviour:behaviour];
                    break;
                }
            }
        }
    }
}

@end
