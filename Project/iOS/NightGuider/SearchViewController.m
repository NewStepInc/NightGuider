//
//  SearchViewController.m
//  Nightlife_2
//
//  Created by Werner on 27.11.12.
//  Copyright (c) 2012 Werner. All rights reserved.
//

#import "SearchViewController.h"
#import "ResultsViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SearchViewController ()
@property (weak, nonatomic) IBOutlet UIButton *searchButton;


@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _searchButton.backgroundColor = [UIColor colorWithRed:0 green:0.592 blue:0.655 alpha:1];
    
    [_searchButton setBackgroundImage:nil forState:UIControlStateNormal];

    _searchButton.layer.cornerRadius = 4.0f;
    
    UIColor* bgColor2 = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.0];
    
    [self.view setBackgroundColor:bgColor2];
    
    
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)close:(UIStoryboardSegue *)segue{
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
   
    if ([[segue identifier] isEqualToString:@"show"]) {
        

        [segue destinationViewController];
        
    }
    
    else if ([segue.identifier isEqualToString:@"search"])
	{
        
        NSLog(@"check");
        
        NSLog(@"datum: %@",self.datePicker.date);

    
        ResultsViewController *resultViewController = segue.destinationViewController;
        
        
        // switch (_wahl.selectedSegmentIndex)
        /*
        switch(self.restrictSegmentControl.selectedSegmentIndex)
         {
         case 0: {
         resultViewController.title = @"Alle";
         resultViewController.art = @"alle";
         NSLog(@"Alle");
             break;
         }
         
         case 1: {
         resultViewController.title = @"Bars";
         resultViewController.art = @"bar";
         NSLog(@"Bars");
             break;
         
         }
         
         case 2: {
         resultViewController.title = @"Discos";
         resultViewController.art = @"disco";
         NSLog(@"Discos");
             break;
         
         }
         
         case 3: {
         resultViewController.title = @"Happy Hour";
         resultViewController.art = @"Happy Hour";
         NSLog(@"Happy Hour");
             break;
         
         }
         
         }
         
        if (_dateSwitch.on){
            NSLog(@"Switch ist auf AN");
            resultViewController.dateSwitch = @"YES";
        }
        else {
            NSLog(@"Switch ist auf AUS");
            resultViewController.dateSwitch = @"NO";
            
        }
    
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateStyle = NSDateFormatterShortStyle;
        df.timeStyle = NSDateFormatterShortStyle;
        
        
        df.timeZone = [NSTimeZone localTimeZone];
        
        */
        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Datum und Zeit" message:[df stringFromDate:self.datePicker.date] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
         */
        
        
        /*
         Nach nähe suchen
        PFQuery *query = [PFQuery queryWithClassName:@"places"];
        [query whereKey:@"location" nearGeoPoint:geoPoint withinMiles:100];
        
        [query orderByDescending:@"name"];
         
         */
        
        resultViewController.dateSwitch = @"YES";

        resultViewController.date = self.datePicker.date;
 
        
	}


}




@end
