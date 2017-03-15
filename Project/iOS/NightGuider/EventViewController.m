//
//  EventViewController.m
//  Nightlife_2
//
//  Created by Werner Kohn on 03.04.13.
//  Copyright (c) 2013 Werner. All rights reserved.
//

#import "EventViewController.h"
#import "MasterCell.h"
#import "EventDetailViewController.h"

#import <QuartzCore/QuartzCore.h>


@interface EventViewController ()

@end

@implementation EventViewController

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
 
 */

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
  //  self = [super initWithClassName:@"Augsburg_Events"];
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // Custom initialization
        
        self.parseClassName = @"Events";
        
        
        self.textKey = @"name";
        self.imageKey = @"icon";
        
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 30;
        
        
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self loadCity];


    /*
    _dfi.dateStyle = NSDateFormatterShortStyle;
    _dfi.timeStyle = NSDateFormatterNoStyle;
    _dfi.timeZone = [NSTimeZone localTimeZone];
    
    _df.dateStyle = NSDateFormatterNoStyle;
    _df.timeStyle = NSDateFormatterShortStyle;
    _df.timeZone = [NSTimeZone localTimeZone];
     */

    self.navigationController.navigationBar.alpha = 1.0;
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
        self.tableView.tableFooterView = footerView;
        self.tableView.separatorColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
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
    
   // [query whereKey:@"club" equalTo:@"club"];
    

    //[query whereKey:@"host" equalTo:_club];
    
    [query whereKey:@"host_id" equalTo:_club_id];
    NSLog(@"klasse: %@",self.parseClassName);
    NSLog(@"host_id: %@", _club_id);


    
    NSDate *today = [NSDate date];
    [query whereKey:@"end_time" greaterThan:today];
    
    [query orderByAscending:@"special"];
    [query orderByAscending:@"start_time"];
 
    
    return query;

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
     
    
    
    
    static NSString *CellIdentifier = @"Cell";
    
    
    MasterCell *cell = (MasterCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    cell.TitleLabel.text = [object objectForKey:@"name"];
    
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

    
    PFFile *thumbnail = [object objectForKey:@"image"];
    cell.FlyerImageView.file = thumbnail;
    
    cell.FlyerImageView.layer.cornerRadius = 28.0f;
    cell.FlyerImageView.layer.borderWidth = 1.0f;
    cell.FlyerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.FlyerImageView.clipsToBounds = YES;
    
    [cell.FlyerImageView loadInBackground];
    [cell.TitleLabel setTextColor:[UIColor colorWithRed:0 green:0.592 blue:0.655 alpha:1]];
    
    [cell.SubtitleLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
    [cell.DateLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
    
    
    
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
