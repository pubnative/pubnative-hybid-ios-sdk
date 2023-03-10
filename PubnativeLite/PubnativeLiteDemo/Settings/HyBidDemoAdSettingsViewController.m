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
    self.navigationItem.title = @"Ad Settings";
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
                            [cell.toggleSwitch setOn:[HyBidRenderingConfig sharedConfig].audioStatus == HyBidAudioStatusON];
                            break;
                        case 1: // MRAID expand enabled
                            [cell.toggleSwitch setOn:[HyBidRenderingConfig sharedConfig].mraidExpand];
                            break;
                        case 2: // Location tracking enabled
                            [cell.toggleSwitch setOn:[HyBidLocationConfig sharedConfig].locationTrackingEnabled];
                            break;
                        case 3: // Location updates enabled
                            [cell.toggleSwitch setOn:[HyBidLocationConfig sharedConfig].locationUpdatesEnabled];
                            break;
                        case 5: // Show EndCard
                            [cell.toggleSwitch setOn:[HyBidRenderingConfig sharedConfig].showEndCard];
                            break;
                    }
                    break;
                }
                case 1: {
                    switch (indexPath.row) {
                        case 2: // Interstitial SKOverlay enabled
                            [cell.toggleSwitch setOn:[HyBidRenderingConfig sharedConfig].interstitialSKOverlay];
                            break;
                        case 3: { // Interstitial close after finish
                            [cell.toggleSwitch setOn:[HyBidRenderingConfig sharedConfig].interstitialCloseOnFinish];
                            break;
                        }
                    }
                    break;
                }
                case 3: {
                    switch (indexPath.row) {
                        case 0: // Rewarded SKOverlay enabled
                            [cell.toggleSwitch setOn:[HyBidRenderingConfig sharedConfig].rewardedSKOverlay];
                            break;
                        case 1: { // Rewarded close after finish
                            [cell.toggleSwitch setOn:[HyBidRenderingConfig sharedConfig].rewardedCloseOnFinish];
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
                        case 4: // EndCard Close Offset
                            cell.textField.text = [[NSString alloc] initWithFormat:@"%@", [HyBidRenderingConfig sharedConfig].endCardCloseOffset.offset.stringValue];
                            [self addDoneButtonToKeyboardForTextField:cell.textField];
                            break;
                    }
                    break;
                }
                case 1: {
                    switch (indexPath.row) {
                        case 0: { // HTML/MRAID Skip Offset
                            cell.textField.text = [HyBidRenderingConfig sharedConfig].interstitialHtmlSkipOffset.offset.stringValue;
                            [self addDoneButtonToKeyboardForTextField:cell.textField];
                            break;
                        }
                        case 1: // Video Skip Offset
                            cell.textField.text = [HyBidRenderingConfig sharedConfig].videoSkipOffset.offset.stringValue;
                            [self addDoneButtonToKeyboardForTextField:cell.textField];
                            break;
                    }
                    break;
                }
                case 3: {
                    switch (indexPath.row) {
                        case 0: { // HTML/MRAID Skip Offset Rewarded
                            cell.textField.text = [HyBidRenderingConfig sharedConfig].rewardedHtmlSkipOffset.offset.stringValue;
                            [self addDoneButtonToKeyboardForTextField:cell.textField];
                            break;
                        }
                    }
                    break;
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
                case 1: { // countdown style
                    [cell.segmentedControl setTitle:@"Pie chart" forSegmentAtIndex:0];
                    [cell.segmentedControl setTitle:@"Timer" forSegmentAtIndex:1];
                    if(cell.segmentedControl.numberOfSegments > 2){
                        [cell.segmentedControl setTitle:@"Progress" forSegmentAtIndex:2];
                    } else {
                        [cell.segmentedControl insertSegmentWithTitle:@"Progress" atIndex:2 animated: YES];
                    }
                    
                    [cell.segmentedControl setSelectedSegmentIndex: [[HyBidRenderingConfig sharedConfig].videoSkipOffset.style intValue]];
                    break;
                }
                case 2: {
                    switch (indexPath.row) {
                        case 0: { // Click behaviour
                            [cell.segmentedControl setTitle:@"Creative" forSegmentAtIndex:0];
                            [cell.segmentedControl setTitle:@"Action" forSegmentAtIndex:1];
                            cell.segmentedControl.selectedSegmentIndex = ([HyBidRenderingConfig sharedConfig].interstitialActionBehaviour) == HB_CREATIVE ? 0 : 1;
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
                @{ @"Location Updates Enabled":             @(SWITCH) },
                @{ @"EndCard Close Offset":                 @(TEXT_FIELD) },
                @{ @"Show EndCard":                         @(SWITCH) }
            ]},
        @1 :
            @{@"Interstitial": @[
                @{ @"HTML/MRAID Skip Offset":                   @(TEXT_FIELD) },
                @{ @"Video Skip Offset":                        @(TEXT_FIELD) },
                @{ @"SKOverlay Enabled":                        @(SWITCH) },
                @{ @"Close After Finish":                       @(SWITCH) },
                @{ @"Countdown style":                       @(SEGMENTED_CONTROL) }
            ]},
        @2 :
            @{@"Fullscreen": @[
                @{ @"Click behaviour": @(SEGMENTED_CONTROL) }
            ]},
        @3 :
            @{@"Rewarded": @[
                @{ @"HTML/MRAID Skip Offset":          @(TEXT_FIELD) },
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
                    [HyBidRenderingConfig sharedConfig].audioStatus = isON ? HyBidAudioStatusON : HyBidAudioStatusMuted;
                    break;
                }
                case 1: { // MRAID expand enabled
                    [HyBidRenderingConfig sharedConfig].mraidExpand = isON;
                    break;
                }
                case 2: { // Location tracking enabled
                    [HyBidLocationConfig sharedConfig].locationTrackingEnabled = isON;
                    break;
                }
                case 3: { // Location updates enabled
                    [HyBidLocationConfig sharedConfig].locationUpdatesEnabled = isON;
                    break;
                }
                case 5: { // Show EndCard
                    [HyBidRenderingConfig sharedConfig].showEndCard = isON;
                    break;
                }
            }
        }
        case 1: {
            switch (indexPath.row) {
                case 2: { // Interstitial SKOverlay enabled
                    [HyBidRenderingConfig sharedConfig].interstitialSKOverlay = isON;
                    break;
                }
                case 3: { // Close interstitial on finish
                    [HyBidRenderingConfig sharedConfig].interstitialCloseOnFinish = isON;
                    break;
                }
            }
        }
        case 3: {
            switch (indexPath.row) {
                case 0: { // Rewarded SKOverlay enabled
                    [HyBidRenderingConfig sharedConfig].rewardedSKOverlay = isON;
                    break;
                }
                case 1: { // Close rewarded on finish
                    [HyBidRenderingConfig sharedConfig].rewardedCloseOnFinish = isON;
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
                case 4: { // EndCard Close Offset
                    [HyBidRenderingConfig sharedConfig].endCardCloseOffset = [[HyBidSkipOffset alloc] initWithOffset:[NSNumber numberWithInt:[value intValue]] isCustom:YES];
                    break;
                }
            }
        }
        case 1: {
            switch (indexPath.row) {
                case 0: { // HTML/MRAID Skip Offset
                    if ([value intValue] >= 0) {
                        [HyBidRenderingConfig sharedConfig].interstitialHtmlSkipOffset = [[HyBidSkipOffset alloc] initWithOffset:[NSNumber numberWithInteger:[value intValue]] isCustom:YES];
                    }
                    break;
                }
                case 1: { // Video Skip Offset
                    if ([value intValue] >= 0) {
                        [HyBidRenderingConfig sharedConfig].videoSkipOffset = [[HyBidSkipOffset alloc] initWithOffset:[NSNumber numberWithInteger:[value intValue]] isCustom:YES];
                    }
                    break;
                }
            }
            break;
        }
        case 3: {
            switch (indexPath.row) {
                case 0: { // HTML/MRAID Skip Offset Rewarded
                    if ([value intValue] >= 0) {
                        [HyBidRenderingConfig sharedConfig].rewardedHtmlSkipOffset = [[HyBidSkipOffset alloc] initWithOffset:[NSNumber numberWithInteger:[value intValue]] isCustom:YES];
                    }
                    break;
                }
            }
            break;
        }
    }
}

- (void)segmentedControlValueChangedAtIndexPath:(NSIndexPath *)indexPath withIndexValue:(NSInteger)value {
    switch (indexPath.section) {
        case 1: {
            switch(indexPath.row){
                case 4: { // countdown style;
                    [HyBidRenderingConfig sharedConfig].videoSkipOffset.style = [NSNumber numberWithInt: value];
                    break;
                }
            }
            break;
        }
        case 2: {
            switch (indexPath.row) {
                case 0: { // Click behaviour
                    HyBidInterstitialActionBehaviour behaviour = value == 0 ? HB_CREATIVE : HB_ACTION_BUTTON;
                    [HyBidRenderingConfig sharedConfig].interstitialActionBehaviour = behaviour;
                    break;
                }
            }
        }
    }
}

@end
