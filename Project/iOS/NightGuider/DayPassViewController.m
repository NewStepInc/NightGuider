//
//  DayPassViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 24.10.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import "DayPassViewController.h"
#import <Parse/Parse.h>
#import "CheckoutViewController.h"
#import "MembershipCityViewController.h"
#import "MoreInformationViewController.h"


@interface DayPassViewController ()
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;

@property (nonatomic, retain) NSDateFormatter * formatter;
@property (nonatomic, retain) NSDate * selectedDate;




@end

@implementation DayPassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //beschreibung
    //bild
    //preis von config?
    //datum auswählen
    //bei datum select weiter zu checkout
    //oder datum auswählen und danach af weiter gehen?
    
    self.title = @"Info";
    self.navigationItem.title = @"zurück";


    self.formatter = [[NSDateFormatter alloc] init];
    [_formatter setDateFormat:@"dd/MM/yyyy --- HH:mm"];
    
    NSLog(@"membershipview wird geladen");
   // _descriptionTextView.text = @"• Für ganz Deutschland!\n\n• Kostenloser Eintritt\n• Prämien nur für dich\n\n• Rabatt bei Gästelistenplätze\n\n• Punktemultiplikator\n\n• Exklusive Sonderangebote\n\n• Ideal für einen Wochenendtrip!";
    
    NSString *description = @"•  Für ganz Deutschland!\n•  Kostenloser Eintritt\n•  Prämien nur für dich\n•  Rabatt bei Gästelistenplätze\n•  Punktemultiplikator\n•  Exklusive Sonderangebote\n•  Ideal für einen Wochenendtrip!";
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 1.5f;
    NSDictionary *attribute = @{
                                NSParagraphStyleAttributeName : paragraphStyle,
                                };
    _descriptionTextView.attributedText = [[NSAttributedString alloc] initWithString:description attributes:attribute];
    [_descriptionTextView setFont:[UIFont fontWithName:@"Helvetica Neue" size:17.0f]];
    _descriptionTextView.textColor = [UIColor whiteColor];


    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        if (!error) {
            NSLog(@"Yay! Config was fetched from the server.");
        } else {
            NSLog(@"Failed to fetch. Using Cached Config.");
            config = [PFConfig currentConfig];
        }
        
        NSString *priceText = config[@"dayTicketPrice"];
        if (!priceText) {
            NSLog(@"Falling back to default message.");
            priceText = @"Ab 29,99€";
        }
        
        
        _priceLabel.text = [NSString stringWithFormat:@"Ab %@",priceText];
        
        
        
    }];
    
    
    
    //            [alert showInfo:self title:@"3 Tagespass" subTitle:@"Mit diesem Pass kommst du kostenlos in alle teilnehmenden Clubs, erhälst besondere Prämien in Clubs und Bars und das in ganz Deutschland!" closeButtonTitle:@"Schließen" duration:0.0f];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - THDatePickerDelegate

- (void)datePickerDonePressed:(THDatePickerViewController *)datePicker {
    self.selectedDate = datePicker.date;
  //  [self refreshTitle];
    [self dismissSemiModalView];
    [self performSegueWithIdentifier:@"cityPick" sender:self];

}

- (void)datePickerCancelPressed:(THDatePickerViewController *)datePicker {
    [self dismissSemiModalView];
}

- (void)datePicker:(THDatePickerViewController *)datePicker selectedDate:(NSDate *)selectedDate {
    NSLog(@"Date selected: %@",[_formatter stringFromDate:selectedDate]);
}
- (IBAction)showDatePicker:(id)sender {
    
    
    
    if(!self.datePicker)
        self.datePicker = [THDatePickerViewController datePicker];
    self.datePicker.date = [NSDate date];
    self.datePicker.delegate = self;
    [self.datePicker setAllowClearDate:NO];
    [self.datePicker setClearAsToday:YES];
    [self.datePicker setAutoCloseOnSelectDate:NO];
    [self.datePicker setAllowSelectionOfSelectedDate:YES];
    [self.datePicker setDisableYearSwitch:YES];
    [self.datePicker setDisableHistorySelection:YES];
    //[self.datePicker setDisableFutureSelection:NO];
  //  [self.datePicker setDaysInHistorySelection:1];
  //  [self.datePicker setDaysInFutureSelection:0];
    //    [self.datePicker setDateTimeZoneWithName:@"UTC"];
    //[self.datePicker setAutoCloseCancelDelay:5.0];
    [self.datePicker setSelectedBackgroundColor:[UIColor colorWithRed:125/255.0 green:208/255.0 blue:0/255.0 alpha:1.0]];
    
    //[self.datePicker setSelectedBackgroundColor:[UIColor colorWithRed:0/255.0 green:188/255.0 blue:212/255.0 alpha:1.0]];
    
    [self.datePicker setCurrentDateColor:[UIColor colorWithRed:242/255.0 green:121/255.0 blue:53/255.0 alpha:1.0]];
    [self.datePicker setCurrentDateColorSelected:[UIColor yellowColor]];
    
    /*
    [self.datePicker setDateHasItemsCallback:^BOOL(NSDate *date) {
        int tmp = (arc4random() % 30)+1;
        return (tmp % 5 == 0);
    }];
    */
    //[self.datePicker slideUpInView:self.view withModalColor:[UIColor lightGrayColor]];
  /*  [self presentSemiViewController:self.datePicker withOptions:@{
                                                                  KNSemiModalOptionKeys.pushParentBack    : @(NO),
                                                                  KNSemiModalOptionKeys.animationDuration : @(1.0),
                                                                  KNSemiModalOptionKeys.shadowOpacity     : @(0.3),
                                                                  }];
    */
    
    [self presentSemiViewController:self.datePicker withOptions:@{
                                                                  KNSemiModalOptionKeys.pushParentBack    : @(NO),
                                                                  KNSemiModalOptionKeys.animationDuration : @(0.2),
                                                                  KNSemiModalOptionKeys.shadowOpacity     : @(0.3),
                                                                  }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    if ([segue.identifier isEqualToString:@"cityPick"]) {
        
      //  MembershipCityViewController *cityPickController = [segue destinationViewController];
        
      //  UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
      //  MembershipCityViewController *cityPickController = [navController topViewController];
        
        MembershipCityViewController *cityPickController = (MembershipCityViewController *)[[segue destinationViewController] topViewController];


        cityPickController.productType = @"dayTicket";
        cityPickController.startDate = _selectedDate;
        
    }
    
    else if ([segue.identifier isEqualToString:@"checkout"])
    {
        NSLog(@"checkout");

        
                CheckoutViewController *checkoutController = (CheckoutViewController *)[[segue destinationViewController] topViewController];
        
        //   PFObject *selectedObject = [self objectAtIndexPath:self.cityTableView.indexPathForSelectedRow];
        
        //    NSString *title = [selectedObject objectForKey:@"name"];
        
        
        
         checkoutController.productType = @"dayTicket";
         
         checkoutController.startDate = _selectedDate;
#warning region or whole germany?
        /*
        checkoutController.region = _;
        checkoutController.regionType = _;
        */


        
         checkoutController.amount = 1;

        
        
        
        
        
    }
    else  if ([segue.identifier isEqualToString:@"moreInfo"])
    {
        MoreInformationViewController *detailController =segue.destinationViewController;
        detailController.isMembership = NO;
        
    }
    
    
    
}


@end
