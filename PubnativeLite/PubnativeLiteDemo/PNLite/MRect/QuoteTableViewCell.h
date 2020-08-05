//
//  QuoteTableViewCell.h
//  HyBidDemo
//
//  Created by Fares Ben Hamouda on 04.08.20.
//  Copyright © 2020 Can Soykarafakili. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QuoteTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *quoteTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *quoteAutorLabel;

@end

NS_ASSUME_NONNULL_END
