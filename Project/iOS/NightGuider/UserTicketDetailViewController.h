//
//  UserTicketDetailViewController.h
//  NightGuider
//
//  Created by Werner Kohn on 26.10.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>


@interface UserTicketDetailViewController : UIViewController

//NSArray *rectsArray;
//UIColor *backgroundColor;

@property (weak, nonatomic) IBOutlet UILabel *smallHeadline;
@property (weak, nonatomic) IBOutlet UILabel *bigHeadline;
@property (weak, nonatomic) IBOutlet PFImageView *bannerImageView;
@property (weak, nonatomic) IBOutlet UILabel *upperLeftLabel;
@property (weak, nonatomic) IBOutlet UILabel *upperRightLabel;
@property (weak, nonatomic) IBOutlet UILabel *downLeftLabel;
@property (weak, nonatomic) IBOutlet UILabel *downMiddleLabel;
@property (weak, nonatomic) IBOutlet UILabel *downRightLabel;
@property (nonatomic, strong) PFObject *ticket;

@property (nonatomic, assign) NSInteger ticketType;


@end
