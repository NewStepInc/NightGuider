//
//  ConfirmationViewController.h
//  NightGuider
//
//  Created by Werner Kohn on 21.06.15.
//  Copyright (c) 2015 Werner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
//#import "PTKView.h"
#import "CardIO.h"



@interface ConfirmationViewController : UITableViewController<CardIOPaymentViewControllerDelegate>


//@property(weak, nonatomic) PTKView *paymentView_2;
@property (nonatomic) PFObject *product_2;
@property (nonatomic, assign) NSInteger *amount_2;
@property (nonatomic, strong) NSDictionary *shippingInfo_2;
@property (nonatomic, assign) NSInteger ticketType;
@property (nonatomic, strong) NSString *token;
@property(nonatomic, strong) NSString *paymentMethod;

@property (nonatomic, strong) PFObject *region;
@property (nonatomic, assign) NSString *regionType;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, assign) NSString *productType;


@property (nonatomic, retain) CardIOCreditCardInfo *cardInfo;





- (id)initStripeWithProduct:(PFObject *)product amount:(NSInteger *)amount shippingInfo:(NSDictionary *)otherShippingInfo userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info;

@end
