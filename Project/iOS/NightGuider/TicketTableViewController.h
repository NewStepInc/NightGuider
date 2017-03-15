//
//  TicketTableViewController.h
//  NightGuider
//
//  Created by Werner Kohn on 29.06.15.
//  Copyright (c) 2015 Werner. All rights reserved.
//

//#import "PFQueryTableViewController.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>


@interface TicketTableViewController : PFQueryTableViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>


@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSDateFormatter *df;
@property (nonatomic, strong) NSString *stadt;


@end
