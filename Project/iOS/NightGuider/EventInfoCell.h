//
//  EventInfoCell.h
//  NightGuider
//
//  Created by Werner Kohn on 18.10.13.
//  Copyright (c) 2013 Werner. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface EventInfoCell : PFTableViewCell

@property (weak, nonatomic) IBOutlet UIButton *priceBtn;
@property (weak, nonatomic) IBOutlet UIButton *extendBtn;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *fadeImageView;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;

@end
