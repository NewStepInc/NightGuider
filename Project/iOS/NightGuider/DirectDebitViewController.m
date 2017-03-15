//
//  DirectDebitViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 16.06.15.
//  Copyright (c) 2015 Werner. All rights reserved.
//

#import "DirectDebitViewController.h"
#import "MBProgressHUD.h"
/*
 #import <PMPayment.h>
#import <PMPaymentParams.h>
#import <PMPaymentMethod.h>
#import <PMTransaction.h>
#import <PMFactory.h>
#import <PMError.h>
#import <PMManager.h>
*/
#import <PayMillSDK/PMSDK.h>
#import <PayMillSDK/PMFactory.h>
#import <PayMillSDK/PMManager.h>
#import <PayMillSDK/PMClient.h>
#import <SCLAlertView.h>
#import <PayMillSDK/PMError.h>
#import "ConfirmationViewController.h"



@interface DirectDebitViewController ()

@property (nonatomic, retain) PAYFormSingleLineTextField *accountHolderField;
@property (nonatomic, retain) PAYFormSingleLineTextField *ibanField;
@property (nonatomic, retain) PAYFormSingleLineTextField *bicField;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSString *token;



@end

@implementation DirectDebitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    
    /*
    NSLog(@"ticketType: %li", _ticketType);
    
    NSLog(@"amount: %zd", _amount_2);
    
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
    
    */
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)loadStructure:(PAYFormTableBuilder *)tableBuilder {
    [tableBuilder addSectionWithName:@"Personal Infos"
                          labelStyle:PAYFormTableLabelStyleSimple
                        contentBlock:^(PAYFormSectionBuilder * sectionBuilder) {
                            self.accountHolderField = [sectionBuilder addFieldWithName:@"Name" placeholder:@"AccountHolder"
                                                                        configureBlock:^(PAYFormSingleLineTextField *formField) {
                                                                            formField.required = YES;
                                                                            formField.textField.accessibilityLabel = @"accountHolderField";
                                                                            formField.textField.isAccessibilityElement = YES;
                                                                            
                                                                            NSString *fullName = [NSString stringWithFormat:@"%@ %@",            [_shippingInfo_2 objectForKey:@"firstName"],
                                                                            [_shippingInfo_2 objectForKey:@"lastName"]];
                                                                            formField.textField.text = fullName;
                                                                        }];
                            
                            
                            self.ibanField = [sectionBuilder addFieldWithName:@"Konto-Nr." placeholder:@"-----"
                                                               configureBlock:^(PAYFormSingleLineTextField *formField) {
                                                                   formField.required = YES;
                                                                   //formField.expanding  = YES;
                                                                   formField.minTextLength = 8;
                                                                   
                                                                   formField.maxTextLength = 15;
                                                                   formField.validateWhileEnter = YES;
                                                                   
                                                                   
                                                                   [formField setFormatTextWithGroupSizes:@[@4, @4, @4, @4, @4,@2]
                                                                                                separator:@" "];
                                                                   
                                                                   formField.cleanBlock = ^id(PAYFormField *formField, id value) {
                                                                       NSString *strValue = value;
                                                                       return [strValue stringByReplacingOccurrencesOfString:@" " withString:@""];
                                                                   };
                                                                   
                                                                   
                                                                   formField.textField.accessibilityLabel = @"ibanField";
                                                                   formField.textField.isAccessibilityElement = YES;
                                                               }];
                            
                            self.bicField = [sectionBuilder addFieldWithName:@"BLZ" placeholder:@"----"
                                                              configureBlock:^(PAYFormSingleLineTextField *formField) {
                                                                  formField.required = YES;
                                                               //   formField.expanding  = YES;
                                                                  
                                                                  formField.minTextLength = 8;
                                                                  
                                                                  formField.maxTextLength = 10;
                                                                  formField.validateWhileEnter = YES;
                                                                  
                                                                  
                                                                  [formField setFormatTextWithGroupSizes:@[@3, @3, @2]
                                                                                               separator:@" "];
                                                                  
                                                                  formField.cleanBlock = ^id(PAYFormField *formField, id value) {
                                                                      NSString *strValue = value;
                                                                      return [strValue stringByReplacingOccurrencesOfString:@" " withString:@""];
                                                                  };
                                                                  
                                                                  
                                                                  
                                                                  
                                                                  formField.textField.accessibilityLabel = @"bicField";
                                                                  formField.textField.isAccessibilityElement = YES;
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
    tableBuilder.selectFirstField = YES;
    
    tableBuilder.validationBlock =  ^NSError *{
        NSLog(@"1");
        
        //IBAN BIC checken
        /*
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
         */
        return nil;
    };
    
    tableBuilder.formSuccessBlock = ^{
        NSLog(@"4");
        
        self.hud.labelText = NSLocalizedString(@"Authorizing...", @"Authorizing...");
        [self.hud show:YES];
        /*
         NSString *msg = [NSString stringWithFormat:@"Well done, %@. Here your Email %@ and Payment Solution %@",
         self.firstNameField.value, self.emailField.value, self.paymentFormField.value];
         
         UIAlertView *alertView  = [[UIAlertView alloc]initWithTitle:@"Success"
         message:msg
         delegate:nil
         cancelButtonTitle:@"Ok"
         otherButtonTitles: nil];
         */
        
        
        
        //PMError *error;
        NSError *error;
        
        PMPaymentParams *params;
        // 1. generate paymill payment method
        
      //  NSLog(@"Cleaned Values: \nIBAN: %@\nBIC: %@\nACC: %@\n", self.ibanField.cleanedValue, self.bicField.cleanedValue, self.accountHolderField.value);
        
      //  id paymentMethod = [PMFactory genNationalPaymentWithIban:self.ibanField.cleanedValue andBic:self.bicField.cleanedValue accHolder:self.accountHolderField.value error:&error];
                
        id paymentMethod = [PMFactory genNationalPaymentWithAccNumber:self.ibanField.cleanedValue accBank:self.bicField.cleanedValue accHolder:self.accountHolderField.value accCountry:@"DE" error:&error];
        
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
        
        
        
        
        
        if(!error) {
            
            if ([_productType isEqualToString:@"membership"]) {
                
                float ticketPrice = [[_region objectForKey:@"membershipPrice_3"] floatValue];
                float sum = ticketPrice * (int)_amount_2 * 100;
                NSString *shortDescription = [NSString stringWithFormat:@"Mitgliedschaft"];
                params = [PMFactory genPaymentParamsWithCurrency:@"EUR" amount:(int)sum description:shortDescription error:&error];
            }
            else if([_productType isEqualToString:@"dayTicket"]){
                
                float ticketPrice = [[_region objectForKey:@"dayPrice_3"] floatValue];
                float sum = ticketPrice * (int)_amount_2 * 100;
                NSString *shortDescription = [NSString stringWithFormat:@"3-Tagesticket"];
                params = [PMFactory genPaymentParamsWithCurrency:@"EUR" amount:(int)sum description:shortDescription error:&error];
                
            }
            
            else{
            
            if (_ticketType == 0) {
                
                float ticketPrice = [[_product_2 objectForKey:@"ticketPrice"] floatValue];
                float sum = ticketPrice * (int)_amount_2 * 100;
                NSString *shortDescription = [NSString stringWithFormat:@"Ticket für %@", [_product_2 objectForKey:@"name"]];
                params = [PMFactory genPaymentParamsWithCurrency:@"EUR" amount:(int)sum description:shortDescription error:&error];
                
            }
            else if (_ticketType == 1){
                
                float guestlistPrice = [[_product_2 objectForKey:@"guestlistPrice"] floatValue];
                float sum = guestlistPrice * (int)_amount_2 * 100;
                
                NSString *shortDescription = [NSString stringWithFormat:@"Gästelistenplätze für %@", [_product_2 objectForKey:@"name"]];
                params = [PMFactory genPaymentParamsWithCurrency:@"EUR" amount:(int)sum description:shortDescription error:&error];
                
                
            }
            else{
                
                float ticketPrice = [[_product_2 objectForKey:@"ticketPrice"] floatValue];
                float guestlistPrice = [[_product_2 objectForKey:@"guestlistPrice"] floatValue];
                float sum = (ticketPrice + guestlistPrice) * (int)_amount_2 *100 ;
                
                NSString *shortDescription = [NSString stringWithFormat:@"Kombiticket für %@", [_product_2 objectForKey:@"name"]];
                params = [PMFactory genPaymentParamsWithCurrency:@"EUR" amount:(int)sum description:shortDescription error:&error];
                
                
            }
                
            }

        }
        else
        {
            NSLog(@"PM Error:%@", error.message);
            NSLog(@"PM Error:%@", [error localizedDescription]);
            
            
        }
        
        if(!error) {
            // 3. generate token
            //    [PMManager generateTokenWithMethod:paymentMethod parameters:params success:^(NSString *token) {
            
         //   NSLog(@"method: %@\n\nparams: %@", paymentMethod, params);
            
            [PMManager generateTokenWithPublicKey:@"024123573803f4a21e162a7ddaa97171"
                                         testMode:YES method:paymentMethod
                                       parameters:params success:^(NSString *token) {
                                           
                                           
                                           //token successfully created
                                         //  [self createTransactionWithToken:token];
                                           _token = token;
                                           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

                                           [self performSegueWithIdentifier:@"confirm" sender:self];

                                       }
                                          failure:^(NSError *error) {
                                              //token generation failed
                                              
                                              [alert showError:self title:@"Error" subTitle:[error localizedDescription] closeButtonTitle:@"OK" duration:0.0f];
                                              NSLog(@"Generate Token Error %@", [error localizedDescription]);
                                              [self showErrorAlertWithTitle:@"Get transactions failure:" errorType:(int)error.code errorMessage:error.localizedDescription];
                                              [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                          }];
        }
        else{
            [alert showError:self title:@"Error" subTitle:[error localizedDescription] closeButtonTitle:@"OK" duration:0.0f];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            NSLog(@"GenCardPayment Error %@", error.message);
        }
        
    };
    //9
    //14
}

#pragma in confirmation ausgelagert

/*
- (void)createTransactionWithToken:(NSString*)token {
    
    self.hud.labelText = NSLocalizedString(@"Authorizing...", @"Authorizing...");
    [self.hud show:YES];
    
  //  NSString *eventid = @"2sxRKVEL55";
    NSString *eventid = _product_2.objectId;

    NSNumber *price = _product_2[@"ticketPrice"];
    NSNumber *amount = [NSNumber numberWithInteger:_amount_2];
    NSString *shortDescription = [NSString stringWithFormat:@"%@ Tickets für %@",amount, [_product_2 objectForKey:@"name"]];


    
    NSDictionary *productInfo = @{
                                  
                                  @"itemName": self.product_2[@"name"],
                                  @"itemId": eventid,
                                  @"token": token,
                                  @"name": self.shippingInfo_2[@"firstName"],
                                  @"email": self.shippingInfo_2[@"email"],
                                  @"address": @"adresse",
                                  @"zip": @"zip",
                                  @"city": @"city",
                                  @"amount": price,
                                  @"itemSize": @"N/A",
                                  @"amount_2": amount,

                                  @"currency": @"eur",
                                  @"description": shortDescription
                                  };
 */
    /*
     NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
     [parameters setObject:token forKey:@"token"];
     [parameters setObject:_amount_2 forKey:@"amount"];
     [parameters setObject:self.currency forKey:@"currency"];
     [parameters setObject:self.description forKey:@"descrition"];
     */

/*
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
    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"user konnte nicht gespeichert werden: %@", [error localizedDescription]);
        }
        else{
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
            
        }
    }];
    

    
}
 */

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */





 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     
     if ([[segue identifier] isEqualToString:@"confirm"]){

         
         ConfirmationViewController *checkoutController = [segue destinationViewController];
         
         if ([_productType isEqualToString:@"membership"]) {
             checkoutController.region = _region;
             checkoutController.amount_2 = _amount_2;
             checkoutController.shippingInfo_2 = _shippingInfo_2;
             checkoutController.regionType = _regionType;
             checkoutController.token = _token;
             checkoutController.paymentMethod = @"l";
             
             checkoutController.productType = _productType;


         }
         else if([_productType isEqualToString:@"dayTicket"]){
             checkoutController.region = _region;
             checkoutController.amount_2 = _amount_2;
             checkoutController.shippingInfo_2 = _shippingInfo_2;
             checkoutController.regionType = _regionType;
             checkoutController.token = _token;
             checkoutController.paymentMethod = @"l";
             checkoutController.startDate = _startDate;
             checkoutController.productType = _productType;


             
         }
         else{
         checkoutController.product_2 = _product_2;
         checkoutController.amount_2 = _amount_2;
         checkoutController.shippingInfo_2 = _shippingInfo_2;
         checkoutController.ticketType = _ticketType;
         checkoutController.token = _token;
         checkoutController.paymentMethod = @"l";
         checkoutController.productType = @"ticket";

             
         }

         
         
         
         
     }
 }
 

- (void)transactionSucceed{
    // [[PMLStoreController sharedInstance] clearCart];
    // [self.navigationController popToViewController:self animated:YES];
    NSLog(@"erfolgreich paymill gekauft");
}
- (void)transactionFailWithError:(NSError*)error{
    
    
    NSLog(@"error %@", error.description);
    NSLog(@"error 2: %@", [error localizedDescription]);
}

-(void)showErrorAlertWithTitle:(NSString*)title errorType:(PMErrorType)type errorMessage:(NSString*)message {
    
    UIAlertView *plistAlert = [[UIAlertView alloc]
                               initWithTitle:[NSString stringWithFormat:@"%@ %ld", title, (long)type]
                               message:message
                               delegate:nil
                               cancelButtonTitle:nil
                               otherButtonTitles:@"OK",nil];
    [plistAlert show];
    
}

@end

