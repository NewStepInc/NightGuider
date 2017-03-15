//
//  ClubBonusTableViewController.h
//  NightGuider
//
//  Created by Werner Kohn on 28.05.15.
//  Copyright (c) 2015 Werner. All rights reserved.
//

//#import "PFQueryTableViewController.h"
#import <ParseUI/ParseUI.h>


@interface ClubBonusTableViewController : PFQueryTableViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>


@property (nonatomic, strong) NSString *clubId;
@property (nonatomic, strong) NSString *clubName;
@property (nonatomic, strong) NSString *city;




@end
