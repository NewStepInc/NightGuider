//
//  ClubBonusTableViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 28.05.15.
//  Copyright (c) 2015 Werner. All rights reserved.
//

#import "ClubBonusTableViewController.h"
#import "SCLAlertView.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "MyLogInViewController.h"

#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import <Bolts/Bolts.h>
#import "Branch.h"
#import "MoreInformationViewController.h"
#import "MBProgressHUD.h"




@interface ClubBonusTableViewController ()
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation ClubBonusTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    //  self = [super initWithClassName:@"Augsburg_Events"];
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // Custom initialization
        
        self.parseClassName = @"Bonus";
        
        
        self.textKey = @"title";
        self.imageKey = @"icon";
        
        self.pullToRefreshEnabled = NO;
        self.paginationEnabled = YES;
        self.objectsPerPage = 30;
        
        
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"Wird geladen", @"Wird geladen...");
    
    NSLog(@"viewdidload");
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
        self.tableView.tableFooterView = footerView;
        self.tableView.separatorColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    //get the current points from the user
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {

        PFQuery *query = [PFQuery queryWithClassName:@"Points"];

        [query whereKey:@"userId" equalTo:currentUser.objectId];
        [query whereKey:@"hostId" equalTo:_clubId];
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
    
            if (!error) {
                  NSString *pointsLabel = [NSString stringWithFormat:@"Aktuelle Punkte: %i",[[object objectForKey:@"amount"] intValue] ];
                
                NSNumber *points =[object objectForKey:@"amount"];
                NSString *pointsString =[object objectForKey:@"amount"];
                int pointsInt =[ [object objectForKey:@"amount" ]intValue];


                NSLog(@"userId: %@, clubID: %@, Pkt: %@, Pkt as String %@, Pkt as int %i",currentUser.objectId,_clubId, points,pointsString, pointsInt);

                self.title = pointsLabel;
            }
            else {
                self.title = @"Aktuelle Punkte : 0";
                NSLog(@"error bei userpoints klasse");
            }
        }];


        
    }
    else{
        self.title = @"Anmeldung erforderlich";
    }

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable {
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    // If Pull To Refresh is enabled, query against the network by default.
    if (self.pullToRefreshEnabled) {
        // query.cachePolicy = kPFCachePolicyNetworkOnly;
        
        query.cachePolicy = kPFCachePolicyNetworkElseCache;
        
    }
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    NSLog(@"klasse: %@",self.parseClassName);
    
    [query whereKey:@"hostId" equalTo:_clubId];


    [query orderByAscending:@"points"];
    
    
    
    return query;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
   // PFImageView *profileImageView = (PFImageView*)[cell viewWithTag:102];

    /*
    if (indexPath.row == 10) {
        static NSString *CellIdentifier = @"currentPointsCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        UILabel *pointsLabel = (UILabel*)[cell viewWithTag:1];

        PFUser *currentUser = [PFUser currentUser];
        if (currentUser) {
            NSString *pointsString = [NSString stringWithFormat:@"Aktuelle Punkte: %@",[currentUser objectForKey:@"points"] ];
            pointsLabel.text = @"Aktuelle Punkte: 50";

        }
        else{
            pointsLabel.text = @"Aktuelle Punkte: 50";
        }

        return cell;

    }
    else {
        */
        static NSString *CellIdentifier = @"bonusCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        NSString *title = [object objectForKey:@"title"];
        NSString *points = [object objectForKey:@"points"];
        NSString *description = [object objectForKey:@"description"];

        UILabel *titleLabel = (UILabel*)[cell viewWithTag:2];
        titleLabel.text = title;
        UILabel *pointsLabel = (UILabel*)[cell viewWithTag:3];
        NSString *pointsText = [NSString stringWithFormat:@"%@ Pkt", points];
        pointsLabel.text = pointsText;
        UITextView *descriptionTextView = (UITextView*)[cell viewWithTag:4];
        descriptionTextView.text = description;
        return cell;

    

    
    
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    switch (indexPath.row) {
        case 0:
            return 100;
            break;
        default:
            return 100;
            break;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    //erst überprüfen ob überhaupt eingeloggt
    
    switch (indexPath.row) {
        case 0:{
            
        }
            break;
        default:{
            
        }
            break;
    }
    PFObject *obj = [self.objects objectAtIndex:indexPath.row];
    
    NSString *description = [obj objectForKey:@"description"];
    NSString *title = [obj objectForKey:@"title"];
    
    
    //check if user is logged in

    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        
        

#pragma check if user has enough points
        
        // do stuff with the user
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        //Hide animation type (Default is FadeOut)
        alert.hideAnimationType = SlideOutToCenter;
        
        //Show animation type (Default is SlideInFromTop)
        alert.showAnimationType = SlideInToCenter;
        
        //Set background type (Default is Shadow)
        alert.backgroundType = Blur;
        
        [alert alertIsDismissed:^{
            NSLog(@"SCLAlertView dismissed!");
            
            //  [self performSegueWithIdentifier:@"returnToMain" sender:self];
            
        }];
        [alert addButton:@"Ja" actionBlock:^{
            NSDictionary *buyBonusInfo = @{
                                          
                                          @"user": currentUser.objectId,
                                          @"bonus_id": obj.objectId,
                                          @"host_id": _clubId,
                                          @"title":title,
                                          @"description":description,
                                          @"host_name":_clubName
                                              
                                          
                                          };

            
            //tabellenzeile 1 aktualisieren
            [PFCloud callFunctionInBackground:@"buy_Bonus"
                               withParameters:buyBonusInfo
                                        block:^(NSString *result, NSError *error) {
                                            if (!error) {
                                                // result is @"Hello world!"
                                                [self loadObjects];
                                                // show the signup or login screen
                                                SCLAlertView *alert = [[SCLAlertView alloc] init];
                                                
                                                //Hide animation type (Default is FadeOut)
                                                alert.hideAnimationType = SlideOutToCenter;
                                                
                                                //Show animation type (Default is SlideInFromTop)
                                                alert.showAnimationType = SlideInToCenter;
                                                
                                                //Set background type (Default is Shadow)
                                                alert.backgroundType = Blur;
                                                
                                                [alert showSuccess:self title:@"Glückwunsch" subTitle:@"Deine Prämie findest du in deinem Profil" closeButtonTitle:@"Ok" duration:0.0f];
                                                  NSString *pointsString = [NSString stringWithFormat:@"Aktuelle Punkte: %@",result];
                                                NSLog(@"result: %@", result);

                                                self.title = pointsString;


                                            }
                                            else {
                                                NSLog(@"Error: %@", error);

                                                // show the signup or login screen
                                                SCLAlertView *alert = [[SCLAlertView alloc] init];
                                                
                                                //Hide animation type (Default is FadeOut)
                                                alert.hideAnimationType = SlideOutToCenter;
                                                
                                                //Show animation type (Default is SlideInFromTop)
                                                alert.showAnimationType = SlideInToCenter;
                                                
                                                //Set background type (Default is Shadow)
                                                alert.backgroundType = Blur;
                                                
                                                [alert showError:self title:@"Fehler" subTitle:[error localizedDescription] closeButtonTitle:@"Ok" duration:0.0f];
                                                [self loadObjects];
                                                

                                            }
                                        }];
        }];
        
        //NSString *bonusTitle = [NSString stringWithFormat:@""];
        
        [alert showInfo:self title:[obj objectForKey:@"title"] subTitle:@"Möchtest du deine Punkte dafür einlösen?" closeButtonTitle:@"Nein" duration:0.0f];
    } else {
        
        // show the signup or login screen
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        //Hide animation type (Default is FadeOut)
        alert.hideAnimationType = SlideOutToCenter;
        
        //Show animation type (Default is SlideInFromTop)
        alert.showAnimationType = SlideInToCenter;
        
        //Set background type (Default is Shadow)
        alert.backgroundType = Blur;
        
        [alert addButton:@"Anmelden" actionBlock:^{
            
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
            

            
            // Present log in view controller
            [self presentViewController:logInViewController animated:YES completion:NULL];
            
            
        }];

        [alert showInfo:self title:@"Nicht angemeldet" subTitle:@"Du musst dich zuerst anmelden" closeButtonTitle:@"Nicht jetzt" duration:0.0f];
        
    }
    
}

- (IBAction)rightBarButtonPressed:(id)sender {
    
    //show information about bonus
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    //Hide animation type (Default is FadeOut)
    alert.hideAnimationType = SlideOutToCenter;
    
    //Show animation type (Default is SlideInFromTop)
    alert.showAnimationType = SlideInToCenter;
    
    //Set background type (Default is Shadow)
    alert.backgroundType = Blur;
    
    [alert addButton:@"Mehr Infos" actionBlock:^{
        [self performSegueWithIdentifier:@"showMoreInfo" sender:self];


    }];
    [alert addButton:@"Premium-Pass" actionBlock:^{
        [self performSegueWithIdentifier:@"showMember" sender:self];

    }];
    
    [alert showWarning:self title:@"Punkte sammeln" subTitle:@"Du erhälst Punkte durch das einchecken in den Club und durch das einladen von Freunden und beim Premium-Pass erhälst du auch noch einen Dublikator für deine Punkte" closeButtonTitle:@"Ok" duration:0.0f];
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
            NSLog(@"borthdayAfter: %@", birthday);            NSString *relationship = userData[@"relationship_status"];
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
                    NSLog(@"ging nicht!!!\nError occured: %@", error);
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

                    
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

//load city
-(void) loadData{
    
    self.city = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/stadt", NSHomeDirectory()] encoding:NSUTF8StringEncoding error:nil];
    
    
}

-(IBAction)backToClubBonus: (UIStoryboardSegue *) segue{
    
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"showMoreInfo"])
    {
        MoreInformationViewController *detailController =segue.destinationViewController;
        detailController.isBonus = YES;
        
    }
}



@end
