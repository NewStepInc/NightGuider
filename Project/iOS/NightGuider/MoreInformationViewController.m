//
//  MoreInformationViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 16.11.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import "MoreInformationViewController.h"
#import <Parse/Parse.h>


@interface MoreInformationViewController ()
@property (weak, nonatomic) IBOutlet UITextView *informationTextView;
@property (nonatomic, strong) NSString *informationLink;


@end

@implementation MoreInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    if (_isMembership) {
        NSLog(@"membership");
        [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
            if (!error) {
                NSLog(@"Yay! Config was fetched from the server.");
            } else {
                NSLog(@"Failed to fetch. Using Cached Config.");
                config = [PFConfig currentConfig];
            }
            
            NSString *informationText = config[@"membershipInformation_de"];
            if (!informationText) {
                NSLog(@"Falling back to default message.");
#warning -- change default message
                
                informationText = @"Welcome!";
            }
            
          //  _informationTextView.text = informationText;
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineHeightMultiple = 1.5f;
            NSDictionary *attribute = @{
                                        NSParagraphStyleAttributeName : paragraphStyle,
                                        };
             _informationTextView.attributedText = [[NSAttributedString alloc] initWithString:informationText attributes:attribute];
            [ _informationTextView setFont:[UIFont fontWithName:@"Helvetica Neue" size:17.0f]];
            _informationTextView.textColor = [UIColor whiteColor];
            _informationLink = config[@"membershipLink_de"];

            
        }];

        
    }
    else if (_isBonus){
        NSLog(@"bonus");
        [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
            if (!error) {
                NSLog(@"Yay! Config was fetched from the server.");
            } else {
                NSLog(@"Failed to fetch. Using Cached Config.");
                config = [PFConfig currentConfig];
            }
            
            NSString *informationText = config[@"bonusInformation_de"];
            if (!informationText) {
                NSLog(@"Falling back to default message.");
#warning -- change default message
                
                informationText = @"Welcome!";
            }
            
            //  _informationTextView.text = informationText;
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineHeightMultiple = 1.5f;
            NSDictionary *attribute = @{
                                        NSParagraphStyleAttributeName : paragraphStyle,
                                        };
            _informationTextView.attributedText = [[NSAttributedString alloc] initWithString:informationText attributes:attribute];
            [ _informationTextView setFont:[UIFont fontWithName:@"Helvetica Neue" size:17.0f]];
            _informationTextView.textColor = [UIColor whiteColor];
            _informationLink = config[@"bonusLink_de"];

        }];

        
    }
    else if (_isTerms){
        NSLog(@"bonus");
        [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
            if (!error) {
                NSLog(@"Yay! Config was fetched from the server.");
            } else {
                NSLog(@"Failed to fetch. Using Cached Config.");
                config = [PFConfig currentConfig];
            }
            
            NSString *informationText = config[@"terms_de"];
            if (!informationText) {
                NSLog(@"Falling back to default message.");
                informationText = @"Leider konnten die AGBs und Datenschutzrichtlinien nicht geladen werden\nVersuch es später erneut oder besuch unsere Website: NightGuider.de\n um die Texte nachzulesen";
            }
            
            //  _informationTextView.text = informationText;
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineHeightMultiple = 1.5f;
            NSDictionary *attribute = @{
                                        NSParagraphStyleAttributeName : paragraphStyle,
                                        };
            _informationTextView.attributedText = [[NSAttributedString alloc] initWithString:informationText attributes:attribute];
            [ _informationTextView setFont:[UIFont fontWithName:@"Helvetica Neue" size:17.0f]];
            _informationTextView.textColor = [UIColor whiteColor];
            _informationLink = config[@"termsLink_de"];
            
        }];
        
        
    }
    else{
        NSLog(@"tagesticket");
        [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
            if (!error) {
                NSLog(@"Yay! Config was fetched from the server.");
            } else {
                NSLog(@"Failed to fetch. Using Cached Config.");
                config = [PFConfig currentConfig];
            }
            
            NSString *informationText = config[@"dayTicketInformation_de"];
            if (!informationText) {
                NSLog(@"Falling back to default message.");
#warning -- change default message
                informationText = @"Welcome!";
            }
            
          //  _informationTextView.text = informationText;
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineHeightMultiple = 1.5f;
            NSDictionary *attribute = @{
                                        NSParagraphStyleAttributeName : paragraphStyle,
                                        };
            _informationTextView.attributedText = [[NSAttributedString alloc] initWithString:informationText attributes:attribute];
            [ _informationTextView setFont:[UIFont fontWithName:@"Helvetica Neue" size:17.0f]];
            _informationTextView.textColor = [UIColor whiteColor];
            _informationLink = config[@"dayTicketLink_de"];

        }];

    }
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)moreButtonPressed:(id)sender {
    
    if (!_informationLink) {
        NSLog(@"Falling back to default link");
        UIApplication *app = [UIApplication sharedApplication];
        [app openURL:[NSURL URLWithString:@"http://nightguider.de/"]];
    }
    else{
        NSLog(@"customLink");
        UIApplication *app = [UIApplication sharedApplication];
        [app openURL:[NSURL URLWithString:_informationLink]];
    }
    
}

@end
