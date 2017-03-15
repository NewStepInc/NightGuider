//
//  FavoriteViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 20.10.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import "FavoriteViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MasterCell.h"
#import "EventDetailViewController.h"
#import "ClubDetailViewController.h"

@interface FavoriteViewController () <UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeControl;

@end


@implementation FavoriteViewController

@synthesize data;
@synthesize clubs;
@synthesize listOfItems;
@synthesize bars;
@synthesize listOfBars;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    // self = [super initWithClassName:@"Augsburg_Events"];
    self = [super initWithCoder:aDecoder];
    
    //self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        // self.parseClassName = @"Augsburg_Events";
        self.textKey = @"name";
        
        
        
        self.parseClassName = @"Events";
        
        
        self.pullToRefreshEnabled = NO;
        self.paginationEnabled = YES;
        self.objectsPerPage = 50;
        
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    [self loadCity];
    
    //   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wechsel:) name:@"stadtWechseln" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newFav:) name:@"neuerFav" object:nil];
    
    
    CGRect newBounds = self.tableView.bounds;
    newBounds.origin.y = newBounds.origin.y + 88 ;
    self.tableView.bounds = newBounds;
    
    ///////////////----------------------
    // UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-BG-pattern.png"]];
    // [self.view setBackgroundColor:bgColor];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@" " style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    
    self.title = @"Favoriten";
    
    // Remove the separator lines for empty cells
    /*
     if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
     UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
     self.tableView.tableFooterView = footerView;
     self.tableView.separatorColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
     self.tableView.separatorInset = UIEdgeInsetsZero;
     }
     */
    
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    
    
    [self loadData];
    NSLog(@"listOfItems: %li",(unsigned long)[self.listOfItems count] );
    NSLog(@"Data: %li", (unsigned long)[self.data count]);
    
    BOOL g = [self.listOfItems count] ==[self.data count];
    
    BOOL h = [self.listOfClubs count] ==[self.clubs count];
    
    NSLog(@"listOfClubs: %li",(unsigned long)[self.listOfClubs count] );
    NSLog(@"Clubs: %li", (unsigned long)[self.clubs count]);
    
    BOOL i = [self.listOfBars count] ==[self.bars count];
    
    NSLog(@"listOfBars: %li",(unsigned long)[self.listOfBars count] );
    NSLog(@"Bars: %li", (unsigned long)[self.bars count]);
    
    
    
    
    if (!g || !h || !i) {
        
        NSLog(@"neuladen");
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        
        [self loadObjects];
        // Remove the separator lines for empty cells
        
        if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
            self.tableView.tableFooterView = footerView;
            self.tableView.separatorColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
            self.tableView.separatorInset = UIEdgeInsetsZero;
        }
        
        
        
        NSLog(@"%s", __PRETTY_FUNCTION__);

        
    }
    
}
- (IBAction)typeControlPressed:(id)sender {
    [self loadObjects];
}

//QueryTable

- (PFQuery *)queryForTable {
    
    
    switch (_typeControl.selectedSegmentIndex) {
        case 0:
        {
            NSLog(@"Events laden");
            PFQuery *query = [PFQuery queryWithClassName:@"Events"];
            
            // [query whereKey:@"city_pick" equalTo:_stadt];
            
            
            if (self.objects.count == 0) {
                query.cachePolicy = kPFCachePolicyCacheThenNetwork;
            }
            
            
            [self loadData];
            
            if (!data) {
                
                data = [[NSMutableArray alloc] init];
                
                [self saveData];
                
                
            }
            
            [query whereKey:@"objectId" containedIn:data];
            
            if ([_sortierung isEqual: @"name"]) {
                [query orderByAscending:@"name"];
                NSLog(@"name");
                
            }
            else if ([_sortierung isEqual: @"date"]){
                [query orderByAscending:@"start_time"];
                NSLog(@"datum");
                
                
            }
            
            
            listOfItems = self.data;
            
            return query;
        }
            
            break;
        case 1:{
            NSLog(@"clubs laden");
            
            PFQuery *query = [PFQuery queryWithClassName:@"Clubs"];
            
            // [query whereKey:@"city_pick" equalTo:_stadt];
            
            
            if (self.objects.count == 0) {
                query.cachePolicy = kPFCachePolicyCacheThenNetwork;
            }
            
            
            [self loadData];
            
            
            
            if(!clubs){
                
                clubs = [[NSMutableArray alloc] init];
                
                [self saveData];
                
            }
            
            
            [query whereKey:@"objectId" containedIn:clubs];
            [query orderByAscending:@"name"];
            
            
            _listOfClubs = self.clubs;
            
            return query;
            
        }
            break;
        case 2:{
            NSLog(@"bars laden");
            
            PFQuery *query = [PFQuery queryWithClassName:@"Bars"];
            
            // [query whereKey:@"city_pick" equalTo:_stadt];
            
            
            if (self.objects.count == 0) {
                query.cachePolicy = kPFCachePolicyCacheThenNetwork;
            }
            
            
            [self loadData];
            
            
            
            if(!bars){
                
                bars = [[NSMutableArray alloc] init];
                
                [self saveData];
                
            }
            
            
            [query whereKey:@"objectId" containedIn:bars];
            [query orderByAscending:@"name"];
            
            
            listOfBars = self.bars;
            
            return query;
            
        }
            break;
            
        default:
        {
            NSLog(@"Events laden");
            PFQuery *query = [PFQuery queryWithClassName:@"Events"];
            
            // [query whereKey:@"city_pick" equalTo:_stadt];
            
            
            if (self.objects.count == 0) {
                query.cachePolicy = kPFCachePolicyCacheThenNetwork;
            }
            
            
            [self loadData];
            
            if (!data) {
                
                data = [[NSMutableArray alloc] init];
                
                [self saveData];
                
                
            }
            
            [query whereKey:@"objectId" containedIn:data];
            
            if ([_sortierung isEqual: @"name"]) {
                [query orderByAscending:@"name"];
                NSLog(@"name");
                
            }
            else if ([_sortierung isEqual: @"date"]){
                [query orderByAscending:@"start_time"];
                NSLog(@"datum");
                
                
            }
            
            
            listOfItems = self.data;
            
            return query;
        }
            
            break;
    }
    

}





- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object {
    
    
    switch (_typeControl.selectedSegmentIndex) {
        case 0:
        {
            static NSString *CellIdentifier = @"FavCell";
            
            MasterCell *cell = (MasterCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[MasterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            
            cell.TitleLabel.text = [object objectForKey:@"name"];
            
            cell.SubtitleLabel.text = [object objectForKey:@"host"];
            
            
            NSDate * zeit = [object objectForKey:@"start_time"];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            // df.dateStyle = NSDateFormatterNoStyle;
            df.dateStyle = NSDateFormatterShortStyle;
            
            df.timeStyle = NSDateFormatterShortStyle;
            df.timeZone = [NSTimeZone localTimeZone];
            
            NSString *header = [df stringFromDate:zeit];
            cell.DateLabel.text = header;
            
            [cell.TitleLabel setTextColor:[UIColor colorWithRed:0 green:0.592 blue:0.655 alpha:1]];
            
            [cell.SubtitleLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
            [cell.DateLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
            
            
            
            
            PFFile *applicantResume = [object objectForKey:@"image"];
            
            
            cell.FlyerImageView.file = applicantResume;
            
            
            cell.FlyerImageView.layer.cornerRadius = 28.0f;
            cell.FlyerImageView.layer.borderWidth = 1.0f;
            cell.FlyerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
            cell.FlyerImageView.clipsToBounds = YES;
            
            
            [cell.FlyerImageView loadInBackground];
            
            
            
            return cell;
            
            
        }
            break;
            
        case 1:{
            static NSString *CellIdentifier = @"ClubFavCell";
            
            MasterCell *cell = (MasterCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[MasterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            
            cell.TitleLabel.text = [object objectForKey:@"name"];
            
            
            
            [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
                if (!error) {
                    // do something with the new geoPoint
                    double distanz = [geoPoint distanceInKilometersTo:[object objectForKey:@"location"]];
                    cell.SubtitleLabel.text = [NSString stringWithFormat:@"Distanz: %.2f km", distanz];
                    
                }
            }];
            
            [cell.TitleLabel setTextColor:[UIColor colorWithRed:0 green:0.592 blue:0.655 alpha:1]];
            
            [cell.SubtitleLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
            
            
            
            
            PFFile *applicantResume = [object objectForKey:@"pic_Small"];
            
            
            cell.FlyerImageView.file = applicantResume;
            
            
            cell.FlyerImageView.layer.cornerRadius = 28.0f;
            cell.FlyerImageView.layer.borderWidth = 1.0f;
            cell.FlyerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
            cell.FlyerImageView.clipsToBounds = YES;
            
            
            [cell.FlyerImageView loadInBackground];
            
            
            
            return cell;
            
            
            
        }
            break;
        case 2:{
            static NSString *CellIdentifier = @"BarFavCell";
            
            MasterCell *cell = (MasterCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell) {
                cell = [[MasterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            
            cell.TitleLabel.text = [object objectForKey:@"name"];
            
            
            
            [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
                if (!error) {
                    // do something with the new geoPoint
                    double distanz = [geoPoint distanceInKilometersTo:[object objectForKey:@"location"]];
                    cell.SubtitleLabel.text = [NSString stringWithFormat:@"Distanz: %.2f km", distanz];
                    
                }
            }];
            
            [cell.TitleLabel setTextColor:[UIColor colorWithRed:0 green:0.592 blue:0.655 alpha:1]];
            
            [cell.SubtitleLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
            
            
            
            
            PFFile *applicantResume = [object objectForKey:@"pic_Small"];
            
            
            cell.FlyerImageView.file = applicantResume;
            
            
            cell.FlyerImageView.layer.cornerRadius = 28.0f;
            cell.FlyerImageView.layer.borderWidth = 1.0f;
            cell.FlyerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
            cell.FlyerImageView.clipsToBounds = YES;
            
            
            [cell.FlyerImageView loadInBackground];
            
            
            
            return cell;
            
            
            
        }
            break;
        default:
            break;
    }
    
    static NSString *CellIdentifier = @"FavCell";
    
    MasterCell *cell = (MasterCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[MasterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    cell.TitleLabel.text = [object objectForKey:@"name"];
    
    cell.SubtitleLabel.text = [object objectForKey:@"host"];
    
    
    NSDate * zeit = [object objectForKey:@"start_time"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterNoStyle;
    df.timeStyle = NSDateFormatterShortStyle;
    df.timeZone = [NSTimeZone localTimeZone];
    
    NSString *header = [df stringFromDate:zeit];
    cell.DateLabel.text = header;
    
    [cell.TitleLabel setTextColor:[UIColor colorWithRed:0 green:0.592 blue:0.655 alpha:1]];
    
    [cell.SubtitleLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
    [cell.DateLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
    
    
    
    
    PFFile *applicantResume = [object objectForKey:@"image"];
    
    // NSData *resumeData = [applicantResume getData];
    //  cell.FlyerImageView.image = [UIImage imageWithData:resumeData];
    cell.FlyerImageView.file = applicantResume;
    
    
    cell.FlyerImageView.layer.cornerRadius = 28.0f;
    cell.FlyerImageView.layer.borderWidth = 1.0f;
    cell.FlyerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.FlyerImageView.clipsToBounds = YES;
    
    
    [cell.FlyerImageView loadInBackground];
    
    //schatten unter letzte zelle
    /*
     if(indexPath.row == [listOfItems count]-1)
     {
     if ([cell.layer.sublayers count] < 2) {
     
     CALayer* shadow = [self createShadowWithFrame:CGRectMake(0, 67, 480, 5)];
     NSLog(@"Schatten bei %@", [object objectForKey:@"name"]);
     
     [cell.layer addSublayer:shadow];
     }
     
     }
     else if ([cell.layer.sublayers count] >= 2){
     
     NSMutableArray *neu2 = [NSMutableArray arrayWithArray:cell.layer.sublayers];
     if (neu2.count >= 2) {
     [neu2 removeObjectAtIndex:1];
     
     cell.layer.sublayers = neu2;
     
     NSLog(@"Schatten gelöscht bei %@", [object objectForKey:@"name"]);
     }
     else{
     NSLog(@"wollte löschen aber kein schatten da");
     }
     
     }
     */
    
    
    
    
    return cell;
    
    
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
    // [cell.textLabel setTextColor:[UIColor colorWithRed:0.0 green:68.0/255 blue:118.0/255 alpha:1.0]];
    [cell.textLabel setTextColor:[UIColor colorWithRed:0 green:0.592 blue:0.655 alpha:1]];
    
    [cell.textLabel setShadowColor:[UIColor whiteColor]];
    [cell.textLabel setShadowOffset:CGSizeMake(0, 1)];
    
    
    cell.textLabel.text = @"Mehr laden...";
    
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

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        
        switch (_typeControl.selectedSegmentIndex) {
            case 0:
            {
                NSString *objekt = [data objectAtIndex:indexPath.row];
                NSLog(@"%@ wird gelöscht", objekt);
                
                
                [data removeObjectAtIndex:indexPath.row];
                
                
                //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                [self saveData];
                [self loadObjects];
                
            }
                break;
                
            case 1:{
                NSString *objekt = [clubs objectAtIndex:indexPath.row];
                NSLog(@"%@ wird gelöscht", objekt);
                
                
                [clubs removeObjectAtIndex:indexPath.row];
                
                
                //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                [self saveData];
                [self loadObjects];
                
            }
                break;
                
            case 2:{
                NSString *objekt = [bars objectAtIndex:indexPath.row];
                NSLog(@"%@ wird gelöscht", objekt);
                
                
                [bars removeObjectAtIndex:indexPath.row];
                
                
                //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                [self saveData];
                [self loadObjects];
                
            }
                break;
                
                
            default:{
                NSString *objekt = [data objectAtIndex:indexPath.row];
                NSLog(@"%@ wird gelöscht", objekt);
                
                
                [data removeObjectAtIndex:indexPath.row];
                
                
                //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                [self saveData];
                [self loadObjects];
            }
                break;
        }
        
        
        
    }
    
}

- (void)searchTapped:(id)sender {
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Sortieren nach"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Name", @"Datum",@"Nähe", nil];
    
    // 3
    [sheet addButtonWithTitle:@"Cancel"];
    sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
    
    // 4
    [sheet showInView:self.view];
    
    
    
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    //nicht reloaddata sonder self loadobjects
    // 1
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (buttonIndex == 0) {
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nach Namen sortieren" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            
            
            [alert show];
            
            _sortierung = @"name";
            [self.tableView reloadData];
            
            
            return;
        }
        
        
        
        else if (buttonIndex == 1) {
            // 3
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nach Datum sortieren" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            
            
            [alert show];
            
            _sortierung = @"date";
            [self.tableView reloadData];
            
        }
        
        else if (buttonIndex == 2) {
            // 3
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nach Nähe sortieren" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            
            [alert show];
            
            _sortierung = @"place";
            [self.tableView reloadData];
            
        }
        
        
    }
    
    // 5
}



//Detailansicht öffnen
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"event"])
    {

        
        EventDetailViewController *detailController =segue.destinationViewController;
        
        PFObject *selectedObject = [self objectAtIndexPath:self.tableView.indexPathForSelectedRow];
        
        NSString *title = [selectedObject objectForKey:@"name"];
        
        NSLog(@"title: %@", title);
        
        detailController.event = selectedObject;
        
        
        
        [detailController setTitle:title];
    }
    
    else if ([segue.identifier isEqualToString:@"club"])
    {
        
        ClubDetailViewController *detailController =segue.destinationViewController;
        
        
        
        PFObject *selectedObject = [self objectAtIndexPath:self.tableView.indexPathForSelectedRow];
        
        
        
        NSString *title = [selectedObject objectForKey:@"name"];
        
        NSLog(@"title: %@", title);
        
        
        detailController.club = selectedObject;
        
        
        [detailController setTitle:title];
        
        
    }
    
}


//Favoriten laden
-(void) loadData
{
    
    data =[NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/data", NSHomeDirectory()]];
    
    clubs =[NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/clubs", NSHomeDirectory()]];
    
    bars =[NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/bars", NSHomeDirectory()]];
    
}



//Favoriten speichern
-(void) saveData{
    
    [data writeToFile:[NSString stringWithFormat:@"%@/Documents/data", NSHomeDirectory()] atomically:YES];
    
    [clubs writeToFile:[NSString stringWithFormat:@"%@/Documents/clubs", NSHomeDirectory()] atomically:YES];
    
    [bars writeToFile:[NSString stringWithFormat:@"%@/Documents/bars", NSHomeDirectory()] atomically:YES];

 //   NSLog(@"Nun sind %li events gespeichert", (unsigned long)[data count]);
    
    
}

//Stadt laden
-(void) loadCity{
    
    self.stadt = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/stadt", NSHomeDirectory()] encoding:NSUTF8StringEncoding error:nil];
    
    
}



-(void) newFav:(NSNotification *) notification{
    
    /*
     [self loadData];
     //  [self.tableView reloadData];
     
     NSLog(@"neuer Fav");
     
     NSLog(@"listOfItems: %li",[self.listOfItems count] );
     NSLog(@"Data: %li", [self.data count]);
     
     BOOL g = [self.listOfItems count] ==[self.data count];
     
     BOOL h = [self.listOfClubs count] ==[self.clubs count];
     
     NSLog(@"listOfClubs: %li",[self.listOfClubs count] );
     NSLog(@"Clubs: %li", [self.clubs count]);
     
     
     
     if (!g || !h) {
     
     NSLog(@"neuladen");
     [self loadObjects];
     
     
     NSLog(@"%s", __PRETTY_FUNCTION__);
     
     
     
     
     
     }
     */
}


@end
