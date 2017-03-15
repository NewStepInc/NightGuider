//
//  TicketPopOverView.h
//  NightGuider
//
//  Created by Werner Kohn on 07.07.15.
//  Copyright (c) 2015 Werner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>



@class TicketPopOverView;             //define class, so protocol can see MyClass
@protocol TicketPopOverViewDelegate <NSObject>   //define delegate protocol
  //define delegate method to be implemented within another class
-(void)ticketPopOverViewDidDismiss:(TicketPopOverView *) sender;
-(void)ticketPopOverViewPurchase:(TicketPopOverView *) sender ticketAmount: (int) ticketAmount;

@end //end protocol

@interface TicketPopOverView : UIView
@property (nonatomic, weak) id <TicketPopOverViewDelegate> delegate; //define MyClassDelegate as delegate
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIStepper *amountStepper;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *freeTicketsLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *hostLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *purchaseButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet PFImageView *bannerImageView;



@end
