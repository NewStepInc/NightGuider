//
//  InfoViewController.m
//  NightGuider
//
//  Created by Werner on 13.12.12.
//  Copyright (c) 2012 Werner. All rights reserved.
//

#import "InfoViewController.h"


@interface InfoViewController ()
@property (weak, nonatomic) IBOutlet UIButton *feedbackButton;
@property (weak, nonatomic) IBOutlet UIButton *urlButton;

@end

@implementation InfoViewController



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    _urlButton.layer.cornerRadius = 8;
    _urlButton.clipsToBounds = YES;
    _urlButton.layer.borderWidth = 1;
    _urlButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    _feedbackButton.layer.cornerRadius = 8;
    _feedbackButton.clipsToBounds = YES;
    _feedbackButton.layer.borderWidth = 1;
    _feedbackButton.layer.borderColor = [UIColor whiteColor].CGColor;

    
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}



-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Cancelled.");
            break;
            
        case MFMailComposeResultSaved:
            NSLog(@"Message saved in drafts folder.");
            break;
            
        case MFMailComposeResultSent:
            NSLog(@"Message is sent.");
            break;
            
        case MFMailComposeResultFailed:
            NSLog(@"Message not send due to error.");
            break;
            
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)openEmail:(id)sender {
    if ([MFMailComposeViewController canSendMail])
    {
        
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc]init];
        mail.mailComposeDelegate = self;
        
        [mail setSubject:@"Supportnachricht"];
        
        NSArray *recipients = [NSArray arrayWithObjects:@"info@nightguider.de", nil];
        [mail setToRecipients:recipients];
        
        /*
         NSString *emailBody = @"Das hier ist eine Testnachricht";
         [mail setMessageBody:emailBody isHTML:NO];
         */
        
        
        mail.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentViewController:mail animated:YES completion:nil];
        
    }
    
    else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fehler" message:@"Email wird von deinem Gerät nicht unterstützt" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
    }
}

- (IBAction)openUrl:(id)sender {
    UIApplication *app = [UIApplication sharedApplication];
    [app openURL:[NSURL URLWithString:@"http://nightguider.de/"]];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


@end

