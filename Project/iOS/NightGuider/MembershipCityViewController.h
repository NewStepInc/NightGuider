//
//  MembershipCityViewController.h
//  NightGuider
//
//  Created by Werner Kohn on 24.10.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>


@interface MembershipCityViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *cityTableView;
@property (nonatomic, assign) NSInteger anzahl;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, assign) NSString *productType;



@end
