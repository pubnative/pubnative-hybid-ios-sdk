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
#import "HyBidSettings.h"
#import "PNLiteLocationManager.h"

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

#pragma mark - UITableViewDatasource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    NSString *key = self.dataSource.allKeys[indexPath.section];
    NSDictionary *value = self.dataSource[key][indexPath.row];
    
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
                        case 0: { // Set initial audio state
                            BOOL isON = [HyBidSettings sharedInstance].audioStatus == HyBidAudioStatusON;
                            [cell.toggleSwitch setOn:isON];
                            break;
                        }
                        case 1: // MRAID expand enabled
                            [cell.toggleSwitch setOn:[HyBidSettings sharedInstance].mraidExpand];
                            break;
                        case 2: // Location tracking enabled
                            [cell.toggleSwitch setOn:[PNLiteLocationManager locationTrackingEnabled]];
                        case 3: // Location updates enabled
                            [cell.toggleSwitch setOn:[PNLiteLocationManager locationUpdatesEnabled]];
                            break;
                    }
                }
                case 1: {
                    switch (indexPath.row) {
                        case 3: { // Close after finish
                            [cell.toggleSwitch setOn: [HyBidSettings sharedInstance].closeOnFinish];
                            break;
                        }
                    }
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
                case 1: {
                    switch (indexPath.row) {
                        case 0: { // HTML/MRAID Skip Offset
                            cell.textField.text = [@([HyBidSettings sharedInstance].htmlSkipOffset) stringValue];
                            [self addDoneButtonToKeyboardForTextField:cell.textField];
                            break;
                        }
                        case 1: // Video Skip Offset
                            cell.textField.text = [[NSString alloc] initWithFormat:@"%ld", [HyBidSettings sharedInstance].videoSkipOffset];
                            [self addDoneButtonToKeyboardForTextField:cell.textField];
                            break;
                        case 2: // EndCard Close Offset
                            cell.textField.text = [[NSString alloc] initWithFormat:@"%@", [HyBidSettings sharedInstance].endCardCloseOffset];
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
    return [self.dataSource[self.dataSource.allKeys[section]] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.allKeys.count;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.dataSource.allKeys[section];
}

#pragma mark - Utils

- (void)populateDataSource
{
    NSDictionary *dict = @{
        @"General": @[
            @{ @"Initial Audio State":          @(SWITCH) },
            @{ @"MRAID Expand Enabled":         @(SWITCH) },
            @{ @"Location Tracking Enabled":    @(SWITCH) },
            @{ @"Location updates enabled":     @(SWITCH) }
        ],
        @"Interstitial": @[
            @{ @"HTML/MRAID Skip Offset":       @(TEXT_FIELD) },
            @{ @"Video Skip Offset":            @(TEXT_FIELD) },
            @{ @"EndCard Close Offset":         @(TEXT_FIELD) },
            @{ @"Close after finish": @(SWITCH) }
        ],
        @"Fullscreen": @[
            @{ @"Click behaviour": @(SEGMENTED_CONTROL) }
        ]
    };
    
    self.dataSource = [[NSDictionary alloc] initWithDictionary:dict];
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
            }
        }
        case 1: {
            switch (indexPath.row) {
                case 3: { // Close interstitial on finish
                    [HyBid setInterstitialCloseOnFinish:isON];
                    break;
                }
            }
        }
    }
}

- (void)textFieldValueChangedAtIndexPath:(NSIndexPath *)indexPath withValue:(NSString *)value {
    switch (indexPath.section) {
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
                case 2: { // EndCard Close Offset
                    [HyBid setEndCardCloseOffset:[NSNumber numberWithInt:[value intValue]]];
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
