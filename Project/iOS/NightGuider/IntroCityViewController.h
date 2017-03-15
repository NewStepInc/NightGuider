//
//  IntroCityViewController.h
//  NightGuider
//
//  Created by Werner Kohn on 05.10.14.
//  Copyright (c) 2014 Werner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>


@interface IntroCityViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UITableView *cityTableView;
@property (nonatomic, assign) NSInteger anzahl;


@end
