//
//  MembershipViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 24.10.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import "MembershipViewController.h"
#import <Parse/Parse.h>
#import "MoreInformationViewController.h"



@interface MembershipViewController ()
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;

@end

@implementation MembershipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.title = @"Info";
    NSLog(@"membershipview wird geladen");
    
    
    _descriptionTextView.text = @"•  Kostenloser Eintritt\n•  Prämien nur für dich\n•  Rabatt bei Gästelistenplätze\n•  Punktemultiplikator\n•  Exklusive Sonderangebote";
    
    
    // get the lowest price from parse config file
    
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        if (!error) {
            NSLog(@"Yay! Config was fetched from the server.");
        } else {
            NSLog(@"Failed to fetch. Using Cached Config.");
            config = [PFConfig currentConfig];
        }
        
        NSString *priceText = config[@"membershipPrice"];
        if (!priceText) {
            NSLog(@"Falling back to default message.");
            priceText = @"Ab 29,99€";
        }
        
        
        _priceLabel.text = [NSString stringWithFormat:@"Ab %@",priceText];

        
        
    }];
    
    //@"Mit diesem Pass kommst du kostenlos in alle teilnehmenden Clubs,  erhälst besondere Prämien in Clubs und Bars, bekommst für deinen Besuch zusätzliche Punkte und Rabatt auf Tickets und Gästelistenplätze!"
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"moreInfo"])
    {
        MoreInformationViewController *detailController =segue.destinationViewController;
        detailController.isMembership = YES;
        
    }
}


@end
