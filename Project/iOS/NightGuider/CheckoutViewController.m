//
//  CheckoutViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 16.06.15.
//  Copyright (c) 2015 Werner. All rights reserved.
//

#import "CheckoutViewController.h"
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
#import <SCLAlertView.h>
#import "DirectDebitViewController.h"
#import "CardIO.h"
#import "ConfirmationViewController.h"
#import "MBProgressHUD.h"
#import "SCLAlertView.h"
#import "MoreInformationViewController.h"

#warning paypal card.io kreditkarte deaktivieren


#define kPayPalNoEnvironment PayPalEnvironmentNoNetwork
#define kPayPalEnvironment PayPalEnvironmentSandbox



@interface CheckoutViewController ()<CardIOPaymentViewControllerDelegate>

@property (nonatomic, retain) PAYFormSingleLineTextField *firstNameField;
@property (nonatomic, retain) PAYFormSingleLineTextField *surNameField;
@property (nonatomic, retain) PAYFormSingleLineTextField *emailField;
@property (nonatomic, retain) PAYFormButtonGroup *paymentFormField;
@property (nonatomic, retain) PAYFormSwitch *formSwitch;

@property(nonatomic, strong, readwrite) PayPalConfiguration *payPalConfig;
@property (nonatomic, retain) CardIOCreditCardInfo *cardInfo;

@property (nonatomic, strong) MBProgressHUD *hud;




@end

@implementation CheckoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /*
    _ticketType == 1 == ticket
    _ticketType == 2 == ticket
    _ticketType == 3 == kombi
*/
    
    NSLog(@"checkout läd");
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    
    // Set up payPalConfig
    _payPalConfig = [[PayPalConfiguration alloc] init];
    _payPalConfig.acceptCreditCards = NO;
    _payPalConfig.merchantName = @"NightGuider UG";
    _payPalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/privacy-full"];
    _payPalConfig.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/useragreement-full"];
    _payPalConfig.languageOrLocale = [NSLocale preferredLanguages][0];
    
    self.environment = kPayPalEnvironment;
    
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@" " style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    NSLog(@"type: %@", _productType);
    

    //check if user is logged in
    
    if (![PFUser currentUser]) {
    
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        //Hide animation type (Default is FadeOut)
        alert.hideAnimationType = SlideOutToTop;
        
        //Show animation type (Default is SlideInFromTop)
        alert.showAnimationType = SlideInFromTop;
        
        //Set background type (Default is Shadow)
        alert.backgroundType = Blur;
        
        [alert alertIsDismissed:^{
            [self dismissViewControllerAnimated:YES completion:NULL];

        }];
        
//user not logged in dismiss view
        
            [alert showInfo:self title:@"Nicht angemeldet" subTitle:@"Bitte melde dich unter dem Tab \"Profil\" an um ein Produkt zu kaufen" closeButtonTitle:@"OK" duration:0.0f];


    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    // Preconnect to PayPal early
    [self setPayPalEnvironment:self.environment];
}

- (void)setPayPalEnvironment:(NSString *)environment {
    self.environment = environment;
    [PayPalMobile preconnectWithEnvironment:environment];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadStructure:(PAYFormTableBuilder *)tableBuilder {
    
    //create personal form
    
    [tableBuilder addSectionWithName:@"Personal Infos"
                          labelStyle:PAYFormTableLabelStyleSimple
                        contentBlock:^(PAYFormSectionBuilder * sectionBuilder) {
                            self.firstNameField = [sectionBuilder addFieldWithName:@"Vorname" placeholder:@"dein Vorname"
                                                                    configureBlock:^(PAYFormSingleLineTextField *formField) {
                                                                        formField.required = YES;
                                                                        formField.textField.accessibilityLabel = @"firstNameField";
                                                                        formField.textField.isAccessibilityElement = YES;
                                                                        if ([[PFUser currentUser] objectForKey:@"first_name"]) {
                                                                            formField.textField.text = [[PFUser currentUser] objectForKey:@"first_name"];
                                                                        }
                                                                    }];
                            
                            
                            self.surNameField = [sectionBuilder addFieldWithName:@"Nachname" placeholder:@"dein Nachname"
                                                                  configureBlock:^(PAYFormSingleLineTextField *formField) {
                                                                      formField.required = YES;
                                                                      formField.textField.accessibilityLabel = @"surnameField";
                                                                      formField.textField.isAccessibilityElement = YES;
                                                                      if ([[PFUser currentUser] objectForKey:@"last_name"]) {
                                                                          formField.textField.text = [[PFUser currentUser] objectForKey:@"last_name"];
                                                                      }
                                                                  }];
                            
                            self.emailField = [sectionBuilder addFieldWithName:@"Email" placeholder:@"EmailAdresse"
                                                                configureBlock:^(PAYFormSingleLineTextField *formField) {
                                                                    formField.required = YES;
                                                                    
                                                                    formField.textField.accessibilityLabel = @"emailField";
                                                                    formField.textField.isAccessibilityElement = YES;
                                                                    if ([[PFUser currentUser] objectForKey:@"email"]) {
                                                                        formField.textField.text = [[PFUser currentUser] objectForKey:@"email"];
                                                                    }
                                                                }];
                        }];
    
    [tableBuilder addSectionWithName:@"Payment Method"
                          labelStyle:PAYFormTableLabelStyleSimple
                        contentBlock:^(PAYFormSectionBuilder * sectionBuilder) {
                            self.paymentFormField = [sectionBuilder addButtonGroupWithMultiSelection:NO
                                                                                        contentBlock:^(PAYFormButtonGroupBuilder *buttonGroupBuilder) {
                                                                                            
#pragma  check if apple pay is available (future option)
                                                                                            //erweiter
                                                                                            /*
                                                                                            NSArray *methods = @[@[@"Apple Pay", @"a"], @[@"Credit Card", @"c"],@[@"Lastschriftverfahren", @"l"], @[@"PayPal", @"p"], @[@"Bitcoin", @"b"]];
                                                                                            */
                                                                                            
                                                                                            
                                                                                            
                                                                                            
                                                                                            if ([_productType isEqualToString:@"membership"]){
                                                                                                
                                                                                                NSArray *methods = @[@[@"Credit Card", @"c"],@[@"Lastschriftverfahren", @"l"]];
                                                                                                
                                                                                                for (NSArray *payment in methods) {
                                                                                                    [buttonGroupBuilder addOption:payment[1] withText:payment[0]];
                                                                                                }

                                                                                            }
                                                                                            else {
                                                                                                
                                                                                                NSArray *methods = @[@[@"Credit Card", @"c"],@[@"Lastschriftverfahren", @"l"], @[@"PayPal", @"p"]];
                                                                                                
                                                                                                for (NSArray *payment in methods) {
                                                                                                    [buttonGroupBuilder addOption:payment[1] withText:payment[0]];
                                                                                                }
                                                                                                
                                                                                            }
                                                                                           
                                                                                            
                                                                                            // [buttonGroupBuilder select:@"Apple Pay"];
                                                                                        }];
                            //   [self.paymentFormField select:YES value:@"Apple Pay"];
                        }];
    
    [tableBuilder addSectionWithName:@"Terms and Conditions" contentBlock:^(PAYFormSectionBuilder * sectionBuilder) {
        [sectionBuilder addButtonWithText:@"Nachlesen"
                                    style:PAYFormButtonStyleDisclosure
                           selectionBlock:^(PAYFormButton *formButton) {
                               
                               //show view with terms and conditions
                               
                               [self performSegueWithIdentifier:@"showTerms" sender:self];

                           }];
        
        self.formSwitch = [sectionBuilder addSwitchWithName:@" Accept"
                                             configureBlock:^(PAYFormSwitch *formSwitch) {
                                                 formSwitch.required = YES;
                                                 
                                                 [formSwitch setErrorMessage:[PAYFormErrorMessage errorMessageWithTitle:@"Accept"
                                                                                                                message:@"Please accept the terms and conditions to continue"]
                                                                forErrorCode:PAYFormMissingErrorCode];
                                                 formSwitch.switchControl.accessibilityLabel = @"termsSwitch";
                                                 formSwitch.switchControl.isAccessibilityElement = YES;
                                             }];
    }];
    
    [tableBuilder addSectionWithLabelStyle:PAYFormTableLabelStyleNone contentBlock:^(PAYFormSectionBuilder * sectionBuilder) {
        [sectionBuilder addButtonWithText:@"Done"
                                    style:PAYFormButtonStylePrimary
                           selectionBlock:^(PAYFormButton *formButton) {
                               [self onDone:formButton];
                           }];
    }];
    
    tableBuilder.finishOnLastField = YES;
    //  tableBuilder.selectFirstField = YES;
    
    PAYHeaderView *header = [[PAYHeaderView alloc]initWithFrame:self.view.frame];
    header.iconImage = [UIImage imageNamed:@"checkoutProgress_1"];
    /*
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
    CGFloat screenHeight = screenSize.height;
     */
   // [header.iconView sizeToFit];
   // header.iconView.width = screenWidth -16;
   // header.iconImage.size.width = screenWidth - 16;
    //[header.iconView sizeToFit];

    header.iconView.contentMode = UIViewContentModeScaleAspectFit;
   // header.iconView.contentMode = UIViewContentModeScaleToFill;
    [header.iconView sizeToFit];


   // header.title = @"Kontaktformular";
    
    //Please enter you contact details
    header.subTitle = @"Bitte geben sie ihre Kontaktdaten ein";
    // header.subTitleLabel.textColor = [[self view]tintColor];
    //  header.subTitleLabel.textColor =[UIColor redColor];
    
    
    
    self.tableView.tableHeaderView = header;
    
    
    tableBuilder.validationBlock =  ^NSError *{
        NSLog(@"1");
        
        //check email
        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        if (![emailTest evaluateWithObject:self.emailField.value]) {
            NSLog(@"2");
            return [NSError validationErrorWithTitle:@"Email wrong" message:@"Please enter a correct Email adresse" control:self.emailField];
        }
        
        if(!self.paymentFormField.value){
            NSLog(@"2/2");
            return [NSError validationErrorWithTitle:@"Bezahlform" message:@"Please enter a payment method" control:self.paymentFormField];
        }
        
        NSLog(@"3");
        return nil;
    };
    
    tableBuilder.formSuccessBlock = ^{
        NSString *msg = [NSString stringWithFormat:@"Well done, %@. Here your Email %@ and Payment Solution %@",
                         self.firstNameField.value, self.emailField.value, self.paymentFormField.value];
        
        NSLog(@"%@",msg);
        
        
        if ([self.paymentFormField.value isEqual:@"a"]) {
            NSLog(@"Apple Pay ausgewäht");
        }
        else if([self.paymentFormField.value isEqual:@"c"]){
            NSLog(@"credit card view");
            /*
             NSDictionary *shippingInfo = @{@"firstName": self.firstNameField.value ?: @"",
             @"lastName": self.surNameField.value ?: @"",
             @"email": self.emailField.value ?: @""
             };
             
             
             NSInteger amount = 2;
             PFObject *product = [[PFObject alloc] initWithClassName:@"test"];
             UIViewController *checkoutController = [[CreditCardViewController alloc] initWithProduct:product amount:&amount shippingInfo:shippingInfo];
             [self.navigationController pushViewController:checkoutController animated:YES];
             */
            
         //   [self performSegueWithIdentifier:@"checkoutStripe" sender:self];
            [self scanCard];
            
            
            
            
        }
        else if([self.paymentFormField.value isEqual:@"p"]){
            NSLog(@"p wird geladen");
          
            PayPalPayment *payment = [[PayPalPayment alloc] init];
            
           // payment.amount = total ;
            payment.currencyCode = @"EUR";
            NSString *shortDescription = [NSString stringWithFormat:@"%i Tickets für %@",(int)_amount, [_ticket objectForKey:@"name"]];
            
            
            
            if (_ticketType == 1) {
                if ((int)_amount == 1) {
                    shortDescription = [NSString stringWithFormat:@"1 Ticket für %@",[_ticket objectForKey:@"name"]];
                    
                }
                else{
                    shortDescription = [NSString stringWithFormat:@"%i Tickets für %@",(int)_amount, [_ticket objectForKey:@"name"]];
                    
                }
                payment.custom = _ticket.objectId;


            }
            else if (_ticketType == 2){

                
                if ((int)_amount == 1) {
                    shortDescription = [NSString stringWithFormat:@"1 Gästelistenplatz für %@",[_ticket objectForKey:@"name"]];
                    
                }
                else{
                    shortDescription = [NSString stringWithFormat:@"%i Gästenlistenplätze für %@",(int)_amount, [_ticket objectForKey:@"name"]];
                    
                    
                }
                payment.custom = _ticket.objectId;

            }
            else if (_ticketType == 3){
                if ((int)_amount == 1) {
                    shortDescription = [NSString stringWithFormat:@"1 Kombiticket für %@",[_ticket objectForKey:@"name"]];

                }
                else{
                    shortDescription = [NSString stringWithFormat:@"%i Kombitickets für %@",(int)_amount, [_ticket objectForKey:@"name"]];

                }
                payment.custom = _ticket.objectId;

                
            }
            else if ([_productType isEqualToString:@"dayTicket"]){
                //ort suchen
                
                shortDescription = [NSString stringWithFormat:@"3-Tagesticket für %@",[_region objectForKey:@"name"]];
                payment.custom = _region.objectId;


            }
            else if ([_productType isEqualToString:@"membership"]){
                
                shortDescription = [NSString stringWithFormat:@"Mitgliedschaft für %@",[_region objectForKey:@"name"]];

                payment.custom = _region.objectId;


            }
            
            
            payment.shortDescription = shortDescription;
            payment.softDescriptor = @"NightGuider UG";
            
            
            if (_ticketType == 1) {
                NSLog(@"option1");
                NSNumber *ticketPrice = [_ticket objectForKey:@"ticketPrice"];
                NSLog(@"1 total: %@", ticketPrice);

                NSDecimalNumber *ticketPriceNum = [NSDecimalNumber decimalNumberWithDecimal:[ticketPrice decimalValue]];
                NSLog(@"2 total: %@", ticketPriceNum);

                NSNumber *amount = [NSNumber numberWithInteger:_amount];
                NSLog(@"3 total: %@", amount);

                NSDecimalNumber *amountNum = [NSDecimalNumber decimalNumberWithDecimal:[amount decimalValue]];
                NSLog(@"4 total: %@", amountNum);

                
                NSDecimalNumber *total = [ticketPriceNum decimalNumberByMultiplyingBy:amountNum];

              //  NSDecimalNumber *mwst = [[NSDecimalNumber alloc] initWithDouble:0.19];
             //   NSDecimalNumber *tax = [total decimalNumberByMultiplyingBy:mwst];
                NSLog(@"total: %@", total);
                payment.amount = total;
                
                
            }
            else if (_ticketType == 2){
                NSLog(@"option 2");
                NSNumber *ticketPrice = [_ticket objectForKey:@"guestlistPrice"];
                NSDecimalNumber *ticketPriceNum = [NSDecimalNumber decimalNumberWithDecimal:[ticketPrice decimalValue]];
                NSNumber *amount = [NSNumber numberWithInteger:_amount];
                NSDecimalNumber *amountNum = [NSDecimalNumber decimalNumberWithDecimal:[amount decimalValue]];
                
                NSDecimalNumber *total = [ticketPriceNum decimalNumberByMultiplyingBy:amountNum];
              //  NSDecimalNumber *mwst = [[NSDecimalNumber alloc] initWithDouble:0.19];
             //   NSDecimalNumber *tax = [total decimalNumberByMultiplyingBy:mwst];
                NSLog(@"total: %@", total);

                payment.amount = total;
                
                
            }
            else if (_ticketType == 3){
                NSLog(@"option 3");
                NSNumber *ticketPrice = [_ticket objectForKey:@"ticketPrice"];
                NSDecimalNumber *ticketPriceNum = [NSDecimalNumber decimalNumberWithDecimal:[ticketPrice decimalValue]];
                NSNumber *guestlistPrice = [_ticket objectForKey:@"guestlistPrice"];
                NSDecimalNumber *guestlistPriceNum = [NSDecimalNumber decimalNumberWithDecimal:[guestlistPrice decimalValue]];
                
                NSDecimalNumber *combiPriceNum = [ticketPriceNum decimalNumberByAdding:guestlistPriceNum];
                
                NSNumber *amount = [NSNumber numberWithInteger:_amount];
                NSDecimalNumber *amountNum = [NSDecimalNumber decimalNumberWithDecimal:[amount decimalValue]];
                
                NSDecimalNumber *total = [combiPriceNum decimalNumberByMultiplyingBy:amountNum];
             //   NSDecimalNumber *mwst = [[NSDecimalNumber alloc] initWithDouble:0.19];
             //   NSDecimalNumber *tax = [total decimalNumberByMultiplyingBy:mwst];
                NSLog(@"total: %@", total);

                payment.amount = total;
                
                
            }
            
            else if([_productType isEqualToString:@"dayTicket"]){

                
                
                NSNumber *ticketPrice = [_region objectForKey:@"dayPrice_3"];
                NSDecimalNumber *ticketPriceNum = [NSDecimalNumber decimalNumberWithDecimal:[ticketPrice decimalValue]];
                NSNumber *amount = [NSNumber numberWithInteger:_amount];
                NSDecimalNumber *amountNum = [NSDecimalNumber decimalNumberWithDecimal:[amount decimalValue]];
                
                NSDecimalNumber *total = [ticketPriceNum decimalNumberByMultiplyingBy:amountNum];
                //  NSDecimalNumber *mwst = [[NSDecimalNumber alloc] initWithDouble:0.19];
                //   NSDecimalNumber *tax = [total decimalNumberByMultiplyingBy:mwst];
                NSLog(@"total: %@", total);
                
                payment.amount = total;
            }
            else if ([_productType isEqualToString:@"membership"]) {
                
                _amount = 1;
                NSNumber *ticketPrice = [_region objectForKey:@"memberhsipPrice_3"];
                NSDecimalNumber *ticketPriceNum = [NSDecimalNumber decimalNumberWithDecimal:[ticketPrice decimalValue]];
                NSNumber *amount = [NSNumber numberWithInteger:_amount];
                NSDecimalNumber *amountNum = [NSDecimalNumber decimalNumberWithDecimal:[amount decimalValue]];
                
                NSDecimalNumber *total = [ticketPriceNum decimalNumberByMultiplyingBy:amountNum];
                //  NSDecimalNumber *mwst = [[NSDecimalNumber alloc] initWithDouble:0.19];
                //   NSDecimalNumber *tax = [total decimalNumberByMultiplyingBy:mwst];
                NSLog(@"total: %@", total);
                
                payment.amount = total;

            }
            
            
            
            
            if (!payment.processable) {
                // This particular payment will always be processable. If, for
                // example, the amount was negative or the shortDescription was
                // empty, this payment wouldn't be processable, and you'd want
                // to handle that here.
                SCLAlertView *alert = [[SCLAlertView alloc] init];
                
                //Hide animation type (Default is FadeOut)
                alert.hideAnimationType = SlideOutToTop;
                
                //Show animation type (Default is SlideInFromTop)
                alert.showAnimationType = SlideInFromTop;
                
                //Set background type (Default is Shadow)
                alert.backgroundType = Blur;
                
                [alert alertIsDismissed:^{
                    NSLog(@"SCLAlertView dismissed!");
                    [self dismissViewControllerAnimated:YES completion:NULL];
                    
                }];
                //error dismiss view
                
                [alert showError:self title:@"Fehler" subTitle:@"Leider ist ein Fehler aufgetreten, versuche es einfach erneut" closeButtonTitle:@"OK" duration:0.0f];
            }
            
            // Update payPalConfig re accepting credit cards.
            //  self.payPalConfig.acceptCreditCards = self.acceptCreditCards;
            NSLog(@"paypal payment: %@", payment);
            PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
                                                                                                        configuration:self.payPalConfig
                                                                                                             delegate:self];
            [self presentViewController:paymentViewController animated:YES completion:nil];
            
            
            
        }
        else if ([self.paymentFormField.value isEqual:@"l"]){
            
            [self performSegueWithIdentifier:@"checkoutPaymill" sender:self];

            
        }
        else if ([self.paymentFormField.value isEqual:@"b"]){
            
            //bitcoin future option
            NSLog(@"bitcoin noch nicht verfügbar");
        }
        
    };
    
    [CardIOUtilities preload];
    
    
}

#pragma mark PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    NSLog(@"PayPal Payment Success!");
    self.resultText = [completedPayment description];
    [self showSuccess];
    
    [self sendCompletedPaymentToServer:completedPayment]; // Payment was processed successfully; send to server for verification and fulfillment
    //zurück zur event ansicht
    [self dismissViewControllerAnimated:YES completion:nil];
   // self.hud.labelText = @"Charging...";
   // [self.hud show:YES];
    
    //[self performSegueWithIdentifier:@"checkoutPayPal" sender:nil];
    
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    NSLog(@"PayPal Payment Canceled");
    self.resultText = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Proof of payment validation

- (void)sendCompletedPaymentToServer:(PayPalPayment *)completedPayment {
    
    self.hud.labelText = @"Charging...";
    [self.hud show:YES];
    
    // TODO: Send completedPayment.confirmation to server
  //  NSLog(@"Here is your proof of payment:\n\n%@\n\nSend this to your server for confirmation and fulfillment.", completedPayment.confirmation);
   
    //NSLog(@"---und alle daten:\n%@", completedPayment);
    
    
    NSString *tokenString = [[completedPayment.confirmation objectForKey:@"response"] objectForKey:@"id"];
    
    NSNumber *amount = [NSNumber numberWithInteger:_amount];

    NSDictionary *paypalCloudInfo = @{};
    

    
    
    //@{@"Betrag":completedPayment.paymentDetails.subtotal,@"City":completedPayment.shippingAddress.city,@"Gesamt":completedPayment.amount}
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    //Hide animation type (Default is FadeOut)
    alert.hideAnimationType = SlideOutToTop;
    
    //Show animation type (Default is SlideInFromTop)
    alert.showAnimationType = SlideInFromTop;
    
    //Set background type (Default is Shadow)
    alert.backgroundType = Blur;
    
    [alert alertIsDismissed:^{
        NSLog(@"SCLAlertView dismissed!");
        [self dismissViewControllerAnimated:YES completion:NULL];
        
    }];
    
    NSLog(@"cloud code aufrufen");
    
    NSString *cloudType = @"Error";

    
    if (_ticketType == 1) {
        cloudType = @"paypal_purchaseTicket";
        NSString *eventId = _ticket.objectId;
        
        paypalCloudInfo = @{@"firstName": self.firstNameField.value ?: @"",
                                               @"lastName": self.surNameField.value ?: @"",
                                               @"email": self.emailField.value ?: @"",
                                               @"itemId": eventId,
                                               @"token": tokenString,
                                               @"paypalInfo": completedPayment.confirmation,
                                               
                                               @"amount": amount,
                                               @"currency": @"eur",
                                               
                                               };
    }
    else if (_ticketType == 2){
        cloudType = @"paypal_purchaseGuestlist";
        NSString *eventId = _ticket.objectId;
        
        paypalCloudInfo = @{@"firstName": self.firstNameField.value ?: @"",
                            @"lastName": self.surNameField.value ?: @"",
                            @"email": self.emailField.value ?: @"",
                            @"itemId": eventId,
                            @"token": tokenString,
                            @"paypalInfo": completedPayment.confirmation,
                            
                            @"amount": amount,
                            @"currency": @"eur",
                            
                            };
        
    }
    else if(_ticketType == 3){
        cloudType = @"paypal_purchaseCombi";
        NSString *eventId = _ticket.objectId;
        
        paypalCloudInfo = @{@"firstName": self.firstNameField.value ?: @"",
                            @"lastName": self.surNameField.value ?: @"",
                            @"email": self.emailField.value ?: @"",
                            @"itemId": eventId,
                            @"token": tokenString,
                            @"paypalInfo": completedPayment.confirmation,
                            
                            @"amount": amount,
                            @"currency": @"eur",
                            
                            };
        
    }
    
    else if ([_productType isEqualToString:@"membership"]) {
        cloudType = @"paypal_purchaseMembership";
        
        
        paypalCloudInfo = @{
                        
                        @"regionId": _region.objectId,
                        @"token": tokenString,
                        @"firstName": self.firstNameField.value ?: @"",
                        @"lastName": self.surNameField.value ?: @"",
                        @"email": self.emailField.value ?: @"",
                        @"regionName": [_region objectForKey:@"name"],
                        // @"regionType": [_region objectForKey:@"regionType"],
                        @"regionType": @"Cities",
                        @"paypalInfo": completedPayment.confirmation,

                        @"amount": amount,
                        @"currency": @"eur",
                        @"duration": @3
                        
                        };

        
    }
    else if ([_productType isEqualToString:@"dayTicket"]){
        cloudType = @"paypal_purchase3DayTicket";
        
        paypalCloudInfo = @{
                        
                        @"regionId": _region.objectId,
                        @"regionType":_regionType,
                        @"token": tokenString,
                        @"firstName": self.firstNameField.value ?: @"",
                        @"lastName": self.surNameField.value ?: @"",
                        @"email": self.emailField.value ?: @"",
                        @"regionName": [_region objectForKey:@"name"],
                        @"paypalInfo": completedPayment.confirmation,
                        @"startDate": _startDate,
                        @"amount": amount,
                        @"currency": @"eur",
                        @"duration": @3
                        
                        };
        
    }

    NSLog(@"type: %@", cloudType);
    
    
    [PFCloud callFunctionInBackground:cloudType
                       withParameters:paypalCloudInfo
                                block:^(NSString *result, NSError *error) {
                                    if (!error) {
                                        // result is @"Hello world!"
                                        NSLog(@"cloud code erfolgreich aufgerufen");
                                        NSLog(@"result: %@", result);
                                        
                                        
                                        
                                        
                                        
                                        [alert showSuccess:self title:@"Erfolgreich" subTitle:@"Wir haben dein Bestellung aufgenommen!" closeButtonTitle:@"Done" duration:0.0f];
                                        
                                        
                                        
                                    }
                                    else{
                                        //  NSLog(@"Cloud code nicht da");
                                        
                                        // Alternative alert types
                                        [alert showError:self title:@"Error" subTitle:[[error userInfo] objectForKey:@"error"] closeButtonTitle:@"OK" duration:0.0f];
                                    }
                                    
                                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

                                }];
}

-(void)payPalFuturePaymentViewController:(PayPalFuturePaymentViewController *)futurePaymentViewController didAuthorizeFuturePayment:(NSDictionary *)futurePaymentAuthorization{
    DLog(@"future payment didauthorize");
}

-(void)payPalFuturePaymentDidCancel:(PayPalFuturePaymentViewController *)futurePaymentViewController{
    DLog(@"future payment did cancel");

}
-(void)payPalProfileSharingViewController:(PayPalProfileSharingViewController *)profileSharingViewController userDidLogInWithAuthorization:(NSDictionary *)profileSharingAuthorization{
    DLog(@"profile sharing didloginwithauthorize");

    
}

-(void)userDidCancelPayPalProfileSharingViewController:(PayPalProfileSharingViewController *)profileSharingViewController{
    DLog(@"profile sharing did cancel");

}

#pragma mark - Helpers

- (void)showSuccess {
    
    NSLog(@"Erfolgreich");
}

-(void)scanCard {

    CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    [self presentViewController:scanViewController animated:YES completion:nil];

}

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    NSLog(@"User canceled payment info");
    // Handle user cancellation here...
    [scanViewController dismissViewControllerAnimated:YES completion:nil];

}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    // The full card number is available as info.cardNumber, but don't log that!
    
  //  NSLog(@"Received card info. Number: %@, expiry: %02lu/%lu, cvv: %@.", info.redactedCardNumber, (unsigned long)info.expiryMonth, (unsigned long)info.expiryYear, info.cvv);
    // Use the card info...
    _cardInfo = info;
    [scanViewController dismissViewControllerAnimated:YES completion:nil];
    
    [self performSegueWithIdentifier:@"checkoutStripe" sender:self];


    
    
    
    
}

-(void)weiterleitung{
    //???
    NSLog(@"es wird weitergeleitet");
    [self performSegueWithIdentifier:@"test" sender:self];

}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"pushSettings"]) {
        [[segue destinationViewController] setDelegate:(id)self];
    }
    else if ([segue.identifier isEqualToString:@"showTerms"])
    {
        MoreInformationViewController *detailController =segue.destinationViewController;
        detailController.isTerms = YES;
        
    }
    else if ([[segue identifier] isEqualToString:@"checkoutStripe"]){
        NSDictionary *shippingInfo = @{@"firstName": self.firstNameField.value ?: @"",
                                       @"lastName": self.surNameField.value ?: @"",
                                       @"email": self.emailField.value ?: @"",


                                       };
        
        /* additional fields
         @"city": self.cityField.value ?: @"",
         @"street": self.streetField.value ?: @"",
         @"zip": self.zipField.value ?: @"",
         */

        
        ConfirmationViewController *checkoutController = [segue destinationViewController];
        
        
        if ([_productType isEqualToString:@"membership"]) {
            checkoutController.region = _region;
            checkoutController.amount_2 = _amount;
            checkoutController.shippingInfo_2 = shippingInfo;
            checkoutController.regionType = _regionType;
            checkoutController.cardInfo = _cardInfo;
            checkoutController.paymentMethod = @"c";
            checkoutController.productType = _productType;

        }
        else if ([_productType isEqualToString:@"dayTicket"]){
            checkoutController.region = _region;
            checkoutController.amount_2 = _amount;
            checkoutController.shippingInfo_2 = shippingInfo;
            checkoutController.regionType = _regionType;
            checkoutController.cardInfo = _cardInfo;
            checkoutController.paymentMethod = @"c";
            checkoutController.startDate = _startDate;
            checkoutController.productType = _productType;


        }
        else{
        NSLog(@"tickettype checkout: %li", _ticketType);
        checkoutController.product_2 = _ticket;
        checkoutController.amount_2 = _amount;
        checkoutController.shippingInfo_2 = shippingInfo;
        checkoutController.ticketType = _ticketType;
        checkoutController.cardInfo = _cardInfo;
        checkoutController.paymentMethod = @"c";
        checkoutController.productType = @"ticket";

        }
        

        
        
        
    }
    else if ([[segue identifier] isEqualToString:@"checkoutPaymill"]){
        NSDictionary *shippingInfo = @{@"firstName": self.firstNameField.value ?: @"",
                                       @"lastName": self.surNameField.value ?: @"",
                                       @"email": self.emailField.value ?: @""
                                       };
        

        DirectDebitViewController *checkoutController = [segue destinationViewController];
        
        if ([_productType isEqualToString:@"membership"]) {
            checkoutController.region = _region;
            checkoutController.amount_2 = _amount;
            checkoutController.shippingInfo_2 = shippingInfo;
            checkoutController.regionType = _regionType;
            checkoutController.productType = _productType;

        }
        else if ([_productType isEqualToString:@"dayTicket"]){
            checkoutController.region = _region;
            checkoutController.amount_2 = _amount;
            checkoutController.shippingInfo_2 = shippingInfo;
            checkoutController.regionType = _regionType;
            checkoutController.startDate = _startDate;
            checkoutController.productType = _productType;

            
        }
        else{
        checkoutController.product_2 = _ticket;
        checkoutController.amount_2 = _amount;
        checkoutController.shippingInfo_2 = shippingInfo;
        checkoutController.ticketType = _ticketType;
            checkoutController.productType = @"ticket";

        }

        
        
        
    }
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

-(IBAction)backToCheckout: (UIStoryboardSegue *) segue{
    
    
}



@end
