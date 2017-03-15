//
//  TicketTableViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 29.06.15.
//  Copyright (c) 2015 Werner. All rights reserved.
//

#import "TicketTableViewController.h"
#import "SCLAlertView.h"
#import "CheckoutViewController.h"
#import "EventDetailViewController.h"
#import "MasterCell.h"
#import "TicketPopOverView.h"
#import "MyLogInViewController.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Bolts/Bolts.h>
#import "Branch.h"
#import "MBProgressHUD.h"




@interface TicketTableViewController ()<TicketPopOverViewDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeControl;
@property (nonatomic, retain) NSMutableDictionary *sections;
@property (nonatomic, retain) NSMutableDictionary *sectionToSportTypeMap;
@property (nonatomic, assign) NSInteger anzahl;
@property (nonatomic, assign) NSInteger sektion;
@property (nonatomic, assign) NSInteger reihe;
@property (nonatomic, assign) NSInteger anzahlObjekte;
@property (nonatomic, assign) NSInteger hideNextPage;
@property (nonatomic, assign) NSInteger amount;
@property (nonatomic, strong) MBProgressHUD *hud;



@end

@implementation TicketTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    //self = [super initWithClassName:@"Augsburg_Events"];
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // Custom initialization
        
        self.parseClassName = @"Events";
        
        
        self.textKey = @"name";
        self.imageKey = @"image";
        
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 30;
        
        self.sections = [NSMutableDictionary dictionary];
        self.sectionToSportTypeMap = [NSMutableDictionary dictionary];
        
        
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // very similiar to highlightviewcontroller
    //except the segmentenControls to change the ticketType
    
    // Do any additional setup after loading the view.
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"Wird geladen", @"Wird geladen...");
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@" " style:UIBarButtonItemStyleBordered target:nil action:nil];
    
    
    //hide lines of empty cells
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
        self.tableView.tableFooterView = footerView;
        
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    
   // [self loadCity];
    
    
    _df.dateStyle = NSDateFormatterShortStyle;
    _df.timeStyle = NSDateFormatterNoStyle;
    
    _df.timeZone = [NSTimeZone localTimeZone];
    

  //  [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    

    
}


- (IBAction)typeControlPressed:(id)sender {
    [self loadObjects];
}

//QueryTable

- (PFQuery *)queryForTable {
    
    [self loadCity];
    
    //only show corresponding tickets
    
    if ([_type isEqualToString:@"ticket"]) {
        _typeControl.selectedSegmentIndex = 1;
        
    }
    else if ([_type isEqualToString:@"guestlist"]){
        _typeControl.selectedSegmentIndex = 0;
        
        
    }
    else if ([_type isEqualToString:@"combi"]){
        _typeControl.selectedSegmentIndex = 2;
        
        
    }

    
    switch (_typeControl.selectedSegmentIndex) {
        case 1:
        {
            //load tickets
            PFQuery *query = [PFQuery queryWithClassName:@"Events"];
            
            
            
            if (self.objects.count == 0) {
                query.cachePolicy = kPFCachePolicyCacheThenNetwork;
            }
            [query whereKey:@"city_pick" equalTo:_stadt];

            [query whereKey:@"ticketAmount" greaterThan:@0];
            NSDate *today = [NSDate date];
            
            [query whereKey:@"ticket_endTime" greaterThan:today];
            [query orderByAscending:@"start_time"];
            [query orderByAscending:@"name"];


            _type = nil;


            
            return query;
        }
            
            break;
        case 0:{
            //load guestlist
            
            PFQuery *query = [PFQuery queryWithClassName:@"Events"];
            
            
            
            if (self.objects.count == 0) {
                query.cachePolicy = kPFCachePolicyCacheThenNetwork;
            }
            
            [query whereKey:@"city_pick" equalTo:_stadt];

            [query whereKey:@"guestlistAmount" greaterThan:@0];

            NSDate *today = [NSDate date];
            
            [query whereKey:@"guestlist_endTime" greaterThan:today];
            
            [query orderByAscending:@"start_time"];
            [query orderByAscending:@"name"];

            _type = nil;

            
            return query;
            
        }
            break;
        case 2:{
            //load combi
            
            PFQuery *query = [PFQuery queryWithClassName:@"Events"];
            
            
            
            if (self.objects.count == 0) {
                query.cachePolicy = kPFCachePolicyCacheThenNetwork;
            }
            [query whereKey:@"city_pick" equalTo:_stadt];

            [query whereKey:@"guestlistAmount" greaterThan:@0];
            [query whereKey:@"ticketAmount" greaterThan:@0];

            
            NSDate *today = [NSDate date];
            
            [query whereKey:@"guestlist_endTime" greaterThan:today];
            [query whereKey:@"ticket_endTime" greaterThan:today];

            
            [query orderByAscending:@"start_time"];
            [query orderByAscending:@"name"];
            _type = nil;

            
            return query;
            
        }
            break;
            
        default:
        {
            NSLog(@"default laden");
            PFQuery *query = [PFQuery queryWithClassName:@"Events"];
            
            // [query whereKey:@"city_pick" equalTo:_stadt];
            
            
            if (self.objects.count == 0) {
                query.cachePolicy = kPFCachePolicyCacheThenNetwork;
            }
            
            [query whereKey:@"city_pick" equalTo:_stadt];

            [query whereKey:@"ticketAmount" greaterThan:@0];
            NSDate *today = [NSDate date];
            
            [query whereKey:@"ticket_endTime" greaterThan:today];
            [query orderByAscending:@"start_time"];
            [query orderByAscending:@"name"];
            _type = nil;


            
            return query;
        }
            
            break;
    }

}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    
    [self.sections removeAllObjects];
    [self.sectionToSportTypeMap removeAllObjects];
    
    
    
    NSInteger section = 0;
    NSInteger rowIndex = 0;
    NSLog(@"neue objekte: %lu",(unsigned long)self.objects.count);
    
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

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section < self.objects.count) {
        
        NSString * header = [self EventDateForSection:indexPath.section];
        NSArray *rowIndecesInSection = [self.sections objectForKey:header];
        NSNumber *rowIndex = [rowIndecesInSection objectAtIndex:indexPath.row];
        
        return [self.objects objectAtIndex:[rowIndex intValue]];
    }
    
    return nil;
}

- (NSString *)EventDateForSection:(NSInteger)section {
    
    return [self.sectionToSportTypeMap objectForKey:[NSNumber numberWithInt:(int)section]];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSInteger sections = self.sections.allKeys.count;
    _sektion = sections;

    if (self.objects.count == 50) {
        _anzahlObjekte = 50;
    }
    
    if ((self.objects.count>=_anzahlObjekte) || self.objects.count == 0) {
        if (self.objects.count < 30) {
            return  sections;
        }
        else{
        NSLog(@"load more");

        _hideNextPage = 0;
            NSLog(@"object.count: %li anzahlobjekte: %li sections: %li", self.objects.count, _anzahlObjekte, sections);
        
        
        return sections+1;
        }
    }
    
    else {
        NSLog(@"no load more");
        
        _hideNextPage = 1;
        return sections;
    }
}

//Anzahl der Reihen in einer Sektion
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    /*
     if ((section=_anzahl)) {
     return 1;
     }
     */
    NSString *header = [self EventDateForSection:section];
    
    NSArray *rowIndecesInSection = [self.sections objectForKey:header];
    // NSLog(@"row in section: %i",rowIndecesInSection.count);
    
    if (section==_sektion) {
        _reihe = rowIndecesInSection.count;
        NSLog(@"bla");

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
    // NSString *header = [df stringFromDate:zeit];
    
    
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
    //label.textColor = [UIColor darkGrayColor];
    
    //  label.shadowColor = [UIColor blackColor];
    //  label.shadowOffset = CGSizeMake(0.0, 1.0);
    //  label.font = [UIFont boldSystemFontOfSize:16];
    //label.font = [UIFont systemFontOfSize:16];
    label.font = FONT_HELVETICA(15);
    //  label.font = FONT_HELVETICA_NORMAL(15);
    
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterShortStyle;
    df.timeStyle = NSDateFormatterNoStyle;
    df.timeZone = [NSTimeZone localTimeZone];
    // NSString *header = [df stringFromDate:zeit];
    
    
    NSString *header = [self EventDateForSection:section];
    
    label.text = header;
    
    
    [view addSubview:label];
    
    
    //Schatten von unten bei bar
    
    CAGradientLayer *l = [CAGradientLayer layer];
    //  l.frame = self.barView.bounds;
    
    // l.frame = CGRectMake(0, 108, 320, 15);
    l.frame = CGRectMake(0, 12, 322, 20);
    //l.frame.size.width = _barView.frame.size.width;
    
    
    UIColor* startColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    UIColor* endColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    l.colors = [NSArray arrayWithObjects:(id)startColor.CGColor, (id)endColor.CGColor, nil];
    UIColor* bgColor3 = [UIColor colorWithRed:0 green:0.592 blue:0.655 alpha:1];
    
    [view setBackgroundColor:bgColor3];
    
    
    return view;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    

    
    if (indexPath.section==_sektion && indexPath.row == 0 && _hideNextPage == 0) {
        NSLog(@"next cell laden");
        //[self loadNextPage];
        
        UITableViewCell *cell = [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
        
        return cell;
        
    }


    
    static NSString *CellIdentifier = @"EventCell";
    
    MasterCell *cell = (MasterCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[MasterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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
    
    [cell.TitleLabel setTextColor:[UIColor colorWithRed:0 green:0.592 blue:0.655 alpha:1]];
    
    [cell.SubtitleLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
    [cell.DateLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
    

    //check how many tickets are left and show the amount if it is less then 10 or 6
    
    switch (_typeControl.selectedSegmentIndex) {
        case 1:
        {
            NSLog(@"tickets laden");
            int amount =[[object objectForKey:@"ticketAmount"]intValue ];
            NSString *availableString = [NSString stringWithFormat:@"  Nur noch %i Tickets ", amount];
            
            if (amount == 1){
                availableString = @"  Nur noch 1 Ticket ";
                cell.AvailableLabel.text = availableString;

                cell.AvailableLabel.backgroundColor = [UIColor redColor];
                cell.AvailableLabel.hidden = NO;
                
            }
            else if (amount < 6) {
                cell.AvailableLabel.text = availableString;

                cell.AvailableLabel.backgroundColor = [UIColor redColor];
                cell.AvailableLabel.hidden = NO;
           
            }
            else if (amount < 11){
                cell.AvailableLabel.text = availableString;

                cell.AvailableLabel.backgroundColor = [UIColor orangeColor];
                cell.AvailableLabel.hidden = NO;
            
            }
            else {
                cell.AvailableLabel.text = @"";

                cell.AvailableLabel.hidden = YES;

            }
            
            cell.AvailableLabel.text = availableString;

            
        }
            break;
        case 2:
        {
            NSLog(@"kombi laden");
            int amount;
            
            if ([[object objectForKey:@"ticketAmount"]intValue ] > [[object objectForKey:@"guestlistAmount"]intValue ]) {
                amount = [[object objectForKey:@"guestlistAmount"]intValue ];
            }
            else{
                amount = [[object objectForKey:@"ticketAmount"]intValue ];

            }
            NSString *availableString = [NSString stringWithFormat:@"  Nur noch %i Tickets ", amount];
            
            if (amount == 1){

                availableString = @"  Nur noch 1 Ticket ";
                cell.AvailableLabel.text = availableString;

                cell.AvailableLabel.backgroundColor = [UIColor redColor];
                cell.AvailableLabel.hidden = NO;
                
            }
            else if (amount < 6) {
                cell.AvailableLabel.text = availableString;

                cell.AvailableLabel.backgroundColor = [UIColor redColor];
                cell.AvailableLabel.hidden = NO;
                
            }
            else if (amount < 11){
                cell.AvailableLabel.text = availableString;

                cell.AvailableLabel.backgroundColor = [UIColor orangeColor];
                cell.AvailableLabel.hidden = NO;
                
            }
            else{
                cell.AvailableLabel.text = @"";

                cell.AvailableLabel.hidden = YES;

            }
            

            
        }
            break;
        case 0:
        {
            NSLog(@"gästelistenplatz laden");
            int amount =[[object objectForKey:@"guestlistAmount"]intValue ];
            NSString *availableString = [NSString stringWithFormat:@"  Nur noch %i Plätze ", amount];
            
            if (amount == 1){
                availableString = @"  Nur noch 1 Platz ";
                cell.AvailableLabel.text = availableString;

                cell.AvailableLabel.backgroundColor = [UIColor redColor];
                cell.AvailableLabel.hidden = NO;
                
            }
            else if (amount < 6) {
                cell.AvailableLabel.text = availableString;

                cell.AvailableLabel.backgroundColor = [UIColor redColor];
                cell.AvailableLabel.hidden = NO;
                
            }
            else if (amount < 11){
                cell.AvailableLabel.text = availableString;

                cell.AvailableLabel.backgroundColor = [UIColor orangeColor];
                cell.AvailableLabel.hidden = NO;
                
            }
            else {
                cell.AvailableLabel.text = @"";
                cell.AvailableLabel.hidden = YES;

            }
            

            
        }
            break;
            
        default:
            break;
    }
    
    
    
    PFFile *applicantResume = [object objectForKey:@"image"];
    
    
    cell.FlyerImageView.file = applicantResume;
    
    
    cell.FlyerImageView.layer.cornerRadius = 28.0f;
    cell.FlyerImageView.layer.borderWidth = 1.0f;
    cell.FlyerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.FlyerImageView.clipsToBounds = YES;
    
    
    [cell.FlyerImageView loadInBackground];
    
    
    
    return cell;

    
    return cell;


}

//didselect...
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    if (indexPath.section==_sektion && indexPath.row == 0 && _hideNextPage == 0) {
        NSLog(@"ende");
        [self loadNextPage];
        
        
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
    

        PFObject *obj = [self objectAtIndexPath:self.tableView.indexPathForSelectedRow];


    
    [alert addButton:@"Kaufen" actionBlock:^{
                

        
        TicketPopOverView *_popoverView = [[TicketPopOverView alloc]init];
        _popoverView.delegate = self;
        [self.view addSubview:_popoverView];
        
       // _popoverView.center = CGPointMake(100, 100);

        _popoverView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);

        _popoverView.frame = [UIScreen mainScreen].bounds;
        
        // Turn off autosizin masks
        _popoverView.translatesAutoresizingMaskIntoConstraints = NO;
        
        // 1. Pin to center y
        //-self.navigationController.navigationBar.frame.size.height]
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_popoverView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-self.navigationController.navigationBar.frame.size.height]];
        
        // 2. Pin to center x
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_popoverView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        
        //get data from event
        PFFile *applicantResume = [obj objectForKey:@"image"];
        
        
        _popoverView.bannerImageView.file = applicantResume;
        [_popoverView.bannerImageView loadInBackground];

        
        int maxAmount ;
        switch (_typeControl.selectedSegmentIndex) {
            case 1:
            {
                NSLog(@"tickets laden");
                maxAmount =[[obj objectForKey:@"ticketAmount"]intValue ];
                _popoverView.amountStepper.maximumValue = maxAmount;
                _popoverView.priceLabel.text = [NSString stringWithFormat:@"%@€",[obj objectForKey:@"ticketPrice"]];



                
                
            }
                break;
            case 2:
            {
                NSLog(@"kombi laden");
                
                if ([[obj objectForKey:@"ticketAmount"]intValue ] > [[obj objectForKey:@"guestlistAmount"]intValue ]) {
                    maxAmount = [[obj objectForKey:@"guestlistAmount"]intValue ];
                    _popoverView.amountStepper.maximumValue = maxAmount;

                }
                else{
                    maxAmount = [[obj objectForKey:@"ticketAmount"]intValue ];
                    _popoverView.amountStepper.maximumValue = maxAmount;

                }
                
                NSNumber *ticketPrice = [obj objectForKey:@"ticketPrice"];
                NSDecimalNumber *ticketPriceNum = [NSDecimalNumber decimalNumberWithDecimal:[ticketPrice decimalValue]];
                NSNumber *guestlistPrice = [obj objectForKey:@"guestlistPrice"];
                NSDecimalNumber *guestlistPriceNum = [NSDecimalNumber decimalNumberWithDecimal:[guestlistPrice decimalValue]];
                
                NSDecimalNumber *combiPriceNum = [ticketPriceNum decimalNumberByAdding:guestlistPriceNum];
                _popoverView.priceLabel.text = [NSString stringWithFormat:@"%@€",combiPriceNum];

                
            }
                break;
            case 0:{
                NSLog(@"gästelistenplatz laden");
                maxAmount =[[obj objectForKey:@"guestlistAmount"]intValue ];
                _popoverView.amountStepper.maximumValue = maxAmount;
                _popoverView.priceLabel.text = [NSString stringWithFormat:@"%@€",[obj objectForKey:@"guestlistPrice"]];


                
            } break;
        }
        _popoverView.hostLabel.text = [obj objectForKey:@"host"];
        _popoverView.eventNameLabel.text = [obj objectForKey:@"name"];
        
        _popoverView.amountLabel.text = @"1 Platz";
        _popoverView.amountStepper.value = 1;
        _popoverView.amountStepper.minimumValue = 1;
        
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateStyle = NSDateFormatterNoStyle;
        df.timeStyle = NSDateFormatterShortStyle;
        df.timeZone = [NSTimeZone localTimeZone];
        NSString *zeit = [df stringFromDate:[obj objectForKey:@"start_time"]];
        NSString *ende = [df stringFromDate:[obj objectForKey:@"end_time"]];
        NSString *string = [NSString stringWithFormat:@"%@ - %@", zeit, ende];
        _popoverView.timeLabel.text = string;
        
        
        NSDateFormatter *dfd = [[NSDateFormatter alloc] init];
        dfd.dateStyle = NSDateFormatterShortStyle;
        dfd.timeStyle = NSDateFormatterNoStyle;
        dfd.timeZone = [NSTimeZone localTimeZone];
        NSString *datum = [dfd stringFromDate:[obj objectForKey:@"start_time"]];
        _popoverView.dateLabel.text = datum;
        

        
        

        
    }];
    [alert addButton:@"Mehr Infos" actionBlock:^{
                
                //performsegue
        //eventdetailview anzeigen
        [self performSegueWithIdentifier:@"detail" sender:self];

        
    }];
    
    
            
    [alert showInfo:self title:@"Event" subTitle:[obj objectForKey:@"name"] closeButtonTitle:@"Schließen" duration:0.0f];
        
    }
    
    
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

-(void)checkBuyOption{
    
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
        
        
        [alert showWarning:self title:@"Nicht eingeloggt" subTitle:@"Du musst eingeloggt sein, um etwas zu kaufen" closeButtonTitle:@"Nicht jetzt" duration:0.0f];
        
        
        
    }
    //email adresse prüfen
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
    else if(_amount != 0 ){
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


-(IBAction)backToTicketTable: (UIStoryboardSegue *) segue{
    
    
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 68;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    if ([segue.identifier isEqualToString:@"detail"])
    {
    EventDetailViewController *detailController =segue.destinationViewController;
    
    //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
   // PFObject *object = [ self.objects objectAtIndex:indexPath.row];
        PFObject *object = [self objectAtIndexPath:self.tableView.indexPathForSelectedRow];

    NSString *title = [object objectForKey:@"name"];
    
    
    detailController.event = object;
    [detailController setTitle:title];
    
    }
    
    else if ([segue.identifier isEqualToString:@"checkout"]){
        
   //     UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
    //    CheckoutViewController *checkoutController = [navController topViewController];
    
      //  PFObject *object = [ self.objects objectAtIndex:indexPath.row];
        
            CheckoutViewController *checkoutController = (CheckoutViewController *)[[segue destinationViewController] topViewController];
        PFObject *object = [self objectAtIndexPath:self.tableView.indexPathForSelectedRow];


        
        

        checkoutController.ticket = object;
        
        if (_typeControl.selectedSegmentIndex == 1) {
            NSLog(@"ticket");
            checkoutController.ticketType = 1;

        }
        else if(_typeControl.selectedSegmentIndex == 2){
            NSLog(@"kombi");

            checkoutController.ticketType = 3;

        }
        else {
            NSLog(@"gäste");

            checkoutController.ticketType = 2;

        }
       // NSLog(@"amount: %i",(int)_amount);

        
        checkoutController.amount = _amount;
        

        
    }
     
}

//Load more.. Zeile
- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    // Override to customize the look of the cell that allows the user to load the next page of objects.
    // The default implementation is a UITableViewCellStyleDefault cell with simple labels.
    
    NSLog(@"Mehr Laden!!!");
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
    _anzahlObjekte = _anzahlObjekte+50;
    
    
    return cell;
}

//Stadt laden
-(void) loadCity{
    
    self.stadt = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/stadt", NSHomeDirectory()] encoding:NSUTF8StringEncoding error:nil];
    
    
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
    [self loadCity];
    
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

                                [self checkBuyOption];
                                
                            }
                        }];
                    }
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

                    [self checkBuyOption];
                    
                    
                    
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
@end
