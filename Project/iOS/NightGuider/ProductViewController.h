//
//  ProductViewController.h
//  NightGuider
//
//  Created by Werner Kohn on 20.10.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface ProductViewController : UITableViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>


@property (nonatomic, strong) NSString *city;


@end
