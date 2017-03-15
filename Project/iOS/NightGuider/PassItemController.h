//
//  PassItemController.h
//  NightGuider
//
//  Created by Werner Kohn on 10.11.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface PassItemController : UIViewController


// Item controller information
@property (nonatomic) NSUInteger itemIndex; // ***
@property (nonatomic, strong) NSString *itemName; // ***

@property (nonatomic, strong) PFObject *pass;
@property (nonatomic, strong) PFObject *bonus;
@property (assign, nonatomic) BOOL isBonus;



@property (nonatomic, assign) NSInteger passType;



@end
