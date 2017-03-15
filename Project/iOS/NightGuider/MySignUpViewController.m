//
//  MySignUpViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 09.07.15.
//  Copyright (c) 2015 Werner. All rights reserved.
//

#import "MySignUpViewController.h"
#import <ParseUI/ParseUI.h>
#import "SCLAlertView.h"

@interface MySignUpViewController ()

@property (nonatomic, retain) PAYFormSingleLineTextField *userNameField;
@property (nonatomic, retain) PAYFormSingleLineTextField *emailTextField;
@property (nonatomic, retain) PAYFormSingleLineTextField *passwordField1;
@property (nonatomic, retain) PAYFormSingleLineTextField *passwordField2;


@property (nonatomic, retain) PAYFormSingleLineTextField *firstNameField;
@property (nonatomic, retain) PAYFormSingleLineTextField *surNameField;
@property (nonatomic, retain) PAYFormSingleLineTextField *birthdayField;
@property (nonatomic, retain) PAYFormButtonGroup *genderField;
@property (nonatomic, retain) PAYFormButtonGroup *relationshipField;

@property (nonatomic, retain) PAYFormSingleLineTextField *streetTextField;
@property (nonatomic, retain) PAYFormSingleLineTextField *postalCodeTextField;
@property (nonatomic, retain) PAYFormSingleLineTextField *cityTextField;


@end

@implementation MySignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"es läd!!");
    // Do any additional setup after loading the view.
    
    self.title = @"Anmelden";

    
    UIBarButtonItem *btnHelp = [[UIBarButtonItem alloc] initWithTitle:@"?" style:UIBarButtonItemStyleBordered target:self action:@selector(helpButtonPressed:)];
    self.navigationItem.rightBarButtonItem = btnHelp;
    
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.leftBarButtonItem = btnCancel;
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadStructure:(PAYFormTableBuilder *)tableBuilder {
    
    NSLog(@"User: %@",[PFUser currentUser]);
    if ([PFUser currentUser]) {
        NSLog(@"schon eingeloggt");
        [PFUser logOut];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    PFUser *user = [PFUser user];

    
    
    [tableBuilder addSectionWithName:nil
                          labelStyle:PAYFormTableLabelStyleNone
                        contentBlock:^(PAYFormSectionBuilder * sectionBuilder) {
                            self.userNameField = [sectionBuilder addFieldWithName:@"Username" placeholder:@"your username"
                                                                   configureBlock:^(PAYFormSingleLineTextField *formField) {
                                                                       // formField.required = YES;
                                                                       formField.minTextLength = 4;
                                                                       formField.textField.accessibilityLabel = @"usernameField";
                                                                       formField.textField.isAccessibilityElement = YES;
  
                                                                       
                                                                   }];
                            
                            self.emailTextField = [sectionBuilder addFieldWithName:@"Email" placeholder:@"your email address"
                                                                    configureBlock:^(PAYFormSingleLineTextField *formField) {
                                                                        formField.textField.accessibilityLabel = @"emailField";
                                                                        formField.textField.isAccessibilityElement = YES;

                                                                        
                                                                    }];
                            
                            self.passwordField1 = [sectionBuilder addFieldWithName:@"Password" placeholder:@"your password"
                                                                    configureBlock:^(PAYFormSingleLineTextField *formField) {
                                                                        [formField activateSecureInput];
                                                                    }];
                            
                            self.passwordField2 = [sectionBuilder addFieldWithName:@"Password 2"
                                                                       placeholder:@"repeat your password"
                                                                    configureBlock:^(PAYFormSingleLineTextField *formField) {
                                                                        [formField activateSecureInput];
                                                                    }];
                            
                        }];
    
    
    
    [tableBuilder addSectionWithName:@"Persönliche Infos"
                          labelStyle:PAYFormTableLabelStyleSimple
                        contentBlock:^(PAYFormSectionBuilder * sectionBuilder) {
                            self.firstNameField = [sectionBuilder addFieldWithName:@"Vorname" placeholder:@"dein Vorname"
                                                                    configureBlock:^(PAYFormSingleLineTextField *formField) {
                                                                        // formField.required = YES;
                                                                        formField.textField.accessibilityLabel = @"firstNameField";

                                                                        
                                                                    }];
                            
                            
                            self.surNameField = [sectionBuilder addFieldWithName:@"Nachname" placeholder:@"dein Nachname"
                                                                  configureBlock:^(PAYFormSingleLineTextField *formField) {
                                                                      //  formField.required = YES;
                                                                      formField.textField.accessibilityLabel = @"surnameField";
                                                                      formField.textField.isAccessibilityElement = YES;

                                                                      
                                                                  }];
                            
                            self.birthdayField = [sectionBuilder addFieldWithName:@"Geburtstag" placeholder:@"dd/mm/yyyy"
                                                                   configureBlock:^(PAYFormSingleLineTextField *formField) {
                                                                       //   formField.required = YES;
                                                                       //formField.validationBlock = PAYValidation.integerValidationBlock;
                                                                       formField.maxTextLength = 8;
                                                                       
                                                                       formField.maxTextLength = 8;
                                                                       formField.validateWhileEnter = YES;
                                                                       
                                                                       
                                                                       
                                                                       [formField setFormatTextWithGroupSizes:@[@2, @2, @4]
                                                                                                    separator:@"/"];
                                                                       
                                                                       formField.cleanBlock = ^id(PAYFormField *formField, id value) {
                                                                           NSString *strValue = value;
                                                                           return [strValue stringByReplacingOccurrencesOfString:@"/" withString:@""];
                                                                       };
                                                                       formField.textField.accessibilityLabel = @"birthdayField";
                                                                       formField.textField.isAccessibilityElement = YES;
                                                                       
                                                                       
                                                                   }];
                        }];
    
    
    [tableBuilder addSectionWithName:@"Gender"
                          labelStyle:PAYFormTableLabelStyleSimple
                        contentBlock:^(PAYFormSectionBuilder * sectionBuilder) {
                            self.genderField.required = YES;
                            self.genderField = [sectionBuilder addButtonGroupWithMultiSelection:NO
                                                                                   contentBlock:^(PAYFormButtonGroupBuilder *buttonGroupBuilder) {
                                                                                       NSArray *genders = @[@[@"männlich", @"m"], @[@"weiblich", @"f"]];
                                                                                       for (NSArray *gender in genders) {
                                                                                           [buttonGroupBuilder addOption:gender[1] withText:gender[0]];
                                                                                       }
                                                                                       

                                                                                       
                                                                                   }];
                            
                            
                            
                        }];
    
    [tableBuilder addSectionWithName:@"Relationship"
                          labelStyle:PAYFormTableLabelStyleSimple
                        contentBlock:^(PAYFormSectionBuilder * sectionBuilder) {
                            self.relationshipField = [sectionBuilder addButtonGroupWithMultiSelection:NO
                                                                                         contentBlock:^(PAYFormButtonGroupBuilder *buttonGroupBuilder) {
                                                                                             NSArray *relationships = @[@[@"Single", @"s"], @[@"In a relationship", @"r"],@[@"Married", @"m"],@[@"Engaged", @"e"]];
                                                                                             for (NSArray *relation in relationships) {
                                                                                                 [buttonGroupBuilder addOption:relation[1] withText:relation[0]];
                                                                                             }
                                                                                             [buttonGroupBuilder select:@"Single"];
                                                                                         }];

                        }];
    
    
    
    
    [tableBuilder addSectionWithName:@"Adresse (optional)"
                          labelStyle:PAYFormTableLabelStyleSimple
                        contentBlock:^(PAYFormSectionBuilder * sectionBuilder) {
                            self.streetTextField = [sectionBuilder addFieldWithName:@"Street" placeholder:@"your street"
                                                                     configureBlock:^(PAYFormSingleLineTextField *formField) {
                                                                         // formField.required = YES;
                                                                         formField.expanding  = YES;
                                                                         formField.textField.accessibilityLabel = @"streetField";
                                                                         formField.textField.isAccessibilityElement = YES;

                                                                         
                                                                     }];
                            
                            self.postalCodeTextField = [sectionBuilder addFieldWithName:@"Postal code" placeholder:@"your postal code"
                                                                         configureBlock:^(PAYFormSingleLineTextField *formField) {
                                                                             // formField.required = YES;
                                                                             formField.cleanBlock = ^id(PAYFormField *formField, id value) {
                                                                                 NSString *strValue = value;
                                                                                 return [strValue stringByReplacingOccurrencesOfString:@" " withString:@""];
                                                                             };
                                                                             formField.textField.accessibilityLabel = @"postalCodeField";
                                                                             formField.textField.isAccessibilityElement = YES;

                                                                             
                                                                         }];
                            self.cityTextField = [sectionBuilder addFieldWithName:@"City" placeholder:@"your city"
                                                                   configureBlock:^(PAYFormSingleLineTextField *formField) {
                                                                       // formField.required = YES;
                                                                       formField.textField.accessibilityLabel = @"cityField";
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
    //  tableBuilder.selectFirstField = YES;
    
    
    tableBuilder.validationBlock =  ^NSError *{
        
        NSLog(@"1");
        if (self.emailTextField.value) {
            NSLog(@"2");
            NSLog(@"email: %@", self.emailTextField.value);
            
            if(![self validateEmail:self.emailTextField.value]) {
                // user entered invalid email address
                NSLog(@"2-1");
                
                
                return [NSError validationErrorWithTitle:@"Email wrong" message:@"Please enter a valid email address" control:self.emailTextField];
                
            }
            
            NSString *password1 = self.passwordField1.value;
            NSString *password2 = self.passwordField2.value;
            
            if (![password1 isEqualToString: password2]) {
                NSLog(@"2-2");
                
                
                return [NSError validationErrorWithTitle:@"Password wrong" message:@"Both Password must match" control:self.passwordField2];
            }
            return nil;
        }
        NSLog(@"3");
        
        
        return nil;
    };
    
    tableBuilder.formSuccessBlock = ^{
        
        user.username = self.userNameField.value;
        user.password = self.passwordField1.value;
        user.email = self.emailTextField.value;
        user [@"first_name"] = self.firstNameField.value;
        user [@"last_name"] = self.surNameField.value;
        user [@"birthday"] = self.birthdayField.value;
        user [@"gender"] = self.genderField.value;
        user [@"relationship"] = self.relationshipField.value;
        
        if (self.streetTextField.value) {
            user [@"street"] = self.streetTextField.value;
        }
        if (self.postalCodeTextField.value) {
            user [@"zip"] = self.postalCodeTextField.value;

        }
        if (self.cityTextField.value) {
            user [@"city"] = self.cityTextField.value;

        }
        
        
        
        NSString *msg2 = @"Wir haben dir eine Bestätigunsemail zugeschickt\nBitte bestätige diese um die Vorteile zu nutzen";
        
        
        
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        //Hide animation type (Default is FadeOut)
        alert.hideAnimationType = SlideOutToCenter;
        
        //Show animation type (Default is SlideInFromTop)
        alert.showAnimationType = SlideInToCenter;
        
        //Set background type (Default is Shadow)
        alert.backgroundType = Blur;
        
        [alert alertIsDismissed:^{
            NSLog(@"zurück zu loginscreen");
            //[self performSegueWithIdentifier:@"backToProfile" sender:self];
            [self dismissViewControllerAnimated:YES
        completion:nil];


            
            
        }];
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {   // Hooray! Let them use the app now.
                [alert showSuccess:self title:@"Erfolgreich registriert" subTitle:msg2 closeButtonTitle:@"OK" duration:0.0f];

            } else {   NSString *errorString = [error userInfo][@"error"];   // Show the errorString somewhere and let the user try again.
                NSLog(@"Fehler beim signup:\n%@",errorString);
                [alert showError:self title:@"Fehler beim anmelden " subTitle:errorString closeButtonTitle:@"OK" duration:0.0f];

            }
        }];
        
        
    };
}

- (BOOL)validateEmail:(NSString *)emailStr {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}
- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}
- (IBAction)helpButtonPressed:(id)sender {
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    //Hide animation type (Default is FadeOut)
    alert.hideAnimationType = SlideOutToCenter;
    
    //Show animation type (Default is SlideInFromTop)
    alert.showAnimationType = SlideInToCenter;
    
    //Set background type (Default is Shadow)
    alert.backgroundType = Blur;
    
    
    
    [alert showInfo:self title:@"Hilfe" subTitle:@"Durch die Anmeldung erhälsts du bei teilnehmenden Clubs Punkte die du gegen Prämien einlösen kannst. Außerdem kannst du Tickets, Gästelistenplätze und Pässe kaufen." closeButtonTitle:@"OK" duration:0.0f];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
