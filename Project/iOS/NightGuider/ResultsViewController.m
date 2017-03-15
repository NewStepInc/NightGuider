//
//  ResultsViewController.m
//  Nightlife_2
//
//  Created by Werner on 04.12.12.
//  Copyright (c) 2012 Werner. All rights reserved.
//

#import "ResultsViewController.h"
#import "EventDetailViewController.h"
#import "MasterCell.h"

#import <QuartzCore/QuartzCore.h>

@interface ResultsViewController ()

@end

@implementation ResultsViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // Custom initialization

            self.parseClassName = @"Events";

        
        self.textKey = @"name";
        self.imageKey = @"image";
    
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 20;
        
        
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self loadCity];

    
    _df.dateStyle = NSDateFormatterShortStyle;
    _df.timeStyle = NSDateFormatterNoStyle;
    
    _df.timeZone = [NSTimeZone localTimeZone];
    

    
    // Remove the separator lines for empty cells
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
        self.tableView.tableFooterView = footerView;
        self.tableView.separatorColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];

    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - PFQueryTableViewController

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
}


// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    [self loadCity];

    NSLog(@"stadt %@",_stadt);
    PFQuery *query = [PFQuery queryWithClassName:@"Events"];
    [query whereKey:@"city_pick" equalTo:_stadt];
    

    
    NSLog(@"wird geladen");

    
    
    
    
    // If Pull To Refresh is enabled, query against the network by default.
    if (self.pullToRefreshEnabled) {
     //   query.cachePolicy = kPFCachePolicyNetworkOnly;

        query.cachePolicy = kPFCachePolicyNetworkElseCache;

    }
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {

        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    
    [query orderByAscending:@"start_time"];

    [query orderByAscending:@"name"];

    
    if ([_dateSwitch isEqualToString:@"YES"]) {
        
        NSLog(@"datum: %@", _date);
        
        // Nach zeit suchen
        
        [query whereKey:@"end_time" greaterThan:_date];
        [query whereKey:@"start_time" lessThanOrEqualTo:_date];
        
    }
    
    else {
        
        NSDate *today = [NSDate date];

        [query whereKey:@"end_time" greaterThan:today];

    }
    
     
    return query;
}
/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (self.objects.count>0&&self.objects!=nil) {
        <#statements#>
    }
}

*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.objects.count>0&&self.objects!=nil) {
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
        
    } else {
        
     //   NSLog(@"objects: %@ anzahl: %li",self.objects, self.objects.count);
        
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
             //   UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        //messageLabel.text = @"No data is currently available. \nPlease pull down to refresh.";
        messageLabel.text = @"1_Derzeit liegen keine Events\nfür dieses Datum vor.";

        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        //messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
      //  [messageLabel sizeToFit];
        
       // [self.view addSubview:messageLabel];
        
        NSLog(@"anzeigen");
     //   _messageLabel.text = @"2_Derzeit liegen keine Events\nfür dieses Datum vor.";
        
        _messageLabel.textColor = [UIColor blackColor];
        _messageLabel.numberOfLines = 0;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.hidden = NO;


        
        
        self.tableView.backgroundView = _messageLabel;
       // self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    
    return 0;
}

//Load more.. Zeile
- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    // Override to customize the look of the cell that allows the user to load the next page of objects.
    // The default implementation is a UITableViewCellStyleDefault cell with simple labels.
    
    static NSString *CellIdentifier = @"NextPage";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    //UIImage* bg = [UIImage imageNamed:@"ipad-list-element.png"];
    
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.textLabel setTextColor:[UIColor colorWithRed:0.0 green:68.0/255 blue:118.0/255 alpha:1.0]];
    [cell.textLabel setShadowColor:[UIColor whiteColor]];
    [cell.textLabel setShadowOffset:CGSizeMake(0, 1)];
    
    
    cell.textLabel.text = @"Mehr laden...";
    
    return cell;
}


// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the textKey in the object,
// and the imageView being the imageKey in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    NSLog(@"läd zelle");
    
    NSDateFormatter *dfi = [[NSDateFormatter alloc] init];
    dfi.dateStyle = NSDateFormatterShortStyle;
    dfi.timeStyle = NSDateFormatterNoStyle;
    dfi.timeZone = [NSTimeZone localTimeZone];

    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterNoStyle;
    df.timeStyle = NSDateFormatterShortStyle;
    df.timeZone = [NSTimeZone localTimeZone];
    
    
    
    NSDate * time = [object objectForKey:@"start_time"];
    NSString *zeit = [dfi stringFromDate:time];
    NSString *uhrzeit = [df stringFromDate:time];

    NSDate * ende = [object objectForKey:@"end_time"];

    NSString *schluss = [df stringFromDate:ende];
    
    NSLog(@"objects: %@ anzahl: %li",self.objects, (unsigned long)self.objects.count);



    
    static NSString *CellIdentifier = @"Cell";
    
    
    MasterCell *cell = (MasterCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[MasterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }


    cell.TitleLabel.text = [object objectForKey:@"name"];
    NSLog(@"Eventname: %@", [object objectForKey:@"name"]);
    
    //cell.SubtitleLabel.text = [NSString stringWithFormat:@"Datum: %@", zeit];
    cell.SubtitleLabel.text = zeit;

    //cell.DateLabel.text = uhrzeit;
    cell.DateLabel.text = [NSString stringWithFormat:@"%@ - %@", uhrzeit,schluss];

    Boolean sp = [[object objectForKey:@"special"] boolValue];
    
    if (sp) {
        
        NSLog(@"%@ ist specialevent", [object objectForKey:@"name"]);
        //Get nur wenn Image in MasterCell deaktiviert ist
        UIImage *bg = [UIImage imageNamed:@"special-list-element.png"];
        [cell.BgImageView setImage:bg];
    }
    else {
        UIImage* bg = [UIImage imageNamed:@"ipad-list-element.png"];
        [cell.BgImageView setImage:bg];
        
        
    }
    
    [cell.TitleLabel setTextColor:[UIColor colorWithRed:0 green:0.592 blue:0.655 alpha:1]];
    
    [cell.SubtitleLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
    [cell.DateLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];

    
    PFFile *thumbnail = [object objectForKey:@"image"];
    cell.FlyerImageView.file = thumbnail;
    
    cell.FlyerImageView.layer.cornerRadius = 28.0f;
    cell.FlyerImageView.layer.borderWidth = 1.0f;
    cell.FlyerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.FlyerImageView.clipsToBounds = YES;
    
    [cell.FlyerImageView loadInBackground];

    
    if (self.objects.count>0&&self.objects!=nil) {
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _messageLabel.hidden = YES;
        NSLog(@"unsichtbar");
        
    } else {
        

        NSLog(@"anzeigen");
        _messageLabel.text = @"3_Derzeit liegen keine Events\nfür dieses Datum vor.";
        
        _messageLabel.textColor = [UIColor blackColor];
        _messageLabel.numberOfLines = 0;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.hidden = NO;
        //messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        //  [messageLabel sizeToFit];
        
        // [self.view addSubview:messageLabel];
        
        
        
        self.tableView.backgroundView = _messageLabel;
        // self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }

    
    return cell;
}



#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    
    EventDetailViewController *detailController =segue.destinationViewController;
    
    PFObject *selectedObject = [self objectAtIndexPath:self.tableView.indexPathForSelectedRow];
    
    NSString *title = [selectedObject objectForKey:@"name"];
    
    NSLog(@"title: %@", title);
    
    detailController.event = selectedObject;
    
    
    
    [detailController setTitle:title];
    
    
}

//Stadt laden
-(void) loadCity{
    
    self.stadt = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/stadt", NSHomeDirectory()] encoding:NSUTF8StringEncoding error:nil];
    
}



@end