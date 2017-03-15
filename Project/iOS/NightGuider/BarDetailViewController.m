//
//  BarDetailViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 12.11.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import "BarDetailViewController.h"
#import "UIScrollView+APParallaxHeader.h"
#import "EventViewController.h"
#import "ClubDescriptionCell.h"
#import "ClubInfoCell.h"
#import <AddressBook/AddressBook.h>
#import "GeoPointAnnotation.h"
#import "GeoPointAnnotation2.h"
#import <QuartzCore/QuartzCore.h>
#import "ClubEventCell.h"

#import <CoreLocation/CoreLocation.h>
#import "BarBonusViewController.h"

#import "Branch.h"
#import "BranchUniversalObject.h"
#import "BranchLinkProperties.h"
#import "MBProgressHUD.h"


@interface BarDetailViewController () <CLLocationManagerDelegate,UIAlertViewDelegate>
{
    BOOL parallaxWithView;
}
#pragma  fav button einfügen
@property (weak, nonatomic) IBOutlet UIBarButtonItem *favButton;
@property (weak, nonatomic) IBOutlet UIButton *favBtn;

@property (nonatomic, strong) NSMutableArray *savedBars;
@property (nonatomic, strong) NSString *imageUrlString;
@property (nonatomic, strong) MBProgressHUD *hud;





@end

@implementation BarDetailViewController{
    CGFloat _textHeight;
    BOOL _textLoaded;
    GeoPointAnnotation *_selectedStation;
    CLLocationManager *locationManager;
    
    
    
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self toggle:nil];
    
    
    if ([self isViewLoaded]) {
        NSLog(@"neu laden");
        NSLog(@"name: %@",[_bar objectForKey:@"name"]);
        
        [self.tableView reloadData];
    }
    
    _prepareForSegueSelected = NO;
    
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
        self.tableView.tableFooterView = footerView;
        self.tableView.separatorColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    _tableReloaded = NO;
    /*
#pragma  ios8 location erlaubnis
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
            alertView.tag = 5;
            [alertView show];
        }
        // [_locationManager requestWhenInUseAuthorization];
        
        else if (status == kCLAuthorizationStatusNotDetermined) {
            [locationManager requestWhenInUseAuthorization];
        }
    }
     */
    
    //registerVeiw for tracking branch links
    NSString *identifier = [NSString stringWithFormat:@"bar/%@",_bar.objectId];
    BranchUniversalObject *branchUniversalObject = [[BranchUniversalObject alloc] initWithCanonicalIdentifier:identifier];
    [branchUniversalObject registerView];
    
    //get picture for resizeable banner
    PFFile *applicantResume = [_bar objectForKey:@"pic_Big"];
    
    [applicantResume getDataInBackgroundWithBlock:^(NSData *resumeData, NSError *error) {
        if (!error) {
            // The find succeeded.
            // NSLog(@"Bild empfangen!");
            UIImage *banner = [UIImage imageWithData:resumeData];
            self.tableView.backgroundView = [[UIImageView alloc] initWithImage:banner];
            
            // NSLog(@"Subviews: %li", (unsigned long)self.tableView.backgroundView.subviews.count);
            
            if (self.tableView.backgroundView.subviews.count == 0) {
                
                UIVisualEffect *blurEffect;
                blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                
                UIVisualEffectView *visualEffectView;
                visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                
                visualEffectView.frame = self.tableView.backgroundView.bounds;
                [self.tableView.backgroundView addSubview:visualEffectView];
                
                visualEffectView.translatesAutoresizingMaskIntoConstraints = NO;
                
                
                NSLayoutConstraint *width =[NSLayoutConstraint
                                            constraintWithItem:visualEffectView
                                            attribute:NSLayoutAttributeWidth
                                            relatedBy:0
                                            toItem:self.tableView.backgroundView
                                            attribute:NSLayoutAttributeWidth
                                            multiplier:1.0
                                            constant:0];
                NSLayoutConstraint *height =[NSLayoutConstraint
                                             constraintWithItem:visualEffectView
                                             attribute:NSLayoutAttributeHeight
                                             relatedBy:0
                                             toItem:self.tableView.backgroundView
                                             attribute:NSLayoutAttributeHeight
                                             multiplier:1.0
                                             constant:0];
                NSLayoutConstraint *top = [NSLayoutConstraint
                                           constraintWithItem:visualEffectView
                                           attribute:NSLayoutAttributeTop
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:self.tableView.backgroundView
                                           attribute:NSLayoutAttributeTop
                                           multiplier:1.0f
                                           constant:0.f];
                NSLayoutConstraint *leading = [NSLayoutConstraint
                                               constraintWithItem:visualEffectView
                                               attribute:NSLayoutAttributeLeading
                                               relatedBy:NSLayoutRelationEqual
                                               toItem:self.tableView.backgroundView
                                               attribute:NSLayoutAttributeLeading
                                               multiplier:1.0f
                                               constant:0.f];
                
                [self.tableView.backgroundView addConstraints:@[width, height, top, leading]];
            }
            
        }
        else NSLog(@"Es konnte kein bild geladen werden");
    }];
    
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@" " style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                              target:self action:@selector(shareButtonTapped:)];
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"Wird geladen...", @"Wird geladen...");
    
    
    
    
    
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    //check if club is favorized

    
    _prepareForSegueSelected = NO;
    //Falls Club schon Favorit Button Orange einfärben
    NSString *ID = _bar.objectId;
    
    self.savedBars =[NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/bars", NSHomeDirectory()]];
    
    for (int i = 0; i<[self.savedBars count]; i++) {
        if ([[self.savedBars objectAtIndex:i] isEqualToString: ID]) {
            
            
            //    NSLog(@"Schon vorhanden");
            //  [_favButton setBackgroundImage:[UIImage imageNamed:@"star-white-filled.jpg"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
           // _favButton.image = [UIImage imageNamed:@"star-white-filled.jpg"];
            [_favBtn setImage:[UIImage imageNamed:@"favoritesSelected" ] forState:UIControlStateNormal];

            
            return;
            
        }
    }
    
   // _favButton.image = [UIImage imageNamed:@"star-white-line.jpg"];
    [_favBtn setImage:[UIImage imageNamed:@"favorites" ] forState:UIControlStateNormal];

    
    
    
}

- (void)toggle:(id)sender
{
    
    //add parallax to view

    if(parallaxWithView == NO)
    {
        // add parallax with view
        
        //  NSLog(@"view laden");
        
        PFFile *applicantResume = [_bar objectForKey:@"pic_Big"];
        // NSData *resumeData = [applicantResume getData];
        
        _imageUrlString = applicantResume.url;
        // UIView *testView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 160)];
        CGRect screenBound = [[UIScreen mainScreen] bounds];
        CGSize screenSize = screenBound.size;
        CGFloat screenWidth = screenSize.width;
        
#warning -- use coinstraints
        
        UIView *testView = [[UIView alloc]initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height
                                                                   , screenWidth, 160)];
        
        [self.tableView addParallaxWithView:testView andHeight:140];
        
        [applicantResume getDataInBackgroundWithBlock:^(NSData *resumeData, NSError *error) {
            if (!error) {
                // The find succeeded.
                //  NSLog(@"Bild empfangen!");
                // self.imageView.image = [UIImage imageWithData:resumeData];
                
                if (resumeData==nil) {
                    NSLog(@"bild konnte nicht geladen werden");
                    
                }
                //NSLog(@"%@",resumeData);
                
                
                //   [self.tableView addParallaxWithImage:[UIImage imageWithData:resumeData] andHeight:160];
                [testView removeFromSuperview];
                
                
                
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:resumeData]];
                //    [imageView setFrame:CGRectMake(0, 0, 320, 160)];
                [imageView setFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height
                                               , screenWidth, 160)];
                
                [imageView setContentMode:UIViewContentModeScaleAspectFill];
                
                
                
                [self.tableView addParallaxWithView:imageView andHeight:160];
                
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }
         ];
        
        // [self.tableView addParallaxWithView:imageView andHeight:160];
        
        
        parallaxWithView = YES;
        
        // UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"with image" style:UIBarButtonSystemItemAction target:self action:@selector(toggle:)];
        //   [self.navigationItem setRightBarButtonItem:barButton];
    }
    else
    {
        // add parallax with image
        //Bild anzeigen
        //  NSLog(@"bild");
        PFFile *applicantResume = [_bar objectForKey:@"pic_Big"];
        // NSData *resumeData = [applicantResume getData];
        
        [applicantResume getDataInBackgroundWithBlock:^(NSData *resumeData, NSError *error) {
            if (!error) {
                // The find succeeded.
                // NSLog(@"Bild empfangen!");
                // self.imageView.image = [UIImage imageWithData:resumeData];
                
                
                [self.tableView addParallaxWithImage:[UIImage imageWithData:resumeData] andHeight:160];
                parallaxWithView = NO;
                
                
                
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }
         ];
        
        
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)back{
    NSLog(@"back");
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    
    if (indexPath.row == 0){
        NSLog(@"bonus 1");
        static NSString *CellIdentifier = @"BonusCell";
        
        ClubEventCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UILabel *pointsLabel = (UILabel*)[cell viewWithTag:1];
        
        cell.textLabel.hidden = YES;
        
        cell.clubNameLabel.text = @"Prämien";
        
        //hide labels if bar is not premium
        
        if(![[_bar objectForKey:@"premium"]boolValue]){
            NSLog(@"nicht premium");
            cell.clubNameLabel.hidden = YES;
            pointsLabel.hidden = YES;
            cell.textLabel.hidden = YES;

            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        else{
            NSLog(@"premium");
            cell.clubNameLabel.hidden = NO;
            pointsLabel.hidden = YES;
            cell.textLabel.hidden = NO;

            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            
            
        }
        
        return cell;
        
    }
    else if (indexPath.row == 1){
        
        
        static NSString *CellIdentifier = @"Info";
        
        ClubInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if ([_bar objectForKey:@"street"]) {
            cell.streetNameLabel.text = [_bar objectForKey:@"street"];
            
        }
        else {
            cell.streetNameLabel.text = @"Nicht verfügbar";
        }
        
        NSString *phoneNumber = [_bar objectForKey:@"phone"];
        if (phoneNumber.length == 0) {
            cell.phoneNumberLabel.text = @"Nicht verfügbar";
            cell.phoneNumberButton.hidden = YES;
        }
        else{
            cell.phoneNumberLabel.text = phoneNumber;
            
        }
        
        if (![_bar objectForKey:@"location"]) {
            cell.streetNameButton.hidden = YES;
        }
        else cell.streetNameButton.hidden = NO;
        
        
        
        
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            if (!error) {
                // do something with the new geoPoint
                double distanz = [geoPoint distanceInKilometersTo:[_bar objectForKey:@"location"]];
                cell.distanceLabel.text = [NSString stringWithFormat:@"Distanz: %.2f km", distanz];
                
            }
        }];
        
        
        UIView *colorView = [[UIView alloc] initWithFrame:cell.streetNameButton.frame];
        colorView.backgroundColor = [UIColor darkGrayColor];
        UIGraphicsBeginImageContext(colorView.bounds.size);
        [colorView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *colorImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [cell.streetNameButton setBackgroundImage:colorImage forState:UIControlStateHighlighted];
        [cell.streetNameButton setBackgroundImage:colorImage forState:UIControlStateSelected];
        
        [cell.phoneNumberButton setBackgroundImage:colorImage forState:UIControlStateHighlighted];
        [cell.phoneNumberButton setBackgroundImage:colorImage forState:UIControlStateSelected];
        
        
        
        [cell.phoneNumberButton addTarget:self action:@selector(phoneNumberPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.streetNameButton addTarget:self action:@selector(streetNamePressed) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.facebookButton addTarget:self action:@selector(facebookPressed) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.websiteButton addTarget:self action:@selector(websitePressed) forControlEvents:UIControlEventTouchUpInside];
        
        // cell.facebookButton.backgroundColor = [UIColor whiteColor];
        [cell.facebookButton setBackgroundImage:nil forState:UIControlStateNormal];
        cell.facebookButton.layer.borderWidth = 1;
        //  cell.facebookButton.layer.borderColor = [[UIColor colorWithRed:0.00 green:0.60 blue:0.80 alpha:1.0]CGColor];
        cell.facebookButton.layer.borderColor = [[UIColor whiteColor]CGColor];
        
        cell.facebookButton.layer.cornerRadius = 6.0f;
        
        
        //  cell.websiteButton.backgroundColor = [UIColor whiteColor];
        [cell.websiteButton setBackgroundImage:nil forState:UIControlStateNormal];
        cell.websiteButton.layer.borderWidth = 1;
        // cell.websiteButton.layer.borderColor = [[UIColor colorWithRed:0.00 green:0.60 blue:0.80 alpha:1.0]CGColor];
        cell.websiteButton.layer.borderColor = [[UIColor whiteColor]CGColor];
        
        cell.websiteButton.layer.cornerRadius = 6.0f;
        
        NSString *fb_link = [_bar objectForKey:@"fb_link"];
        if (fb_link.length == 0) {
            cell.facebookButton.hidden = YES;
        }
        
        NSString *url = [_bar objectForKey:@"url"];
        if (url.length == 0) {
            cell.websiteButton.hidden = YES;
        }
        
        PFGeoPoint *geoPoint =[_bar objectForKey:@"location"];
        
        cell.mapView.userInteractionEnabled = NO;
        cell.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude), MKCoordinateSpanMake(0.01f, 0.01f));
        
        // add the annotation
        GeoPointAnnotation2 *annotation = [[GeoPointAnnotation2 alloc] initWithObject:_bar];
        [cell.mapView addAnnotation:annotation];
        
        
        
        
        
        
        
        
        return cell;
        
        
    }
    else if (indexPath.row == 2){
        
        //descriptionview
        //resize to textsize
        
        static NSString *CellIdentifier = @"Description";
        
        ClubDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        cell.descriptionTextView.text = [_bar objectForKey:@"description"];
        cell.descriptionTextView.scrollEnabled = NO;
        
        cell.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, cell.bounds.size.width);
        
        
        CGRect frame = cell.descriptionTextView.bounds;
        
        // Take account of the padding added around the text.
        
        UIEdgeInsets textContainerInsets = cell.descriptionTextView.textContainerInset;
        UIEdgeInsets contentInsets = cell.descriptionTextView.contentInset;
        
        CGFloat leftRightPadding = textContainerInsets.left + textContainerInsets.right + cell.descriptionTextView.textContainer.lineFragmentPadding * 2 + contentInsets.left + contentInsets.right;
        CGFloat topBottomPadding = textContainerInsets.top + textContainerInsets.bottom + contentInsets.top + contentInsets.bottom;
        
        frame.size.width -= leftRightPadding;
        frame.size.height -= topBottomPadding;
        
        NSString *textToMeasure = cell.descriptionTextView.text;
        if ([textToMeasure hasSuffix:@"\n"])
        {
            textToMeasure = [NSString stringWithFormat:@"%@-", cell.descriptionTextView.text];
        }
        
        // NSString class method: boundingRectWithSize:options:attributes:context is
        // available only on ios7.0 sdk.
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        
        NSDictionary *attributes = @{ NSFontAttributeName: cell.descriptionTextView.font, NSParagraphStyleAttributeName : paragraphStyle };
        
        CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil];
        
        CGFloat measuredHeight = ceilf(CGRectGetHeight(size) + topBottomPadding);
        
        [cell.descriptionTextView sizeToFit];
        [cell.descriptionTextView layoutIfNeeded];
        
        
        CGRect helperFrame = cell.descriptionTextView.frame;
        
        helperFrame.size.height = measuredHeight*2;
        
        cell.descriptionTextView.frame = helperFrame;
        
        [cell.descriptionTextView sizeToFit];
        
        [cell.descriptionTextView layoutIfNeeded];
        
        CGSize size2 = [cell.descriptionTextView sizeThatFits:CGSizeMake(cell.descriptionTextView.frame.size.width, FLT_MAX)];
        
        //DLog(@"neue höhe: %f", size2.height);
        
        if (size2.height >_textHeight) {
            _textHeight = size2.height + 15;
        }
        
        
        
        if (_textHeight>15 && cell.descriptionTextView.text.length>0 && _tableReloaded==NO) {
            
            
            NSArray *indexPathArray = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]];
            
            [self.tableView reloadRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
        }
        
        return cell;
        
        
    }
    else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
       // cell.textLabel.text = [NSString stringWithFormat:@"Row %ld", indexPath.row+1];
        return cell;
        
        
    }
    // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    //  cell.textLabel.text = [NSString stringWithFormat:@"Row %i", indexPath.row+1];
    
    
    // Configure the cell...
    
    //return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // return (indexPath.row % 2) ? 125 : 251;
    
    switch (indexPath.row) {

        case 0:{
            //hide offer cell if bar is not premium

            if([[_bar objectForKey:@"premium"]boolValue]){
                return 60;
            }
            else
                return 0;
        }
            break;
            
        case 1:
            return 150;
            break;
            
        case 3:{
            
            //resize height according to contentsize

            if (_textHeight>0) {
                // return _textHeight;
                return _textHeight;
                
            }
            else return 0;
            

            
            break;
        }
            
        case 4:
            return 80;
            break;
            
        case 5:
            return 45;
            break;
            
        default:
            break;
    }
    
    return 45;
    
    
}



-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    //not necessary
    //old function to hide the navigation bar
    
    // NSLog(@"content y: %f", self.tableView.contentOffset.y);
    if (_prepareForSegueSelected == NO) {
        
        if (self.tableView.contentOffset.y < -64) {

            _moreButton.hidden = NO;
            _backButton.hidden = NO;
            

            
        }
        else{
            
            _moreButton.hidden = YES;
            _backButton.hidden = YES;

            
        }
    }
    
}

//Detailansicht öffnen
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    
if ([segue.identifier isEqualToString:@"bonus"])
    {
        
        BarBonusViewController *bonusController =segue.destinationViewController;
        
        _prepareForSegueSelected = YES;
        
        bonusController.barId = [_bar objectId];
        bonusController.barName = [_bar objectForKey:@"name"];
        
        
        
        
        [bonusController setTitle:@"Prämien"];
        
    }
    
    
    
    
}

-(void)streetNamePressed{
    
    //prompt user if he wants to open maps to see directions

    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Maps öffnen"
                                                    message:@"Möchtest du dir die Route anzeigen lassen?"
                                                   delegate:nil
                                          cancelButtonTitle:@"Nein"
                                          otherButtonTitles:@"Ja", nil];
    alert.tag = 1;
    [alert show];
    
    
}

-(void)openMaps{
    
    NSLog(@"route anzeigen");
    PFGeoPoint *geoPoint = [_bar objectForKey:@"location"];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    
    GeoPointAnnotation *point = [[GeoPointAnnotation alloc] init];
    
    point.title = [_bar objectForKey:@"name"];
    //point.subtitle = [NSString stringWithFormat:@"Rating: %@", [object objectForKey:@"rating"]];
    
    point.coordinate = coordinate;
    
    NSString * country = [_bar objectForKey:@"country"];
    NSString * city = [_bar objectForKey:@"city"];
    NSString * street = [_bar objectForKey:@"street"];
    NSString * zip = [_bar objectForKey:@"zip"];
    
    
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
    
    
    point.phoneNumber = [_bar objectForKey:@"phoneNumber"];
    point.url = [_bar objectForKey:@"url"];
    
    
    _selectedStation = point;
    
    MKMapItem *mapItem = [_selectedStation mapItem];
    NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking};
    [mapItem openInMapsWithLaunchOptions:launchOptions];
}

-(void)websitePressed{
    //prompt user if he wants to open the webbrowser
    //but first check if website is available
    
    if ([_bar objectForKey:@"url"]) {
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Website öffnen"
                                                        message:@"Möchtest du die Website anzeigen?"
                                                       delegate:nil
                                              cancelButtonTitle:@"Nein"
                                              otherButtonTitles:@"Ja", nil];
        alert.tag = 4;
        [alert show];
    }
    else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Website öffnen"
                                                        message:@"Leider ist keine Website hinterlegt"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
}
-(void)openWebsite
{
    UIApplication *app = [UIApplication sharedApplication];
    [app openURL:[NSURL URLWithString:[_bar objectForKey:@"url"]]];
    
    
}

-(void)facebookPressed{
    //prompt user if he wants to open the facebook page
    //but first check if facebook url is available
    
    if ([_bar objectForKey:@"fb_link"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook öffnen"
                                                        message:@"Möchtest du zur Facebook Seite weitergeleitet werden?"
                                                       delegate:nil
                                              cancelButtonTitle:@"Nein"
                                              otherButtonTitles:@"Ja", nil];
        alert.tag = 3;
        [alert show];
        
    }
    else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook öffnen"
                                                        message:@"Leider ist keine Facebook Seite hinterlegt"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        
    }
    
    
    
}

-(void)openFacebookPage
{
    UIApplication *app = [UIApplication sharedApplication];
    [app openURL:[NSURL URLWithString:[_bar objectForKey:@"fb_link"]]];
    
    
    
}

-(void)phoneNumberPressed{
    //prompt user if he wants to call the number

    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Anrufen"
                                                    message:@"Möchtest du diese Nummer anrufen?"
                                                   delegate:nil
                                          cancelButtonTitle:@"Nein"
                                          otherButtonTitles:@"Ja", nil];
    alert.tag = 2;
    [alert show];
    
    
}

-(void)callPhoneNumber
{
    NSString *phoneNumber = [[_bar objectForKey:@"phone"] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    
    NSURL *phoneNumberURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNumber]];
    
    NSLog(@"phone: %@", phoneNumberURL);
    
    if(phoneNumber == nil){
        NSLog(@"keine nummer vorhanden");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fehler"
                                                        message:@"Keine Nummer vorhanden"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        
    }
    else if ([[UIApplication sharedApplication]canOpenURL:phoneNumberURL]){
        [[UIApplication sharedApplication] openURL:phoneNumberURL];
    }
    
    else{
        NSLog(@"kann nicht gewählt werden");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fehler"
                                                        message:@"Nummer kann nicht gewählt werden"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 1) {
        if (buttonIndex == 1) {
            // Open Maps
            [self openMaps];
        }
    }
    else if (actionSheet.tag == 2) {
        if (buttonIndex == 1) {
            // Call phoneNumber
            [self callPhoneNumber];
        }
    }
    else if (actionSheet.tag == 3) {
        if (buttonIndex == 1) {
            // Open facebook
            [self openFacebookPage];
        }
    }
    else if (actionSheet.tag == 4) {
        if (buttonIndex == 1) {
            // Open Website
            [self openWebsite];
        }
    }
    else if (actionSheet.tag == 5) {
        if (buttonIndex == 1) {
            // Send the user to the Settings for this app
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:settingsURL];
        }
    }
    
}

- (IBAction)favButtonPressed:(id)sender {
    //add or remove the club from the favorite list

    NSLog(@"fav pressed");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"neuerFav" object:nil];
    
    
    NSString *ID = _bar.objectId;
    
    for (int i = 0; i<[self.savedBars count]; i++) {
        
        NSString *barName =[self.savedBars objectAtIndex:i];
        
        if ([barName isEqualToString:ID]) {
            NSLog(@"Schon vorhanden");
            [self.savedBars removeObjectAtIndex:i];
            
            [self.savedBars writeToFile:[NSString stringWithFormat:@"%@/Documents/bars", NSHomeDirectory()] atomically:YES];
            
            NSLog(@"Größe von data array: %lu", (unsigned long)[self.savedBars count]);
           // _favButton.image = [UIImage imageNamed:@"star-white-line.jpg"];
            [_favBtn setImage:[UIImage imageNamed:@"favorites" ] forState:UIControlStateNormal];

            
            
            return;
            
        }
    }
    
    [self.savedBars addObject:ID];
    
    NSLog(@"Id wurde hinzugefügt: %@", ID);
    [self.savedBars sortUsingSelector:@selector(compare:)];
    
    [self.savedBars writeToFile:[NSString stringWithFormat:@"%@/Documents/bars", NSHomeDirectory()] atomically:YES];
   // _favButton.image = [UIImage imageNamed:@"star-white-filled.jpg"];
    [_favBtn setImage:[UIImage imageNamed:@"favoritesSelected" ] forState:UIControlStateNormal];

    
}

-(void)shareButtonTapped:(id)sender{
    
    NSString *identifier = [NSString stringWithFormat:@"bar/%@",_bar.objectId];
    BranchUniversalObject *branchUniversalObject = [[BranchUniversalObject alloc] initWithCanonicalIdentifier:identifier];
    // Facebook OG tags -- this will overwrite any defaults you set up on the Branch Dashboard
    branchUniversalObject.title = [_bar objectForKey:@"name"];
    branchUniversalObject.contentDescription = [_bar objectForKey:@"description"];
    
    //userinfo anhängen
    [branchUniversalObject addMetadataKey:@"barId" value:_bar.objectId];
    if ([PFUser currentUser]) {
        [branchUniversalObject addMetadataKey:@"user" value:[PFUser currentUser].objectId];
        
    }
    else {
        [branchUniversalObject addMetadataKey:@"user" value:@"not logged in"];
        
    }
    
    // Add any additional custom OG tags here
    [branchUniversalObject addMetadataKey:@"$og_title" value:[_bar objectForKey:@"name"]];
    [branchUniversalObject addMetadataKey:@"$og_description" value:[_bar objectForKey:@"description"]];
    
    
    BranchLinkProperties *linkProperties = [[BranchLinkProperties alloc] init];
    linkProperties.feature = @"bar_share";
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
    
    if ([_imageUrlString isEqualToString:@""]) {
        
        NSLog(@"Bild Url noch nicht gespeichert");
        PFFile *applicantResume = [_bar objectForKey:@"pic_Big"];
        // NSData *resumeData = [applicantResume getData];
        _imageUrlString = applicantResume.url;
        [branchUniversalObject addMetadataKey:@"$og_image_url" value:_imageUrlString];
        
        [branchUniversalObject registerView];
        
        
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
        
        [branchUniversalObject registerView];

        [branchUniversalObject showShareSheetWithLinkProperties:linkProperties
                                                   andShareText:@"Super amazing thing I want to share!"
                                             fromViewController:self
                                                    andCallback:^{
                                                        NSLog(@"finished presenting");
                                                    }];
        
        
    }
    
    
    
    
}



@end
