//
//  ResultsViewController.h
//  Nightlife_2
//
//  Created by Werner on 04.12.12.
//  Copyright (c) 2012 Werner. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface ResultsViewController : PFQueryTableViewController

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *art;
@property (nonatomic, strong) NSDateFormatter *df;
@property (nonatomic, strong) NSString *dateSwitch;
@property (nonatomic, strong) NSString *stadt;
@property (nonatomic, strong) UILabel *messageLabel;



@end
