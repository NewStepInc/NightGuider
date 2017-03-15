//
//  UserTicketViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 28.05.15.
//  Copyright (c) 2015 Werner. All rights reserved.
//

#import "UserTicketViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "SCLAlertView.h"
#import "UserTicketDetailViewController.h"


@interface UserTicketViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeControl;

@end

@implementation UserTicketViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        // Custom initialization
        
        self.textKey = @"title";
        
        
        
        self.parseClassName = @"Ticket";
        
        
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 50;
        
        
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"wird geladen");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//QueryTable

- (PFQuery *)queryForTable {
    
    
    switch (_typeControl.selectedSegmentIndex) {
        case 0:
        {
            NSLog(@"Tickets laden");
            PFQuery *query = [PFQuery queryWithClassName:@"Ticket"];
            
            
            if (self.objects.count == 0) {
                query.cachePolicy = kPFCachePolicyCacheThenNetwork;
            }
            
            

            NSLog(@"1");
            
           // [query whereKey:@"userId" equalTo:[PFUser currentUser].objectId];
            
           // NSLog(@"user id: %@", [PFUser currentUser].objectId );
            [query whereKey:@"user" equalTo:[PFUser currentUser]];
            NSLog(@"2");

            NSDate *today = [NSDate date];
            [query whereKey:@"endTime" greaterThan:today];
            NSLog(@"3");

            [query orderByAscending:@"startTime"];
            NSLog(@"4");

            [query whereKey:@"ticketFulfilled" equalTo:[NSNumber numberWithBool:NO]];
            NSLog(@"5");
            
            [query whereKey:@"ticket" equalTo:[NSNumber numberWithBool:YES]];
            NSLog(@"6");



            
          //  listOfItems = self.data;
            
            return query;
        }
            
            break;
        case 1:
        {
            NSLog(@"Gästeliste laden");
            PFQuery *query = [PFQuery queryWithClassName:@"Ticket"];
            
            
            if (self.objects.count == 0) {
                query.cachePolicy = kPFCachePolicyCacheThenNetwork;
            }
            
            
            
            NSLog(@"1");
            
            // [query whereKey:@"userId" equalTo:[PFUser currentUser].objectId];
            
            // NSLog(@"user id: %@", [PFUser currentUser].objectId );
            [query whereKey:@"user" equalTo:[PFUser currentUser]];
            NSLog(@"2");
            
            NSDate *today = [NSDate date];
            [query whereKey:@"endTime" greaterThan:today];
            NSLog(@"3");
            
            [query orderByAscending:@"startTime"];
            NSLog(@"4");
            
            [query whereKey:@"guestlistFulfilled" equalTo:[NSNumber numberWithBool:NO]];
            NSLog(@"5");
            
            [query whereKey:@"guestlist" equalTo:[NSNumber numberWithBool:YES]];
            NSLog(@"6");
            
            
            
            
            
            //  listOfItems = self.data;
            
            return query;
        }
            
            break;
        case 2:
        {
            NSLog(@"Kombi laden");
            PFQuery *query = [PFQuery queryWithClassName:@"Ticket"];
            
            
            if (self.objects.count == 0) {
                query.cachePolicy = kPFCachePolicyCacheThenNetwork;
            }
            
            
            
            NSLog(@"1");
            
            // [query whereKey:@"userId" equalTo:[PFUser currentUser].objectId];
            
            // NSLog(@"user id: %@", [PFUser currentUser].objectId );
            [query whereKey:@"user" equalTo:[PFUser currentUser]];
            NSLog(@"2");
            
            NSDate *today = [NSDate date];
            [query whereKey:@"endTime" greaterThan:today];
            NSLog(@"3");
            
            [query orderByAscending:@"startTime"];
            NSLog(@"4");
            
            [query whereKey:@"guestlistFulfilled" equalTo:[NSNumber numberWithBool:NO]];
            NSLog(@"5");
            
            [query whereKey:@"guestlist" equalTo:[NSNumber numberWithBool:YES]];
            NSLog(@"6");
            
            [query whereKey:@"ticketFulfilled" equalTo:[NSNumber numberWithBool:NO]];
            NSLog(@"7");
            
            [query whereKey:@"ticket" equalTo:[NSNumber numberWithBool:YES]];
            NSLog(@"8");
            
            
            
            //  listOfItems = self.data;
            
            return query;
        }
            
            break;
        case 3:{
            NSLog(@"Prämien laden");
            
            PFQuery *query = [PFQuery queryWithClassName:@"UserBonus"];
            
            if (self.objects.count == 0) {
                query.cachePolicy = kPFCachePolicyCacheThenNetwork;
            }
            
            

            
            
            [query whereKey:@"userId" equalTo:[PFUser currentUser].objectId];
            
            [query whereKey:@"fulfilled" equalTo:[NSNumber numberWithBool:NO]];
            
            
         //   _listOfClubs = self.clubs;
            
            return query;
            
        }
            break;
        default:
        {
            NSLog(@"Tickets laden");
            PFQuery *query = [PFQuery queryWithClassName:@"Ticket"];
            
            
            if (self.objects.count == 0) {
                query.cachePolicy = kPFCachePolicyCacheThenNetwork;
            }
            
            
            
            
            [query whereKey:@"userId" equalTo:[PFUser currentUser].objectId];
            
            NSDate *today = [NSDate date];
            [query whereKey:@"endTime" greaterThan:today];
            [query orderByAscending:@"startTime"];
            [query whereKey:@"fulfilled" equalTo:[NSNumber numberWithBool:NO]];
            //[PFQuery orQueryWithSubQueries:arrayOfQueries].
            
            
            
            
            //  listOfItems = self.data;
            
            return query;
        }
            
            break;
    }
    
    }





- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object {
    
    
    switch (_typeControl.selectedSegmentIndex) {
        case 4:
        {
            
            static NSString *CellIdentifier = @"TicketCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            NSString *title = [object objectForKey:@"title"];
            NSNumber *amount = [object objectForKey:@"ticketAmount"];
            NSString *host = [object objectForKey:@"host"];
            NSDate *startTime = [object objectForKey:@"startTime"];
            
            NSString* titleString;
            /*
            if([[object objectForKey:@"ticket"]boolValue] && [[object objectForKey:@"guestlist"]boolValue]){
                
                amount = [object objectForKey:@"ticketAmount"];
                if([[object objectForKey:@"ticketAmount"]intValue] == 1){
                    titleString = @"1 Kombiticket für:";

                }
                else{
                    titleString = [NSString stringWithFormat:@"%i Kombitickets für:", (int)amount];

                }
                
            }
            else if ([[object objectForKey:@"ticket"]boolValue]){
                amount = [object objectForKey:@"ticketAmount"];

                if([[object objectForKey:@"ticketAmount"]intValue] == 1){
                    titleString = @"1 Ticket für:";

                }
                else{
                    titleString = [NSString stringWithFormat:@"%i Tickets für:", (int)amount];

                }
                
            }
            else {
                amount = [object objectForKey:@"guestlistAmount"];

                if([[object objectForKey:@"guestlistAmount"]intValue] == 1){
                    titleString = @"1 Gästelistenplatz für:";

                }
                else{
                    titleString = [NSString stringWithFormat:@"%i Gästelistenplätze für:", (int)amount];

                }
                
            }
             */
            
            titleString = title;
            


            
            UILabel *titleLabel = (UILabel*)[cell viewWithTag:4];
            titleLabel.text = titleString;
            
            UILabel *amountLabel = (UILabel*)[cell viewWithTag:5];
            NSString *amountText = [NSString stringWithFormat:@"Anzahl: %@", amount];
            amountLabel.text = amountText;
            amountLabel.hidden = NO;

            UILabel *hostLabel = (UILabel*)[cell viewWithTag:6];
            hostLabel.text = host;
            
            UILabel *dateLabel = (UILabel*)[cell viewWithTag:7];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateStyle = NSDateFormatterShortStyle;
            df.timeStyle = NSDateFormatterShortStyle;
            df.timeZone = [NSTimeZone localTimeZone];
            NSString *dateText = [df stringFromDate:startTime];
            dateLabel.text = dateText;
            
             PFImageView *profileImageView = (PFImageView*)[cell viewWithTag:3];
            PFFile *applicantResume = [object objectForKey:@"image"];
            profileImageView.file = applicantResume;
            
            
            profileImageView.layer.cornerRadius = 28.0f;
            profileImageView.layer.borderWidth = 1.0f;
            profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
            profileImageView.clipsToBounds = YES;
            
            
            [profileImageView loadInBackground];
            
            [titleLabel setTextColor:[UIColor colorWithRed:0 green:0.592 blue:0.655 alpha:1]];
            [hostLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
            [amountLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
            [dateLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];



            return cell;

            
            
        }
            break;
            
        case 3:{
            static NSString *CellIdentifier = @"BonusCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            NSString *title = [object objectForKey:@"title"];
            NSString *host = [object objectForKey:@"hostName"];
            
            
            UILabel *titleLabel = (UILabel*)[cell viewWithTag:1];
            titleLabel.text = title;
            

            
            UILabel *hostLabel = (UILabel*)[cell viewWithTag:2];
            hostLabel.text = host;

            /*
            PFImageView *profileImageView = (PFImageView*)[cell viewWithTag:10];
            PFFile *applicantResume = [object objectForKey:@"image"];
            profileImageView.file = applicantResume;
            
            
            profileImageView.layer.cornerRadius = 28.0f;
            profileImageView.layer.borderWidth = 1.0f;
            profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
            profileImageView.clipsToBounds = YES;
            
            
            [profileImageView loadInBackground];
            */
            
            
            [titleLabel setTextColor:[UIColor colorWithRed:0 green:0.592 blue:0.655 alpha:1]];
            [hostLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
            
            
            
            return cell;
            
            
            
        }
            break;
        default:
            break;
    }
    

    
    static NSString *CellIdentifier = @"TicketCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString *title = [object objectForKey:@"title"];
    NSNumber *amount = @0;
    switch (_typeControl.selectedSegmentIndex){
        case 0:{
            amount = [object objectForKey:@"ticketAmount"];
        } break;
        case 1:{
            amount = [object objectForKey:@"guestlistAmount"];
        } break;
        case 2:{
            int summe =[[object objectForKey:@"guestlistAmount"]intValue] + [[object objectForKey:@"ticketAmount"]intValue];
            amount = [NSNumber numberWithInt:summe];
        }break;
        default:
            break;
    }
    NSString *host = [object objectForKey:@"host"];
    NSDate *startTime = [object objectForKey:@"startTime"];
    
    
    
    UILabel *titleLabel = (UILabel*)[cell viewWithTag:4];
    titleLabel.text = title;
    
    UILabel *amountLabel = (UILabel*)[cell viewWithTag:5];
    NSString *amountText = [NSString stringWithFormat:@"Anzahl: %@", amount];
    amountLabel.text = amountText;
    amountLabel.hidden = NO;
    
    UILabel *hostLabel = (UILabel*)[cell viewWithTag:6];
    hostLabel.text = host;
    
    UILabel *dateLabel = (UILabel*)[cell viewWithTag:7];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterShortStyle;
    df.timeStyle = NSDateFormatterShortStyle;
    df.timeZone = [NSTimeZone localTimeZone];
    NSString *dateText = [df stringFromDate:startTime];
    dateLabel.text = dateText;
    
    PFImageView *profileImageView = (PFImageView*)[cell viewWithTag:3];
    PFFile *applicantResume = [object objectForKey:@"image"];
    profileImageView.file = applicantResume;
    
    
    profileImageView.layer.cornerRadius = 28.0f;
    profileImageView.layer.borderWidth = 1.0f;
    profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    profileImageView.clipsToBounds = YES;
    
    
    [profileImageView loadInBackground];
    
    [titleLabel setTextColor:[UIColor colorWithRed:0 green:0.592 blue:0.655 alpha:1]];
    [hostLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
    [amountLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
    [dateLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
    
    
    
    return cell;

    
    
}


- (IBAction)typeControlPressed:(id)sender {
    [self loadObjects];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    

    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    if ([segue.identifier isEqualToString:@"ticketDetail"])
    {
        
        
        UserTicketDetailViewController *detailController =segue.destinationViewController;
        
        PFObject *selectedObject = [self objectAtIndexPath:self.tableView.indexPathForSelectedRow];
        
        NSString *title = [selectedObject objectForKey:@"title"];
        
        NSLog(@"title: %@", title);
        
        detailController.ticket = selectedObject;
        detailController.ticketType = _typeControl.selectedSegmentIndex;
        
        NSLog(@"detail laden");

        
        [detailController setTitle:title];
      //  self.navigationController.delegate = self;
        
        
        
        
        
    }
    
}


@end
