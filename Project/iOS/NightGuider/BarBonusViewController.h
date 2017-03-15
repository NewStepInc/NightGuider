//
//  BarBonusViewController.h
//  NightGuider
//
//  Created by Werner Kohn on 12.11.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import <ParseUI/ParseUI.h>

@interface BarBonusViewController : PFQueryTableViewController<PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>


@property (nonatomic, strong) NSString *barId;
@property (nonatomic, strong) NSString *barName;
@property (nonatomic, strong) NSString *city;


@end
