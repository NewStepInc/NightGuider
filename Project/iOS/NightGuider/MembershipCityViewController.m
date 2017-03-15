//
//  MembershipCityViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 24.10.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import "MembershipCityViewController.h"
#import <Parse/Parse.h>
#import "CheckoutViewController.h"
#import "SCLAlertView.h"
#import "MyLogInViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "Branch.h"
#import <Bolts/Bolts.h>
#import "MBProgressHUD.h"




@interface MembershipCityViewController ()

@property (strong) NSArray * cityArray;
@property (strong) NSMutableArray * cityArray_2;

@property (strong) NSString * parseClassName;
@property (strong) NSString * cityName;
@property (strong) NSString * cityId;
@property (strong) PFObject * city;
@property (strong) NSString * regionType;
//@property (strong) BOOL  shouldClose;
@property (nonatomic, assign) BOOL shouldClose;
@property (nonatomic, strong) NSString *stadt;
@property (nonatomic, strong) MBProgressHUD *hud;




@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedLocation;




@end

@implementation MembershipCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"Wird geladen", @"Wird geladen...");
    [self.hud show:YES];

    
    if ([_productType isEqualToString:@"dayTicket"]) {
        self.title = @"3-Tagesticket";
    }
    
    else{
        self.title = @"Premiumpass";

    }

    
    PFQuery *query = [PFQuery queryWithClassName:@"Cities"];
    [query orderByAscending:@"name"];
    
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        _anzahl = objects.count;
      //  self.cityArray = [[NSArray alloc] initWithArray:objects];
        self.cityArray_2 = [[NSMutableArray alloc] initWithArray:objects];
        
        [self.cityTableView reloadData];
        
        _regionType = @"Cities";
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];


    }];
    
    
    
    //  [self.cityTableView reloadData];
    [_cityTableView setDelegate:self];
    [_cityTableView setDataSource:self];
    
    NSLog(@"set to no");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    
    if (_shouldClose) {
        NSLog(@"schließen");
        [self performSegueWithIdentifier:@"backToProducts" sender:self];
        //  [self dismissViewControllerAnimated:YES completion:nil];
        
    }
}
/*
 - (PFQuery *)queryForTable {
 PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
 
 // If no objects are loaded in memory, we look to the cache first to fill the table
 // and then subsequently do a query against the network.
 if ([self.cityArray count] == 0) {
 query.cachePolicy = kPFCachePolicyCacheThenNetwork;
 }
 
 [query orderByAscending:@"name"];
 
 return query;
 }
 
 -(void) retrieveFromParse {
 [[self queryForTable] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
 if(!error) {
 self.cityArray = [[NSArray alloc] initWithArray:objects];
 NSLog(@"anzahl %li",(unsigned long)_cityArray.count );
 [self.cityTableView reloadData];
 }
 }];
 }
 
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return _cityArray_2.count;
    //else return _preisArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    //  cell.textLabel.text = [object objectForKey:@"name"];
    //indexPath.row;
    // HighScore * highScore = [self.highScoresArray objectAtIndex:indexPath.row];
    
    PFObject *city = [self.cityArray_2 objectAtIndex:indexPath.row];
    // cell.textLabel.text = [object o]
    cell.textLabel.text = [city objectForKey:@"name"];
    // cell.textLabel.text = @"test";
    
    
    if ([_productType isEqualToString:@"dayTicket"]) {
        NSString *priceString = [NSString stringWithFormat:@"%@ €",[city objectForKey:@"dayPrice_3"] ];
        cell.detailTextLabel.text = priceString;
    }
    
    else{
        NSString *priceString = [NSString stringWithFormat:@"%@ €",[city objectForKey:@"membershipPrice_3"] ];
        cell.detailTextLabel.text = priceString;
    }

    
    //  UIColor* bgColor = [UIColor blackColor];
    UIColor* bgColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    
    //  [cell setBackgroundColor:bgColor];
    cell.contentView.backgroundColor = bgColor;
    
    
    
    
    /*
     PFFile *thumbnail = [object objectForKey:@"thumbnail"];
     cell.imageView.image = [UIImage imageNamed:@"placeholder.jpg"];
     cell.imageView.file = thumbnail;
     */
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PFObject *city = [self.cityArray_2 objectAtIndex:indexPath.row];
    
    
    self.cityName = [city objectForKey:@"name"];
    self.cityId = city.objectId;
    self.city = city;

    
    if ([PFUser currentUser]) {
        [self performSegueWithIdentifier:@"checkout" sender:self];
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
        
        if ([_productType isEqualToString:@"dayTicket"]) {
        [alert showInfo:self title:@"Nicht angemeldet" subTitle:@"Du musst eingeloggt sein um dir ein 3-Tagesticket zu kaufen" closeButtonTitle:@"Nicht Jetzt" duration:0.0f];        }
        
        else{
        [alert showInfo:self title:@"Nicht angemeldet" subTitle:@"Du musst eingeloggt sein um dir eine Premiummitgliedschaft zu kaufen" closeButtonTitle:@"Nicht Jetzt" duration:0.0f];
        }
        

        
    }


    
    
    
    
    
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"checkout"])
    {
        NSLog(@"checkout");
        
    //    UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
   //     CheckoutViewController *checkoutController = [navController topViewController];
        
    CheckoutViewController *checkoutController = (CheckoutViewController *)[[segue destinationViewController] topViewController];
        

        
        
        
         checkoutController.region = _city;
        /*
        switch (_segmentedLocation.selectedSegmentIndex) {
            case 0:
            {
                //stadt
                checkoutController.regionType = _regionType;

            } break;
            case 1:{
                //Bundesland
                checkoutController.regionType = _regionType;

                
            } break;
            case 2:{
                //land
                checkoutController.regionType = _regionType;

                
            } break;
            default:{
                checkoutController.regionType = _regionType;

                
            } break;
        };
        */
        
        
        //pass the type of the region (city,state, country)
        checkoutController.regionType = _regionType;

        
         checkoutController.amount = 1;
        
        
        //if it is a dayTicket pass the startdate and the productType to dayTicket
        
        if ([_productType isEqualToString:@"dayTicket"]) {
            
            checkoutController.productType = @"dayTicket";
            checkoutController.startDate = _startDate;

        }
        else{
            checkoutController.productType = @"membership";

        }
        
        
        _shouldClose = YES;

        
        
        
        
        
        
        
    }
    
}
- (IBAction)changeLocation:(id)sender {
    
  //  [self.cityTableView reloadData];
    [self.hud show:YES];

    switch (_segmentedLocation.selectedSegmentIndex) {
        case 0:
        {
            _regionType = @"Cities";
            
            PFQuery *query = [PFQuery queryWithClassName:@"Cities"];
            [query orderByAscending:@"name"];
            
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                _anzahl = objects.count;
              //  self.cityArray = [[NSArray alloc] initWithArray:objects];
                self.cityArray_2 = [[NSMutableArray alloc] initWithArray:objects];

                
                [self.cityTableView reloadData];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

            }];
            
            
            
            //  [self.cityTableView reloadData];
            [_cityTableView setDelegate:self];
            [_cityTableView setDataSource:self];
            
        } break;
        case 1:{
            _regionType = @"State";

            PFQuery *query = [PFQuery queryWithClassName:@"State"];
            [query orderByAscending:@"name"];
            
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                _anzahl = objects.count;
                //  self.cityArray = [[NSArray alloc] initWithArray:objects];
                self.cityArray_2 = [[NSMutableArray alloc] initWithArray:objects];
                
                [self.cityTableView reloadData];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

            }];
            
            
            
            //  [self.cityTableView reloadData];
            [_cityTableView setDelegate:self];
            [_cityTableView setDataSource:self];
            
            
        } break;
        case 2:{
            
            _regionType = @"Country";

            PFQuery *query = [PFQuery queryWithClassName:@"Country"];
            [query orderByAscending:@"name"];
            
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                _anzahl = objects.count;
                //  self.cityArray = [[NSArray alloc] initWithArray:objects];
                self.cityArray_2 = [[NSMutableArray alloc] initWithArray:objects];
                
                [self.cityTableView reloadData];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

            }];
            
            
            
            //  [self.cityTableView reloadData];
            [_cityTableView setDelegate:self];
            [_cityTableView setDataSource:self];
            
            
        } break;
        default:{
            
            _regionType = @"Cities";

            PFQuery *query = [PFQuery queryWithClassName:@"Cities"];
            [query orderByAscending:@"name"];
            
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                _anzahl = objects.count;
                //  self.cityArray = [[NSArray alloc] initWithArray:objects];
                self.cityArray_2 = [[NSMutableArray alloc] initWithArray:objects];
                
                [self.cityTableView reloadData];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

            }];
            
            
            
            //  [self.cityTableView reloadData];
            [_cityTableView setDelegate:self];
            [_cityTableView setDataSource:self];
            
            
        } break;
    };

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
                                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

                                
                                
                            }
                        }];
                        
                    }
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

                    
                    [self performSegueWithIdentifier:@"checkout" sender:self];

                    
                }
                else {
                    NSLog(@"ging nicht!!!\nError occured: %@", error);
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

                    
                }
            }
             ];

            
            
            
        }
    }];
}

//load city
-(void) loadData{
    
    //stadt = city
    self.stadt = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/stadt", NSHomeDirectory()] encoding:NSUTF8StringEncoding error:nil];
    
    
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


@end
