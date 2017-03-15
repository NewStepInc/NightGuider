//
//  ProductViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 20.10.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import "ProductViewController.h"
#import "SCLAlertView.h"
#import "TicketTableViewController.h"

#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "MyLogInViewController.h"

#import <Bolts/Bolts.h>
#import "Branch.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"



#pragma reminder (anmeldung) daten sammeln
@interface ProductViewController ()
@property (nonatomic, strong) MBProgressHUD *hud;


@end

@implementation ProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"Wird geladen", @"Wird geladen...");
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@" " style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
        self.tableView.tableFooterView = footerView;
        
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDayTicket:) name:@"showDayTicket" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMemberTicket:) name:@"showMemberTicket" object:nil];
    
    //reminder for login
    
    if ([PFUser currentUser]) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"notificationRequestOpened"]){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            int stat = (int) [defaults integerForKey:@"loginOpenings"];
            int stat_1 = stat++;
            if (stat >= 4)
            {
                //ask every 4th time
                NSLog(@"stat: %i",stat);
                
                
                
                SCLAlertView *alert = [[SCLAlertView alloc] init];
                
                //Hide animation type (Default is FadeOut)
                alert.hideAnimationType = SlideOutToTop;
                
                //Show animation type (Default is SlideInFromTop)
                alert.showAnimationType = SlideInFromTop;
                
                //Set background type (Default is Shadow)
                alert.backgroundType = Blur;
                
                [alert alertIsDismissed:^{
                    NSLog(@"SCLAlertView dismissed!");
                    //scalert nicht jetzt
                    [defaults setInteger:0 forKey:@"loginOpenings"];
                    [defaults synchronize];
                }];
                
                [alert addButton:@"Ja" actionBlock:^{
                    //einloggen
                    //scalert nicht jetzt
                    [defaults setInteger:0 forKey:@"loginOpenings"];
                    [defaults synchronize];
                    [self openLoginPopup];
                    
                    
                }];
                
                
                //user not logged in, if you like to login and recieve points for checking in an recieving bonuses
                
                [alert showInfo:self title:@"Nicht angemeldet" subTitle:@"Wenn du dich anmeldest erhälst du viele Vorteile wie zb. Punkte für Besuche und Prämien" closeButtonTitle:@"Nicht Jetzt" duration:0.0f];
                
                
                
            }
            else{
                [defaults setInteger:stat_1 forKey:@"loginOpenings"];
                [defaults synchronize];
            }

        }
        else{
            NSLog(@"push request wurde erst aufgerufen - loginrequest überspringen");
            
            //push notification reminder shown skip the reminder for login for this time
        }

           }


    
    
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showDayTicket:(NSNotification *) notification
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"Tagesticket im Vordergrund angezeigt");
    
    //directly open dayTicketView because of branch link or push notification
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    if (appDelegate.dayTicket) {
        appDelegate.dayTicket = NO;
        NSLog(@"push view öffnen");
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self performSegueWithIdentifier:@"showDayTicket" sender:self];

        
        
    }
    else{
        [[NSNotificationCenter defaultCenter] removeObserver:self];

    }
    
    
}

- (void)showMemberTicket:(NSNotification *) notification
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"Membership im Vordergrund angezeigt");
    
    //directly open memberTicketView because of branch link or push notification

    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    if (appDelegate.memberTicket) {
        NSLog(@"member anzeigen");
        appDelegate.memberTicket = NO;
        NSLog(@"push view öffnen");
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self performSegueWithIdentifier:@"showMember" sender:self];
        
        
        
    }
    else{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
    }
    
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    if (indexPath.row==0) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"threeDayCell" ];
        return cell;
        
    }
    
    else if (indexPath.row == 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"premiumPassCell" ];
        return cell;
        
    }
    else if (indexPath.row == 2){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ticketCell" ];
        return cell;
        
    }
    else if (indexPath.row == 3){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"guestlistCell" ];
        return cell;
        
    }
    else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"combiCell" ];
        return cell;
        
    }
    
    
    
}




//Stadt laden
-(void) loadCity{
    
    self.city = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/stadt", NSHomeDirectory()] encoding:NSUTF8StringEncoding error:nil];
    
    
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    
    NSLog(@"pflogin erfolgreich");
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]] ) {
        [self getUserData];
        
    }
    else{
        NSLog(@"kein fb login");
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

-(void)getUserData{
    
    
    [self.hud show:YES];
    
    
    NSLog(@"Benutzer ist eingeloggt");
    [self loadCity];
    
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
            
            
            [[PFUser currentUser]saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                    [currentInstallation setObject:_city forKey:@"city"];
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
            [currentInstallation setObject:_city forKey:@"city"];
            [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
            [currentInstallation saveInBackground];
            
            
            
        }
    }];
}






#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    if ([segue.identifier isEqualToString:@"ticket"])
    {
        TicketTableViewController *ticketController =segue.destinationViewController;
        
        ticketController.type = @"ticket";
    }
    else if ([segue.identifier isEqualToString:@"guestlist"])
    {
        TicketTableViewController *ticketController =segue.destinationViewController;
        
        ticketController.type = @"guestlist";
    }
    else if ([segue.identifier isEqualToString:@"combi"])
    {
        TicketTableViewController *ticketController =segue.destinationViewController;
        
        ticketController.type = @"combi";
    }
    
}


-(IBAction)backToProducts: (UIStoryboardSegue *) segue{
    
    
}


@end
