//
//  ClubDetailViewController.h
//  NightGuider
//
//  Created by Werner Kohn on 24.04.14.
//  Copyright (c) 2014 Werner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface ClubDetailViewController : UITableViewController

@property (nonatomic, strong) PFObject *club;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *moreButton;
#pragma oder ndoch mit #?
@property (nonatomic, assign) BOOL prepareForSegueSelected;
@property (nonatomic, assign) BOOL tableReloaded;



@end
