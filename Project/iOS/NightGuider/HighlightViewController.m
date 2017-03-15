//
//  HighlightViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 20.10.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import "HighlightViewController.h"
#import "MasterCell.h"


#import "CityViewController.h"
#import "EventDetailViewController.h"


#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "Branch.h"
#import "BranchUniversalObject.h"
#import "BranchLinkProperties.h"


@interface HighlightViewController ()<UIAlertViewDelegate>

@end

@implementation HighlightViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // Custom initialization
        
        
        [self loadData];

        
        self.parseClassName = @"Events";
        self.textKey = @"name";
        
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 50;
        
        self.sections = [NSMutableDictionary dictionary];
        self.sectionToSportTypeMap = [NSMutableDictionary dictionary];
        
    
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //loadcity
    [self loadData];
    
    
    if ( !self.stadt) {
        
        //if city is not selected show citypicker
        [self performSegueWithIdentifier:@"changeCity" sender:self];
        
        
    }
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.navigationItem.title = self.cityName;
    
    

    
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@" " style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showEvent:) name:@"showEvent" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wechsel:) name:@"stadtWechseln" object:nil];
    

    
    // Remove the separator lines for empty cells
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
        self.tableView.tableFooterView = footerView;
        self.tableView.separatorColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    //helper variables for panigination
    _anzahl=self.objectsPerPage;
    
    _hideNextPage = 0;
    _anzahlObjekte = 50;
    
    
    [self loadData];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PFQueryTableViewController
//This method is called every time objects are loaded from Parse via the PFQuery

- (void)objectsDidLoad:(NSError *)error {
    
    //from previous exmaple taken where table was divided by sports
    
    [super objectsDidLoad:error];
    
    
    [self.sections removeAllObjects];
    [self.sectionToSportTypeMap removeAllObjects];
    
    
    
    NSInteger section = 0;
    NSInteger rowIndex = 0;
    
    DLog(@"neue objekte: %lu",(unsigned long)self.objects.count);
    
    for (PFObject *object in self.objects) {
        
        
        NSDate * zeit = [object objectForKey:@"start_time"];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        
        /*
         df.dateStyle = NSDateFormatterShortStyle;
         df.timeStyle = NSDateFormatterNoStyle;
         */
        
        df.timeZone = [NSTimeZone localTimeZone];
        
        [df setDateFormat:@"ccc, dd.MM.YY"];
        
        NSString *header = [df stringFromDate:zeit];
        
        NSMutableArray *objectsInSection = [self.sections objectForKey:header];
        if (!objectsInSection) {
            objectsInSection = [NSMutableArray array];
            
            
            [self.sectionToSportTypeMap setObject:header forKey:[NSNumber numberWithInt:(int)section++]];
        }
        
        [objectsInSection addObject:[NSNumber numberWithInt:(int)rowIndex++]];
        [self.sections setObject:objectsInSection forKey:header];
        
    }

    [self.tableView reloadData];
    
}



//Anfrage bei Parse
- (PFQuery *)queryForTable {
    
    [self loadData];
    
    self.parseClassName = @"Events";
    
    
    
    NSLog(@"querytable klasse: %@\nstadt: %@", self.parseClassName, self.stadt);
    
    self.navigationItem.title = self.cityName;
    
    //PFQuery *query = [PFQuery queryWithClassName:[NSString stringWithFormat:@"%@_Events",self.stadt]];
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    
    if (self.stadt) {
        
        [query whereKey:@"city_pick" equalTo:self.stadt];
    }
    
    
    // If Pull To Refresh is enabled, query against the network by default.
    
    // [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    
    if (self.pullToRefreshEnabled) {
        // query.cachePolicy = kPFCachePolicyNetworkOnly;
        
        query.cachePolicy = kPFCachePolicyNetworkElseCache;
        
    }
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        
        
        
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    NSDate *today = [NSDate date];
    [query whereKey:@"end_time" greaterThan:today];
    
    [query orderByAscending:@"special"];
    [query orderByAscending:@"start_time"];
    
    
    return query;
}

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
 //   NSLog(@"objectatindexpath: %li, row %li", indexPath.section, indexPath.row);
    if (indexPath.section < self.objects.count) {
        
        NSString * header = [self EventDateForSection:indexPath.section];
        NSArray *rowIndecesInSection = [self.sections objectForKey:header];
        NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row];
        
        return [self.objects objectAtIndex:[rowIndex intValue]];
    }
    
    return nil;
}



#pragma mark - UITableViewDataSource
//Anzahl der Sektionen
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSInteger sections = self.sections.allKeys.count;
    
    _sektion = sections;
    if (self.objects.count == 50) {
        _anzahlObjekte = 50;
    }
    if (self.objects.count >50 && self.objects.count <=100){
        _secondPage = 1;
        _hideNextPage = 0;
        return sections;
        
        
        
    }
    else{
        _secondPage = 0;
    }
    
    
   // NSLog(@"objekte geladen: %li alte objekte: %li",(unsigned long)self.objects.count,_anzahlObjekte);
    
    
    if ((self.objects.count>=_anzahlObjekte) || self.objects.count == 0) {
        if (self.objects.count < 50) {
            
           // NSLog(@"unter 50?");
            return  sections;
        }
        else{
          //  NSLog(@"neue laden");
            _hideNextPage = 0;
            return sections+1;
        }
    }
    
    else {
      //  NSLog(@"keine neue laden");
        
        _hideNextPage = 1;
        return sections;
    }
    
    
}

//Anzahl der Reihen in einer Sektion
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSString *header = [self EventDateForSection:section];
    
    NSArray *rowIndecesInSection = [self.sections objectForKey:header];

    
    if(section>_sektion){
       // NSLog(@"+++++++++++++++section nicht gleich sektion");
        
    }
    
    // NSLog(@"row in section: %i",rowIndecesInSection.count);
    if (section==_sektion) {
        _reihe = rowIndecesInSection.count;
#warning vlt auch null lassen?
        
      //  NSLog(@"objekte geladen: %li alte objekte: %li sections: %li sektion: %li",(unsigned long)self.objects.count,_anzahlObjekte,_sections.count, _sektion);
        
        return 1;
        
    }
    
    
    
    return rowIndecesInSection.count;
    
}

//Überschrift der Sektionen
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterShortStyle;
    df.timeStyle = NSDateFormatterNoStyle;
    df.timeZone = [NSTimeZone localTimeZone];
    NSString *header = [self EventDateForSection:section];

    return header;
}

//HeaderStyle
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    
    UIImageView *nav=[[UIImageView alloc] initWithFrame:CGRectMake(0, -1, 320, 24)];
    
    [view addSubview:nav];
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(10, -9, 320, 40);
    label.backgroundColor = [UIColor clearColor];
    
    label.textColor = [UIColor colorWithHue:(136.0/360.0)  // Slightly bluish green
                                 saturation:1.0
                                 brightness:0.60
                                      alpha:1.0];
    
    
    
    label.textColor = [UIColor whiteColor];

    label.font = FONT_HELVETICA(15);
    
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterShortStyle;
    df.timeStyle = NSDateFormatterNoStyle;
    df.timeZone = [NSTimeZone localTimeZone];
    
    
    NSString *header = [self EventDateForSection:section];
    
    label.text = header;
    
    
    [view addSubview:label];
    
    
    //Schatten von unten bei bar
    
    CAGradientLayer *l = [CAGradientLayer layer];

    l.frame = CGRectMake(0, 12, 322, 20);
    
    
    UIColor* startColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    UIColor* endColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    l.colors = [NSArray arrayWithObjects:(id)startColor.CGColor, (id)endColor.CGColor, nil];
    UIColor* bgColor3 = [UIColor colorWithRed:0 green:0.592 blue:0.655 alpha:1];

    [view setBackgroundColor:bgColor3];
    
    
    return view;
    
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    
    if (indexPath.section==_sektion && indexPath.row == 0 && _hideNextPage == 0) {
        NSLog(@"-------------------ende");
        _anzahlObjekte = _anzahlObjekte+50;
        [self loadNextPage];
        
    }
    
}


#pragma mark - ()

- (NSString *)EventDateForSection:(NSInteger)section {
    
    return [self.sectionToSportTypeMap objectForKey:[NSNumber numberWithInt:(int)section]];
}

//Anzeige in der Zelle
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object {

    if (indexPath.section==_sektion && indexPath.row == 0 && _hideNextPage == 0) {
        NSLog(@"next cell laden");
        //[self loadNextPage];
        
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        
        return cell;

    }
    
    
    
    
    static NSString *CellIdentifier = @"Cell";
    
    
    MasterCell *cell = (MasterCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[MasterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Boolean sp = [[object objectForKey:@"special"] boolValue];
    
    if (sp) {
        NSLog(@"YES - %@", [object objectForKey:@"name"]);
        
        //orangeGelb
        cell.contentView.backgroundColor = [UIColor colorWithRed:1 green:0.757 blue:0.027 alpha:1];
        
        [cell.TitleLabel setTextColor:[UIColor whiteColor]];
        [cell.SubtitleLabel setTextColor:[UIColor whiteColor]];
        [cell.DateLabel setTextColor:[UIColor whiteColor]];
        
        
    }
    else {
        

        cell.contentView.backgroundColor = [UIColor whiteColor];
        
        
        //dunkelcyan
        [cell.TitleLabel setTextColor:[UIColor colorWithRed:0 green:0.592 blue:0.655 alpha:1]];
        
        [cell.SubtitleLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
        [cell.DateLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
        
        
        
    }
    
    if([[object objectForKey:@"isGay"]boolValue]){
        cell.gayView.hidden = NO;
    }
    else{
        cell.gayView.hidden = YES;
        
    }
    if([[object objectForKey:@"isUnderEighteen"]boolValue]){
        cell.underEighteenView.hidden = NO;
    }
    else{
        cell.underEighteenView.hidden = YES;
        
    }
    if([[object objectForKey:@"isOverThirty"]boolValue]){
        cell.overThirtyView.hidden = NO;
    }
    else{
        cell.overThirtyView.hidden = YES;
        
    }
    
    cell.TitleLabel.text = [object objectForKey:@"name"];
    
    
    cell.SubtitleLabel.text = [object objectForKey:@"host"];
    
    NSDate * zeit = [object objectForKey:@"start_time"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterNoStyle;
    df.timeStyle = NSDateFormatterShortStyle;
    df.timeZone = [NSTimeZone localTimeZone];
    
    NSString *header = [df stringFromDate:zeit];
    cell.DateLabel.text = header;
    
    PFFile *thumbnail = [object objectForKey:@"image"];
    cell.TestImageView.file = thumbnail;
    
    cell.TestImageView.layer.cornerRadius = 28.0f;
    cell.TestImageView.layer.borderWidth = 1.0f;
    cell.TestImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.TestImageView.clipsToBounds = YES;
    
    [cell.TestImageView loadInBackground];
    
    
    //get branch links for spotlight search
    
    NSString * identifier = [NSString stringWithFormat:@"event/%@",object.objectId];
    BranchUniversalObject *branchUniversalObject = [[BranchUniversalObject alloc] initWithCanonicalIdentifier:identifier];
    branchUniversalObject.title = [object objectForKey:@"name"];
    branchUniversalObject.contentDescription = [object objectForKey:@"description"];
    branchUniversalObject.imageUrl = thumbnail.url;
   // branchUniversalObject.keywords = @[@"event",@"party",_stadt,@"disco",@"club",@"bar"];
    [branchUniversalObject addMetadataKey:@"eventId" value:object.objectId];
    

    [branchUniversalObject listOnSpotlightWithCallback:^(NSString *url, NSError *error) {
        if (!error) {
           // NSLog(@"success getting url! %@", url);
        }
    }];
    
    
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
    
    
    //load more cell
    
   // NSLog(@"Mehr Laden!!!");
   // NSLog(@"indexpathsection: %li row: %li", indexPath.section, indexPath.row);
    static NSString *CellIdentifier = @"NextPage";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //  [cell.textLabel setTextColor:[UIColor colorWithRed:0.0 green:68.0/255 blue:118.0/255 alpha:1.0]];
    [cell.textLabel setTextColor:[UIColor colorWithRed:0 green:0.592 blue:0.655 alpha:1]];
    
    [cell.textLabel setShadowColor:[UIColor whiteColor]];
    [cell.textLabel setShadowOffset:CGSizeMake(0, 1)];
    
    cell.textLabel.text = @"Mehr laden...";
    // _anzahlObjekte = _anzahlObjekte+50;
   // NSLog(@"anzahl: %li", _anzahlObjekte);
    
    
    return cell;
}



- (NSIndexPath *)_indexPathForPaginationCell {
    
  //  NSLog(@"-------pagination bei sektion: %li", _sektion);
    
    if (_secondPage == 1) {
        return [NSIndexPath indexPathForRow:0 inSection:_sektion-1];
    }
    
    return [NSIndexPath indexPathForRow:0 inSection:_sektion];
    
}



-(void) wechsel:(NSNotification *) notification{
    
    [self loadData];
    self.navigationItem.title = self.cityName;
    NSLog(@"neue stadt: %@",_cityName);
    //NSLog(@"stadt wechsel zu %@",[NSString stringWithFormat:@"%@_Events",self.stadt]);
    //  [self.tableView reloadData];
    [self loadObjects];
    NSLog(@"stadt wechsel");
    
}



- (void)showEvent:(NSNotification *) notification
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"Besonderes Event wird im Vordergrund angezeigt");
    
    
    //directly open event because of branch link or push notifications
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString *pushID = appDelegate.eventId;
    
    
    if ([pushID length] != 0) {
        appDelegate.eventId = nil;
        NSLog(@"push view öffnen");
        PFQuery *eventQuery = [PFQuery queryWithClassName:@"Events"];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        [eventQuery getObjectInBackgroundWithId:pushID block:^(PFObject *object, NSError *error) {
            if (!error) {
                [self performSegueWithIdentifier:@"pushSegue" sender:object];
                
            }
        }];
        
        
    }
    
    
}


-(void) showPushEvent:(NSNotification *) notification{
    
    
    //directly open event because of push notifications


    
    NSString *pushID =[[notification userInfo] objectForKey:@"push_id"];
    
    NSLog(@"zeigen aufgerufen id: %@", pushID);
    
    if ([pushID length] != 0) {
        NSLog(@"push view öffnen!!!");
        PFQuery *eventQuery = [PFQuery queryWithClassName:@"Events"];
        
        [eventQuery getObjectInBackgroundWithId:pushID block:^(PFObject *object, NSError *error) {
            if (!error) {
                [self performSegueWithIdentifier:@"pushSegue" sender:object];
                
            }
        }];
        
    }
    
    
    
}


//load city
-(void) loadData{
    
    
    //stadt = city
    
    self.stadt = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/stadt", NSHomeDirectory()] encoding:NSUTF8StringEncoding error:nil];

    self.cityName = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/cityName", NSHomeDirectory()] encoding:NSUTF8StringEncoding error:nil];
    
    //cityName exmaple: Munich
    //city example: munich

    
    
}

//save city
-(void) saveData{
    
    
    //city = stadt
    [self.stadt writeToFile:[NSString stringWithFormat:@"%@/Documents/stadt", NSHomeDirectory()] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    
}

-(IBAction)start: (UIStoryboardSegue *) segue{
    NSLog(@"start");
    
    
    
    NSLog(@"dismiss");
    [self dismissViewControllerAnimated:NO completion:^{
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
        {
            
            NSLog(@"app already launched");
            
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
        }
    }];
    
    
    
}

-(void)refresh{
    NSLog(@"refresh");
    [self.tableView reloadData];
    
}


//Detailansicht öffnen
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    
    if ([segue.identifier isEqualToString:@"Detail"])
    {
        
        EventDetailViewController *detailController =segue.destinationViewController;
        
        PFObject *selectedObject = [self objectAtIndexPath:self.tableView.indexPathForSelectedRow];
        
        NSString *title = [selectedObject objectForKey:@"name"];
        
        NSLog(@"title: %@", title);
        
        detailController.event = selectedObject;
        
        
        
        [detailController setTitle:title];
        self.navigationController.delegate = self;
        
        //detailController.hidesBottomBarWhenPushed = YES;
        
        
        
        
    }
    
    
    
    
    if ([segue.identifier isEqualToString:@"pushSegue"]) {
        
        EventDetailViewController *detailController =segue.destinationViewController;
        
        
        if (sender ==nil) {
            NSLog(@"objekt wurde nicht geladen");
        }
        else{
            
            detailController.event = sender;
            [detailController setTitle:[sender objectForKey:@"name"]];
        }
        
        
    }
    
    
    
    
}

- (IBAction)done:(UIStoryboardSegue *)segue {
    NSLog(@"done");
}


- (void)cityViewControllerDone:(CityViewController *)controller
{
    NSLog(@"dismiss");
    [self dismissViewControllerAnimated:NO completion:^{
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
        {
            // app already launched
            //  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"HasLaunchedOnce"];
            //[PFUser currentUser];
            //  [PFUser logOut];
            
            NSLog(@"app already launched");
            // [[NSNotificationCenter defaultCenter] postNotificationName:@"stadtWechseln" object:nil];
            // [self loadObjects];
            
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            // [[NSNotificationCenter defaultCenter] postNotificationName:@"MyLoginAnzeigen" object:nil];
            
            //Fbrequest
            //  [self login];
            
            
            
        }
    }];
    
}
 




- (IBAction)cityPickButtonPressed:(id)sender {


    //ask if city should change
    
    //Stadt wechseln? = Change City?
    //Nein = NO
    //Ja = YES
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:_cityName
                                                        message:@"Stadt wechseln?"
                                                       delegate:self
                                              cancelButtonTitle:@"Nein"
                                              otherButtonTitles:@"Ja", nil];
    alertView.tag = 1;
    [alertView show];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 1) {
        if (buttonIndex == 1) {
            // Change city
            [self performSegueWithIdentifier:@"changeCity" sender:self];
        }
    }
}



@end


