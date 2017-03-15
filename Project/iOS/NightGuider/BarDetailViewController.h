//
//  BarDetailViewController.h
//  NightGuider
//
//  Created by Werner Kohn on 12.11.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>


@interface BarDetailViewController : UITableViewController

@property (nonatomic, strong) PFObject *bar;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, assign) BOOL prepareForSegueSelected;
@property (nonatomic, assign) BOOL tableReloaded;

@end
