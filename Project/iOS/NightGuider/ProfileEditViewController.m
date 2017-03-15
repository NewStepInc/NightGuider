//
//  ProfileEditViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 15.06.15.
//  Copyright (c) 2015 Werner. All rights reserved.
//

#import "ProfileEditViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "SCLAlertView.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <CoreData/CoreData.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import <Bolts/Bolts.h>
#import "Branch.h"
#import "MBProgressHUD.h"


@interface ProfileEditViewController ()


@property (nonatomic, retain) PAYFormSingleLineTextField *userNameField;
@property (nonatomic, retain) PAYFormSingleLineTextField *emailTextField;

@property (nonatomic, retain) PAYFormSingleLineTextField *firstNameField;
@property (nonatomic, retain) PAYFormSingleLineTextField *surNameField;
@property (nonatomic, retain) PAYFormSingleLineTextField *birthdayField;
@property (nonatomic, retain) PAYFormButtonGroup *genderField;
@property (nonatomic, retain) PAYFormButtonGroup *relationshipField;

@property (nonatomic, retain) PAYFormSingleLineTextField *streetTextField;
@property (nonatomic, retain) PAYFormSingleLineTextField *postalCodeTextField;
@property (nonatomic, retain) PAYFormSingleLineTextField *cityTextField;
@property (nonatomic, strong) MBProgressHUD *hud;







@end

@implementation ProfileEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"Wird geladen", @"Wird geladen...");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)loadStructure:(PAYFormTableBuilder *)tableBuilder {
    
    NSLog(@"User: %@",[PFUser currentUser]);
    
    PFUser *currentUser = [PFUser currentUser];
    
    if (![PFFacebookUtils isLinkedWithUser:currentUser]) {
        [tableBuilder addSectionWithLabelStyle:PAYFormTableLabelStyleNone contentBlock:^(PAYFormSectionBuilder * sectionBuilder) {
            [sectionBuilder addButtonWithText:@"Mit Facebook verbinden"
                                        style:PAYFormButtonStyleHilighted
                               selectionBlock:^(PAYFormButton *formButton) {
                                   [self connectFacebook];
                               }];
        }];
        
    }
    
    
    [tableBuilder addSectionWithName:nil
                          labelStyle:PAYFormTableLabelStyleNone
                        contentBlock:^(PAYFormSectionBuilder * sectionBuilder) {
                            self.userNameField = [sectionBuilder addFieldWithName:@"Username" placeholder:@"your username"
                                                                   configureBlock:^(PAYFormSingleLineTextField *formField) {
                                                                      // formField.required = YES;
                                                                       formField.minTextLength = 4;
                                                                       formField.textField.accessibilityLabel = @"usernameField";
                                                                       formField.textField.isAccessibilityElement = YES;
                                                                       formField.textField.text = [PFUser currentUser].username;
                                                                       //unnötig?
                                                                       /*
                                                                       if ([PFUser currentUser].username) {
                                                                           formField.textField.text = [PFUser currentUser].username;
                                                                       }
                                                                        */

                                                                   }];
                            
                            self.emailTextField = [sectionBuilder addFieldWithName:@"Email" placeholder:@"your email address"
                                                                    configureBlock:^(PAYFormSingleLineTextField *formField) {
                                                                        formField.textField.accessibilityLabel = @"emailField";
                                                                        formField.textField.isAccessibilityElement = YES;
                                                                        if ([[PFUser currentUser] objectForKey:@"email"]) {
                                                                            formField.textField.text = [[PFUser currentUser] objectForKey:@"email"];
                                                                        }

                                                                    }];

                        }];
    

    
    [tableBuilder addSectionWithName:@"Personal Infos"
                          labelStyle:PAYFormTableLabelStyleSimple
                        contentBlock:^(PAYFormSectionBuilder * sectionBuilder) {
                            self.firstNameField = [sectionBuilder addFieldWithName:@"Vorname" placeholder:@"dein Vorname"
                                                                    configureBlock:^(PAYFormSingleLineTextField *formField) {
                                                                       // formField.required = YES;
                                                                        formField.textField.accessibilityLabel = @"firstNameField";
                                                                        formField.textField.isAccessibilityElement = YES;
                                                                        if ([[PFUser currentUser] objectForKey:@"first_name"]) {
                                                                            formField.textField.text = [[PFUser currentUser] objectForKey:@"first_name"];
                                                                        }
                                                                        
                                                                    }];
                            
                            
                            self.surNameField = [sectionBuilder addFieldWithName:@"Nachname" placeholder:@"dein Nachname"
                                                                  configureBlock:^(PAYFormSingleLineTextField *formField) {
                                                                    //  formField.required = YES;
                                                                      formField.textField.accessibilityLabel = @"surnameField";
                                                                      formField.textField.isAccessibilityElement = YES;
                                                                      if ([[PFUser currentUser] objectForKey:@"last_name"]) {
                                                                          formField.textField.text = [[PFUser currentUser] objectForKey:@"last_name"];
                                                                      }

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
                                                                       
                                                                       
                                                                       if ([[PFUser currentUser] objectForKey:@"birthday"]) {
                                                                           formField.textField.text = [[PFUser currentUser] objectForKey:@"birthday"];
                                                                       }
                                                                       

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
                                                                                       

                                                                                       /*
                                                                                       if ([[PFUser currentUser] objectForKey:@"gender"]) {
                                                                                           NSLog(@"1 gibt es");
                                                                                           if ([[[PFUser currentUser] objectForKey:@"gender"] isEqualToString:@"male"]) {
                                                                                               NSLog(@"1 male");
                                                                                               [buttonGroupBuilder select:@"männlich"];
                                                                                               
                                                                                           }
                                                                                           else{
                                                                                               [buttonGroupBuilder select:@"weiblich"];
                                                                                               
                                                                                           }
                                                                                       }
                                                                                        */

                                                                                   }];
                            

                            
                            if ([[PFUser currentUser] objectForKey:@"gender"]) {
                                if ([[[PFUser currentUser] objectForKey:@"gender"] isEqualToString:@"male"]) {
                                    NSLog(@"male");
                                    [self.genderField select:YES value:@"m"];

                                }
                                else{
                                    [self.genderField select:YES value:@"f"];

                                }
                            }


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
                            
                            if ([[PFUser currentUser] objectForKey:@"relationship"]) {
                                NSLog(@"gibt es");
                                if ([[[PFUser currentUser] objectForKey:@"relationship"] isEqualToString:@"Single"]) {
                                    [self.relationshipField select:YES value:@"s"];
                                    
                                }
                                else if ([[[PFUser currentUser] objectForKey:@"relationship"] isEqualToString:@"Married"]){
                                    [self.relationshipField select:YES value:@"m"];

                                }
                                else if ([[[PFUser currentUser] objectForKey:@"relationship"] isEqualToString:@"Engaged"]){
                                    [self.relationshipField select:YES value:@"e"];
                                    
                                }
                                else{
                                    [self.relationshipField select:YES value:@"r"];
                                    
                                }
                            }

                        }];
    
    
    
    
    [tableBuilder addSectionWithName:@"Address"
                          labelStyle:PAYFormTableLabelStyleSimple
                        contentBlock:^(PAYFormSectionBuilder * sectionBuilder) {
                            self.streetTextField = [sectionBuilder addFieldWithName:@"Street" placeholder:@"your street"
                                                                     configureBlock:^(PAYFormSingleLineTextField *formField) {
                                                                        // formField.required = YES;
                                                                         formField.expanding  = YES;
                                                                         formField.textField.accessibilityLabel = @"streetField";
                                                                         formField.textField.isAccessibilityElement = YES;
                                                                         if ([[PFUser currentUser] objectForKey:@"street"]) {
                                                                             formField.textField.text = [[PFUser currentUser] objectForKey:@"street"];
                                                                         }

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
                                                                             if ([[PFUser currentUser] objectForKey:@"zip"]) {
                                                                                 formField.textField.text = [[PFUser currentUser] objectForKey:@"zip"];
                                                                             }

                                                                         }];
                            self.cityTextField = [sectionBuilder addFieldWithName:@"City" placeholder:@"your city"
                                                                   configureBlock:^(PAYFormSingleLineTextField *formField) {
                                                                      // formField.required = YES;
                                                                       formField.textField.accessibilityLabel = @"cityField";
                                                                       formField.textField.isAccessibilityElement = YES;
                                                                       if ([[PFUser currentUser] objectForKey:@"city"]) {
                                                                           formField.textField.text = [[PFUser currentUser] objectForKey:@"city"];
                                                                       }

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

            } else {
                // user entered valid email address
                NSLog(@"2-2");

                return nil;
            }
        }
        NSLog(@"3");


        return nil;
    };
    
    tableBuilder.formSuccessBlock = ^{

        
        if (self.userNameField.value) {
            [PFUser currentUser].username = self.userNameField.value;

        }
        if (self.emailTextField.value) {
            [PFUser currentUser].email = self.emailTextField.value;

        }
        if (self.firstNameField.value) {
            [PFUser currentUser] [@"first_name"] = self.firstNameField.value;

        }
        if (self.surNameField.value) {
            [PFUser currentUser] [@"last_name"] = self.surNameField.value;

        }
        if (self.birthdayField.value) {
            [PFUser currentUser] [@"birthday"] = self.birthdayField.value;

        }
        if (self.genderField.value) {
            [PFUser currentUser] [@"gender"] = self.genderField.value;

        }
        if (self.relationshipField.value) {
            [PFUser currentUser] [@"relationship"] = self.relationshipField.value;

        }
        
        if (self.streetTextField.value) {
            [PFUser currentUser] [@"street"] = self.streetTextField.value;
        }
        if (self.postalCodeTextField.value) {
            [PFUser currentUser] [@"zip"] = self.postalCodeTextField.value;
            
        }
        if (self.cityTextField.value) {
            [PFUser currentUser] [@"city"] = self.cityTextField.value;
            
        }

        

        
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        //Hide animation type (Default is FadeOut)
        alert.hideAnimationType = SlideOutToCenter;
        
        //Show animation type (Default is SlideInFromTop)
        alert.showAnimationType = SlideInToCenter;
        
        //Set background type (Default is Shadow)
        alert.backgroundType = Blur;
        
        [alert alertIsDismissed:^{
            NSLog(@"zurück zu profil");
            [self performSegueWithIdentifier:@"backToProfile" sender:self];

            
        }];

        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                [alert showSuccess:self title:@"Erfolgreich geupdated" subTitle:nil closeButtonTitle:@"OK" duration:0.0f];
            }
            else{
                [alert showError:self title:@"Fehler" subTitle:error.localizedDescription closeButtonTitle:@"OK" duration:0.0f];
            }
        }];
        
        
    };
}

- (BOOL)validateEmail:(NSString *)emailStr {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}

-(void)connectFacebook{

    
    NSArray *permissionsArray = @[@"email",@"user_birthday",@"user_location", @"user_events",@"user_relationships"];
    
    if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [PFFacebookUtils linkUserInBackground:[PFUser currentUser] withReadPermissions:permissionsArray block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Woohoo, user is linked with Facebook!");
                [self getUserData];

            }
        }];
    }
    


}

-(void)getUserData{
    
    [self.hud show:YES];

    
    NSLog(@"Benutzer ist eingeloggt");
    [self loadData];
    
    NSString *requestPath = @"me/?fields=name,location,email,gender,birthday,relationship_status,first_name,last_name";
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:requestPath parameters:nil];
    
    
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            NSString *facebookId = userData[@"id"];
            NSString *name = userData[@"name"];
            NSString *location = userData[@"location"][@"name"];
            NSString *gender = userData[@"gender"];
            NSString *birthdayBefore = userData[@"birthday"];
            NSLog(@"birthdayBefore: %@", birthdayBefore);
            NSArray  *birthdayArray = [birthdayBefore componentsSeparatedByString:@"/"];
            NSString *birthday = [NSString stringWithFormat:@"%@/%@/%@", [birthdayArray objectAtIndex:1], [birthdayArray objectAtIndex:0], [birthdayArray objectAtIndex:2]];
            NSLog(@"borthdayAfter: %@", birthday);
            
            NSString *relationship = userData[@"relationship_status"];
            NSString *first_name = userData [@"first_name"];
            NSString *last_name = userData [@"last_name"];
            NSString *email = userData [@"email"];
            NSDictionary *coverPhoto = userData [@"cover"];
            NSString *coverUrl = coverPhoto [@"source"];
            
            
            NSLog(@"benutzername: %@",name);
            NSLog(@"id: %@",facebookId);
            NSLog(@"geburtstag: %@",birthday);
            NSLog(@"beziehungsstatus: %@",relationship);
            NSLog(@"geschlecht: %@",gender);
            NSLog(@"heimatstadt: %@",location);
            NSLog(@"Vorname: %@",first_name);
            NSLog(@"Nachname: %@",last_name);
            
            // NSString *str =@"3/15/2012 9:15 PM";
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"MM/dd/yyyy"];
            NSDate *date = [formatter dateFromString:birthday];
            NSLog(@"geburtstag %@",date);
            
            if (email) {
                [[PFUser currentUser]setObject:email forKey:@"email"];
                NSLog(@"email");
                
            }
            
            if (gender) {
                [[PFUser currentUser]setObject:gender forKey:@"gender"];
                NSLog(@"1");
                
            }
            if (birthday) {
                [[PFUser currentUser]setObject:birthday forKey:@"birthday"];
                NSLog(@"2");
                
            }
            if (relationship) {
                [[PFUser currentUser]setObject:relationship forKey:@"relationship"];
                NSLog(@"3");
                
            }
            if (location) {
                [[PFUser currentUser]setObject:location forKey:@"location"];
                NSLog(@"4");
                
            }
            if (first_name) {
                [[PFUser currentUser]setObject:first_name forKey:@"first_name"];
                NSLog(@"5");
                
            }
            if (last_name) {
                [[PFUser currentUser]setObject:last_name forKey:@"last_name"];
                NSLog(@"6");
                
            }
            if (_city) {
                [[PFUser currentUser]setObject:_city forKey:@"city"];
                NSLog(@"7");
                
            }
            if (name) {
                [PFUser currentUser].username = name;
                NSLog(@"8");
                
            }
            
            if (coverUrl) {
                // NSData *imageData = UIImagePNGRepresentation(image);
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:coverUrl]];
                PFFile *imageFile = [PFFile fileWithName:@"profile.png" data:imageData];
                
                [[PFUser currentUser]setObject:imageFile forKey:@"profilePicture"];
                
                NSLog(@"9");
                
            }
            
            SCLAlertView *alert = [[SCLAlertView alloc] init];
            
            //Hide animation type (Default is FadeOut)
            alert.hideAnimationType = SlideOutToCenter;
            
            //Show animation type (Default is SlideInFromTop)
            alert.showAnimationType = SlideInToCenter;
            
            //Set background type (Default is Shadow)
            alert.backgroundType = Blur;
            
            [alert alertIsDismissed:^{
                NSLog(@"zurück zu profil");
                [self performSegueWithIdentifier:@"backToProfile" sender:self];
                
                
            }];

            
            
            [[PFUser currentUser]saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"erfolgreich verknüpft");
                    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                    [currentInstallation setObject:_city forKey:@"city"];
                    [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
                    [currentInstallation saveEventually];
                    [[Branch getInstance] setIdentity: [PFUser currentUser].objectId];

                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

                     [alert showSuccess:self title:@"Erfolgreich geupdated" subTitle:nil closeButtonTitle:@"OK" duration:0.0f];
                    

                    
                }
                else {
                    NSLog(@"user: %@",[PFUser currentUser ]);
                    NSLog(@"ging nicht!!!\nError occured: %@", error);
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

                    [alert showError:self title:@"Fehler" subTitle:error.localizedDescription closeButtonTitle:@"OK" duration:0.0f];

                  //  [self dismissViewControllerAnimated:YES completion:nil];
                    
                }
            }];
            
            
            
            
        }
    }];
}


//Stadt laden
-(void) loadData{
    
    self.city = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/stadt", NSHomeDirectory()] encoding:NSUTF8StringEncoding error:nil];
    
    
}


@end
