//
//  CityViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 13.09.13.
//  Copyright (c) 2013 Werner. All rights reserved.
//

#import "CityViewController.h"
#import <Parse/Parse.h>
#import "HighlightViewController.h"

@interface CityViewController ()
    @property (strong) NSArray * cityArray;
    @property (strong) NSString * parseClassName;
    @property (strong) NSString *stadt;
    @property (strong) NSString *cityName;





@end

@implementation CityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"cities";
        [self retrieveFromParse];
        [_cityTableView setDelegate:self];
        [_cityTableView setDataSource:self];

     //   [self showBackground];
     //   [self addTable];
    }
    return self;
}
*/
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"Cities"];
    [query orderByAscending:@"name"];

    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        _anzahl = objects.count;
        self.cityArray = [[NSArray alloc] initWithArray:objects];

        [self.cityTableView reloadData];
    }];
     
    
    
  //  [self.cityTableView reloadData];
    [_cityTableView setDelegate:self];
    [_cityTableView setDataSource:self];
    
    NSLog(@"set to no");
    //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"HasLaunchedOnce"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
   
    /*
    if ([_cityTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
        _cityTableView.tableFooterView = footerView;
        _cityTableView.separatorColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
        _cityTableView.separatorInset = UIEdgeInsetsZero;
    }
     */


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.

    return _cityArray.count;
    //else return _preisArray.count;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    NSLog(@"tabelle wird geladen");
    static NSString *identifier = @"Cell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
  //  cell.textLabel.text = [object objectForKey:@"name"];
    cell.textLabel.text = @"Test Stadt";

    

    return cell;
}
*/

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

    PFObject *city = [self.cityArray objectAtIndex:indexPath.row];
   // cell.textLabel.text = [object o]
    cell.textLabel.text = [city objectForKey:@"name"];
   // cell.textLabel.text = @"test";

   
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
    
    PFObject *city = [self.cityArray objectAtIndex:indexPath.row];
    
    NSString *cityBigFirstLetter = [city objectForKey:@"city"];
    
    //cityBigFirstLetter = [NSString stringWithFormat:@"%@%@",[[cityBigFirstLetter substringToIndex:1] uppercaseString],[cityBigFirstLetter substringFromIndex:1] ];
    
    self.cityName = [city objectForKey:@"name"];
    self.stadt = cityBigFirstLetter;
    
    NSLog(@"Stadt ausgewählt: %@",_stadt);

    [self saveData];
    
     if ([PFUser currentUser]) {
         NSLog(@"user logged in?");
         [[PFUser currentUser]setObject:_stadt forKey:@"city"];
         [[PFUser currentUser] saveEventually];


    }
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setObject:_stadt forKey:@"city"];
    [currentInstallation saveInBackground];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stadtWechseln" object:nil];
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"city picker weg");
    }];
     

    
    

}

//Stadt speichern
-(void) saveData{
    
    [self.stadt writeToFile:[NSString stringWithFormat:@"%@/Documents/stadt", NSHomeDirectory()] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    [self.cityName writeToFile:[NSString stringWithFormat:@"%@/Documents/cityName", NSHomeDirectory()] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
}


@end
