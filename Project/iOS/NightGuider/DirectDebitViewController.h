//
//  DirectDebitViewController.h
//  NightGuider
//
//  Created by Werner Kohn on 16.06.15.
//  Copyright (c) 2015 Werner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAYFormBuilder.h"
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>


@interface DirectDebitViewController : PAYFormTableViewController

//@property(weak, nonatomic) PTKView *paymentView_2;
@property (nonatomic) PFObject *product_2;
@property (nonatomic, assign) NSInteger *amount_2;
@property (nonatomic, strong) NSDictionary *shippingInfo_2;
@property (nonatomic, assign) NSInteger ticketType;

@property (nonatomic, strong) PFObject *region;
@property (nonatomic, assign) NSString *regionType;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, assign) NSString *productType;


@end
