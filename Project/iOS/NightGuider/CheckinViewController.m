//
//  CheckinViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 18.11.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import "CheckinViewController.h"
#import "SCLAlertView.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>



@interface CheckinViewController () <CLLocationManagerDelegate,UIAlertViewDelegate,CBCentralManagerDelegate>
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic) CBCentralManager *bluetoothManager;

@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end

@implementation CheckinViewController{
    CLLocationManager *locationManager;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"Wird geladen", @"Wird geladen...");
    [self.hud show:YES];
    
    _bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self
                                                             queue:nil
                                                           options:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]
                                                                                               forKey:CBCentralManagerOptionShowPowerAlertKey]];

    


    
    
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        if (!error) {
            NSLog(@"Yay! Config was fetched from the server.");
        } else {
            NSLog(@"Failed to fetch. Using Cached Config.");
            config = [PFConfig currentConfig];
        }
        
        NSString *informationText = config[@"checkinInformation_de"];
        if (!informationText) {
            NSLog(@"Falling back to default message.");
            informationText = @"Der Checkin läuft kontaktlos ab. Du musst dein Smartphone nicht einmal aus deiner Tasche nehmen, kein lästiges abscannen oder abstempeln lassen!\nGehe einfach durch den Eingang und schon erhälst du deine Punkte gut geschrieben. Dafür musst du jedoch angemeldet sein, der App die benötiten Rechte erteilen und dein Bluetooth aktivieren.\nKeine Sorge es wird Bluetooth 4.0 verwendet eine sehr Akkuschonende Variante und flls du doch sorgen wegen deines Akkus hast kannst du Bluetooth nach erfolrgeichem Checkin natürlich auch wieder ausschalten :)\nViel Spaß beim Punkte sammeln!";
        }
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineHeightMultiple = 1.5f;
        NSDictionary *attribute = @{
                                    NSParagraphStyleAttributeName : paragraphStyle,
                                    };
        _descriptionTextView.attributedText = [[NSAttributedString alloc] initWithString:informationText attributes:attribute];
        [ _descriptionTextView setFont:[UIFont fontWithName:@"Helvetica Neue" size:16.0f]];
        _descriptionTextView.textColor = [UIColor whiteColor];
    }];
     
        

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
- (IBAction)checkinButtonPressed:(id)sender {
    
    NSLog(@"buttonpressed");
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    //Hide animation type (Default is FadeOut)
    alert.hideAnimationType = SlideOutToTop;
    
    //Show animation type (Default is SlideInFromTop)
    alert.showAnimationType = SlideInFromTop;
    
    //Set background type (Default is Shadow)
    alert.backgroundType = Blur;
    
    [alert alertIsDismissed:^{
    }];

    
#pragma  ios8 location erlaubnis
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        NSLog(@"reagiert auf requestalwaysauthorization");
        
    }
    
    if(IOS_NEWER_OR_EQUAL_TO_8){
        
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        
        NSLog(@"erlaubnis erfragen");
        
        
        if (status == kCLAuthorizationStatusDenied) {
            NSLog(@"erlaubnis abgelehnt");
            
            [locationManager requestAlwaysAuthorization];
            
            
            
             NSString *title;
             title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
             NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
             
             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
             message:message
             delegate:self
             cancelButtonTitle:@"Cancel"
             otherButtonTitles:@"Settings", nil];
             alertView.tag = 1;
             [alertView show];
             
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"startRanging" object:nil userInfo:nil];
            
        }
        // [_locationManager requestWhenInUseAuthorization];
        
        else if (status == kCLAuthorizationStatusNotDetermined) {
            NSLog(@"erlaubnis noch nicht erteilt");
            
            [locationManager requestAlwaysAuthorization];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"startRanging" object:nil userInfo:nil];
            
            
            // [locationManager requestWhenInUseAuthorization];
        }
        
        else if (status == kCLAuthorizationStatusAuthorizedWhenInUse){
            
            NSLog(@"erlaubnis always noch nicht erteilt");
            
            [locationManager requestAlwaysAuthorization];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"startRanging" object:nil userInfo:nil];
        }
        
        else{
            NSLog(@"erlaubnis erteilt");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"startRanging" object:nil userInfo:nil];
            
        }
        
    }
    
    
    else{
        NSLog(@"ios 7");
    }
    
    
    NSString *stateString = nil;
    switch(_bluetoothManager.state)
    {
        case CBCentralManagerStateResetting: stateString = @"The connection with the system service was momentarily lost, update imminent."; break;
            
        case CBCentralManagerStateUnsupported: {
            stateString = @"The platform doesn't support Bluetooth Low Energy.";
            [alert showNotice:self title:@"Nicht verfügbar" subTitle:stateString closeButtonTitle:@"Abbrechen" duration:0.0f];
        }break;
            
        case CBCentralManagerStateUnauthorized: {
            stateString = @"The app is not authorized to use Bluetooth Low Energy.";
            [alert addButton:@"Öffnen" actionBlock:^{
                NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:settingsURL];
            }];
            [alert showNotice:self title:@"Erlaubnis verweigert" subTitle:stateString closeButtonTitle:@"Abbrechen" duration:0.0f];
        }break;
            
        case CBCentralManagerStatePoweredOff: {
            stateString = @"Bluetooth is currently powered off.";
            [alert addButton:@"Öffnen" actionBlock:^{
                NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:settingsURL];
        }];
            [alert showNotice:self title:@"Bluetooth aus" subTitle:stateString closeButtonTitle:@"Abbrechen" duration:0.0f];
        }break;
            
        case CBCentralManagerStatePoweredOn: {
            stateString = @"Bluetooth is currently powered on and available to use.";
            [alert showSuccess:self title:@"Aktiv" subTitle:stateString closeButtonTitle:@"Abbrechen" duration:0.0f];
            
        }break;
            
        default: stateString = @"State unknown, update imminent."; break;
            
    }
    NSLog(@"Bluetooth State: %@",stateString);
    
    

}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == 1) {
        if (buttonIndex == 1) {
            // Send the user to the Settings for this app
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:settingsURL];
        }
    }
    
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    // This delegate method will monitor for any changes in bluetooth state and respond accordingly
    NSLog(@"bluetooth check wird aufgerufn");
    NSString *stateString = nil;
    switch(_bluetoothManager.state)
    {
        case CBCentralManagerStateResetting: stateString = @"The connection with the system service was momentarily lost, update imminent."; break;
        case CBCentralManagerStateUnsupported: stateString = @"The platform doesn't support Bluetooth Low Energy."; break;
        case CBCentralManagerStateUnauthorized: stateString = @"The app is not authorized to use Bluetooth Low Energy."; break;
        case CBCentralManagerStatePoweredOff: stateString = @"Bluetooth is currently powered off."; break;
        case CBCentralManagerStatePoweredOn: stateString = @"Bluetooth is currently powered on and available to use."; break;
        default: stateString = @"State unknown, update imminent."; break;
    }
    NSLog(@"Bluetooth State: %@",stateString);
}

@end
