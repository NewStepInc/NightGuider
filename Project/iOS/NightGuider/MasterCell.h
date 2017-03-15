//
//  MasterCell.h
//  Nightlife_2
//
//  Created by Werner on 19.11.12.
//  Copyright (c) 2012 Werner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>


@class PFImageView;
@interface MasterCell : PFTableViewCell
@property (weak, nonatomic) IBOutlet PFImageView *FlyerImageView;
@property (strong, nonatomic) IBOutlet UIImageView *BgImageView;
@property (strong, nonatomic) IBOutlet PFImageView *IconImageView;
@property (strong, nonatomic) IBOutlet PFImageView *selectedIconImageView;

@property (strong, nonatomic) IBOutlet UILabel *TitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *SubtitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *DateLabel;
@property (strong, nonatomic) IBOutlet UILabel *AvailableLabel;


@property (strong, nonatomic) IBOutlet UIImageView *DisclosureImageView;
@property (strong, nonatomic) IBOutlet PFImageView *testView;
@property (weak, nonatomic) IBOutlet PFImageView *TestImageView;

//@property (strong, nonatomic) NSString *sp;
@property (assign, nonatomic) BOOL *sp;

@property (weak, nonatomic) IBOutlet UIView *overThirtyView;
@property (weak, nonatomic) IBOutlet UIView *underEighteenView;
@property (weak, nonatomic) IBOutlet UIView *gayView;

@property (weak, nonatomic) IBOutlet UIView *rightBannerView;
@property (weak, nonatomic) IBOutlet UIView *middleBannerView;
@property (weak, nonatomic) IBOutlet UIView *leftBannerView;


@property (weak, nonatomic) IBOutlet UIView *premiumView;

@property (weak, nonatomic) IBOutlet UILabel *upperRightLabel;

@end
