//
//  ProfileViewController.h
//  NightGuider
//
//  Created by Werner Kohn on 20.10.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface ProfileViewController : UITableViewController <UIImagePickerControllerDelegate,PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UILabel *fbName;
@property (nonatomic, strong) NSString *stadt;

@end
