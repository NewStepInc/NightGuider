//
//  CheckoutViewController.h
//  NightGuider
//
//  Created by Werner Kohn on 16.06.15.
//  Copyright (c) 2015 Werner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAYFormBuilder.h"
#import "PayPalMobile.h"
#import <Parse/Parse.h>


@interface CheckoutViewController : PAYFormTableViewController <PayPalPaymentDelegate, PayPalFuturePaymentDelegate, PayPalProfileSharingDelegate, UIPopoverControllerDelegate>

@property(nonatomic, strong, readwrite) NSString *environment;
@property(nonatomic, assign, readwrite) BOOL acceptCreditCards;
@property(nonatomic, strong, readwrite) NSString *resultText;
@property (nonatomic, strong) PFObject *ticket;
@property (nonatomic, assign) NSInteger ticketType;
@property (nonatomic, assign) NSInteger amount;
@property (nonatomic, strong) PFObject *region;
@property (nonatomic, assign) NSString *regionType;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, assign) NSString *productType;









@end
