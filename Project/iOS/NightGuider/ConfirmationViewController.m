//
//  ConfirmationViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 21.06.15.
//  Copyright (c) 2015 Werner. All rights reserved.
//

#import "ConfirmationViewController.h"
//#import "PTKView.h"
#import "STPCard.h"
#import "STPToken.h"
//#import "STPCheckoutView.h"
#import "Stripe.h"
#import "MBProgressHUD.h"
#import <SCLAlertView.h>
#import "UIImage+ImageEffects.h"



@interface ConfirmationViewController ()//<PTKViewDelegate>

//@property(weak, nonatomic) PTKView *paymentView;
@property (nonatomic) PFObject *product;
@property (nonatomic, assign) NSInteger *amount;
@property (nonatomic, strong) NSDictionary *shippingInfo;
@property (nonatomic, strong) MBProgressHUD *hud;


- (void)displayError:(NSError *)error;
- (void)charge:(STPToken *)token;


@end

@implementation ConfirmationViewController

- (id)initStripeWithProduct:(PFObject *)product amount:(NSInteger *)amount shippingInfo:(NSDictionary *)otherShippingInfo userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info {
    if (self = [super init]) {
        self.product = product;
        self.amount = amount;
        self.shippingInfo = otherShippingInfo;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
 //   NSLog(@"produkt: %@", _product);
 //   NSLog(@"produkt 2: %@", _product_2);
    NSLog(@"ticketType: %li", _ticketType);

    NSLog(@"amount: %zd", _amount);
    NSLog(@"info: %@", _shippingInfo);
    
   // NSLog(@"new:\npro: %@\namount: %zd\ninfo: %@", _product_2, _amount_2, _shippingInfo_2);
    
    //braucht man nicht man nimmt card.io
    /*
    PTKView *view = [[PTKView alloc] initWithFrame:CGRectMake(15,120,290,55)];
    self.paymentView = view;
    self.paymentView.delegate = self;
    [self.view addSubview:self.paymentView];
    */
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if ([_productType isEqualToString:@"dayTicket"]) {
        NSLog(@"tagesticket");
        NSLog(@"regiontype: %@", _regionType);
        NSLog(@"product: %@", _region);
        NSLog(@"startdate: %@", _startDate);
        

    }
    else if ([_productType isEqualToString:@"membership"])
    {
        NSLog(@"membership");
        NSLog(@"regiontype: %@", _regionType);
        NSLog(@"product: %@", _region);
    }
    
    else{
        NSLog(@"producttype: %@", _productType);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return 5;
            break;
        case 2:
            return 1;
            break;
            
        default:
            return 0;

            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"indexpath: %li row: %li", indexPath.section, indexPath.row);
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //banner von event
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bannerCell" forIndexPath:indexPath];
            
            
            PFImageView *bannerImageView = (PFImageView*)[cell viewWithTag:111];
             NSLog(@"1");

            /*
            bannerImageView.backgroundColor = [UIColor blackColor];
            PFFile *thumbnail = [_product_2 objectForKey:@"image"];
            NSLog(@"2");

            bannerImageView.file = thumbnail;
            bannerImageView.clipsToBounds = YES;
            NSLog(@"3");
            bannerImageView.contentMode =UIViewContentModeScaleAspectFill;


            [bannerImageView loadInBackground];
            */
            
            //Bild anzeigen
            PFFile *applicantResume = [_product_2 objectForKey:@"pic_big"];
            
#warning get images for membership and dayTicket
            if ([_productType isEqualToString:@"membership"]) {

            }
            else if ([_productType isEqualToString:@"dayTicket"]){

                
            }
            else{
                
            }
            
            
            [applicantResume getDataInBackgroundWithBlock:^(NSData *resumeData, NSError *error) {
                if (!error) {
                    // The find succeeded.
                    NSLog(@"Bild empfangen!");
                    //self.imageView.image = [UIImage imageWithData:resumeData];
                    UIImage* bigPic = [UIImage imageWithData:resumeData];

                    
                    
                        UIColor *tintColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.5f];
                        
                        UIImage *backgroundImage = [bigPic applyBlurWithRadius:1 tintColor:tintColor saturationDeltaFactor:0.6 maskImage:nil];
                        

                        bannerImageView.image = backgroundImage;
                        bannerImageView.alpha= 0.8f;
                        bannerImageView.clipsToBounds = YES;
                        bannerImageView.contentMode =UIViewContentModeScaleAspectFill;

                    
                } else {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }
             ];

             
            
            
            NSString *title;
            NSDate *date;
            
            if ([_productType isEqualToString:@"membership"]) {
                
                title = [_region objectForKey:@"name"];
                UILabel *dateLabel = (UILabel*)[cell viewWithTag:2];
                dateLabel.text = @"";

            }
            else if ([_productType isEqualToString:@"dayTicket"]){
                title = [_region objectForKey:@"name"];

                date = _startDate;
                UILabel *dateLabel = (UILabel*)[cell viewWithTag:2];
                NSDateFormatter *dfd = [[NSDateFormatter alloc] init];
                dfd.dateStyle = NSDateFormatterLongStyle;
                dfd.timeStyle = NSDateFormatterNoStyle;
                dfd.timeZone = [NSTimeZone localTimeZone];
                NSString *datum = [dfd stringFromDate:date];
                dateLabel.text = datum;

                
            }
            else{
                title = [_product_2 objectForKey:@"name"];
                date = [_product_2 objectForKey:@"start_time"];
                UILabel *dateLabel = (UILabel*)[cell viewWithTag:2];
                NSDateFormatter *dfd = [[NSDateFormatter alloc] init];
                dfd.dateStyle = NSDateFormatterLongStyle;
                dfd.timeStyle = NSDateFormatterNoStyle;
                dfd.timeZone = [NSTimeZone localTimeZone];
                NSString *datum = [dfd stringFromDate:date];
                dateLabel.text = datum;

            }
            
            UILabel *titleLabel = (UILabel*)[cell viewWithTag:1];
            titleLabel.text = title;
            
            NSLog(@"2");



            return cell;


        }
        else{
            //benutzerinfo
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell" forIndexPath:indexPath];
            cell.textLabel.text = [_shippingInfo_2 objectForKey:@"firstName"];
            cell.detailTextLabel.text = [_shippingInfo_2 objectForKey:@"lastName"];

            return cell;


        }
    }
    else if (indexPath.section == 1){
        
        if (indexPath.row == 0) {
            //ticketname
            NSLog(@"1");
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"productCell" forIndexPath:indexPath];
            NSLog(@"2");

            if ([_productType isEqualToString:@"membership"]) {
                
                cell.textLabel.text = @"Mitgliedschaft";
                
                NSString *priceString = [NSString stringWithFormat:@"%.02f €",[[_region objectForKey:@"membershipPrice_3"]floatValue]];
                
                cell.detailTextLabel.text =priceString;
                
            }
            else if ([_productType isEqualToString:@"dayTicket"]){
                cell.textLabel.text = @"3-Tagesticket";
                
                NSString *priceString = [NSString stringWithFormat:@"%.02f €",[[_region objectForKey:@"dayPrice_3"]floatValue]];
                
                cell.detailTextLabel.text =priceString;
                
            }
            
            else{
                
            if (_ticketType == 1) {
                /*
                NSString *productName = [NSString stringWithFormat:@"Ticket für %@", [_product_2 objectForKey:@"name"]];
                cell.textLabel.text = productName;
                 */
                cell.textLabel.text = @"Ticket";

                NSString *priceString = [NSString stringWithFormat:@"%.02f €",[[_product_2 objectForKey:@"ticketPrice"]floatValue]];
                
                cell.detailTextLabel.text =priceString;


            }
            else if (_ticketType == 2){
                /*
                NSString *productName = [NSString stringWithFormat:@"Gästelistenplatz für %@", [_product_2 objectForKey:@"name"]];
                cell.textLabel.text = productName;
                 */
                NSLog(@"wird noch geladen");
                cell.textLabel.text = @"Gästelistenplatz";

                NSString *priceString = [NSString stringWithFormat:@"%.02f €",[[_product_2 objectForKey:@"guestlistPrice"]floatValue]];
                cell.detailTextLabel.text = priceString;
                NSLog(@"3");


                
            }
            else{
                /*
                NSString *productName = [NSString stringWithFormat:@"Kombiticket für %@", [_product_2 objectForKey:@"name"]];
                cell.textLabel.text = productName;
                 */
                NSLog(@"4");

                cell.textLabel.text = @"Kombiticket";

                
                float ticketPrice = [[_product_2 objectForKey:@"ticketPrice"] floatValue];
                float guestlistPrice = [[_product_2 objectForKey:@"guestlistPrice"] floatValue];
                float sum = ticketPrice + guestlistPrice;
                NSString *subtitle = [NSString stringWithFormat:@"%.02f €", sum];

                cell.detailTextLabel.text = subtitle;

                
            }
                
            }
            
            return cell;


        }
        else if (indexPath.row == 1){
            //Anzahl Tickets
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"quantityCell" forIndexPath:indexPath];
            NSString *subtitle = [NSString stringWithFormat:@"%u", (unsigned)_amount_2];

            cell.detailTextLabel.text = subtitle;
            return cell;


        }
        else if (indexPath.row == 2){
            //Preis vor Steuern
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"subtotalCell" forIndexPath:indexPath];
            
            if ([_productType isEqualToString:@"membership"]) {

                float ticketPrice = [[_region objectForKey:@"membershipPrice_3"] floatValue];
                float sum = ticketPrice * (int)_amount_2;
                float tax = sum * 0.19;
                
                NSString *subtitle = [NSString stringWithFormat:@"%.02f €", sum-tax];
                
                cell.detailTextLabel.text = subtitle;
                
            }
            else if ([_productType isEqualToString:@"dayTicket"]){
                
                float ticketPrice = [[_region objectForKey:@"dayPrice_3"] floatValue];
                float sum = ticketPrice * (int)_amount_2;
                float tax = sum * 0.19;
                
                NSString *subtitle = [NSString stringWithFormat:@"%.02f €", sum-tax];
                
                cell.detailTextLabel.text = subtitle;
                
            }
            else{
                
            
            if (_ticketType == 1) {

                float ticketPrice = [[_product_2 objectForKey:@"ticketPrice"] floatValue];
                float sum = ticketPrice * (int)_amount_2;
                float tax = sum * 0.19;

                NSString *subtitle = [NSString stringWithFormat:@"%.02f €", sum-tax];
                
                cell.detailTextLabel.text = subtitle;
                
                
            }
            else if (_ticketType == 2){

                float guestlistPrice = [[_product_2 objectForKey:@"guestlistPrice"] floatValue];
                float sum = guestlistPrice * (int)_amount_2;
                float tax = sum * 0.19;

                NSString *subtitle = [NSString stringWithFormat:@"%.02f €", sum-tax];
                
                cell.detailTextLabel.text = subtitle;
                
                
            }
            else{

                float ticketPrice = [[_product_2 objectForKey:@"ticketPrice"] floatValue];
                float guestlistPrice = [[_product_2 objectForKey:@"guestlistPrice"] floatValue];
                float sum = (ticketPrice + guestlistPrice) * (int)_amount_2;
                float tax = sum * 0.19;

                NSString *subtitle = [NSString stringWithFormat:@"%.02f €", sum-tax];
                
                cell.detailTextLabel.text = subtitle;
                
                
            }
            
            }
            return cell;

            

            
        }
        else if (indexPath.row == 3){
            //Steuern
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"taxCell" forIndexPath:indexPath];
            
            if ([_productType isEqualToString:@"membership"]) {
                
                float ticketPrice = [[_region objectForKey:@"membershipPrice_3"] floatValue];
                float sum = ticketPrice * (int)_amount_2;
                float tax = sum * 0.19;
                
                NSString *subtitle = [NSString stringWithFormat:@"%.02f €", tax];
                
                cell.detailTextLabel.text = subtitle;
                
            }
            else if ([_productType isEqualToString:@"dayTicket"]){
                
                float ticketPrice = [[_region objectForKey:@"dayPrice_3"] floatValue];
                float sum = ticketPrice * (int)_amount_2;
                float tax = sum * 0.19;
                
                NSString *subtitle = [NSString stringWithFormat:@"%.02f €", tax];
                
                cell.detailTextLabel.text = subtitle;
                
            }
            else{
                
                
            if (_ticketType == 1) {
                
                float ticketPrice = [[_product_2 objectForKey:@"ticketPrice"] floatValue];
                float sum = ticketPrice * (int)_amount_2;
                float tax = sum * 0.19;
                
                NSString *subtitle = [NSString stringWithFormat:@"%.02f €", tax];
                
                cell.detailTextLabel.text = subtitle;
                
                
            }
            else if (_ticketType == 2){
                
                float guestlistPrice = [[_product_2 objectForKey:@"guestlistPrice"] floatValue];
                float sum = guestlistPrice * (int)_amount_2;
                float tax = sum * 0.19;
                
                NSString *subtitle = [NSString stringWithFormat:@"%.02f €", tax];
                
                cell.detailTextLabel.text = subtitle;
                
                
            }
            else{
                
                float ticketPrice = [[_product_2 objectForKey:@"ticketPrice"] floatValue];
                float guestlistPrice = [[_product_2 objectForKey:@"guestlistPrice"] floatValue];
                float sum = (ticketPrice + guestlistPrice) * (int)_amount_2;
                float tax = sum * 0.19;
                
                NSString *subtitle = [NSString stringWithFormat:@"%.02f €", tax];
                
                cell.detailTextLabel.text = subtitle;
                
                
            }
            
            }
            return cell;


        }
        else if (indexPath.row == 4){
            //Summe
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"totalCell" forIndexPath:indexPath];
            
            if ([_productType isEqualToString:@"membership"]) {
                
                float ticketPrice = [[_region objectForKey:@"membershipPrice_3"] floatValue];
                float sum = ticketPrice * (int)_amount_2;
                
                NSString *subtitle = [NSString stringWithFormat:@"%.02f € / monatlich", sum];
                
                cell.detailTextLabel.text = subtitle;
            }
            else if([_productType isEqualToString:@"dayTicket"]){
                float ticketPrice = [[_region objectForKey:@"dayPrice_3"] floatValue];
                float sum = ticketPrice * (int)_amount_2;
                
                NSString *subtitle = [NSString stringWithFormat:@"%.02f €", sum];
                
                cell.detailTextLabel.text = subtitle;
            }
            
            else{
                
            if (_ticketType == 1) {
                
                float ticketPrice = [[_product_2 objectForKey:@"ticketPrice"] floatValue];
                float sum = ticketPrice * (int)_amount_2;
                
                NSString *subtitle = [NSString stringWithFormat:@"%.02f €", sum];
                
                cell.detailTextLabel.text = subtitle;
                
                
            }
            else if (_ticketType == 2){
                
                float guestlistPrice = [[_product_2 objectForKey:@"guestlistPrice"] floatValue];
                float sum = guestlistPrice * (int)_amount_2;
                
                NSString *subtitle = [NSString stringWithFormat:@"%.02f €", sum];
                
                cell.detailTextLabel.text = subtitle;
                
                
            }
            else{
                
                float ticketPrice = [[_product_2 objectForKey:@"ticketPrice"] floatValue];
                float guestlistPrice = [[_product_2 objectForKey:@"guestlistPrice"] floatValue];
                float sum = (ticketPrice + guestlistPrice) * (int)_amount_2;
                
                NSString *subtitle = [NSString stringWithFormat:@"%.02f €", sum];
                
                cell.detailTextLabel.text = subtitle;
                
                
            }
                
            }
            
            return cell;

        }
        else {
            NSLog(@"5");

            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
            return cell;


        }
        
    }
    else{
        NSLog(@"checkout Cell");
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"checkoutCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
    }
}

//Überschrift der Sektionen
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 1:
            return @"Details";
            break;
        case 2:
            return @"\n";
            break;
            
        default: return @"";
            break;
    };
    
    
    
}




//didselect...
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   // [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    //erst überprüfen ob überhaupt eingeloggt
    if(indexPath.section == 2 && indexPath.row == 0){
        NSLog(@"Bestätigen geklickt");
        
        if ([_paymentMethod isEqualToString:@"l"]) {
            NSLog(@"lastschriftverfahren ausführen");
            [self createTransactionWithToken:_token];
        }
        else if ([_paymentMethod isEqualToString:@"c"]){
            NSLog(@"Kreditkartenverfahren ausführen");
            [self checkoutStripe];
            
        }
        else{
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            
            //Hide animation type (Default is FadeOut)
            alert.hideAnimationType = SlideOutToTop;
            
            //Show animation type (Default is SlideInFromTop)
            alert.showAnimationType = SlideInFromTop;
            
            //Set background type (Default is Shadow)
            alert.backgroundType = Blur;
            
            [alert alertIsDismissed:^{
                NSLog(@"SCLAlertView dismissed!");
                [self performSegueWithIdentifier:@"returnToMain" sender:self];
            }];
            
            [alert showError:self title:@"Fehlerhafte Zahlungsmethode" subTitle:@"Leider konnte deine Zahlungsmethode nicht erfasst werden, versuche es erneut" closeButtonTitle:@"OK" duration:0.0f];
        }
        
    }
    

}

#pragma mark - ()
/*
- (void) paymentView:(PTKView*)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid
{
    NSLog(@"Card number: %@", card.number);
    NSLog(@"Card expiry: %lu/%lu", (unsigned long)card.expMonth, (unsigned long)card.expYear);
    NSLog(@"Card cvc: %@", card.cvc);
    NSLog(@"Address zip: %@", card.addressZip);
    
    
    // self.navigationItem.rightBarButtonItem.enabled = valid;
}
 */

-(void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)paymentViewController{
    DLog(@"card.io did cancel");

}

-(void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)cardInfo inPaymentViewController:(CardIOPaymentViewController *)paymentViewController{
    DLog(@"card.io did provide creditcardinfo");

}
- (void)checkoutStripe {
    NSLog(@"--1");
    self.hud.labelText = NSLocalizedString(@"Authorizing...", @"Authorizing...");
    [self.hud show:YES];
    STPAPIClient *client = [[STPAPIClient alloc] initWithPublishableKey:@"pk_test_JCOG2vg068yxMoJTSEPa4Qna"];
//[STPAPIClient sharedClient]
    
    /*
    STPCard *card = [[STPCard alloc] init];
    card.number = self.paymentView.card.number;
    card.expMonth = self.paymentView.card.expMonth;
    card.expYear = self.paymentView.card.expYear;
    card.cvc = self.paymentView.card.cvc;
    */
    
    STPCardParams *card = [[STPCardParams alloc] init];
    card.number = _cardInfo.cardNumber;
    card.expMonth = _cardInfo.expiryMonth;
    card.expYear = _cardInfo.expiryYear;
    card.cvc = _cardInfo.cvv;
    
    
    NSLog(@"--2");
    //[Stripe createTokenWithCard:card completion:^(STPToken *token, NSError *error) {

    [client createTokenWithCard:card completion:^(STPToken *token, NSError *error) {
        if (error) {
            NSLog(@"--3");
            
            // [self handleError:error];
            [self.hud hide:YES];
            
            [self displayError:error];
            
        } else {
            // [self createBackendChargeWithToken:token];
            NSLog(@"--4");
            
            [self charge:token];
            
        }
    }];
}


- (void)displayError:(NSError *)error {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                      message:[error localizedDescription]
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                            otherButtonTitles:nil];
    [message show];
}


- (void)charge:(STPToken *)token {
    //[_paymentView resignFirstResponder];
    
    self.hud.labelText = @"Charging...";
    [self.hud show:YES];

    /*
     NSDictionary *productInfo = @{
     @"itemName": self.product[@"name"],
     @"amount": self.shippingInfo[@"amount"],
     @"cardToken": token.tokenId,
     @"name": self.shippingInfo[@"firstName"],
     @"email": self.shippingInfo[@"email"],
     @"address": self.shippingInfo[@"address"],
     @"zip": self.shippingInfo[@"zip"],
     @"city_state": self.shippingInfo[@"cityState"]
     };
     
     */
    NSLog(@"charge token 5");
    
    //kesselhaus event
    /*
    NSString *eventid = @"2sxRKVEL55";
    NSString *eventName = @"Careers4engineers";
    */
    NSString *eventid = _product_2.objectId;
    /*
#pragma tickettype
    if (_ticketType == 0) {
        
        float ticketPrice = [[_product_2 objectForKey:@"ticketPrice"] floatValue];
        float sum = ticketPrice * (int)_amount_2;
        NSString *shortDescription = [NSString stringWithFormat:@"Ticket für %@", [_product_2 objectForKey:@"name"]];
        
    }
    else if (_ticketType == 1){
        
        float guestlistPrice = [[_product_2 objectForKey:@"guestlistPrice"] floatValue];
        float sum = guestlistPrice * (int)_amount_2;
        
        NSString *shortDescription = [NSString stringWithFormat:@"Gästelistenplätze für %@", [_product_2 objectForKey:@"name"]];
        
        
    }
    else{
        
        float ticketPrice = [[_product_2 objectForKey:@"ticketPrice"] floatValue];
        float guestlistPrice = [[_product_2 objectForKey:@"guestlistPrice"] floatValue];
        float sum = (ticketPrice + guestlistPrice) * (int)_amount_2;
        
        NSString *shortDescription = [NSString stringWithFormat:@"Kombiticket für %@", [_product_2 objectForKey:@"name"]];
        
        
    }
    
    */
    
#pragma geht das mit price initalisierung?
    
    NSNumber *price = @0;

    if ([_productType isEqualToString:@"membership"]) {
        NSNumber *ticketPrice = [_region objectForKey:@"membershipPrice_3"];
        NSDecimalNumber *ticketPriceNum = [NSDecimalNumber decimalNumberWithDecimal:[ticketPrice decimalValue]];
        NSNumber *amount = [NSNumber numberWithInteger:(int)_amount_2];
        NSDecimalNumber *amountNum = [NSDecimalNumber decimalNumberWithDecimal:[amount decimalValue]];
        
        NSDecimalNumber *total = [ticketPriceNum decimalNumberByMultiplyingBy:amountNum];
        
        price = total;
        NSLog(@"membership 1");
    }
    
    else if ([_productType isEqualToString:@"dayTicket"]){
        
        NSNumber *ticketPrice = [_region objectForKey:@"dayPrice_3"];
        NSDecimalNumber *ticketPriceNum = [NSDecimalNumber decimalNumberWithDecimal:[ticketPrice decimalValue]];
        NSNumber *amount = [NSNumber numberWithInteger:(int)_amount_2];
        NSDecimalNumber *amountNum = [NSDecimalNumber decimalNumberWithDecimal:[amount decimalValue]];
        
        NSDecimalNumber *total = [ticketPriceNum decimalNumberByMultiplyingBy:amountNum];
        
        price = total;
    }
    else{
    
    if (_ticketType == 1) {
        NSNumber *ticketPrice = [_product_2 objectForKey:@"ticketPrice"];
        NSDecimalNumber *ticketPriceNum = [NSDecimalNumber decimalNumberWithDecimal:[ticketPrice decimalValue]];
        NSNumber *amount = [NSNumber numberWithInteger:(int)_amount_2];
        NSDecimalNumber *amountNum = [NSDecimalNumber decimalNumberWithDecimal:[amount decimalValue]];
        
        NSDecimalNumber *total = [ticketPriceNum decimalNumberByMultiplyingBy:amountNum];

        price = total;

        
        
    }
    else if (_ticketType == 2){
        NSNumber *ticketPrice = [_product_2 objectForKey:@"guestlistPrice"];
        NSDecimalNumber *ticketPriceNum = [NSDecimalNumber decimalNumberWithDecimal:[ticketPrice decimalValue]];
        NSNumber *amount = [NSNumber numberWithInteger:(int)_amount_2];
        NSDecimalNumber *amountNum = [NSDecimalNumber decimalNumberWithDecimal:[amount decimalValue]];
        
        NSDecimalNumber *total = [ticketPriceNum decimalNumberByMultiplyingBy:amountNum];
        price = total;

        
        
    }
    else{
        NSNumber *ticketPrice = [_product_2 objectForKey:@"ticketPrice"];
        NSDecimalNumber *ticketPriceNum = [NSDecimalNumber decimalNumberWithDecimal:[ticketPrice decimalValue]];
        NSNumber *guestlistPrice = [_product_2 objectForKey:@"guestlistPrice"];
        NSDecimalNumber *guestlistPriceNum = [NSDecimalNumber decimalNumberWithDecimal:[guestlistPrice decimalValue]];
        
        NSDecimalNumber *combiPriceNum = [ticketPriceNum decimalNumberByAdding:guestlistPriceNum];
        
        NSNumber *amount = [NSNumber numberWithInteger:(int)_amount_2];
        NSDecimalNumber *amountNum = [NSDecimalNumber decimalNumberWithDecimal:[amount decimalValue]];
        
        NSDecimalNumber *total = [combiPriceNum decimalNumberByMultiplyingBy:amountNum];
        price = total;

        
        
    }
        
    }


    NSNumber *amount = [NSNumber numberWithInteger:(int)_amount_2];
  //  NSString *shortDescription = [NSString stringWithFormat:@"%@ Tickets für %@",amount, [_product_2 objectForKey:@"name"]];
    
    
    NSString *tokenString = token.tokenId;
    
    NSDictionary *productInfo = @{
                                  };

    
    if ([_productType isEqualToString:@"membership"]) {
        NSLog(@"membership 2");

        productInfo = @{
                                      
                                      @"regionId": _region.objectId,
                                      @"cardToken": tokenString,
                                      @"firstName": self.shippingInfo_2[@"firstName"],
                                      @"lastName": self.shippingInfo_2[@"lastName"],
                                      @"email": self.shippingInfo_2[@"email"],
                                      @"regionName": [_region objectForKey:@"name"],
                                      @"regionType": _regionType,

                                      @"amount": amount,
                                      @"currency": @"eur",
                                      @"duration": @3
                                      
                                      };
        
        NSLog(@"membership 3");

    }
    
    else if ([_productType isEqualToString:@"dayTicket"]){
        productInfo = @{
                                      
                        @"regionId": _region.objectId,
                        @"regionType": _regionType,
                        @"cardToken": tokenString,
                        @"firstName": self.shippingInfo_2[@"firstName"],
                        @"lastName": self.shippingInfo_2[@"lastName"],
                        @"email": self.shippingInfo_2[@"email"],
                        @"regionName": [_region objectForKey:@"name"],
                        @"startDate": _startDate,
                        @"amount": amount,
                        @"currency": @"eur",
                        @"duration": @3
                        
                                      };
    }
    
    else{
        productInfo = @{
                        
                                      @"itemId": eventid,
                                      @"cardToken": tokenString,
                                      @"firstName": self.shippingInfo_2[@"firstName"],
                                      @"lastName": self.shippingInfo_2[@"lastName"],
                                      @"email": self.shippingInfo_2[@"email"],
                                      
                                      @"amount": amount,
                                      @"currency": @"eur",
                                      
                                      };
        
    }
    
    /*
     @"street": self.shippingInfo_2[@"street"],
     @"zip": self.shippingInfo_2[@"zip"],
     @"city": self.shippingInfo_2[@"city"],
     */

    
    
    
    NSLog(@"6");
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    //Hide animation type (Default is FadeOut)
    alert.hideAnimationType = SlideOutToTop;
    
    //Show animation type (Default is SlideInFromTop)
    alert.showAnimationType = SlideInFromTop;
    
    //Set background type (Default is Shadow)
    alert.backgroundType = Blur;
    
    [alert alertIsDismissed:^{
        NSLog(@"SCLAlertView dismissed!");
        //  [self performSegueWithIdentifier:@"returnToMain" sender:self];
        
    }];
    
    
    NSString *cloudType = @"Error";
    
    if ([_productType isEqualToString:@"membership"]) {
        cloudType = @"stripe_purchaseMembership";

    }
    else if ([_productType isEqualToString:@"dayTicket"]){
        cloudType = @"stripe_purchase3DayTicket";

    }
    
    else{
        
        if (_ticketType == 1) {
            cloudType = @"stripe_purchaseTicket";
        }
        else if (_ticketType == 2){
            cloudType = @"stripe_purchaseGuestlist";
        }
        else {
            cloudType = @"stripe_purchaseCombi";
        
        }
    
    }
    NSLog(@"type: %@", cloudType);
    
    [PFCloud callFunctionInBackground:cloudType
                       withParameters:productInfo
                                block:^(id object, NSError *error) {
                                    [self.hud hide:YES];
                                    NSLog(@"7");
                                    
                                    if (error) {
                                        /*
                                         [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                         message:[[error userInfo] objectForKey:@"error"]
                                         delegate:nil
                                         cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                         otherButtonTitles:nil] show];
                                         */
                                        
                                        [alert showError:self title:@"Error" subTitle:[[error userInfo] objectForKey:@"error"] closeButtonTitle:@"OK" duration:0.0f];
                                        
                                    } else {
                                        NSLog(@"erfolgreich");
                                        //  [self performSegueWithIdentifier:@"returnToMain" sender:self];
                                        
                                        
                                        [self showSuccess];

                                        
                                        /*
                                         PFFinishViewController *finishController = [[PFFinishViewController alloc] initWithProduct:self.product];
                                         [self.navigationController pushViewController:finishController animated:YES];*/
                                    }
                                    
                                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

                                }];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)createTransactionWithToken:(NSString*)token {
    
    self.hud.labelText = NSLocalizedString(@"Authorizing...", @"Authorizing...");
    [self.hud show:YES];
    
    //  NSString *eventid = @"2sxRKVEL55";
    NSString *eventid = _product_2.objectId;
    
#pragma tickettype
#pragma geht das mit price initalisierung?
    
    NSNumber *price = @0;
    
    if ([_productType isEqualToString:@"membership"]) {
        NSNumber *ticketPrice = [_region objectForKey:@"membershipPrice_3"];
        NSDecimalNumber *ticketPriceNum = [NSDecimalNumber decimalNumberWithDecimal:[ticketPrice decimalValue]];
        NSNumber *amount = [NSNumber numberWithInteger:_amount_2];
        NSDecimalNumber *amountNum = [NSDecimalNumber decimalNumberWithDecimal:[amount decimalValue]];
        
        NSDecimalNumber *total = [ticketPriceNum decimalNumberByMultiplyingBy:amountNum];
        
        price = total;
    }
    else if ([_productType isEqualToString:@"dayTicket"]){
        NSNumber *ticketPrice = [_region objectForKey:@"dayPrice_3"];
        NSDecimalNumber *ticketPriceNum = [NSDecimalNumber decimalNumberWithDecimal:[ticketPrice decimalValue]];
        NSNumber *amount = [NSNumber numberWithInteger:_amount_2];
        NSDecimalNumber *amountNum = [NSDecimalNumber decimalNumberWithDecimal:[amount decimalValue]];
        
        NSDecimalNumber *total = [ticketPriceNum decimalNumberByMultiplyingBy:amountNum];
        
        price = total;
    }
    
    else{
        
    if (_ticketType == 1) {
        NSNumber *ticketPrice = [_product_2 objectForKey:@"ticketPrice"];
        NSDecimalNumber *ticketPriceNum = [NSDecimalNumber decimalNumberWithDecimal:[ticketPrice decimalValue]];
        NSNumber *amount = [NSNumber numberWithInteger:_amount_2];
        NSDecimalNumber *amountNum = [NSDecimalNumber decimalNumberWithDecimal:[amount decimalValue]];
        
        NSDecimalNumber *total = [ticketPriceNum decimalNumberByMultiplyingBy:amountNum];
        
        price = total;
        
        
        
    }
    else if (_ticketType == 2){
        NSNumber *ticketPrice = [_product_2 objectForKey:@"guestlistPrice"];
        NSDecimalNumber *ticketPriceNum = [NSDecimalNumber decimalNumberWithDecimal:[ticketPrice decimalValue]];
        NSNumber *amount = [NSNumber numberWithInteger:_amount_2];
        NSDecimalNumber *amountNum = [NSDecimalNumber decimalNumberWithDecimal:[amount decimalValue]];
        
        NSDecimalNumber *total = [ticketPriceNum decimalNumberByMultiplyingBy:amountNum];
        price = total;
        
        
        
    }
    else{
        NSNumber *ticketPrice = [_product_2 objectForKey:@"ticketPrice"];
        NSDecimalNumber *ticketPriceNum = [NSDecimalNumber decimalNumberWithDecimal:[ticketPrice decimalValue]];
        NSNumber *guestlistPrice = [_product_2 objectForKey:@"guestlistPrice"];
        NSDecimalNumber *guestlistPriceNum = [NSDecimalNumber decimalNumberWithDecimal:[guestlistPrice decimalValue]];
        
        NSDecimalNumber *combiPriceNum = [ticketPriceNum decimalNumberByAdding:guestlistPriceNum];
        
        NSNumber *amount = [NSNumber numberWithInteger:_amount_2];
        NSDecimalNumber *amountNum = [NSDecimalNumber decimalNumberWithDecimal:[amount decimalValue]];
        
        NSDecimalNumber *total = [combiPriceNum decimalNumberByMultiplyingBy:amountNum];
        price = total;
        
        
        
    }
        
    }

   // NSNumber *price = _product_2[@"ticketPrice"];
    NSNumber *quantity = [NSNumber numberWithInteger:_amount_2];

    
    NSDictionary *productInfo = @{
                                  };
    NSLog(@"1");
    if ([_productType isEqualToString:@"membership"]) {
            NSString *shortDescription = [NSString stringWithFormat:@"Mitgliedschaft für %@",[_region objectForKey:@"name"]];
        
        NSLog(@"membership");
        
        
        productInfo = @{
                        
                        @"firstName": self.shippingInfo_2[@"firstName"],
                        @"lastName": self.shippingInfo_2[@"lastName"],
                        @"regionName": [_region objectForKey:@"name"],
                        @"regionId": _region.objectId,
                        @"token": token,
                        @"email": self.shippingInfo_2[@"email"],
                     //   @"regionType": [_region objectForKey:@"regionType"],
                        @"regionType": _regionType,

                        @"price": price,
                        @"quantity": quantity,
                        
                        @"currency": @"EUR",
                        @"description": shortDescription,
                        @"duration": @3

                        
                        
                        
                        };
    }
    else if([_productType isEqualToString:@"dayTicket"]){
            NSString *shortDescription = [NSString stringWithFormat:@"3-Tagesticket für %@",[_region objectForKey:@"name"]];
        
        NSLog(@"dayTicket");

        productInfo = @{
                        
                        @"firstName": self.shippingInfo_2[@"firstName"],
                        @"lastName": self.shippingInfo_2[@"lastName"],
                        @"regionName": [_region objectForKey:@"name"],
                        @"regionId": _region.objectId,
                        @"regionType": _regionType,
                        @"token": token,
                        @"email": self.shippingInfo_2[@"email"],
                        @"startDate": _startDate,
                        @"price": price,
                        @"quantity": quantity,
                        
                        @"currency": @"EUR",
                        @"description": shortDescription,
                        @"duration": @3

                        
                        
                        
                        };
    }
    
    else{
        
            NSString *shortDescription = [NSString stringWithFormat:@"%@ Tickets für %@",quantity, [_product_2 objectForKey:@"name"]];
        

        productInfo = @{
                        
                        @"firstName": self.shippingInfo_2[@"firstName"],
                        @"lastName": self.shippingInfo_2[@"lastName"],
                        @"itemName": self.product_2[@"name"],
                        @"itemId": eventid,
                        @"token": token,
                        @"email": self.shippingInfo_2[@"email"],
                        
                        @"price": price,
                        @"quantity": quantity,
                        
                        @"currency": @"EUR",
                        @"description": shortDescription
                        
                        
                        
                        };
        
    }
    
    
    

    /*
     NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
     [parameters setObject:token forKey:@"token"];
     [parameters setObject:_amount_2 forKey:@"amount"];
     [parameters setObject:self.currency forKey:@"currency"];
     [parameters setObject:self.description forKey:@"descrition"];
     */
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    //Hide animation type (Default is FadeOut)
    alert.hideAnimationType = SlideOutToTop;
    
    //Show animation type (Default is SlideInFromTop)
    alert.showAnimationType = SlideInFromTop;
    
    //Set background type (Default is Shadow)
    alert.backgroundType = Blur;
    
    [alert alertIsDismissed:^{
        NSLog(@"SCLAlertView dismissed!");
        //  [self performSegueWithIdentifier:@"returnToMain" sender:self];
    }];
    
    NSString *cloudType = @"Error";
    
    if ([_productType isEqualToString:@"membership"]) {
        cloudType = @"paymill_purchaseMembership";

    }
    else if ([_productType isEqualToString:@"dayTicket"]){
        cloudType = @"paymill_purchase3DayTicket";

    }
    else{
        if (_ticketType == 1) {
            cloudType = @"paymill_purchaseTicket";
        }
        else if (_ticketType == 2){
            cloudType = @"paymill_purchaseGuestlist";
        }
        else {
            cloudType = @"paymill_purchaseCombi";
        
        }
    }
    
    NSLog(@"type: %@", cloudType);
    
    NSLog(@"paymill infos %@",productInfo);
    

            [PFCloud callFunctionInBackground:cloudType withParameters:productInfo
                                        block:^(id object, NSError *error) {
                                            if(error == nil){

                                                [self showSuccess];
                                                
                                            }
                                            else {
                                                // [self transactionFailWithError:error];
                                                NSLog(@"bei cloud");
                                                [alert showError:self title:@"Error" subTitle:[[error userInfo] objectForKey:@"error"] closeButtonTitle:@"OK" duration:0.0f];
                                            }
                                            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                        } ];
            
    

    /*
     
     [PFCloud callFunctionInBackground:@"paymill_purchaseGuestList" withParameters:productInfo
     block:^(id object, NSError *error) {
     if(error == nil){
     //  [self transactionSucceed];
     [alert showSuccess:self title:@"Erfolgreich" subTitle:@"Wir haben dein Bestellung aufgenommen!" closeButtonTitle:@"Done" duration:0.0f];
     }
     else {
     // [self transactionFailWithError:error];
     NSLog(@"bei cloud");
     [alert showError:self title:@"Error" subTitle:[[error userInfo] objectForKey:@"error"] closeButtonTitle:@"OK" duration:0.0f];
     }
     [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
     } ];
     */
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 100;
    }
    else return 44;

    
}


- (void)showSuccess {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    //Hide animation type (Default is FadeOut)
    alert.hideAnimationType = SlideOutToTop;
    
    //Show animation type (Default is SlideInFromTop)
    alert.showAnimationType = SlideInFromTop;
    
    //Set background type (Default is Shadow)
    alert.backgroundType = Blur;
    
    [alert alertIsDismissed:^{
        NSLog(@"SCLAlertView dismissed!");
     //   [self performSegueWithIdentifier:@"returnToMain" sender:self];
        [self dismissViewControllerAnimated:YES completion:NULL];

    }];

  //  NSString *infoMsg = @"Dein Ticket wird unter dem Reiter Profil abgespeichert.\nMache einen Screenshot von dem QR-Code für den Fall, dass kein Internet vorhanden ist.\nAuf verlangen des Hosts ist dein Ausweis und der deiner Begleiter vorzuzeigen.\nDer Host behält sich das Recht vor den Eintritt trotz Ticket/Gästelistenplatz zu verwehren.\nMehr Infos unter NightGuider.de oder auf der Website des Betreibers";
    
    [alert showSuccess:self title:@"Erfolgreich" subTitle:@"Dir wird eine Bestätigungsmail zugesand, deinen Kauf findest du unter deinem Profil bei Tickets, zeige beim Event den QR-Code vor um dein Ticket einzulösen" closeButtonTitle:@"OK" duration:0.0f];

}
- (IBAction)infoButtonPressed:(id)sender {
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    //Hide animation type (Default is FadeOut)
    alert.hideAnimationType = SlideOutToTop;
    
    //Show animation type (Default is SlideInFromTop)
    alert.showAnimationType = SlideInFromTop;
    
    //Set background type (Default is Shadow)
    alert.backgroundType = Blur;
    
    [alert alertIsDismissed:^{
        NSLog(@"SCLAlertView dismissed!");
    }];
    
    [alert showInfo:self title:@"Infos zum einlösen" subTitle:@"Dein Ticket wird unter dem Reiter Profil abgespeichert.\nMache einen Screenshot von dem QR-Code für den Fall, dass kein Internet vorhanden ist.\nAuf verlangen des Hosts ist dein Ausweis und der deiner Begleiter vorzuzeigen.\nDer Host behält sich das Recht vor den Eintritt trotz Ticket/Gästelistenplatz zu verwehren.\nMehr Infos unter NightGuider.de oder auf der Website des Betreibers" closeButtonTitle:@"OK" duration:0.0f];
}

@end
