//
//  ClubViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 20.10.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import "ClubViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MasterCell.h"
#import "ClubDetailViewController.h"
#import <ParseUI/ParseUI.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "Branch.h"
#import "BranchUniversalObject.h"
#import "BranchLinkProperties.h"
#import "ClubMapViewController.h"



@interface ClubViewController ()<CLLocationManagerDelegate,UISearchDisplayDelegate, UISearchBarDelegate>{
    
}
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (weak, nonatomic) IBOutlet UISegmentedControl *orderControl;
@property (nonatomic, strong) PFQuery *distanceQuery;
@property (nonatomic, assign) NSInteger anzahlObjekte;
@property (nonatomic, assign) NSInteger hideNextPage;




@end

@implementation ClubViewController{
    CLLocationManager *locationManager;
    
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    //  self = [super initWithClassName:@"discos"];
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // Custom initialization
        
        // self.parseClassName = @"discos";
        self.textKey = @"name";
        [self loadData];
        
        
        self.parseClassName = @"Clubs";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 30;
        
    }
    return self;
}





- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadData];
    NSLog(@"stadt geladen: %@",self.stadt);
    

    //searchbar above tableview
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.tableView.tableHeaderView = self.searchBar;
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchBar.delegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.delegate = self;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    CGPoint offset = CGPointMake(0, self.searchBar.frame.size.height);
    self.tableView.contentOffset = offset;
    self.searchResults = [NSMutableArray array];
    
    
    
    
    self.navigationItem.title = @"Clubs";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wechsel:) name:@"stadtWechseln" object:nil];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@" " style:UIBarButtonItemStyleBordered target:nil action:nil];
    
#pragma  ios8 location erlaubnis
    
    //needs more testing
    //maybe not necessary because of same function in appdelegate
    
    //ckeck ios8 location permission
    
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        
        NSLog(@"reagiert auf requestalwaysauthorization");
        
    }
    
    if(IOS_NEWER_OR_EQUAL_TO_8){

        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        
        NSLog(@"erlaubnis erfragen");

        
        if (status == kCLAuthorizationStatusDenied) {
            NSLog(@"erlaubnis abgelehnt");
            

            //prompt the user to allow backgroundlocation in the settings
            
            
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
            
            
            

            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"startRanging" object:nil userInfo:nil];

        }
        // [_locationManager requestWhenInUseAuthorization];
        
        else if (status == kCLAuthorizationStatusNotDetermined) {
            NSLog(@"erlaubnis noch nicht erteilt");

            [locationManager requestAlwaysAuthorization];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"startRanging" object:nil userInfo:nil];


           // [locationManager requestWhenInUseAuthorization];
        }
        
        else if (status == kCLAuthorizationStatusAuthorizedWhenInUse){
            
            NSLog(@"erlaubnis always noch nicht erteilt");
            
            [locationManager requestAlwaysAuthorization];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"startRanging" object:nil userInfo:nil];
        }
        
        else{
            NSLog(@"erlaubnis erteilt");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"startRanging" object:nil userInfo:nil];

        }
        
    }
    
    
    else{
        NSLog(@"ios 7");
    }
    
    //helping variables to enable paginaging
    
    _hideNextPage = 0;
    
    _anzahlObjekte = 30;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showClub:) name:@"showClub" object:nil];


}

- (void)showClub:(NSNotification *) notification
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"Besonderer club wird im Vordergrund angezeigt");
    
    //directly open club if branch link is opened or push noification
    
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString *pushID = appDelegate.clubId;
    
    NSLog(@"pushid: %@",pushID);
    if ([pushID length] != 0) {
        appDelegate.clubId = nil;
        NSLog(@"push view öffnen");
        PFQuery *eventQuery = [PFQuery queryWithClassName:@"Clubs"];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        [eventQuery getObjectInBackgroundWithId:pushID block:^(PFObject *object, NSError *error) {
            if (!error) {
                [self performSegueWithIdentifier:@"pushSegue" sender:object];
                
            }
        }];
        
        
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"pressed");
    NSLog(@"%@",searchBar.text);
    
    [self filterResults:searchBar.text];
    
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)SearchBar
{
    [self.tableView reloadData];
    
}
- (IBAction)orderButtonPressed:(id)sender {
    [self queryForTableWithCompletionHandler:^(PFQuery *query) {
        // Now make use of query object
        [self loadObjects];
        
    }];
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    [query whereKey:@"city_pick" equalTo:_stadt];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    switch (_orderControl.selectedSegmentIndex) {
        case 0:
            [query orderByAscending:@"name"];
            return query;
            
            
            break;
        case 1:
        {

            return _distanceQuery;
        }
            
            break;
            
        default:
            return query;
            
            break;
    }
    
}

-(void)queryForTableWithCompletionHandler:(void(^)(PFQuery*))completionHandler
{
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        
        [query whereKey:@"city_pick" equalTo:_stadt];
        [query whereKey:@"location" nearGeoPoint:geoPoint];
        
        
        // Instead of return
        // return query;
        // call completion block here
        _distanceQuery = query;
        completionHandler(query);
        
        // [self loadObjects];
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    
    self.navigationController.navigationBar.alpha = 1.0;
    
}

-(void)filterResults:(NSString *)searchTerm {
    NSLog(@"neue suche: %@", searchTerm);
    
    [self.searchResults removeAllObjects];
    
    PFQuery *query = [PFQuery queryWithClassName: self.parseClassName];

    [query whereKey:@"city_pick" equalTo:_stadt];
    
    [query whereKey:@"name" containsString:searchTerm];
    
    [query orderByAscending:@"name"];


    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error) {
            NSLog(@"objekte: %li",(unsigned long)objects.count);
            //  NSLog(@"2: %@", objects[1]);
            [self.searchResults removeAllObjects];
            [self.searchResults addObjectsFromArray:objects];
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
        else{
            NSLog(@"error bei callback");
        }
        
    }];
    
}

- (void)callbackWithResult:(NSArray *)objects error:(NSError *)error
{
    NSLog(@"callback");
    if(!error) {
        [self.searchResults removeAllObjects];
        [self.searchResults addObjectsFromArray:objects];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    else{
        NSLog(@"error bei callback");
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object {
    
    if (self.objects.count >= _anzahlObjekte
        && indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {

        //if last cell show load more cell
        
        NSLog(@"mehr aden zelle laden");
                UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        return cell;
        
    }
    
    static NSString *CellIdentifier = @"ClubCell";
    
    MasterCell *cell = (MasterCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        NSLog(@"was");
        cell = [[MasterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    
    if (tableView != self.searchDisplayController.searchResultsTableView) {
        
        
        if (object) {
            cell.IconImageView.file = [object objectForKey:@"pic_Small"];
            [cell.IconImageView loadInBackground];
            
            
            // PFQTVC will take care of asynchronously downloading files, but will only load them when the tableview is not moving. If the data is there, let's load it right away.
            if ([cell.IconImageView.file isDataAvailable]) {
                [cell.IconImageView loadInBackground];
            }
            
            
        }

        
        cell.IconImageView.layer.cornerRadius = 27.0f;
        cell.IconImageView.layer.borderWidth = 1.0f;
        cell.IconImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.IconImageView.clipsToBounds = YES;
        
        cell.TitleLabel.text = [object objectForKey:@"name"];
        
        if([[object objectForKey:@"premium"]boolValue]){
            cell.premiumView.hidden = NO;
        }
        else{
            cell.premiumView.hidden = YES;
            
        }
        
        
        
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            if (!error) {
                // do something with the new geoPoint
                double distanz = [geoPoint distanceInKilometersTo:[object objectForKey:@"location"]];
                cell.SubtitleLabel.text = [NSString stringWithFormat:@"Distanz: %.2f km", distanz];
                
            }
        }];
        
        [cell.TitleLabel setTextColor:[UIColor colorWithRed:0 green:0.592 blue:0.655 alpha:1]];
        
        [cell.SubtitleLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
        
        //get branch link for spotlight search
        
        NSString * identifier = [NSString stringWithFormat:@"club/%@",object.objectId];
        BranchUniversalObject *branchUniversalObject = [[BranchUniversalObject alloc] initWithCanonicalIdentifier:identifier];
        branchUniversalObject.title = [object objectForKey:@"name"];
        branchUniversalObject.contentDescription = [object objectForKey:@"description"];
        PFFile *bigImage = [object objectForKey:@"pic_Big"];
        branchUniversalObject.imageUrl = bigImage.url;
        [branchUniversalObject addMetadataKey:@"clubId" value:object.objectId];
        
        
        [branchUniversalObject listOnSpotlightWithCallback:^(NSString *url, NSError *error) {
            if (!error) {
               // NSLog(@"success getting url! %@", url);
            }
        }];
        
    }
    
    
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        NSLog(@"suchliste anzeigen");
        static NSString *CellIdentifier = @"SearchCell";
        
        
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        
        PFObject *obj3 = [self.searchResults objectAtIndex:indexPath.row];

        cell.textLabel.text = [obj3 objectForKey:@"name"];
        cell.textLabel.textColor = [UIColor blackColor];

        return cell;

    }
    
    
    
    
    return cell;
    
}

-(CALayer *)createShadowWithFrame:(CGRect)frame
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = frame;
    
    
    UIColor* lightColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    UIColor* darkColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    
    gradient.colors = [NSArray arrayWithObjects:(id)darkColor.CGColor, (id)lightColor.CGColor, nil];
    
    return gradient;
}


//Load more.. Zeile
- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    // Override to customize the look of the cell that allows the user to load the next page of objects.
    // The default implementation is a UITableViewCellStyleDefault cell with simple labels.
    static NSString *CellIdentifier = @"NextPage";
    NSLog(@"next page loaded");
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    [cell.textLabel setTextColor:[UIColor colorWithRed:0 green:0.592 blue:0.655 alpha:1]];
    
    [cell.textLabel setShadowColor:[UIColor whiteColor]];
    [cell.textLabel setShadowOffset:CGSizeMake(0, 1)];
    
    
    cell.textLabel.text = @"Mehr laden...";
    
    return cell;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSLog(@"jetzt laden %@", searchString);
    //[self filterResults:searchString];
    return NO;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    

    if (tableView == self.tableView) {
        //if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSLog(@"normale tabelle");
        NSLog(@"objects: %li anzahl: %li", self.objects.count, _anzahlObjekte);
        //|| self.objects.count == 0
        if (self.objects.count >= _anzahlObjekte ) {
            NSLog(@"mehr laden anzeigen");
            //show load more cell
            
            _hideNextPage = 0;

            return self.objects.count + 1;
        } else {
            NSLog(@"mehr laden weg");
            
            //Do not show load more cell
            _hideNextPage = 1;

            return self.objects.count;
        }
        /*
        //return self.objects.count;
        if ((self.objects.count>=_anzahlObjekte) || self.objects.count == 0) {
            if (self.objects.count < 50) {
                
                // NSLog(@"unter 50?");
                return  self.objects.count;
            }
            else{
                //  NSLog(@"neue laden");
                _hideNextPage = 0;
                return self.objects.count+1;
            }
        }
        
        else {
            //  NSLog(@"keine neue laden");
            
            _hideNextPage = 1;
            return self.objects.count;
        }
         */

        
    } else {
        NSLog(@"results: %li",(unsigned long)self.searchResults.count);
        return self.searchResults.count;
        
    }
    
}

-(IBAction)back: (UIStoryboardSegue *) segue{
    
    
}


//Detailansicht öffnen
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    
    if ([segue.identifier isEqualToString:@"detail"])
    {
        
        ClubDetailViewController *detailController =segue.destinationViewController;
        
        NSLog(@"aufgerufen");
        
        if (self.tableView != self.searchDisplayController.searchResultsTableView) {
            if (self.searchDisplayController.active) {
                NSLog(@"suche");
                
                //open detailview via the search
                
                
                PFObject *selectedObject2 = [self.searchResults objectAtIndex: self.searchDisplayController.searchResultsTableView.indexPathForSelectedRow.row];
                NSString *title = [selectedObject2 objectForKey:@"name"];
                
                NSLog(@"title: %@", title);
                
                detailController.club = selectedObject2;
                
                [detailController setTitle:title];
                
            }
            else{
                
                
                
                PFObject *selectedObject2 = [self objectAtIndexPath:self.tableView.indexPathForSelectedRow];
                
                NSString *title = [selectedObject2 objectForKey:@"name"];
                
                NSLog(@"title: %@", title);
                
                detailController.club = selectedObject2;
                
                [detailController setTitle:title];
            }
        }
        else if ([self.tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
            
            NSLog(@"2te ");

            
        }
        else NSLog(@"wierd");
    }
    
    else if ([segue.identifier isEqualToString:@"pushSegue"]) {
        
        
        //open detailview from push notification or branch link
        
        ClubDetailViewController *detailController =segue.destinationViewController;
        
        
        if (sender ==nil) {
            NSLog(@"objekt wurde nicht geladen");
        }
        else{
            
            detailController.club = sender;
            [detailController setTitle:[sender objectForKey:@"name"]];
        }
        
        
    }
    
    else if ([segue.identifier isEqualToString:@"showMap"])
    {
        
        ClubMapViewController *mapController =segue.destinationViewController;
        
        
        mapController.hostType = @"club";
        
        
    }


    
    
    
    
    
}

//load city
-(void) loadData{
    
    
    //stadt = city
    self.stadt = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/stadt", NSHomeDirectory()] encoding:NSUTF8StringEncoding error:nil];
    
}

-(void) wechsel:(NSNotification *) notification{
    
    [self loadData];

    [self loadObjects];
    
    //reload tableview because of city change
    
    NSLog(@"city change clubs");
    
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 1) {
        if (buttonIndex == 1) {
            // Send the user to the Settings for this app
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:settingsURL];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    
    if (indexPath.row == self.objects.count && _hideNextPage == 0) {
        NSLog(@"-------------------wird neu geladen");
        _anzahlObjekte = _anzahlObjekte+30;
      //  [self loadNextPage];
        
    }
    
}




@end
