//
//  EventDetailViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 15.10.13.
//  Copyright (c) 2013 Werner. All rights reserved.
//

#import "EventDetailViewController.h"
#import "ClubDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AddressBook/AddressBook.h>
#import "GeoPointAnnotation.h"
#import "GeoPointAnnotation2.h"

//#import "FlyerViewController.h"
#import "EventKitController.h"
#import "RouteCell.h"
#import "MapCell.h"
#import "FbSegmentCell.h"
#import "EventInfoCell.h"
#import "BannerCell.h"
#import "JLCalendarPermission.h"
//#import "SettingsViewController.h"
#import "RMPickerViewController.h"
#import <SCLAlertView.h>
#import "CheckoutViewController.h"


#import "UIImage+ImageEffects.h"

#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

#import <CoreLocation/CoreLocation.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import <Bolts/Bolts.h>
#import "TicketPopOverView.h"
#import "MyLogInViewController.h"
#import "Branch.h"
#import "BranchUniversalObject.h"
#import "BranchLinkProperties.h"
#import "MBProgressHUD.h"




typedef enum SocialButtonTags
{
    SocialButtonTagFacebook,
    SocialButtonTagSinaWeibo,
    SocialButtonTagTwitter
} SocialButtonTags;

//,RMPickerViewControllerDelegate
@interface EventDetailViewController ()<UIActionSheetDelegate,CLLocationManagerDelegate ,RMPickerViewControllerDelegate,TicketPopOverViewDelegate>{
    EventKitController *_eventKitController;
    GeoPointAnnotation *_selectedStation;
  //  TicketPopOverView *_popoverView;
    


    
}

@property (nonatomic, strong) NSMutableArray *data;
@property (strong, nonatomic) NSMutableDictionary *postParams;
@property (nonatomic, assign) NSInteger ticketType;
@property (nonatomic, assign) NSInteger amount;
@property (nonatomic, strong) NSString *imageUrlString;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, assign) NSInteger ticketOption;







@end

@implementation EventDetailViewController{
    BOOL _textExpanded;
    CGRect _defaultFrame;
    CGFloat _textHeight;
    CGFloat _origHeight;
    CLLocationManager *locationManager;



}

/*
- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
    }
    return self;
}
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   // _eventKitController = [[EventKitController alloc] init];
    
    //load hud
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"Wird geladen", @"Wird geladen...");
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                              target:self action:@selector(moreTapped:)];
    

    
    
    // ask for ios8 location permissions
    
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        
        if (status == kCLAuthorizationStatusDenied) {
            NSString *title;
            title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
            NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Settings", nil];
            alertView.tag = 1;
            [alertView show];
        }
        // [_locationManager requestWhenInUseAuthorization];
        
        else if (status == kCLAuthorizationStatusNotDetermined) {
            [locationManager requestWhenInUseAuthorization];
        }
    }

    
    
    if (_thumbnail==nil) {
        NSLog(@"------ es wurde kein bild geladen");
        //Bild anzeigen
        
    }
    else {
        
    NSLog(@"------ thumbnail wurde geladen");
    
    
    }
    
    //get branch links for sharing
    
    NSString *identifier = [NSString stringWithFormat:@"event/%@",_event.objectId];
    BranchUniversalObject *branchUniversalObject = [[BranchUniversalObject alloc] initWithCanonicalIdentifier:identifier];
    // Facebook OG tags -- this will overwrite any defaults you set up on the Branch Dashboard
    branchUniversalObject.title = [_event objectForKey:@"name"];
    branchUniversalObject.contentDescription = [_event objectForKey:@"description"];
    
    //userinfo anhängen
    // [branchUniversalObject addMetadataKey:@"property1" value:@"blue"];
    //  [branchUniversalObject addMetadataKey:@"property2" value:@"red"];
    
    // Add any additional custom OG tags here
    [branchUniversalObject addMetadataKey:@"$og_title" value:[_event objectForKey:@"name"]];
    [branchUniversalObject addMetadataKey:@"$og_description" value:[_event objectForKey:@"description"]];
    
    
    BranchLinkProperties *linkProperties = [[BranchLinkProperties alloc] init];
    linkProperties.feature = @"event_share";
    //   linkProperties.channel = @"facebook";
    //  [linkProperties addControlParam:@"$ios_deepview" withValue:@"default_template"];
    //  [linkProperties addControlParam:@"$android_deepview" withValue:@"default_template"];
    NSLog(@"event: %@", _event);
    
 
    // if imageURl is not available, get the link from parse
    
    if ([_imageUrlString isEqualToString:@""] ||!_imageUrlString) {
        
        NSLog(@"-------- Bild Url noch nicht gespeichert");
        PFFile *applicantResume = [_event objectForKey:@"pic_big"];
        // NSData *resumeData = [applicantResume getData];
        _imageUrlString = applicantResume.url;
        [branchUniversalObject addMetadataKey:@"$og_image_url" value:_imageUrlString];
        
        
        
        
        branchUniversalObject.imageUrl = _imageUrlString;
        
        
        [branchUniversalObject registerView];
        
        [branchUniversalObject getShortUrlWithLinkProperties:linkProperties andCallback:^(NSString *url, NSError *error) {
            if (!error) {
                NSLog(@"success getting url! %@", url);
                self.postParams = [@{
                                     @"link" : url,
                                     @"picture" : _imageUrlString,
                                     @"name" : [_event objectForKey:@"name"],
                                     @"caption" : @"Auf NightGuider - Dein Guide für alle Partys immer und überall.",
                                     @"description" : [_event objectForKey:@"description"]
                                     } mutableCopy];
            }
        }];

        
        
    }
    else{
        branchUniversalObject.imageUrl = _imageUrlString;
        [branchUniversalObject addMetadataKey:@"$og_image_url" value:_imageUrlString];
        
        [branchUniversalObject registerView];

        
        [branchUniversalObject getShortUrlWithLinkProperties:linkProperties andCallback:^(NSString *url, NSError *error) {
            if (!error) {
                NSLog(@"success getting url! %@", url);
                
                NSLog(@"imageurl %@ name %@", _imageUrlString, [_event objectForKey:@"name"]);

                self.postParams = [@{
                                     @"link" : url,
                                     @"picture" : _imageUrlString,
                                     @"name" : [_event objectForKey:@"name"],
                                     @"caption" : @"Auf NightGuider - Dein Guide für alle Partys immer und überall.",
                                     @"description" : [_event objectForKey:@"description"]
                                     } mutableCopy];
                
                NSLog(@"branch erfolgreich");
            }
        }];
        
        
    }
    

    
    NSLog(@"geo abfrage");

    
    
    _textExpanded = NO;
   // [_eventTableView setDelegate:self];
  //  [_eventTableView setDataSource:self];
    
    _geoPoint =[_event objectForKey:@"location"];
    _street = [_event objectForKey:@"street"];
    
    //get the distance from the event
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            // do something with the new geoPoint
            // _distance = [geoPoint distanceInKilometersTo:[_club objectForKey:@"location"]];
            _distance = [geoPoint distanceInKilometersTo:_geoPoint];
            
            NSLog(@"d: %lf",_distance);
            
        }
        else{
            NSLog(@"geopoint error: %@",error);
            
        }

    }];
    
    
    //get the distance from the host
    // also retrieve the adress from host

    if (_club == nil && [_event objectForKey:@"host"] != nil ) {
        NSLog(@"club noch nicht vorhanden");
        
           NSString *city = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/stadt", NSHomeDirectory()] encoding:NSUTF8StringEncoding error:nil];
        NSString *cityClubs = @"Clubs";

        PFQuery *query = [PFQuery queryWithClassName:cityClubs];
        
        [query whereKey:@"city_pick" equalTo:city];
        
        [query whereKey:@"name" equalTo:[_event objectForKey:@"host"] ];
        
        
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (!object) {
                NSLog(@"The getFirstObject request failed.");
            } else {
                // The find succeeded.
                _club = object;
                _street = [_club objectForKey:@"street"];
                _clubName = [_club objectForKey:@"name"];
                _geoPoint =[_club objectForKey:@"location"];
                
                [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
                    if (!error) {
                        // do something with the new geoPoint
                       // _distance = [geoPoint distanceInKilometersTo:[_club objectForKey:@"location"]];
                        _distance = [geoPoint distanceInKilometersTo:_geoPoint];

                        NSLog(@"d: %lf",_distance);
                        [self.tableView reloadData];

                        
                    }
                    else{
                        NSLog(@"error: %@",error);
                        [self.tableView reloadData];

                    }
                }];
                
                }
        }];
    }
    

    
    
    
    //remove the seperatorlines below the results

    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footerView;
    self.tableView.separatorColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@" " style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    



}




-(void)viewWillAppear:(BOOL)animated{

    NSString *ID = _event.objectId;
    
    NSLog(@"viewwillappear");

    
    //check if Event is markes as favorite
    
    
    self.data =[NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/data", NSHomeDirectory()]];
    
    for (int i = 0; i<[self.data count]; i++) {
        if ([[self.data objectAtIndex:i] isEqualToString: ID]) {
            
            //already favorite
            
            NSLog(@"Schon vorhanden");
            [_favBtn setImage:[UIImage imageNamed:@"favoritesSelected" ] forState:UIControlStateNormal];
            
            
            /*
            _favBtn.layer.borderColor = [[UIColor whiteColor] CGColor];
            _favBtn.layer.cornerRadius = 4.0f;
            _favBtn.layer.backgroundColor =[[UIColor whiteColor] CGColor];
            _favBtn.layer.borderWidth = 1.0f;
            [_favBtn setTitle:@"Favorit" forState:UIControlStateNormal];
            [_favBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            */
            
            
            if (_favorite == NO) {
                
                // if event wasn`t favorite, now it is.
                // Reload the table and mark the Event as favorite
                
                _favorite = YES;
                NSArray *indexPathArray = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]];
                
              //  [_eventTableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
                
                [self.tableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];

            }
            
            return;
            
        }
    }
    
    NSLog(@"viewwillappear for schleife durch");

    
    [_favBtn setImage:[UIImage imageNamed:@"favorites" ] forState:UIControlStateNormal];


    if (_favorite == YES) {
        
        
        // Event is not favorite anymore
        // Reload the table
        _favorite = NO;
        NSArray *indexPathArray = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        //[_eventTableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
        
        [self.tableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
        
    }
    
    
    NSLog(@"Nicht mehr favorit");
    self.navigationController.navigationBar.alpha = 1.0;

    return;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return 7;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
        if (indexPath.row == 0) {
            static NSString *CellIdentifier = @"bannerCell2";
            // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            BannerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

            
            //Load Picture
            
            PFFile *applicantResume = [_event objectForKey:@"pic_big"];
            // NSData *resumeData = [applicantResume getData];
            _imgURL = [NSURL URLWithString:[applicantResume.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

            _imageUrlString = applicantResume.url;

            [applicantResume getDataInBackgroundWithBlock:^(NSData *resumeData, NSError *error) {
                if (!error) {
                    // The find succeeded.
                    NSLog(@"Bild empfangen!");
                    //self.imageView.image = [UIImage imageWithData:resumeData];
                    
                    
                    _bigPic = [UIImage imageWithData:resumeData];
                    
                    cell.flyerImageView.image = _bigPic;
                    
                    
                    cell.flyerImageView.layer.cornerRadius = 43.0f;
                    cell.flyerImageView.layer.borderWidth = 1.5f;
                    cell.flyerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
                    cell.flyerImageView.clipsToBounds = YES;
                    
                    
                        UIColor *tintColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.5f];
                        
                        UIImage *backgroundImage = [_bigPic applyBlurWithRadius:5 tintColor:tintColor saturationDeltaFactor:0.6 maskImage:nil];
                        
                        UIImageView *imageView2 = [[UIImageView alloc] initWithImage:backgroundImage];
                        imageView2.contentMode = UIViewContentModeScaleAspectFill;
                        imageView2.clipsToBounds = YES;
                        imageView2.alpha = 0.8f;
                        //  self.BannerView = imageView2;
                        cell.bannerImageView.image = backgroundImage;
                        cell.bannerImageView.alpha= 0.8f;
                        cell.bannerImageView.clipsToBounds = YES;
                        cell.bannerImageView.contentMode =UIViewContentModeScaleAspectFill;
                        
                
                    
                    
                } else {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }
             ];
            

            cell.favBtn.selected = _favorite;

            [cell.reminderBtn addTarget:self action:@selector(addEventToCalender) forControlEvents:UIControlEventTouchUpInside];
            [cell.favBtn addTarget:self action:@selector(addFavTapped:) forControlEvents:UIControlEventTouchUpInside];

            
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateStyle = NSDateFormatterNoStyle;
            df.timeStyle = NSDateFormatterShortStyle;
            df.timeZone = [NSTimeZone localTimeZone];
            NSString *zeit = [df stringFromDate:[_event objectForKey:@"start_time"]];
            NSString *ende = [df stringFromDate:[_event objectForKey:@"end_time"]];
            NSString *string = [NSString stringWithFormat:@"%@ - %@", zeit, ende];
            cell.timeLabel.text = string;
            
            
            NSDateFormatter *dfd = [[NSDateFormatter alloc] init];
            dfd.dateStyle = NSDateFormatterLongStyle;
            dfd.timeStyle = NSDateFormatterNoStyle;
            dfd.timeZone = [NSTimeZone localTimeZone];
            NSString *datum = [dfd stringFromDate:[_event objectForKey:@"start_time"]];
            cell.dateLabel.text = datum;
            
            cell.hostLabel.text = [_event objectForKey:@"host"];
#pragma hostlabel zu button
         //   cell.hostButton.titleLabel.text = [_event objectForKey:@"host"];
          //  cell.hostButton.titleLabel.text = @"Testclub";
            [cell.hostButton setTitle:[_event objectForKey:@"host"] forState:UIControlStateNormal];



            [cell.hostButton sizeToFit];
 
            [cell.hostButton addTarget:self action:@selector(locationButtonTapped) forControlEvents:UIControlEventTouchUpInside];


            
            
            return cell;
        }
        
    else if (indexPath.row == 1) {
        static NSString *CellIdentifier = @"segmentCell";
        FbSegmentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        
        [cell.fbSegment setSelectedSegmentIndex:UISegmentedControlNoSegment];
        
        /*
        [FBSDKAccessToken refreshCurrentAccessToken:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            NSDictionary *resultDictionary = (NSDictionary *) result;
            NSArray *permissionsArray= [resultDictionary objectForKey:@"data"];
            NSMutableSet *permissionsSet = [NSMutableSet new];
            
            for (NSDictionary *permissionDic in permissionsArray) {
                if ([[permissionDic objectForKey:@"status"] caseInsensitiveCompare:@"granted"] == NSOrderedSame) {
                    [permissionsSet addObject:[permissionDic objectForKey:@"permission"]];
                }
            }
        }];
        */
        NSDictionary *eventParameters= @{@"fields": @"data"};

        
        // get current events accesstoken to see if user is attending the event
        
 if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"user_events"] ) {
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/events" parameters:eventParameters]
             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 if (!error) {
                     NSArray* data = [result objectForKey:@"data"];

                     //permission granted
                     
                     //check all events from the user
                     for (int j = 0; j < [data count]; j++) {
                         
                         NSString* fbId = [((NSDictionary*) data[j]) objectForKey:@"id"];

                         NSNumber *eidNumber =[_event objectForKey:@"eid"];
                         NSString *eid = [NSString stringWithFormat:@"%@",eidNumber];
                     //    NSString *eidString =[[_event objectForKey:@"eid"] stringValue];



                         //looking for the current event

                         if ( [fbId isEqualToString:eid]) {
                             NSLog(@"passendes event gefunden");

                             NSString *status = [((NSDictionary*) data[j]) objectForKey:@"rsvp_status"];
                             
                             if ( [status isEqualToString:@"unsure"]) {
                                 NSLog(@"1");
                                 cell.fbSegment.selectedSegmentIndex = 1;

                             }
                             else if ([status isEqualToString:@"attending"]) {
                                 NSLog(@"2");

                                 cell.fbSegment.selectedSegmentIndex = 0;

                             }
                             else if([status isEqualToString:@"declining"]){
                                 NSLog(@"3");

                                 cell.fbSegment.selectedSegmentIndex = 2;

                             }
                         }

                         
                     }

                 }
                 else{
                     NSLog(@"error fetching user event: %@", [error localizedDescription]);
                 }
             }];
            
        }
 else{
     NSLog(@"user_events nicht erlaubt");
     
     //premission not granted
     
     [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me/permissions"
                                        parameters:nil
                                        HTTPMethod:@"GET"]
      startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
          if (!error) {
              NSLog(@"Permissions:\n%@",result);

          }
          else NSLog(@"error bei permissions anzeigen : %@", [error localizedDescription]);
      }];

     /*
     FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
     [loginManager logInWithReadPermissions:@[@"user_events"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         if ([result.declinedPermissions containsObject:@"user_events"]) {
             // TODO: do not request permissions again immediately. Consider providing a NUX
             // describing  why the app want this permission.
             NSLog(@"User hat schon wieder events abgelehnt");
         } else {
             // ...
             NSLog(@"sonstiges bei frage");

         }
     }];
      */
     
 }
     
        

        
        [cell.fbSegment addTarget: self action: @selector(segmentedControlDidChange:) forControlEvents: UIControlEventValueChanged];


        switch (cell.fbSegment.selectedSegmentIndex) {
            case 0:
                NSLog(@"Teilnehmen ausgewählt");
                break;
            case 1:
                NSLog(@"Vielleicht ausgewählt");

                break;
            case 2:
                NSLog(@"Ablehnen ausgewählt");

                break;
                
            default:
                break;
        }
        
        return cell;

    }
    else if (indexPath.row == 2){
        static NSString *CellIdentifier = @"winCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        //look if winning a ticket is available
        //future option not necessary
        
        
        if ([[_event objectForKey:@"winTicket"]intValue] > 1) {

            NSString * labelString = [NSString stringWithFormat:@"Gewinne %i Tickets", [[_event objectForKey:@"winTicket"]intValue]];
            cell.textLabel.text = labelString;
            
        }
        else if ([[_event objectForKey:@"winTicket"]intValue] == 1) {
            
            NSString * labelString = [NSString stringWithFormat:@"Gewinne 1 Ticket"];
            cell.textLabel.text = labelString;
            
        }
        else if ([[_event objectForKey:@"winGuestlist"]intValue] > 1) {
            
            NSString * labelString = [NSString stringWithFormat:@"Gewinne %i Gästelistenplätze", [[_event objectForKey:@"winGuestlist"]intValue]];
;
            cell.textLabel.text = labelString;
            
        }
        else if ([[_event objectForKey:@"winGuestlist"]intValue] == 1) {
            
            NSString * labelString = [NSString stringWithFormat:@"Gewinne 1 Gästelistenplatz"];
            cell.textLabel.text = labelString;
            
        }
        
        else if ([[_event objectForKey:@"winGuestlist"]intValue] > 0 && [[_event objectForKey:@"winTicket"]intValue] > 1){
            NSString * labelString = [NSString stringWithFormat:@"Gewinne %i Kombitickets", [[_event objectForKey:@"winTicket"]intValue]];
;
            cell.textLabel.text = labelString;
            
        }
        
        else if ([[_event objectForKey:@"winGuestlist"]intValue] > 0 && [[_event objectForKey:@"winTicket"]intValue] > 1){
            NSString * labelString = [NSString stringWithFormat:@"Gewinne 1 Kombiticket"];
            ;
            cell.textLabel.text = labelString;
            
        }
        
        else {
            cell.textLabel.text = @"Teilnahme der Verlosung abgeschlossen";
            cell.backgroundColor = [UIColor clearColor];

        }
        
        return cell;
        
    }
    else if (indexPath.row == 3){
        [self.hud show:YES];


        static NSString *CellIdentifier = @"buyCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        NSDate *today = [NSDate date];

        
        //look which tickettype is available
        
        
        if ([[_event objectForKey:@"ticketAmount"]intValue] > 0 && [[_event objectForKey:@"guestlistAmount"]intValue] < 1 && [_event objectForKey:@"ticket_endTime"] > today) {
            
            //buy tickets
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            _ticketOption = 1;

            cell.textLabel.text = @"Tickets kaufen";

            
        }
        
        else if ([[_event objectForKey:@"guestlistAmount"]intValue] > 0 && [[_event objectForKey:@"ticketAmount"]intValue] < 1 && [_event objectForKey:@"guestlist_endTime"] > today){
            
            //buy guestlist
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            _ticketOption = 2;

            cell.textLabel.text = @"Gästelistenplätze kaufen";

        }
        
        else if ([[_event objectForKey:@"ticketAmount"]intValue] > 0 && [[_event objectForKey:@"guestlistAmount"]intValue] > 0 && [_event objectForKey:@"guestlist_endTime"] > today && [_event objectForKey:@"ticket_endTime"] > today){
            
            //buy tickets/guestlist
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            _ticketOption = 3;

            cell.textLabel.text = @"Tickets/Gästelistenplätze kaufen";

        }else{
            //no tickets available
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            _ticketOption = 0;

            NSLog(@"Keine Tickets verfügbar");
            cell.backgroundColor = [UIColor clearColor];

        }

        
        return cell;
        
    }
    else if (indexPath.row == 4){
        static NSString *CellIdentifier = @"infoCell";
        EventInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        
        NSString *entrance = [_event objectForKey:@"entrancePrice"];
        
        if ( [entrance length]  == 0 ) {
            
            cell.priceBtn.hidden = YES;
            
        }
        else [cell.priceBtn setTitle:entrance forState:UIControlStateNormal];
        

        //load description of the event
        
        cell.descriptionTextView.text =[_event objectForKey:@"description"];
        [cell.descriptionTextView sizeToFit];
        [cell.descriptionTextView layoutIfNeeded];
        
        CGSize size = [cell.descriptionTextView sizeThatFits:CGSizeMake(cell.descriptionTextView.frame.size.width, FLT_MAX)];
        
        // if the textview size is bigger then the contentsize, set textheight to the current textview size
        if (size.height >_textHeight) {
            _textHeight = size.height;
        }

        cell.descriptionTextView.scrollEnabled = NO;
        

        
        
        if(_textExpanded == YES){
            [cell.extendBtn setTitle:@"... " forState:UIControlStateNormal];

        }
        else{
            [cell.extendBtn setTitle:@"... " forState:UIControlStateNormal];

        }

        
        

        [cell.extendBtn addTarget:self action:@selector(expandButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        

        return cell;

    }
    else if (indexPath.row == 5) {
        static NSString *CellIdentifier = @"mapCell";
        MapCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        //show map
        
        cell.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(_geoPoint.latitude, _geoPoint.longitude), MKCoordinateSpanMake(0.01f, 0.01f));
        
        // add the annotation
        GeoPointAnnotation2 *annotation = [[GeoPointAnnotation2 alloc] initWithObject:_club];
        [cell.mapView addAnnotation:annotation];


        return cell;

    }
    else if (indexPath.row == 6){
        static NSString *CellIdentifier = @"streetCell";
        RouteCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        //show the distance
        NSLog(@"Distanz: %lf straße: %@",_distance,_street);
        
        if (_distance==0) {
            cell.distanceLabel.hidden = YES;
        }
        else{
            cell.distanceLabel.hidden = NO;
            cell.distanceLabel.text = [NSString stringWithFormat:@"Distanz: %.2f km", _distance];
        }

        if (_street==nil) {
            cell.streetLabel.hidden = YES;
        }
        else{
            cell.streetLabel.hidden = NO;
            cell.streetLabel.text = _street;
        }

       // cell.streetLabel.text = [_club objectForKey:@"street"];
       // NSLog(@"straße: %@",[_event objectForKey:@"street"]);
      //  cell.distanceLabel.text = @"Distanz: 5km";
        
       // [cell.routeBtn performSelector:@selector(login) withObject:nil afterDelay:1];
        
        if (_club == nil) {
            cell.routeBtn.hidden = YES;
        }
        else{
            cell.routeBtn.hidden = NO;
        	[cell.routeBtn addTarget:self action:@selector(routeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        }


        return cell;

    }

    static NSString *CellIdentifier = @"default";
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    return cell;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // [super tableView:tableView didSelectRowAtIndexPath:indexPath];

    
    switch (indexPath.row) {
        case 2:{
            NSLog(@"win tickets pressed");
        }
            break;
        case 3:{
            NSLog(@"buy ticket");
            [self buyButtonTapped];
        }
            break;
        default:{
            
        }
            break;
    }
    


}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
   // return (indexPath.row % 2) ? 125 : 251;
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    CGFloat screenWidth = screenSize.width;
    CGFloat screenHeigth = screenSize.height;
    

    switch (indexPath.row) {
        case 0:
            return 112;
            break;
            
        case 1:
            return 51;
            break;

        case 2:{
            // if winning tickets are not available hide the cell
            
            if([[_event objectForKey:@"winTicket"]intValue] > 0|| [[_event objectForKey:@"winGuestlist"]intValue] > 0){
                return 51;
            }
            else
                return 0;
        }
            break;
            

        case 3:{
            
            // if tickets are not available hide the cell

            if([[_event objectForKey:@"ticketAmount"]intValue] > 0 || [[_event objectForKey:@"guestlistAmount"]intValue] > 0){
                return 51;
            }
            else
                return 0;
        }
            break;
            
            
        case 4:{
#pragma expanding cell
            //return 170;
            //50+textview 250
            /*
            NSLog(@"%i",_textExpanded);
            DLog(@"text height %f", _textHeight);
            NSLog(@"größe: %f",_textExpanded ? (_textHeight+50) : (screenHeigth-288-64-49));
             */
           // return _textExpanded ? (50+_textHeight) : 170.0f;
           // return _textExpanded ? (50+_textHeight) : (screenHeigth-288-64-49);

            //resize the view if textExpanded Button is pressed
            //check orientation of the device for the correct height of the textview
            
            if (screenHeigth-288-64-49 < 0) {
                return _textExpanded ? (_textHeight+50) : (screenWidth-288-64-49);
            }
            else{
                return _textExpanded ? (_textHeight+50) : (screenHeigth-288-64-49);
            }

            break;
        }
            
        case 5:
            return 80;
            break;
            
        case 6:
            return 45;
            break;
            
        default:
            break;
    }
    
    NSLog(@"wird ausgführt");
    return 45;
    
    

    
    
}






-(void)segmentedControlDidChange:(UISegmentedControl *)sender {
    
    NSLog(@"segment changed");
    
    //check if the user is logged in wih facebook

    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]] ) {

        
        //check if permission for rsvp an event is granted
        
    
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"] && [[FBSDKAccessToken currentAccessToken] hasGranted:@"rsvp_event"] ) {
        // TODO: publish content.
        switch (sender.selectedSegmentIndex) {
            case 0:
                [self attendEvent];
                break;
            case 1:
                [self maybeEvent];
                break;
            case 2:
                [self declineEvent];
                break;
                
            default:
                break;
        }
        
    }
        else {
            
            //get publish permissions to rsvp in behalf
            
            
            [PFFacebookUtils logInInBackgroundWithPublishPermissions:@[ @"publish_actions" , @"rsvp_event"] block:^(PFUser *user, NSError *error) {
                if (!user) {
                    NSLog(@"Uh oh. The user cancelled the Facebook login.");
                } else {
                    NSLog(@"User now has publish permissions!");
                    switch (sender.selectedSegmentIndex) {
                        case 0:
                        [self attendEvent];
                        break;
                        case 1:
                        [self maybeEvent];
                        break;
                        case 2:
                        [self declineEvent];
                        break;
                        
                        default:
                        break;
                    }
                }
            }];
            }
}
    
    else if (![PFUser currentUser]){
        
        //User is not logged in show alert
        
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        //Hide animation type (Default is FadeOut)
        alert.hideAnimationType = SlideOutToTop;
        
        //Show animation type (Default is SlideInFromTop)
        alert.showAnimationType = SlideInFromTop;
        
        //Set background type (Default is Shadow)
        alert.backgroundType = Blur;
        
        [alert alertIsDismissed:^{
          //  sender.selectedSegmentIndex = UISegmentedControlNoSegment;
            [sender setSelectedSegmentIndex:UISegmentedControlNoSegment];
            
        }];
        
        [alert addButton:@"Anmelden" actionBlock:^{
            
            //if pressed show the loginview with permissions
            
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
            
            
        }];
        
        
        [alert showWarning:self title:@"Nicht eingeloggt" subTitle:@"Du musst mit Facebook eingeloggt sein, um an diesem Event über Facebook teilzunehmen" closeButtonTitle:@"Nicht jetzt" duration:0.0f];

    }
    
    else if([PFUser currentUser] && ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]] ){
        
        //User is logged in but not with facebook

        
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        //Hide animation type (Default is FadeOut)
        alert.hideAnimationType = SlideOutToTop;
        
        //Show animation type (Default is SlideInFromTop)
        alert.showAnimationType = SlideInFromTop;
        
        //Set background type (Default is Shadow)
        alert.backgroundType = Blur;
        
        [alert alertIsDismissed:^{
        }];
        
        [alert addButton:@"ok" actionBlock:^{
            
            //try to connect with facebook
            
            NSArray *permissionsArray = @[@"email",@"user_birthday",@"user_location", @"user_events",@"user_relationships"];
            
                [PFFacebookUtils linkUserInBackground:[PFUser currentUser] withReadPermissions:permissionsArray block:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"Woohoo, user is linked with Facebook!");
                        [self getUserData];
                        switch (sender.selectedSegmentIndex) {
                            case 0:
                            [self attendEvent];
                            break;
                            case 1:
                            [self maybeEvent];
                            break;
                            case 2:
                            [self declineEvent];
                            break;
                            
                            default:
                            break;
                        }
                        
                    }
                }];
            
        }];


        
        
        [alert showWarning:self title:@"Nicht mit Facebook verbunden" subTitle:@"Du musst dich in deinem Profil mit Facebok verbinden" closeButtonTitle:@"Nicht jetzt" duration:0.0f];
        
    }
};



-(void)attendEvent{
    NSLog(@"Teilnehmen ausgewählt");
    
    NSString *graphPath = [NSString stringWithFormat:@"%@/attending",[_event objectForKey:@"eid"]];
    
    
    [[[FBSDKGraphRequest alloc]
      initWithGraphPath:graphPath
      parameters: nil
      HTTPMethod:@"POST"]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             
             if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shareEvent"])
                {
                    NSString *message = [NSString stringWithFormat:@"Ich gehe zu %@\nWer hat Lust mitzukommen?",[_event objectForKey:@"name"]];
                    self.postParams[@"message"] = message;
                    [self publishStory];
                }
         
         }
     }];


}

-(IBAction)moreTapped:(id)sender{
    
    
    // share event
    
    NSString *identifier = [NSString stringWithFormat:@"event/%@",_event.objectId];
    BranchUniversalObject *branchUniversalObject = [[BranchUniversalObject alloc] initWithCanonicalIdentifier:identifier];
    // Facebook OG tags -- this will overwrite any defaults you set up on the Branch Dashboard
    branchUniversalObject.title = [_event objectForKey:@"name"];
    branchUniversalObject.contentDescription = [_event objectForKey:@"description"];
    
    //userinfo anhängen
    [branchUniversalObject addMetadataKey:@"eventId" value:_event.objectId];
    if ([PFUser currentUser]) {
        [branchUniversalObject addMetadataKey:@"user" value:[PFUser currentUser].objectId];

    }
    else {
        [branchUniversalObject addMetadataKey:@"user" value:@"not logged in"];

    }
    
    // Add any additional custom OG tags here
    [branchUniversalObject addMetadataKey:@"$og_title" value:[_event objectForKey:@"name"]];
    [branchUniversalObject addMetadataKey:@"$og_description" value:[_event objectForKey:@"description"]];

    
    BranchLinkProperties *linkProperties = [[BranchLinkProperties alloc] init];
    linkProperties.feature = @"event_share";
 //   linkProperties.channel = @"facebook";
  //  [linkProperties addControlParam:@"$ios_deepview" withValue:@"default_template"];
  //  [linkProperties addControlParam:@"$android_deepview" withValue:@"default_template"];
    
    /*
    [branchUniversalObject getShortUrlWithLinkProperties:linkProperties andCallback:^(NSString *url, NSError *error) {
        if (!error) {
            NSLog(@"success getting url! %@", url);
        }
    }];
    */
    
    //check if the imageUrl is already loaded
    
    if ([_imageUrlString isEqualToString:@""]) {
        
        NSLog(@"Bild Url noch nicht gespeichert");
        PFFile *applicantResume = [_event objectForKey:@"pic_big"];
        // NSData *resumeData = [applicantResume getData];
        _imageUrlString = applicantResume.url;
        [branchUniversalObject addMetadataKey:@"$og_image_url" value:_imageUrlString];

        
        
        
        branchUniversalObject.imageUrl = _imageUrlString;
        [branchUniversalObject showShareSheetWithLinkProperties:linkProperties
                                                   andShareText:@"Super amazing thing I want to share!"
                                             fromViewController:self
                                                    andCallback:^{
                                                        NSLog(@"finished presenting");
                                                    }];
        
        
    }
    else{
        branchUniversalObject.imageUrl = _imageUrlString;
        [branchUniversalObject addMetadataKey:@"$og_image_url" value:_imageUrlString];

        [branchUniversalObject showShareSheetWithLinkProperties:linkProperties
                                                   andShareText:@"Super amazing thing I want to share!"
                                             fromViewController:self
                                                    andCallback:^{
                                                        NSLog(@"finished presenting");
                                                    }];
        
        
    }
    

    /*
    
    NSString *initalTextString = [NSString stringWithFormat:@"%@ \n %@\n",[_event objectForKey:@"name"],[_event objectForKey:@"fb_link"]];
    NSURL *link = [NSURL URLWithString:@"http://nightguider.de"];
    
    
    NSArray* dataToShare = @[initalTextString,link,_bigPic];
    
    UIActivityViewController* activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                      applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:^{}];
     
     */
    
}

-(void)maybeEvent{
    
    NSLog(@"Vielleicht ausgewählt");
    NSLog(@"eid: %@",[_event objectForKey:@"eid"]);
    // NSString *graphPath = [NSString stringWithFormat:@"https://graph.facebook.com/%@/maybe",[_event objectForKey:@"eid"]];
    NSString *graphPath = [NSString stringWithFormat:@"%@/maybe",[_event objectForKey:@"eid"]];
    

    
    [[[FBSDKGraphRequest alloc]
      initWithGraphPath:graphPath
      parameters: nil
      HTTPMethod:@"POST"]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             
             if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shareEvent"])
             {
                 NSString *message = [NSString stringWithFormat:@"Ich gehe vielleicht zu %@\nWer hat Lust mitzukommen?",[_event objectForKey:@"name"]];
                 self.postParams[@"message"] = message;
                 [self publishStory];
             }
             NSLog(@"sollte geklappt haben");
             
         }
     }];
    
    

    
}

-(void)declineEvent{
    
    NSLog(@"Ablehnen ausgewählt");
    NSString *graphPath = [NSString stringWithFormat:@"%@/declined",[_event objectForKey:@"eid"]];

    
    [[[FBSDKGraphRequest alloc]
      initWithGraphPath:graphPath
      parameters: nil
      HTTPMethod:@"POST"]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             
             NSLog(@"sollte geklappt haben");

             
         }
     }];
    
}

- (void)publishStory
{
    

    
    [[[FBSDKGraphRequest alloc]
     initWithGraphPath:@"me/feed"
     parameters:_postParams
     HTTPMethod:@"POST" ]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                         id result,
                         NSError *error) {
         NSString *alertText;
         if (error) {
             alertText = [NSString stringWithFormat:
                          @"error: domain = %@, code = %ld",
                          error.domain, (long)error.code];
         } else {
             alertText = [NSString stringWithFormat:
                          @"Posted action, id: %@",
                          result[@"id"]];
         }
         // Show the result in an alert
         /*
         [[[UIAlertView alloc] initWithTitle:@"Result"
                                     message:alertText
                                    delegate:self
                           cancelButtonTitle:@"OK!"
                           otherButtonTitles:nil]
          show];
          */
     }];
}


- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 1) {
        if (buttonIndex == 1) {
            // Send the user to the Settings for this app
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:settingsURL];
        }
    }
    else{
    if (buttonIndex == 1)
    {
        
       // SettingsViewController *controller=[[SettingsViewController alloc]init];
        // assuming your controller has identifier "privacy" in the Storyboard
        //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        /*
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone_test" bundle:nil];

        SettingsViewController *controller = (SettingsViewController*)[storyboard instantiateViewControllerWithIdentifier:@"settings"];
        
        // present
              //self.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
        [self presentViewController:controller animated:YES completion:nil];
         
         */
        
        
        
    }
    }
}


- (void)showUnavailableAlertForServiceType: (NSString *)serviceType
{
    NSString *serviceName = @"";
    
    if (serviceType == SLServiceTypeFacebook) {
        serviceName = @"Facebook";
    }
    else if (serviceType == SLServiceTypeSinaWeibo) {
        serviceName = @"Sina Weibo";
    }
    else if (serviceType == SLServiceTypeTwitter) {
        serviceName = @"Twitter";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Account"
                                                        message:[NSString stringWithFormat:@"Please go to the device settings and add a %@ account in order to share through that service", serviceName]
                                                       delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Settings", nil];
    alertView.tag = 1;
    [alertView show];
}


-(void)addEventToCalender
{

    /*
    [[JLCalendarPermission sharedInstance] authorize:^(BOOL granted, NSError * _Nullable error) {
        NSLog(@"DER CODE GEHT");
    }];
    */
    
    //check calender permissions
    
    [[JLCalendarPermission sharedInstance] authorizeWithTitle:@"Zugriff auf Erinnerungsfunktion erlauben?" message:@"Dadurch kann NightGuider dich an das Event erinnern" cancelTitle:@"Nicht jetzt" grantTitle:@"ok" completion:^(BOOL granted, NSError * _Nullable error) {
        
        [self presentReenableVCForCore:[JLCalendarPermission sharedInstance]
                               granted:granted
                                 error:error];
        if(granted){
            
            //open date picker
            
            _eventKitController = [[EventKitController alloc] init];
            
            RMPickerViewController *pickerVC = [RMPickerViewController pickerController];
            pickerVC.delegate = self;
            pickerVC.titleLabel.text = @"Reminder\n\nWann möchtest du an dieses Event erinnert werden?";
            
            //You can enable or disable bouncing and motion effects
            pickerVC.disableBouncingWhenShowing = false;
            pickerVC.disableMotionEffects = false;
            pickerVC.disableBlurEffects = true;
            
            
            if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                
                [pickerVC show];
                
                
            } else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                
                [pickerVC showFromRect:[self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] inView:self.view];
                
                
            }
            
        }
        else{
            NSLog(@"reminder nicht erlaubt");
            
        }
    }];
    
    
    

    
    
    
    
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

- (void)pickerViewController:(RMPickerViewController *)vc didSelectRows:(NSArray *)selectedRows {
    NSLog(@"Successfully selected rows: %@", selectedRows);
    int row = (int)[selectedRows objectAtIndex:0];
    NSLog(@"Selected row: %i", row);
    
    
    //get date and set reminder with it

    switch (row) {
        case 0:{
            [_eventKitController addEventWithName:[_event objectForKey:@"name"] startTime:[_event objectForKey:@"start_time"] endTime:[_event objectForKey:@"end_time"] timeBeforeEvent:day_0];
        }
            break;
        case 1:{
            [_eventKitController addEventWithName:[_event objectForKey:@"name"] startTime:[_event objectForKey:@"start_time"] endTime:[_event objectForKey:@"end_time"] timeBeforeEvent:day_1];
        }
            break;
        case 2:{
            [_eventKitController addEventWithName:[_event objectForKey:@"name"] startTime:[_event objectForKey:@"start_time"] endTime:[_event objectForKey:@"end_time"] timeBeforeEvent:day_2];
        }
            break;
        case 3:{
            [_eventKitController addEventWithName:[_event objectForKey:@"name"] startTime:[_event objectForKey:@"start_time"] endTime:[_event objectForKey:@"end_time"] timeBeforeEvent:day_3];
        }
            break;
        case 4:{
            [_eventKitController addEventWithName:[_event objectForKey:@"name"] startTime:[_event objectForKey:@"start_time"] endTime:[_event objectForKey:@"end_time"] timeBeforeEvent:day_4];
        }
            break;
        case 5:{
            [_eventKitController addEventWithName:[_event objectForKey:@"name"] startTime:[_event objectForKey:@"start_time"] endTime:[_event objectForKey:@"end_time"] timeBeforeEvent:day_5];
        }
            break;
        case 6:{
            [_eventKitController addEventWithName:[_event objectForKey:@"name"] startTime:[_event objectForKey:@"start_time"] endTime:[_event objectForKey:@"end_time"] timeBeforeEvent:day_6];
        }
            break;
        case 7:{
            [_eventKitController addEventWithName:[_event objectForKey:@"name"] startTime:[_event objectForKey:@"start_time"] endTime:[_event objectForKey:@"end_time"] timeBeforeEvent:day_7];
        }
            break;
        case 8:{
            [_eventKitController addEventWithName:[_event objectForKey:@"name"] startTime:[_event objectForKey:@"start_time"] endTime:[_event objectForKey:@"end_time"] timeBeforeEvent:day_14];
        }
            break;
            
            
        default:{
            NSLog(@"default");
            [_eventKitController addEventWithName:[_event objectForKey:@"name"] startTime:[_event objectForKey:@"start_time"] endTime:[_event objectForKey:@"end_time"] timeBeforeEvent:day_0];
            
        }
            break;
    }

}

- (void)pickerViewControllerDidCancel:(RMPickerViewController *)vc {
    NSLog(@"Selection was canceled");
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 9;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (row) {
        case 0:{
            return @"5 Stunden vorher";
        }
            break;
        case 1:{
            return  @"1 Tag vorher";
        }
            break;
        case 2:{
            return  @"2 Tage vorher";
        }
            break;
        case 3:{
            return  @"3 Tage vorher";
        }
            break;
        case 4:{
            return  @"4 Tage vorher";

        }
            break;
        case 5:{
            return  @"5 Tage vorher";

        }
            break;
        case 6:{
            return  @"6 Tage vorher";

        }
            break;
        case 7:{
            return  @"7 Tage vorher";

        }
            break;
        case 8:{
            return  @"14 Tage vorher";

        }
            break;
            
            
        default:{
            NSLog(@"default");
            return  @"5 Stunden vorher";

            
        }
            break;
    }

    
}

//Event zu Favoriten hinzufügen
-(void)addFavTapped:(id)sender {
    NSLog(@"fav pressed");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"neuerFav" object:nil];

    
    NSString *ID = _event.objectId;
    
    
    //check if event is already favorite
    
    for (int i = 0; i<[self.data count]; i++) {
        
        NSString *eventName =[self.data objectAtIndex:i];
        
        if ([eventName isEqualToString:ID]) {
            NSLog(@"event already favorite");
            
            //event already favorite so remove it from the list
        
            
            
            [self.data removeObjectAtIndex:i];
            
            [self.data writeToFile:[NSString stringWithFormat:@"%@/Documents/data", NSHomeDirectory()] atomically:YES];
            
            NSLog(@"Größe von data array: %lu", (unsigned long)[self.data count]);


            _favorite = NO;
           // cell.favBtn.selected = NO;
            
            [_favBtn setImage:[UIImage imageNamed:@"favorites" ] forState:UIControlStateNormal];


            
            //reload tableviewcell to deselect the favorite icon
            
            NSArray *indexPathArray = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]];
            
            //[_eventTableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
            
            [self.tableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];

            
            
            return;
            
        }
    }
    
    
    //add event to the favorite events list
    
    [self.data addObject:ID];
    
    NSLog(@"Id wurde hinzugefügt: %@", ID);
    [self.data sortUsingSelector:@selector(compare:)];
    
    [self.data writeToFile:[NSString stringWithFormat:@"%@/Documents/data", NSHomeDirectory()] atomically:YES];
    [_favBtn setImage:[UIImage imageNamed:@"favoritesSelected" ] forState:UIControlStateNormal];

    _favorite = YES;
    
    //reload data to set the icon to favoriteselected
    
    NSArray *indexPathArray = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    [self.tableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];


    
    
    
    
}

-(void)routeButtonTapped{
    
    //ask of user wants to get the directions to the event

    NSLog(@"route anzeigen");
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    //Hide animation type (Default is FadeOut)
    alert.hideAnimationType = SlideOutToTop;
    
    //Show animation type (Default is SlideInFromTop)
    alert.showAnimationType = SlideInFromTop;
    
    //Set background type (Default is Shadow)
    alert.backgroundType = Blur;
    
    [alert alertIsDismissed:^{
    }];
    
    [alert addButton:@"Ja" actionBlock:^{
        
        //open maps and get the directions
        
        PFGeoPoint *geoPoint = [_club objectForKey:@"location"];
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
        
        GeoPointAnnotation *point = [[GeoPointAnnotation alloc] init];
        
        point.title = [_club objectForKey:@"host"];
        //point.subtitle = [NSString stringWithFormat:@"Rating: %@", [object objectForKey:@"rating"]];
        
        point.coordinate = coordinate;
        
        NSString * country = [_club objectForKey:@"country"];
        NSString * city = [_club objectForKey:@"city"];
        NSString * street = [_club objectForKey:@"street"];
        NSString * zip = [_club objectForKey:@"zip"];
        
        
        NSDictionary *addressDict2 = @{
                                       
                                       (NSString*)kABPersonAddressCountryKey :country,
                                       (NSString*)kABPersonAddressCityKey : city,
                                       (NSString*)kABPersonAddressStreetKey : street,
                                       (NSString*)kABPersonAddressZIPKey : zip};
        
        
        /*
         NSDictionary *addressDict2 = @{
         
         (NSString*)kABPersonAddressCountryKey : country,
         (NSString*)kABPersonAddressCityKey : @"Stadt",
         (NSString*)kABPersonAddressStreetKey : @"Straße",
         (NSString*)kABPersonAddressZIPKey : @"PLZ"};
         */
        
        
        point.address = addressDict2;
        
        /*
         point.countryKey  = country;
         point.cityKey = city;
         point.streetKey = street;
         point.zipKey = zip;
         */
        
        
        point.phoneNumber = [_club objectForKey:@"phoneNumber"];
        point.url = [_club objectForKey:@"url"];
        
        
        _selectedStation = point;
        
        MKMapItem *mapItem = [_selectedStation mapItem];
        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking};
        [mapItem openInMapsWithLaunchOptions:launchOptions];


    }];
    
    [alert showInfo:self title:@"Maps öffnen" subTitle:@"Möchtest du dir die Route anzeigen lassen?" closeButtonTitle:@"Nein" duration:0.0f];
    
}

-(void)expandButtonTapped{
    EventInfoCell *cell = [[EventInfoCell alloc]init];
    
    //expand or shrink the textview

    if (_textExpanded==NO) {
        _textExpanded=YES;
        NSLog(@"expand yes");
        cell.fadeImageView.hidden = YES;


    }
    else {
        _textExpanded=NO;
        NSLog(@"expand no");


        cell.fadeImageView.hidden = YES;

    }
    

    
    NSArray *indexPathArray = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]];

    [self.tableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];

    
    
}

-(void)locationButtonTapped{
    
    //open to clubdetailview from the host
    
    NSLog(@"Location anzeigen");
    NSLog(@"name: %@",[_club objectForKey:@"name" ]);
    if ([[_club objectForKey:@"name" ] length] != 0) {
        // if (![_event objectForKey:@"host"]) {
        
        [self performSegueWithIdentifier:@"club" sender:self];

    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Leider konnte der Host nicht geladen werden." message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }

}



//Detailansicht öffnen
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"flyer"])
	{
        
        //outdaded
        //originaly should open the image of the event
        
        /*
        FlyerViewController *flyerController =segue.destinationViewController;
        
        
        NSString *title = [_event objectForKey:@"name"];
        
        
        flyerController.flyer = _bigPic;
        
        flyerController.imgURL = _imgURL;
        
        [flyerController setTitle:title];
         */
    }
    
    else if ([segue.identifier isEqualToString:@"club"])
	{
        
        ClubDetailViewController *detailController =segue.destinationViewController;
        
        NSString *title = [_club objectForKey:@"name"];
        
        NSLog(@"title: %@", title);
        
        
        detailController.club = _club;
        
        
        [detailController setTitle:title];
        
        
    }
    
    else if ([segue.identifier isEqualToString:@"checkout"])
    {
        NSLog(@"checkout");

    //    UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
     //   CheckoutViewController *checkoutController = [navController topViewController];
    CheckoutViewController *checkoutController = (CheckoutViewController *)[[segue destinationViewController] topViewController];

//set ticktettype and amount
        

        NSLog(@"tickettype: %i",(int)_ticketType);

        checkoutController.ticketType = _ticketType;
        NSLog(@"amount: %i",(int)_amount);

        checkoutController.amount = _amount;
        
        NSLog(@"event: %@", _event);
        checkoutController.ticket = _event;
 

        
        
        
        
    }
    
    
    
    
    
    
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
#pragma  necessary
                                /*
                                 NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                                 NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                                 [self.tableView beginUpdates];
                                 [self.tableView reloadRowsAtIndexPaths:@[indexPaths] withRowAnimation:UITableViewRowAnimationNone];
                                 [self.tableView endUpdates];
                                 */
                                
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
             [currentInstallation setObject:_stadt forKey:@"city"];
             [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
             [currentInstallation saveInBackground];


            
        }
    }];
}

-(void)openPopOver{

    //open popup to select the amount of tickets
    
    
    TicketPopOverView *_popoverView = [[TicketPopOverView alloc]init];
    _popoverView.delegate = self;
    [self.view addSubview:_popoverView];
    
    _popoverView.center = CGPointMake(100, 100);
    
    // Turn off autosizin masks
    _popoverView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 1. Pin to center y
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_popoverView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-self.navigationController.navigationBar.frame.size.height]];
    
    // 2. Pin to center x
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_popoverView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    
    //get data from event
    PFFile *applicantResume = [_event objectForKey:@"image"];
    
    
    _popoverView.bannerImageView.file = applicantResume;
    [_popoverView.bannerImageView loadInBackground];
    
    
    int maxAmount ;
    switch (_ticketType) {
        case 1:
        {
            NSLog(@"tickets laden");
            maxAmount =[[_event objectForKey:@"ticketAmount"]intValue ];
            _popoverView.amountStepper.maximumValue = maxAmount;
            _popoverView.priceLabel.text = [NSString stringWithFormat:@"%@€",[_event objectForKey:@"ticketPrice"]];
            
            
            
            
            
        }
            break;
        case 3:
        {
            NSLog(@"kombi laden");
            
            if ([[_event objectForKey:@"ticketAmount"]intValue ] > [[_event objectForKey:@"guestlistAmount"]intValue ]) {
                maxAmount = [[_event objectForKey:@"guestlistAmount"]intValue ];
                _popoverView.amountStepper.maximumValue = maxAmount;
                
            }
            else{
                maxAmount = [[_event objectForKey:@"ticketAmount"]intValue ];
                _popoverView.amountStepper.maximumValue = maxAmount;
                
            }
            
            NSNumber *ticketPrice = [_event objectForKey:@"ticketPrice"];
            NSDecimalNumber *ticketPriceNum = [NSDecimalNumber decimalNumberWithDecimal:[ticketPrice decimalValue]];
            NSNumber *guestlistPrice = [_event objectForKey:@"guestlistPrice"];
            NSDecimalNumber *guestlistPriceNum = [NSDecimalNumber decimalNumberWithDecimal:[guestlistPrice decimalValue]];
            
            NSDecimalNumber *combiPriceNum = [ticketPriceNum decimalNumberByAdding:guestlistPriceNum];
            _popoverView.priceLabel.text = [NSString stringWithFormat:@"%@€",combiPriceNum];
            
            
        }
            break;
        case 2:{
            NSLog(@"gästelistenplatz laden");
            maxAmount =[[_event objectForKey:@"guestlistAmount"]intValue ];
            _popoverView.amountStepper.maximumValue = maxAmount;
            _popoverView.priceLabel.text = [NSString stringWithFormat:@"%@€",[_event objectForKey:@"guestlistPrice"]];
            
            
            
        } break;
    }
    _popoverView.hostLabel.text = [_event objectForKey:@"host"];
    _popoverView.eventNameLabel.text = [_event objectForKey:@"name"];
    
    //1 Seat
    _popoverView.amountLabel.text = @"1 Platz";
    _popoverView.amountStepper.value = 1;
    _popoverView.amountStepper.minimumValue = 1;
    
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterNoStyle;
    df.timeStyle = NSDateFormatterShortStyle;
    df.timeZone = [NSTimeZone localTimeZone];
    NSString *zeit = [df stringFromDate:[_event objectForKey:@"start_time"]];
    NSString *ende = [df stringFromDate:[_event objectForKey:@"end_time"]];
    NSString *string = [NSString stringWithFormat:@"%@ - %@", zeit, ende];
    _popoverView.timeLabel.text = string;
    
    
    NSDateFormatter *dfd = [[NSDateFormatter alloc] init];
    dfd.dateStyle = NSDateFormatterShortStyle;
    dfd.timeStyle = NSDateFormatterNoStyle;
    dfd.timeZone = [NSTimeZone localTimeZone];
    NSString *datum = [dfd stringFromDate:[_event objectForKey:@"start_time"]];
    _popoverView.dateLabel.text = datum;
    
    
    
}

-(void)ticketPopOverViewDidDismiss:(TicketPopOverView *) sender{
    NSLog(@"popover schließen");

}


-(void)ticketPopOverViewPurchase:(TicketPopOverView *) sender ticketAmount: (int) ticketAmount{
    NSLog(@"ticket kaufen 2");
    NSLog(@"Anzahl: %i", ticketAmount);
    
    
    _amount = ticketAmount;
    
    
    [self checkBuyOption];

    
}






-(void)buyButtonTapped{
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    //Hide animation type (Default is FadeOut)
    alert.hideAnimationType = SlideOutToTop;
    
    //Show animation type (Default is SlideInFromTop)
    alert.showAnimationType = SlideInFromTop;
    
    //Set background type (Default is Shadow)
    alert.backgroundType = Blur;
    
    [alert alertIsDismissed:^{
    }];

    
    if (_ticketOption == 0 || !_ticketOption) {
        [alert showError:self title:@"Kaufen" subTitle:@"Leider sind für dieses Event keine Produkte mehr vorhanden" closeButtonTitle:@"OK" duration:0.0f];
    }
    else if (_ticketOption == 1){
        //ticket
        
        _ticketType = 1;
        [self openPopOver];
        
    }
    else if(_ticketOption == 2){
        //guestlist
        
        _ticketType = 2;
        [self openPopOver];
        
    }
    else if(_ticketOption == 3){
        
        [alert addButton:@"Tickets" actionBlock:^{
            
            _ticketType = 1;
            
            [self openPopOver];
            
        }];
        
        [alert addButton:@"Gästeliste" actionBlock:^{
            
            
            if ([[_event objectForKey:@"ticketAvailable"]boolValue]) {
                SCLAlertView *alert_2 = [[SCLAlertView alloc] init];
                
                //Hide animation type (Default is FadeOut)
                alert_2.hideAnimationType = SlideOutToTop;
                
                //Show animation type (Default is SlideInFromTop)
                alert_2.showAnimationType = SlideInFromTop;
                
                //Set background type (Default is Shadow)
                alert_2.backgroundType = Blur;
                
                [alert_2 alertIsDismissed:^{
                }];
                
                [alert_2 addButton:@"Gästeliste" actionBlock:^{
                    
                    _ticketType = 2;
                    
                    [self openPopOver];
                    
                    
                }];
                
                [alert_2 addButton:@"Kombiticket" actionBlock:^{
                    
                    _ticketType = 3;
                    
                    [self openPopOver];
                    
                    
                }];
                
                [alert_2 showNotice:self title:@"Gästelistenplatz" subTitle:@"Bitte beachte, dass du eventuell nur mit einem Ticket Eintritt erhälst. Ohne Ticket empfehlen wir ein Kombiticket, dass kombiniert das Eintrittsticket mit einem Gästelistenplatz. (Für weitere Informationen wende dich bitte an den Veranstalter)" closeButtonTitle:@"Abbrechen" duration:0.0f];
                
            }
            else{
                
                _ticketType = 2;
                
                [self openPopOver];
                
            }
            
            
            
            
            
            
        }];
        
        [alert addButton:@"Kombiticket" actionBlock:^{
            
            _ticketType = 3;
            
            [self openPopOver];
            
            
        }];
        
        
        [alert showInfo:self title:@"Kaufen" subTitle:@"Welche Art?" closeButtonTitle:@"Abbrechen" duration:0.0f];

    }
    else{
        [alert showError:self title:@"Kaufen" subTitle:@"Leider sind für dieses Event keine Produkte mehr vorhanden" closeButtonTitle:@"OK" duration:0.0f];
    }
    
    /*
    
    [self.hud show:YES];

    
    NSDate *today = [NSDate date];
    
  //  einzelne if schleifen und eine variable muss abgearbeitet wrden und am schluss eine schleife die solange abläuft bis alle variablen geklärt sind
    
    int ticket = 0;
    int guestlist = 0;
    int combi = 0;
    

    
    if ([[_event objectForKey:@"ticketAmount"]intValue] > 0 && [[_event objectForKey:@"guestlistAmount"]intValue] < 1 && [_event objectForKey:@"ticket_endTime"] > today) {
        _ticketType = 1;
        
        [self openPopOver];
        
    }
    
    else if ([[_event objectForKey:@"guestlistAmount"]intValue] > 0 && [[_event objectForKey:@"ticketAmount"]intValue] < 1 && [_event objectForKey:@"guestlist_endTime"] > today){
        _ticketType = 2;
        
        [self openPopOver];
    }
    
    else {
    
        
    

    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    //Hide animation type (Default is FadeOut)
    alert.hideAnimationType = SlideOutToTop;
    
    //Show animation type (Default is SlideInFromTop)
    alert.showAnimationType = SlideInFromTop;
    
    //Set background type (Default is Shadow)
    alert.backgroundType = Blur;
    
    [alert alertIsDismissed:^{
    }];
    
    if ([[_event objectForKey:@"ticketAmount"]intValue] > 0 && [_event objectForKey:@"ticket_endTime"] > today) {
        [alert addButton:@"Tickets" actionBlock:^{
            
            _ticketType = 1;
            
            [self openPopOver];
            
        }];
        
        ticket = 1;
    }
    else{
        NSLog(@"kein ticket verfügbar");
        ticket = 2;
    }
        
    
    if ([[_event objectForKey:@"guestlistAmount"]intValue] > 0 && [_event objectForKey:@"guestlist_endTime"] > today ) {
        [alert addButton:@"Gästeliste" actionBlock:^{
            
            
            if ([[_event objectForKey:@"ticketAvailable"]boolValue]) {
                SCLAlertView *alert = [[SCLAlertView alloc] init];
                
                //Hide animation type (Default is FadeOut)
                alert.hideAnimationType = SlideOutToTop;
                
                //Show animation type (Default is SlideInFromTop)
                alert.showAnimationType = SlideInFromTop;
                
                //Set background type (Default is Shadow)
                alert.backgroundType = Blur;
                
                [alert alertIsDismissed:^{
                }];
                
                [alert addButton:@"Gästeliste" actionBlock:^{
                    
                    _ticketType = 2;
                    
                    [self openPopOver];
                    
                    
                }];
                
                [alert addButton:@"Kombiticket" actionBlock:^{
                    
                    _ticketType = 3;
                    
                    [self openPopOver];
                    
                    
                }];
                
                [alert showNotice:self title:@"Gästelistenplatz" subTitle:@"Bitte beachte, dass du eventuell nur mit einem Ticket Eintritt erhälst. Ohne Ticket empfehlen wir ein Kombiticket, dass kombiniert das Eintrittsticket mit einem Gästelistenplatz. (Für weitere Informationen wende dich bitte an den Veranstalter)" closeButtonTitle:@"Abbrechen" duration:0.0f];
                
            }
            else{
                
                _ticketType = 2;
                
                [self openPopOver];
                
            }
            
            
            
            
        }];

        guestlist = 1;
    }
    else{
        NSLog(@"kein gästelistenplatz verfügbar");
        guestlist = 2;
    }
    
    if ([[_event objectForKey:@"ticketAmount"]intValue] > 0 && [[_event objectForKey:@"guestlistAmount"]intValue] > 0 && [_event objectForKey:@"ticket_endTime"] > today && [_event objectForKey:@"guestlist_endTime"] > today) {
        [alert addButton:@"Kombiticket" actionBlock:^{
            
            _ticketType = 3;
            
            [self openPopOver];
            
            
        }];
        
        combi = 1;
    }
    else{
        NSLog(@"kein kombiticket verfügbar");
        combi = 2;
    }
    
    if (!([[_event objectForKey:@"ticketAmount"]intValue] > 0) && !([[_event objectForKey:@"guestlistAmount"]intValue] > 0)) {
    
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        [alert showError:self title:@"Kaufen" subTitle:@"Leider sind für dieses Event keine Produkte mehr vorhanden" closeButtonTitle:@"OK" duration:0.0f];

    }
    else {
    //wait because not all tickets are checked if the user clicks to early
        
        NSLog(@"ticket: %i Guestlist: %i Combi: %i", ticket,guestlist,combi);
        
        if(ticket==2 && guestlist==2 && combi==2){
            NSLog(@"fehler bei ticket auswahl erneut laden");
            int64_t delayInSeconds = 0.6;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

                [self buyButtonTapped];
                
            });
        }
        else {
            BOOL  repeat= YES;
            
            while (repeat) {
                
                if (ticket!=0 && guestlist!=0 && combi!=0) {
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

                    [alert showInfo:self title:@"Kaufen" subTitle:@"Welche Art?" closeButtonTitle:@"Abbrechen" duration:0.0f];
                    
                    repeat = NO;
                    break;
                }
                
                usleep(1000);
                
            }
        }
     
        
    }


    }
     
     */

}

-(void)checkBuyOption{
    
    
    // only continue to checkout if user is already logged in
    
    
    PFUser *currentUser = [PFUser currentUser];
    if(!currentUser){
        
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        //Hide animation type (Default is FadeOut)
        alert.hideAnimationType = SlideOutToTop;
        
        //Show animation type (Default is SlideInFromTop)
        alert.showAnimationType = SlideInFromTop;
        
        //Set background type (Default is Shadow)
        alert.backgroundType = Blur;
        
        [alert alertIsDismissed:^{
        }];
        
        [alert addButton:@"Anmelden" actionBlock:^{
            
            MyLogInViewController *logInViewController = [[MyLogInViewController alloc] init];
            
            NSArray *permissionsArray = @[@"email",@"user_birthday",@"user_location", @"user_events",@"user_relationships"];
            
            [logInViewController setFacebookPermissions:permissionsArray];
            
            [logInViewController setFields:PFLogInFieldsUsernameAndPassword
             | PFLogInFieldsFacebook
             | PFLogInFieldsSignUpButton
             | PFLogInFieldsPasswordForgotten
             | PFLogInFieldsLogInButton
             | PFLogInFieldsDismissButton];
            
            [logInViewController setDelegate:self];

            
            // Instantiate our custom sign up view controller
            /*
             MySignUpViewController *signUpViewController = [[MySignUpViewController alloc] init];
             [signUpViewController setDelegate:self];
             [signUpViewController setFields:PFSignUpFieldsDefault | PFSignUpFieldsAdditional];
             
             // Link the sign up view controller
             [logInViewController setSignUpController:signUpViewController];
             */
            
            // Present log in view controller
            [self presentViewController:logInViewController animated:YES completion:NULL];
            
            
        }];

        
        [alert showWarning:self title:@"Nicht eingeloggt" subTitle:@"Du musst eingeloggt sein, um etwas zu kaufen" closeButtonTitle:@"Nicht jetzt" duration:0.0f];


        
    }
    //check user email
    
    else if ([[currentUser objectForKey:@"emailVerified"]boolValue]&& ![PFFacebookUtils isLinkedWithUser:currentUser]){
        
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        
        //Hide animation type (Default is FadeOut)
        alert.hideAnimationType = SlideOutToTop;
        
        //Show animation type (Default is SlideInFromTop)
        alert.showAnimationType = SlideInFromTop;
        
        //Set background type (Default is Shadow)
        alert.backgroundType = Blur;
        
        [alert alertIsDismissed:^{
        }];
        
        [alert addButton:@"Erneut senden" actionBlock:^{
            
            //updating the email will force Parse to resend the verification email
            NSString *email = [[PFUser currentUser] objectForKey:@"email"];
            NSLog(@"email: %@",email);
            if (!email) {
                SCLAlertView *alert = [[SCLAlertView alloc] init];
                
                //Hide animation type (Default is FadeOut)
                alert.hideAnimationType = SlideOutToTop;
                
                //Show animation type (Default is SlideInFromTop)
                alert.showAnimationType = SlideInFromTop;
                
                //Set background type (Default is Shadow)
                alert.backgroundType = Blur;
                
                [alert alertIsDismissed:^{
                }];
                [alert showNotice:self title:@"Keine Email vorhanden" subTitle:@"Bitte melde dich dich per email an: support@nightguider.de" closeButtonTitle:@"OK" duration:0.0f];
            }
            [[PFUser currentUser] setObject:@"foo@foo.com" forKey:@"email"];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error ){
                
                if( succeeded ) {
                    
                    [[PFUser currentUser] setObject:email forKey:@"email"];
                    [[PFUser currentUser] saveInBackground];
                    
                }
                
            }];
            
            
        }];
        
        
        [alert showNotice:self title:@"Email verfizieren" subTitle:@"Du musst deine Email noch bestätigenn" closeButtonTitle:@"OK" duration:0.0f];

        
    }
    else if(_ticketType != 0 && _amount != 0 ){
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
        
        [alert showError:self title:@"Fehler bei Auswahl" subTitle:@"Die getroffene Auswahl war fehlerhaft, bitte öffne das Event erneut und versuche es noch einmal" closeButtonTitle:@"OK" duration:0.0f];



    }

}

-(IBAction)backToEventDetail: (UIStoryboardSegue *) segue{
    
    
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    NSLog(@"pflogin erfolgreich");
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]] ) {
        [self getUserData];
        
    }
    else{
        NSLog(@"kein fb login");
        [self.tableView reloadData];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    

    
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
    }];
    
    [alert showError:self title:@"Fehler" subTitle:@"Leider ist ein Fehler beim Login aufgetreten, bitte versuche es später nochmal" closeButtonTitle:@"OK" duration:0.0f];

}



//load city
-(void) loadData{
    //stadt = city
    
    self.stadt = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/stadt", NSHomeDirectory()] encoding:NSUTF8StringEncoding error:nil];
    
    
}


@end
