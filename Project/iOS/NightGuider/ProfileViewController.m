//
//  ProfileViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 20.10.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import "ProfileViewController.h"

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "SCLAlertView.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <CoreData/CoreData.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import <Bolts/Bolts.h>

#import "ProfileEditViewController.h"
#import "CRFAQTableViewController.h"
//#import "JBWhatsAppActivity.h"
#import "MyLogInViewController.h"
#import "Branch.h"
#import "BranchUniversalObject.h"
#import "BranchLinkProperties.h"
#import "MBProgressHUD.h"
#import "JLPhotosPermission.h"








@interface ProfileViewController ()<UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonRight;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"Wird geladen", @"Wird geladen...");
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView reloadData];
    
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
        self.tableView.tableFooterView = footerView;
        
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@" " style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"Wird geladen", @"Wird geladen...");
    
    
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [self loadData];
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        self.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle: @"Edit"
                                                                                   style: UIBarButtonItemStyleBordered
                                                                                  target: self
                                                                                  action: @selector(openEditView)];
    }
    else{
        self.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle: @"Login"
                                                                                   style: UIBarButtonItemStyleBordered
                                                                                  target: self
                                                                                  action: @selector(openLoginPopup)];
        
        
    }
    
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 12;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        static NSString *CellIdentifier = @"top";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        
        
        
        PFFile *banner = [[PFUser currentUser] objectForKey:@"profilePicture"];
        
        PFImageView *bannerImageView = (PFImageView*)[cell viewWithTag:101];
        // thumbnailImageView.image = [UIImage imageNamed:@"placeholder.jpg"];
        
        PFFile *profile = [[PFUser currentUser] objectForKey:@"profilePicture"];
        PFImageView *profileImageView = (PFImageView*)[cell viewWithTag:102];
        // thumbnailImageView.image = [UIImage imageNamed:@"placeholder.jpg"];
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2;
        profileImageView.clipsToBounds = YES;
        profileImageView.layer.borderWidth = 2;
        profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        
        
        //checken ob user eingeloggt falls nicht dummy daten
        PFUser *currentUser = [PFUser currentUser];
        if (currentUser) {
            UILabel *nameLabel = (UILabel*) [cell viewWithTag:100];
            nameLabel.text = [[PFUser currentUser] objectForKey:@"username"];
            NSLog(@"username: %@", [[PFUser currentUser] objectForKey:@"username"]);
            NSLog(@"firstname: %@", [[PFUser currentUser] objectForKey:@"first_name"]);
            bannerImageView.file = banner;
            profileImageView.file = profile;
            
            
        }
        else{
            UILabel *nameLabel = (UILabel*) [cell viewWithTag:100];
            nameLabel.text = @"Nicht eingeloggt";
            
            UIImage *chosenImage = [UIImage imageNamed:@"background"];
            bannerImageView.file = nil;
            
            bannerImageView.image = chosenImage;
            
            UIImage *profileImage = [UIImage imageNamed:@"test"];
            profileImageView.file = nil;
            
            profileImageView.image = profileImage;
            
            
            
            
        }
        // bannerImageView.file = banner;
        
        
        
        NSLog(@"Subviews: %li", (unsigned long)bannerImageView.subviews.count);
        
        if (bannerImageView.subviews.count == 0) {
            
            UIVisualEffect *blurEffect;
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            
            UIVisualEffectView *visualEffectView;
            visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            
            visualEffectView.frame = bannerImageView.bounds;
            [bannerImageView addSubview:visualEffectView];
            
            visualEffectView.translatesAutoresizingMaskIntoConstraints = NO;

            
            NSLayoutConstraint *width =[NSLayoutConstraint
                                        constraintWithItem:visualEffectView
                                        attribute:NSLayoutAttributeWidth
                                        relatedBy:0
                                        toItem:bannerImageView
                                        attribute:NSLayoutAttributeWidth
                                        multiplier:1.0
                                        constant:0];
            NSLayoutConstraint *height =[NSLayoutConstraint
                                         constraintWithItem:visualEffectView
                                         attribute:NSLayoutAttributeHeight
                                         relatedBy:0
                                         toItem:bannerImageView
                                         attribute:NSLayoutAttributeHeight
                                         multiplier:1.0
                                         constant:0];
            NSLayoutConstraint *top = [NSLayoutConstraint
                                       constraintWithItem:visualEffectView
                                       attribute:NSLayoutAttributeTop
                                       relatedBy:NSLayoutRelationEqual
                                       toItem:bannerImageView
                                       attribute:NSLayoutAttributeTop
                                       multiplier:1.0f
                                       constant:0.f];
            NSLayoutConstraint *leading = [NSLayoutConstraint
                                           constraintWithItem:visualEffectView
                                           attribute:NSLayoutAttributeLeading
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:bannerImageView
                                           attribute:NSLayoutAttributeLeading
                                           multiplier:1.0f
                                           constant:0.f];
            
            [bannerImageView addConstraints:@[width, height, top, leading]];
            
        }
        
        
        [bannerImageView loadInBackground];
        
        NSLog(@"username: %@", [[PFUser currentUser] objectForKey:@"username"]);
        
        [profileImageView loadInBackground];
        
        UIButton *vipButton = (UIButton*)[cell viewWithTag:103];
        vipButton.layer.cornerRadius = 15;
        vipButton.clipsToBounds = YES;
        vipButton.layer.borderWidth = 1;
        vipButton.layer.borderColor = [UIColor whiteColor].CGColor;
        
        
        
        return cell;
    }
    else if (indexPath.row == 1) {
        static NSString *CellIdentifier = @"tickets";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    }
    else if (indexPath.row == 2) {
        static NSString *CellIdentifier = @"pass";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    }
    else if (indexPath.row == 3) {
        static NSString *CellIdentifier = @"bonus";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    }
    else if (indexPath.row == 4) {
        static NSString *CellIdentifier = @"checkin";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    }
    else if (indexPath.row == 5) {
        static NSString *CellIdentifier = @"cityChange";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.detailTextLabel.text = _stadt;
        return cell;
    }
    else if (indexPath.row == 6) {
        static NSString *CellIdentifier = @"favorite";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    }
    
    else if (indexPath.row == 7) {
        static NSString *CellIdentifier = @"postFb";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UISwitch *shareEventSwitch = (UISwitch *)[cell viewWithTag:301];
        UILabel *shareEventLabel = (UILabel *)[cell viewWithTag:302];
        
        
        if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
            shareEventSwitch.hidden = NO;
            shareEventLabel.hidden = NO;
            
        }
        else{
            shareEventSwitch.hidden = YES;
            shareEventLabel.hidden = YES;
        }
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shareEvent"]) {
            shareEventSwitch.on = YES;
        }
        else{
            shareEventSwitch.on = NO;
            
            
        }
        [shareEventSwitch addTarget:self action:@selector(shareEventToggled:) forControlEvents:UIControlEventValueChanged];
        
        return cell;
    }
    
    else if (indexPath.row == 8) {
        static NSString *CellIdentifier = @"share";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    }
    else if (indexPath.row == 9) {
        static NSString *CellIdentifier = @"faq";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    }
    else if (indexPath.row == 10) {
        static NSString *CellIdentifier = @"about";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    }
    else if (indexPath.row == 11) {
        static NSString *CellIdentifier = @"logout";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        
        return cell;
    }
    else{
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        return 240;
    }
    else if(indexPath.row == 7){
        if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
            return 50;
        }
        else return 0;
        
    }
    else{
        return 50;
    }
}

- (IBAction)unwindToProfileController:(UIStoryboardSegue *)unwindSegue
{
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}


- (IBAction)vipPressed:(id)sender {
    
#warning -- schauen ob vip falls ja weiterleiten zur usermember
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    //Hide animation type (Default is FadeOut)
    alert.hideAnimationType = SlideOutToCenter;
    
    //Show animation type (Default is SlideInFromTop)
    alert.showAnimationType = SlideInToCenter;
    
    //Set background type (Default is Shadow)
    alert.backgroundType = Blur;
    
    [alert alertIsDismissed:^{
        //  [self performSegueWithIdentifier:@"returnToMain" sender:self];
        
    }];
    [alert addButton:@"Mehr erfahren" actionBlock:^{
        NSLog(@"weiterleitung an website");
          [self performSegueWithIdentifier:@"member" sender:self];

    }];
    
    [alert showInfo:self title:@"Kein VIP" subTitle:@"Möchtest du eine Mitgliedschaft erwerben und unzählige Vorteile genießen?" closeButtonTitle:@"Jetzt nicht" duration:0.0f];
    
}

-(void)getUserData{
    
    [self.hud show:YES];

    
    NSLog(@"Benutzer ist eingeloggt");
    [self loadData];
    
    NSString *requestPath = @"me/?fields=name,location,email,gender,birthday,relationship_status,first_name,last_name,cover";
    
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
            NSLog(@"CoverPhoto: %@",coverPhoto);
            NSLog(@"CoverUrl: %@", coverUrl);
            
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
            if (_stadt) {
                [[PFUser currentUser]setObject:_stadt forKey:@"city"];
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
            
            
            [[PFUser currentUser]saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                    [currentInstallation setObject:_stadt forKey:@"city"];
                    [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
                    [currentInstallation saveEventually];
                    [[Branch getInstance] setIdentity: [PFUser currentUser].objectId];

                    
                    
                    if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
                        [PFFacebookUtils linkUserInBackground:[PFUser currentUser] withReadPermissions:nil block:^(BOOL succeeded, NSError *error) {
                            if (succeeded) {
                                NSLog(@"Woohoo, user logged in with Facebook!");


                                [self.tableView reloadData];
                                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

                                
                            }
                        }];
                    }

                    
                    [self.tableView reloadData];
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

                    
                    
                    
                }
                else {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

                    NSLog(@"ging nicht!!!\nError occured: %@", error);
                    
                }
            }
             ];
            
            
             PFInstallation *currentInstallation = [PFInstallation currentInstallation];
             [currentInstallation setObject:_stadt forKey:@"city"];
             [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
             [currentInstallation saveInBackground];


            
        }
    }];
}

- (IBAction)shareEventToggled:(id)sender {
    UISwitch* theSwitch = (UISwitch*) sender;
    BOOL theSwitchIsOn = theSwitch.on;
    
    NSLog(@"eventteilnahme: %i",theSwitchIsOn);
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shareEvent"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"shareEvent"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"teilen ausschalten");
    }
    else{
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shareEvent"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"teilen anschalten");
        
        
    }
}
- (IBAction)fbSwitchToggled:(id)sender {
    //bereits eingeloggte user mit fb verbinden
    
    /*
     if (![PFFacebookUtils isLinkedWithUser:user]) {
     [PFFacebookUtils linkUserInBackground:user withReadPermissions:nil block:^(BOOL succeeded, NSError *error) {
     if (succeeded) {
     NSLog(@"Woohoo, user is linked with Facebook!");
     }
     }];
     }
     */
    //oder auch die verbindung löschen
    /*
     [PFFacebookUtils unlinkUserInBackground:user block:^(BOOL succeeded, NSError *error) {
     if (succeeded) {
     NSLog(@"The user is no longer associated with their Facebook account.");
     }
     }];
     */
    
    UISwitch* theSwitch = (UISwitch*) sender;
    BOOL theSwitchIsOn = theSwitch.on;
    NSLog(@"fb connect: %i",theSwitchIsOn);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:6 inSection:0];
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
    
    /*
     if ([FBSession.activeSession isOpen]) {
     // Session is open
     NSLog(@"user in fb eingeloggt");
     
     [PFUser logOut];
     
     [FBSession.activeSession closeAndClearTokenInformation];
     _fbName.text = @"Logged out";
     [self.tableView reloadData];
     
     
     
     }
     */
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        // Session is open
        NSLog(@"user in fb eingeloggt");
        
        [PFUser logOut];
        
        
        _fbName.text = @"Logged out";
        [self.tableView reloadData];
        
    }
    
    else {
        // Session is closed
        NSLog(@"user nicht in fb eingeloggt");
        
        //NSArray *permissionsArray = @[@"email", @"user_likes",@"user_birthday",@"user_interests",@"user_hometown",@"user_location",@"friends_events", @"user_events",@"user_relationships"];
        
        NSArray *permissionsArray = @[@"email",@"user_birthday",@"user_location", @"user_events",@"user_relationships"];
        
        // Login PFUser using Facebook
        [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
            //  [_activityIndicator stopAnimating]; // Hide loading indicator
            
            if (!user) {
                if (!error) {
                    NSLog(@"Uh oh. The user cancelled the Facebook login.");
                    [self.tableView beginUpdates];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPaths] withRowAnimation:UITableViewRowAnimationNone];
                    [self.tableView endUpdates];
                    
                } else {
                    NSLog(@"Uh oh. An error occurred: %@", error);
                    UIAlertView* alertNotLoggedIn = [[UIAlertView alloc] initWithTitle:@"Fehler" message:@"Bitte erteile NightGuider unter Einstellungen/Facebook die Erlaubnis dich einzuloggen"delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    
                    [alertNotLoggedIn show];
                    [self.tableView beginUpdates];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPaths] withRowAnimation:UITableViewRowAnimationNone];
                    [self.tableView endUpdates];
                    
                    
                }
            } else if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
                [self getUserData];
                //_fbName.text = [PFUser currentUser].username;
                _fbName.text = [[PFUser currentUser] objectForKey:@"first_name"];
                
                //   [self.navigationController pushViewController:[[UserDetailsViewController alloc] initWithStyle:UITableViewStyleGrouped] animated:YES];
                [self.tableView reloadData];
                
                
                
            } else {
                NSLog(@"User with facebook logged in!");
                [self getUserData];
                //    _fbName.text = [PFUser currentUser].username;
                _fbName.text = [[PFUser currentUser] objectForKey:@"first_name"];
                [self.tableView reloadData];
                
                
                
                // [self.navigationController pushViewController:[[UserDetailsViewController alloc] initWithStyle:UITableViewStyleGrouped] animated:YES];
                
            }
        }];
        
        
        
    }
    
}


//Stadt laden
-(void) loadData{
    
    self.stadt = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/stadt", NSHomeDirectory()] encoding:NSUTF8StringEncoding error:nil];
    
    
}

-(void)logout{
    
    //erst überprüfen ob überhaupt eingeloggt
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        // do stuff with the user
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        //Hide animation type (Default is FadeOut)
        alert.hideAnimationType = SlideOutToCenter;
        
        //Show animation type (Default is SlideInFromTop)
        alert.showAnimationType = SlideInToCenter;
        
        //Set background type (Default is Shadow)
        alert.backgroundType = Blur;
        
        [alert alertIsDismissed:^{
            //  [self performSegueWithIdentifier:@"returnToMain" sender:self];
            
        }];
        [alert addButton:@"Ja" actionBlock:^{
            //ausloggen
            [PFUser logOut];
            [[Branch getInstance] logout];
            
            self.navigationItem.rightBarButtonItem =  [[UIBarButtonItem alloc] initWithTitle: @"Login"
                                                                                       style: UIBarButtonItemStyleBordered
                                                                                      target: self
                                                                                      action: @selector(openLoginPopup)];
            
            [self.tableView reloadData];
            
            //tabelle aktualisieren
            NSLog(@"ausgeloggt");
        }];
        
        [alert showInfo:self title:@"Abmelden" subTitle:@"Möchtest du dich ausloggen?" closeButtonTitle:@"Nein" duration:0.0f];
    } else {
        
        // show the signup or login screen
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        //Hide animation type (Default is FadeOut)
        alert.hideAnimationType = SlideOutToCenter;
        
        //Show animation type (Default is SlideInFromTop)
        alert.showAnimationType = SlideInToCenter;
        
        //Set background type (Default is Shadow)
        alert.backgroundType = Blur;
        
        [alert showInfo:self title:@"Nicht angemeldet" subTitle:@"Du bist schon abgemeldet" closeButtonTitle:@"Ok" duration:0.0f];
        
    }
    
    
    
    
}

- (IBAction)photoButtonPressed:(id)sender {
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        // do stuff with the user

        //  [[JLPhotosPermission sharedInstance] setExtraAlertEnabled:YES];
        [[JLPhotosPermission sharedInstance] authorizeWithTitle:@"Zugriff Bilder erlauben?" message:@"Dadurch kannst du dein Porfilbild verändern" cancelTitle:@"Nicht jetzt" grantTitle:@"ok" completion:^(BOOL granted, NSError * _Nullable error) {
            NSLog(@"photoLibrary returned %@ with error %@", @(granted), error);
            [self presentReenableVCForCore:[JLPhotosPermission sharedInstance] granted:granted error:error];
            if (granted) {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.allowsEditing = YES;
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                
                [self presentViewController:picker animated:YES completion:NULL];
            }
            
        }];
        
    } else {
        // show the signup or login screen
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        //Hide animation type (Default is FadeOut)
        alert.hideAnimationType = SlideOutToCenter;
        
        //Show animation type (Default is SlideInFromTop)
        alert.showAnimationType = SlideInToCenter;
        
        //Set background type (Default is Shadow)
        alert.backgroundType = Blur;
        
        [alert alertIsDismissed:^{
            //  [self performSegueWithIdentifier:@"returnToMain" sender:self];
            
        }];
        [alert addButton:@"Ja" actionBlock:^{
            
            //tabelle aktualisieren
            NSLog(@"einloggen");
        }];
        
        [alert showInfo:self title:@"Nicht angemeldet" subTitle:@"Du musst eingeloggt sein, um ein Profilbild auszuwählen. Möchtest du dich einloggen?" closeButtonTitle:@"Jetzt Nicht" duration:0.0f];
    }
}

- (void)presentReenableVCForCore:(JLPermissionsCore *)core
                         granted:(BOOL)granted
                           error:(NSError *)error {
    if (!granted && error.code == JLPermissionSystemDenied) {
        UIViewController *vc = [core reenableViewController];
        if (vc) {
            [self presentViewController:vc animated:YES completion:nil];
        } else {
            [core displayReenableAlert];
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [self.hud show:YES];
    NSLog(@"bild ausgewählt");
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    NSData *imageData = UIImagePNGRepresentation(chosenImage);
    PFFile *imageFile = [PFFile fileWithName:@"profile.png" data:imageData];
    
    /*
     PFObject *userPhoto = [PFObject objectWithClassName:@"UserPhoto"];
     userPhoto[@"imageName"] = @"My trip to Hawaii!";
     userPhoto[@"imageFile"] = imageFile;
     [userPhoto saveInBackground];
     */
    
    [[PFUser currentUser]setObject:imageFile forKey:@"profilePicture"];
    [[PFUser currentUser]saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"bild erfolgrech hochgeladen");
            NSLog(@"tabelle neu laden");
            /*
             NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
             NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
             [self.tableView beginUpdates];
             [self.tableView reloadRowsAtIndexPaths:@[indexPaths] withRowAnimation:UITableViewRowAnimationNone];
             [self.tableView endUpdates];
             */
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

            [self.tableView reloadData];
            
            
            
        }
        else{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

            NSLog(@"fehler beim bildhochladen");
        }
    }];
    
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"bild abgebrochen");
    
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
     UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
     NSString *cellText = cell.textLabel.text;
     
     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
     NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
     [self.tableView beginUpdates];
     [self.tableView reloadRowsAtIndexPaths:@[indexPaths] withRowAnimation:UITableViewRowAnimationNone];
     */
    //stimmt sogar
    NSLog(@"pathforrow: %ld\nsection %ld: ",(long)indexPath.row, (long)indexPath.section);
    
    if((long)indexPath.row == 11 ){
        NSLog(@"letzter button gedrückt");
        [self logout];
    }
    else if ((long)indexPath.row == 1){
        NSLog(@"userticket");
        
        if ([PFUser currentUser]) {
            [self performSegueWithIdentifier:@"userTicket" sender:self];
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
                
            }];
            
            [alert addButton:@"Ok" actionBlock:^{
                
                [self openLoginPopup];
                
                
            }];
            
            [alert showInfo:self title:@"Nicht angemeldet" subTitle:@"Du musst eingeloggt sein um bereits gekaufte Tickets und Prämien zu sehen" closeButtonTitle:@"Nicht Jetzt" duration:0.0f];
            
            
        }


    }
    
    else if ((long)indexPath.row == 2){
        
        if ([PFUser currentUser]) {
            [self performSegueWithIdentifier:@"userMember" sender:self];
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
                
            }];
            
            [alert addButton:@"Ok" actionBlock:^{
                
                [self openLoginPopup];
                
                
            }];
            
            [alert showInfo:self title:@"Nicht angemeldet" subTitle:@"Du musst eingeloggt sein um dir eine Premiummitgliedschaft oder ein 3-Tagesticket zu kaufen" closeButtonTitle:@"Nicht Jetzt" duration:0.0f];
            
        }
        
    }
    else if ((long)indexPath.row == 3){
        
        if ([PFUser currentUser]) {
            [self performSegueWithIdentifier:@"userPoints" sender:self];
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
                
            }];
            
            [alert addButton:@"Ok" actionBlock:^{
                
                [self openLoginPopup];
                
                
            }];
            
            [alert showInfo:self title:@"Nicht angemeldet" subTitle:@"Du musst eingeloggt sein um Punkte zusammeln und Prämien einlösen zu können" closeButtonTitle:@"Nicht Jetzt" duration:0.0f];
            
        }
        
    }
    
    else if ((long)indexPath.row == 8){
        
        [self shareApp];
        
#pragma  -- if gold coins activated uncomment to tell user he gets rewards for signing in
        /*
        if ([PFUser currentUser]) {
            [self shareApp];
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
                [self shareApp];
                
            }];
            
            [alert addButton:@"Anmelden" actionBlock:^{
                
                [self openLoginPopup];
                
                
            }];
            
            [alert showInfo:self title:@"Gold Coins" subTitle:@"Wenn du dich einloggst bekommst du für Freunde dich sich anmelden Gold Coins" closeButtonTitle:@"Nein Danke" duration:0.0f];
            
        }
         */

        
    }
    else if ((long)indexPath.row == 9){
        [self openFAQ];

    }
    
    /*
    if (indexPath == [NSIndexPath indexPathForRow:10 inSection:0]) {
        NSLog(@"letzter button gedrückt");
        [self logout];
    }
    else if (indexPath == [NSIndexPath indexPathForRow:1 inSection:0])
    {
        
        NSLog(@"userticket");
        
#warning oder algemeines segue und auskommentieren?
        
        */
        /*
        
        if ([PFUser currentUser]) {
              [self performSegueWithIdentifier:@"userTicket" sender:self];
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
                
            }];
            
            [alert addButton:@"Ok" actionBlock:^{
                
                [self openLoginPopup];
                
                
            }];
            
            [alert showInfo:self title:@"Nicht angemeldet" subTitle:@"Du musst eingeloggt sein um bereits gekaufte Tickets und Prämien zu sehen" closeButtonTitle:@"Nicht Jetzt" duration:0.0f];
         
         
        }
         */
        /*

    }
    else if (indexPath == [NSIndexPath indexPathForRow:2 inSection:0])
    {
        if ([PFUser currentUser]) {
              [self performSegueWithIdentifier:@"userMember" sender:self];
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
                
            }];
            
            [alert addButton:@"Ok" actionBlock:^{
                
                [self openLoginPopup];
                
                
            }];
            
            [alert showInfo:self title:@"Nicht angemeldet" subTitle:@"Du musst eingeloggt sein um dir eine Premiummitgliedschaft oder ein 3-Tagesticket zu kaufen" closeButtonTitle:@"Nicht Jetzt" duration:0.0f];
            
        }
    }

    else if (indexPath == [NSIndexPath indexPathForRow:7 inSection:0])
    {
        if ([PFUser currentUser]) {
            [self shareApp];
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
                [self shareApp];
                
            }];
            
            [alert addButton:@"Anmelden" actionBlock:^{
                
                [self openLoginPopup];
                
                
            }];
            
            [alert showInfo:self title:@"Gold Coins" subTitle:@"Wenn du dich einloggst bekommst du für Freunde dich sich anmelden Gold Coins" closeButtonTitle:@"Nein Danke" duration:0.0f];
            
        }
    }
    else if (indexPath == [NSIndexPath indexPathForRow:8 inSection:0])
    {
        
        [self openFAQ];
    }
    
    */
}

-(void)openFAQ{
    NSLog(@"sollte faq aufrufen");
    
    CRFAQTableViewController *faqViewController = [[CRFAQTableViewController alloc] init];
    
    
    
    [faqViewController addQuestion:@"Wie Checke ich in ein Event ein?" withAnswer:@"Aktiviere Bluetooth unter den Einstellungen und betritt einfach den Club, dadurch wirst du automatisch erkannt ohne dein Gerät aus der Tasche zu nehmen"];
    [faqViewController addQuestion:@"Warum Bluetooth?" withAnswer:@"Es wird Bluetooth 4.0 verwendet, dies ist eine neue sehr akkuschonende Technologie, die uns ermöglicht dich kontaktlos und benutzerfreundlich einzuloggen. Bluetooth 4.0 ist nicht mit dem alten Bluetooth zu vergleichen, bei dem der Akku rapide absinkt, probiere es doch ienfach mal aus."];
    [faqViewController addQuestion:@"Was sind Gold Coins?" withAnswer:@"Gold Coins sind globale Coins die nicht nur auf einen speziellen Club gebunden sind"];
    [faqViewController addQuestion:@"Was kann ich mit Gold Coins machen?" withAnswer:@"Mit Gold Coins kannst du verschiedene Dinge machen, bis jetzt ist es möglich Tickets und Gästelistenplätze zu ergattern, in Zukunft wird es noch mehr Optionen geben, wie zb. alle Tickets oder Gästelistenplätze damit zu kaufen oder die Punkte auch in Prämien und Premium-Pässe umzutauschen. Am beste du schaust auf die Facebook Seite für Neuigkeiten"];
    [faqViewController addQuestion:@"Wie bekomme ich Gold Coins?" withAnswer:@"Gold Coins bekommst du, in dem du Freunde in die App einlädst und diese sich anmelden, auf unserer Promowand sind weitere Optionen, oder durch vervollständigen deines Profils und durch Sonderaktionen"];
    [faqViewController addQuestion:@"Was ist ein Kombiticket?" withAnswer:@"Das Kombiticket ist eine Kombination aus dem normalen Ticket und einem Gästelistenplatz"];
    [faqViewController addQuestion:@"Was sind Club-Coins?" withAnswer:@"Club-Coins sind speziell an den jeweiligen Club gebunden"];
    [faqViewController addQuestion:@"Was kann ich mit Club-Coins machen?" withAnswer:@"Deine Club-Coins kannst du in Prämien umtauschen und so unter anderem Freien Eintritt, Gästelistenplätze oder auch Freigetränke erhalten"];
    [faqViewController addQuestion:@"Wie bekomme ich Club-Coins?" withAnswer:@"In dem du dich durch die App in das Event eincheckst, dies geht ganz leicht in dem du Bluettoth aktivierst und der App die jeweiligen Rechte gibst"];
    [faqViewController addQuestion:@"Was ist ein 3 Tagespass?" withAnswer:@"Mit dem 3 Tagespass erhälst du in ganz Deutschland 3 tagelang kostenlosen Eintritt, optimal für eine Städte Reise, Clubhopping oder ein Ausgiebiges Partywochenende"];
    [faqViewController addQuestion:@"Was ist ein Premiumpass?" withAnswer:@"Mit deinem Premiumpass erhälst du kostenlosen Eintritt, optimal für eine Städte Reise, Clubhopping oder ein Ausgiebiges Partywochenende\nZusatzlich Rabatt bei dem Kauf von Tickets oder Gästelistenplätze\nAußerdem erhälst du regelmäßig Gold-Coins\nUnd den Multiplikator, bei dem du durch deinen Check-In im Club noch mehr Punkte erhäkst"];
    [faqViewController addQuestion:@"Wie löse ich ein Ticket/Gästelistenplatz ein?" withAnswer:@"Gehe auf den Reiter Profil und dort auf Tickets, wähle dein jeweiliges Ticket aus und zeige den QR-Code vor"];
    [faqViewController addQuestion:@"Wie löse ich Prämien ein?" withAnswer:@"Gehe auf den Reiter Profil und dort auf Tickets, der wähle anschließend den zweite Tab oben aus, wähle nur die Prämie aus und zeige den QR-Code an der Kasse vor"];
    [faqViewController addQuestion:@"Wie benutze ich meinen Pass?" withAnswer:@"Gehe auf den Reiter Profil und dort auf QR-Code anzeigen, zeige diesen vor und das wars :)"];
    [faqViewController addQuestion:@"Ich kann einen Club nicht finden?" withAnswer:@"Das tut uns Leid, wir versuchen unser Bestes alle Clubs zu erfassen, schicke uns doch am Besten eine Email an info@nightguider.de\nVielleicht bekommst du ja ein spezielles Dankeschön, falls uns dieser Club noch nicht aufgefallen ist ;)"];
    
    [faqViewController addQuestion:@"Wo erhalte ich noch mehr Informationen" withAnswer:@"Auf unserer Support Seite unter: support.nightguider.de \noder per Email an support@nightguider.de"];
    
    faqViewController.title = @"FAQ";
    
    
    [self.navigationController pushViewController:faqViewController animated:YES];
    
    
    
    
}

-(void)openEditView{
    
    
    [self performSegueWithIdentifier:@"editProfile" sender:self];
    
    
}

-(void)openLoginPopup{
    
    MyLogInViewController *logInViewController = [[MyLogInViewController alloc] init];
    logInViewController.delegate = self;

    
    NSArray *permissionsArray = @[@"email",@"user_birthday",@"user_location", @"user_events",@"user_relationships"];
    
    [logInViewController setFacebookPermissions:permissionsArray];
    
    [logInViewController setFields:PFLogInFieldsUsernameAndPassword
     | PFLogInFieldsFacebook
     | PFLogInFieldsSignUpButton
     | PFLogInFieldsPasswordForgotten
     | PFLogInFieldsLogInButton
     | PFLogInFieldsDismissButton];
    
    [logInViewController setDelegate:self];
    
    
    [self presentViewController:logInViewController animated:YES completion:NULL];
    
    
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    
    NSLog(@"pflogin erfolgreich");
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    _fbName.text = [PFUser currentUser].username;
    
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]] ) {
        [self getUserData];
        
    }
    else{
        NSLog(@"kein fb login");
        [self.tableView reloadData];
    }
    
    
    
    
}
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    NSLog(@"pflogin abgebrochen");
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    
}
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error
{
    
    NSLog(@"Fehler beim login: %@", error);
    
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
    
        [alert showError:self title:@"Fehler" subTitle:@"Leider ist ein Fehler beim Login aufgetreten, bitte versuche es später nochmal" closeButtonTitle:@"OK" duration:0.0f];
    
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    DLog(@"singup aufgerufen 2");

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    DLog(@"singup abgrebrochen 2");

    [self dismissViewControllerAnimated:YES completion:nil];
}




-(void)shareApp{
    
    
    BranchUniversalObject *branchUniversalObject = [[BranchUniversalObject alloc] initWithCanonicalIdentifier:@"appShare"];


    if ([PFUser currentUser]) {
        [branchUniversalObject addMetadataKey:@"user" value:[PFUser currentUser].objectId];
        
    }
    else {
        [branchUniversalObject addMetadataKey:@"user" value:@"not logged in"];
        
    }
    

    
    
    BranchLinkProperties *linkProperties = [[BranchLinkProperties alloc] init];
    linkProperties.feature = @"inApp_share";
    [branchUniversalObject showShareSheetWithLinkProperties:linkProperties
                                               andShareText:@"Waaaaassss Uuuuup!! NightGuider voll der krasse Shiat!"
                                         fromViewController:self
                                                andCallback:^{
                                                    NSLog(@"finished presenting");
    }];
    //   linkProperties.channel = @"facebook";
    //  [linkProperties addControlParam:@"$ios_deepview" withValue:@"default_template"];
    //  [linkProperties addControlParam:@"$android_deepview" withValue:@"default_template"];
    
/*
#warning message und params ersetzen
    NSLog(@"sollte teilen dialog öffnen");
    
    if ([ PFUser currentUser]) {
        //branch referral link erstellen
        [[Branch getInstance] getShortURLWithParams:@{@"UserId": [[PFUser currentUser] objectId]} andChannel:@"inApp" andFeature:BRANCH_FEATURE_TAG_SHARE andCallback:^(NSString *url, NSError *error) {
            
            if (!error)
            {   NSLog(@"got my Branch link to share: %@", url);
                NSString* message = [NSString stringWithFormat:@"Schau dir mal die App NightGuider an, da gibt es alle Events, Tickets und Gästelistenplätze und sie ist kostenlos: %@", url];
                
#warning whatsapp share nicht erlaubt?
                

                
                WhatsAppMessage *whatsappMsg = [[WhatsAppMessage alloc] initWithMessage:message forABID:nil];
                
                NSArray *applicationActivities = @[[[JBWhatsAppActivity alloc] init]];
                NSArray *excludedActivities    = @[UIActivityTypePrint, UIActivityTypePostToWeibo];
                NSArray *activityItems         = @[message, whatsappMsg];
                
                UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
                activityViewController.excludedActivityTypes = excludedActivities;
                
                [self presentViewController:activityViewController animated:YES completion:^{}];
            }
            else{
                NSLog(@"Error creating referral url");
                NSString* message = [NSString stringWithFormat:@"Schau dir mal die App NightGuider an, da gibt es alle Events, Tickets und Gästelistenplätze und sie ist kostenlos: (link)"];
                WhatsAppMessage *whatsappMsg = [[WhatsAppMessage alloc] initWithMessage:message forABID:nil];
                
                NSArray *applicationActivities = @[[[JBWhatsAppActivity alloc] init]];
                NSArray *excludedActivities    = @[UIActivityTypePrint, UIActivityTypePostToWeibo];
                NSArray *activityItems         = @[message, whatsappMsg];
                
                UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
                activityViewController.excludedActivityTypes = excludedActivities;
                
                [self presentViewController:activityViewController animated:YES completion:^{}];
            }
        }];
        
        
    }else{
        NSString* message = [NSString stringWithFormat:@"Schau dir mal die App NightGuider an, da gibt es alle Events, Tickets und Gästelistenplätze und sie ist kostenlos: (link)"];
        
        WhatsAppMessage *whatsappMsg = [[WhatsAppMessage alloc] initWithMessage:message forABID:nil];
        
        NSArray *applicationActivities = @[[[JBWhatsAppActivity alloc] init]];
        NSArray *excludedActivities    = @[UIActivityTypePrint, UIActivityTypePostToWeibo];
        NSArray *activityItems         = @[message, whatsappMsg];
        
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
        activityViewController.excludedActivityTypes = excludedActivities;
        
        [self presentViewController:activityViewController animated:YES completion:^{}];
        
    }
 
 */
    
    
    
}





-(IBAction)backToProfile: (UIStoryboardSegue *) segue{
    
    
}


@end
