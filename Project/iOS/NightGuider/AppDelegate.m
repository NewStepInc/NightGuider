//
//  AppDelegate.m
//  NightGuider
//
//  Created by Werner Kohn on 20.10.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <Bolts/Bolts.h>
#import <PAYFormBuilder.h>
#import "PayPalMobile.h"
#import "Stripe.h"
#import "Branch.h"



#warning -- key here necessary?

NSString * const StripePublishableKey = @"pk_test_JCOG2vg068yxMoJTSEPa4Qna";


@interface AppDelegate ()<UIAlertViewDelegate>
@property int status;

@property (nonatomic, strong) NSString *major;
@property (nonatomic, strong) NSString *minor;
@property (nonatomic, strong) NSString *uuid_string;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //customize appearance
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0 green:0.737 blue:0.831 alpha:1]];
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:0.00 green:0.60 blue:0.80 alpha:1.0]];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UITabBarController *tabb = (UITabBarController *)self.window.rootViewController;
    tabb.selectedIndex = 2;
    
    
    [Parse setApplicationId:@"Jy3BtpqGCsg2Wa6tFM1XpJRN76MRjOPG2oEGCGjB" clientKey:@"GUgJ6gEU3R8GgvN3ZZJWek6xixQ9Tr9z6txQVJg4"];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];


  /*  [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
   */
    
    PFACL *defaultACL = [PFACL ACL];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    //searchbar textcolor
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    
    _pushID = nil;
    _eventId =nil;
    _clubId =nil;
    _barId =nil;
    _memberTicket = NO;
    _dayTicket = NO;
    
    if (_eventId) {
        NSLog(@"nil zählt");
    }
    
    //check if app openeed via branch link
#warning sometimes skipping to productsview also after the app launch
    //take the tabb.selectedIndex out of branch block
    
    Branch *branch = [Branch getInstance];
    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        if (!error) {
            // params are the deep linked params associated with the link that the user clicked -> was re-directed to this app
            // params will be empty if no data found
            // ... insert custom logic here ...
            NSLog(@"params: %@", params);
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
            {
                
                NSLog(@"app already launched_1");
                /*
                 UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                 
                 UITabBarController *vc =[storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
                 
                 vc.selectedIndex=2;
                 
                 self.window.rootViewController = vc;
                 [self.window makeKeyAndVisible];
                 */
                
                NSLog(@"status am anfang: %i", _status);
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                int stat = (int) [defaults integerForKey:@"status"];
                [defaults setBool:NO forKey:@"notificationRequestOpened"];
                
                NSLog(@"stat: %i",stat);
                
                //check if notifications are allowed
                if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
                    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"notificationAllowed"])
                    {
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        int statNoti = (int) [defaults integerForKey:@"notificationOpenings"];
                        int stat_1 = statNoti++;
                        if (stat >= 7)
                        {
                            
                            //open reminder for notifications
                            [defaults setBool:YES forKey:@"notificationRequestOpened"];
                            
                            NSLog(@"push info anzeigen");

                            
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Push Benachrichtigung 2"
                                                                                message:@"Möchtest Benachrichtigungen erlauben?\nDadurch erhälst du spannende Informationen und Angebote"
                                                                               delegate:self
                                                                      cancelButtonTitle:@"Nicht jetzt"
                                                                      otherButtonTitles:@"Ja", nil];
                            alertView.tag = 1;
                            [alertView show];
                        }
                        else{
                            [defaults setInteger:stat_1 forKey:@"notificationOpenings"];
                            [defaults synchronize];
                            
                        }
                        
                        
                    }
                    else{
                        
                        
                        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                                        UIUserNotificationTypeBadge |
                                                                        UIUserNotificationTypeSound);
                        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                                 categories:nil];
                        [application registerUserNotificationSettings:settings];
                        [application registerForRemoteNotifications];
                        
                    }
                }
                
                
                _status = 3;
                
                // Store the data
                
                [defaults setInteger:_status forKey:@"status"];
                [defaults synchronize];
                
                
                //prepare locationmanager
                
                if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
                    
                    

                    //   UILocalNotification *notification2 = [[UILocalNotification alloc] init];
                    
                    //   notification2.alertBody = NSLocalizedString(@"Monitoring not available_2", @"");
                    //  [[UIApplication sharedApplication] presentLocalNotificationNow:notification2];
                    
                }
                
                else {
                    
                    
                    if (_locationManager!=nil) {
                        if(_beaconRegion){
                            NSLog(@"uuid schon vorhanden");
                            _beaconRegion.notifyOnEntry = YES;
                            _beaconRegion.notifyOnExit = YES;
                            _beaconRegion.notifyEntryStateOnDisplay = YES;
                            [_locationManager startMonitoringForRegion:_beaconRegion];
                            
                            [_locationManager requestStateForRegion:_beaconRegion];
                            
                            
                            
                        }
                        else{
                            _uuid = [[NSUUID alloc] initWithUUIDString:@"f7826da6-4fa2-4e98-8024-bc5b71e0893e"];
                            NSLog(@"uuid laden");
                            _locationManager = [[CLLocationManager alloc] init];
                            _locationManager.delegate = self;
                            _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid identifier:@"com.wernerkohn.clubbeacon"];
                            if(_beaconRegion){
                                _beaconRegion.notifyOnEntry = YES;
                                _beaconRegion.notifyOnExit = YES;
                                _beaconRegion.notifyEntryStateOnDisplay = YES;
                                [_locationManager startMonitoringForRegion:_beaconRegion];
                                [_locationManager startRangingBeaconsInRegion:_beaconRegion];
                                
                                [_locationManager requestStateForRegion:_beaconRegion];
                                
                                
                            }
                            
                        }
                    }
                    else{
                        _uuid = [[NSUUID alloc] initWithUUIDString:@"f7826da6-4fa2-4e98-8024-bc5b71e0893e"];
                        
                        
                        _locationManager = [[CLLocationManager alloc] init];
                        _locationManager.delegate = self;
                        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid identifier:@"com.wernerkohn.clubbeacon"];
                        if(_beaconRegion){
                            //   NSLog(@"beaconregion");
                            _beaconRegion.notifyOnEntry = YES;
                            _beaconRegion.notifyOnExit = YES;
                            _beaconRegion.notifyEntryStateOnDisplay = YES;
                            [_locationManager stopMonitoringForRegion:_beaconRegion];
                            
                            [_locationManager startMonitoringForRegion:_beaconRegion];
                            
                            [_locationManager requestStateForRegion:_beaconRegion];
                            
                            [_locationManager startRangingBeaconsInRegion:_beaconRegion];
                            
                            
                            
                        }
                        
                    }
                    
                    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
                        NSLog(@"open alert");
                        
#pragma status
                        /*
                        kCLAuthorizationStatusNotDetermined User has not been asked to authorize location monitoring.
                        
                        kCLAuthorizationStatusRestricted User has “Location Services” turned off in “Settings”.
                        
                        kCLAuthorizationStatusDenied User tapped “NO” or turned off in “Settings”.
                        
                        kCLAuthorizationStatusAuthorized applies to iOS7 and below.
                        
                        kCLAuthorizationStatusAuthorizedAlways User authorized background use.
                        
                        kCLAuthorizationStatusAuthorizedWhenInUse User authorized use only while app is in foreground.
                         */

                        
                        if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {

                            NSLog(@"wheninuse");
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Locationservice erlauben"
                                                                                message:@"Setze bei Ortnungsdienst den Hacken auf \"Immer\"\nDadurch erhälst du Punkte fürs einchecken, ohne die App zu öffnen!"
                                                                               delegate:self
                                                                      cancelButtonTitle:@"Nicht jetzt"
                                                                      otherButtonTitles:@"OK", nil];
                            alertView.tag = 3;
                            [alertView show];


                        }
                        else if(status == kCLAuthorizationStatusDenied){
                            NSLog(@"denied");
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Locationservice erlauben"
                                                                                message:@"Möchtest du Locationservice in den Einstellungen erlauben?\nDadurch kann die Distanz und die Route zu Clubs angezeigt werden und du erhälst Punkte fürs einchecken!"
                                                                               delegate:self
                                                                      cancelButtonTitle:@"Nicht jetzt"
                                                                      otherButtonTitles:@"Ja", nil];
                            alertView.tag = 3;
                            [alertView show];
                            

                        }
                        
                        else if (status == kCLAuthorizationStatusNotDetermined) {
                            NSLog(@"notdetermined");

                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Locationservice erlauben"
                                                                                message:@"Möchtest Locationservice erlauben?\nDadurch kann die Distanz und die Route zu Clubs angezeigt werden und du erhälst Punkte fürs einchecken!"
                                                                               delegate:self
                                                                      cancelButtonTitle:@"Nicht jetzt"
                                                                      otherButtonTitles:@"Ja", nil];
                            alertView.tag = 2;
                            [alertView show];

                        }
                        else if(status == kCLAuthorizationStatusRestricted){
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Locationservice deaktiviert"
                                                                                message:@"Möchtest Locationservice aktivieren?\nDadurch kann die Distanz und die Route zu Clubs angezeigt werden und du erhälst Punkte fürs einchecken!"
                                                                               delegate:self
                                                                      cancelButtonTitle:@"Nicht jetzt"
                                                                      otherButtonTitles:@"Einstellungen", nil];
                            alertView.tag = 3;
                            [alertView show];
                        }
                        else{
                            NSLog(@"always on erlaubt status: %d",status);

                        }
                    }
                    [_locationManager startUpdatingLocation];
                    
                    
                }
                
#pragma prüfen ob es direkt die installation ist, falls ja zuerst stadt und login auswählen, nach login tab auswählen
                //if first launch open citypicker and loginscreen
                
                if ([params objectForKey:@"eventId"])
                {
                    
                    NSLog(@"id: %@",[params objectForKey:@"eventId"]);
                    _eventId =[params objectForKey:@"eventId"];
                    
                    UITabBarController *tabb = (UITabBarController *)self.window.rootViewController;
                    tabb.selectedIndex = 0;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showEvent" object:nil];
                    
                    
                }
                else if ([params objectForKey:@"clubId"])
                {
                    
                    NSLog(@"id: %@",[params objectForKey:@"clubId"]);
                    _clubId =[params objectForKey:@"clubId"];
                    
                    UITabBarController *tabb = (UITabBarController *)self.window.rootViewController;
                    tabb.selectedIndex = 1;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showClub" object:nil];
                    
                    
                }
                else if ([params objectForKey:@"barId"])
                {
                    
                    NSLog(@"id: %@",[params objectForKey:@"barId"]);
                    _barId =[params objectForKey:@"barId"];
                    
                    UITabBarController *tabb = (UITabBarController *)self.window.rootViewController;
                    tabb.selectedIndex = 3;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showBar" object:nil];
                    
                    
                }
                else if ([params objectForKey:@"dayTicket_3"])
                {
                    
                    NSLog(@"id: %@",[params objectForKey:@"dayTicket_3"]);
                    _dayTicket = YES;
                    
                    
                    UITabBarController *tabb = (UITabBarController *)self.window.rootViewController;
                    tabb.selectedIndex = 2;
                    
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showDayTicket" object:nil];
                    
                    
                }
                else if ([params objectForKey:@"memberTicket_3"])
                {
                    
                    NSLog(@"memberticket %@",[params objectForKey:@"memberTicket_3"]);
                    _memberTicket = YES;
                    
                    
                    UITabBarController *tabb = (UITabBarController *)self.window.rootViewController;
                    tabb.selectedIndex = 2;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"showMemberTicket" object:nil];
                    
                    
                }
                else{
                    /*
                    UITabBarController *tabb = (UITabBarController *)self.window.rootViewController;
                    tabb.selectedIndex = 2;
                     */
                }
                
                
                
                
                
                
            }
            else
            {
                NSLog(@"app first time launched 1");
                /*
                 
                 UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                 
                 UIViewController *vc =[storyboard instantiateViewControllerWithIdentifier:@"CityPickerViewController"];
                 
                 
                 self.window.rootViewController = vc;
                 [self.window makeKeyAndVisible];
                 */
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                
                UIViewController *vc =[storyboard instantiateViewControllerWithIdentifier:@"CityPickerViewController"];
                
                self.window.rootViewController = vc;
                [self.window makeKeyAndVisible];
                //Prompt push notification
/*
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Push Benachrichtigung 1"
                                                                    message:@"Möchtest Benachrichtigungen erlauben?\nDadurch erhälst du spannende Informationen und Angebote"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Nicht jetzt"
                                                          otherButtonTitles:@"Ja", nil];
                alertView.tag = 1;
                [alertView show];
 */
                
                
                
                
                
                
            }

            

            NSLog(@"eventId: %@", [params objectForKey:@"eventId"]);


            

        }
        else{
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
            {
                
                NSLog(@"app already launched");
                /*
                 UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                 
                 UITabBarController *vc =[storyboard instantiateViewControllerWithIdentifier:@"tabBarController"];
                 
                 vc.selectedIndex=2;
                 
                 self.window.rootViewController = vc;
                 [self.window makeKeyAndVisible];
                 */
                
                NSLog(@"status am anfang: %i", _status);
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                int stat = (int) [defaults integerForKey:@"status"];
                [defaults setBool:NO forKey:@"notificationRequestOpened"];
                
                NSLog(@"stat: %i",stat);
                
                if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
                    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"notificationAllowed"])
                    {
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        int statNoti = (int) [defaults integerForKey:@"notificationOpenings"];
                        int stat_1 = statNoti++;
                        if (stat >= 7)
                        {
                            [defaults setBool:YES forKey:@"notificationRequestOpened"];
                            
                            NSLog(@"push info anzeigen");
                            
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Push Benachrichtigung miss 1"
                                                                                message:@"Möchtest Benachrichtigungen erlauben?\nDadurch erhälst du spannende Informationen und Angebote"
                                                                               delegate:self
                                                                      cancelButtonTitle:@"Nicht jetzt"
                                                                      otherButtonTitles:@"Ja", nil];
                            alertView.tag = 1;
                            [alertView show];
                            
                        }
                        else{
                            [defaults setInteger:stat_1 forKey:@"notificationOpenings"];
                            [defaults synchronize];
                            
                        }
                        
                        
                    }
                    else{
                        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                                        UIUserNotificationTypeBadge |
                                                                        UIUserNotificationTypeSound);
                        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                                 categories:nil];
                        [application registerUserNotificationSettings:settings];
                        [application registerForRemoteNotifications];
                        
                    }
                }
                
                
                _status = 3;
                
                // Store the data
                
                [defaults setInteger:_status forKey:@"status"];
                [defaults synchronize];
                
                
                if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
                    
                    
                    
                    //   UILocalNotification *notification2 = [[UILocalNotification alloc] init];
                    
                    //   notification2.alertBody = NSLocalizedString(@"Monitoring not available_2", @"");
                    //  [[UIApplication sharedApplication] presentLocalNotificationNow:notification2];
                    
                }
                
                else {
                    
                    
                    if (_locationManager!=nil) {
                        if(_beaconRegion){
                            NSLog(@"uuid schon vorhanden");
                            _beaconRegion.notifyOnEntry = YES;
                            _beaconRegion.notifyOnExit = YES;
                            _beaconRegion.notifyEntryStateOnDisplay = YES;
                            [_locationManager startMonitoringForRegion:_beaconRegion];
                            
                            [_locationManager requestStateForRegion:_beaconRegion];
                            
                            
                            
                        }
                        else{
                            _uuid = [[NSUUID alloc] initWithUUIDString:@"f7826da6-4fa2-4e98-8024-bc5b71e0893e"];
                            NSLog(@"uuid laden");
                            _locationManager = [[CLLocationManager alloc] init];
                            _locationManager.delegate = self;
                            _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid identifier:@"com.wernerkohn.clubbeacon"];
                            if(_beaconRegion){
                                _beaconRegion.notifyOnEntry = YES;
                                _beaconRegion.notifyOnExit = YES;
                                _beaconRegion.notifyEntryStateOnDisplay = YES;
                                [_locationManager startMonitoringForRegion:_beaconRegion];
                                [_locationManager startRangingBeaconsInRegion:_beaconRegion];
                                
                                [_locationManager requestStateForRegion:_beaconRegion];
                                
                                
                            }
                            
                        }
                    }
                    else{
                        _uuid = [[NSUUID alloc] initWithUUIDString:@"f7826da6-4fa2-4e98-8024-bc5b71e0893e"];
                        
                        
                        _locationManager = [[CLLocationManager alloc] init];
                        _locationManager.delegate = self;
                        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid identifier:@"com.wernerkohn.clubbeacon"];
                        if(_beaconRegion){
                            //   NSLog(@"beaconregion");
                            _beaconRegion.notifyOnEntry = YES;
                            _beaconRegion.notifyOnExit = YES;
                            _beaconRegion.notifyEntryStateOnDisplay = YES;
                            [_locationManager stopMonitoringForRegion:_beaconRegion];
                            
                            [_locationManager startMonitoringForRegion:_beaconRegion];
                            
                            [_locationManager requestStateForRegion:_beaconRegion];
                            
                            [_locationManager startRangingBeaconsInRegion:_beaconRegion];
                            
                            
                            
                        }
                        
                    }
                    
                    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
                        NSLog(@"alert aufrufen");
                        
                        
                        
                        if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
                            
                            NSLog(@"wheninuse");
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Locationservice erweitert"
                                                                                message:@"Setze bei Ortnungsdienst den Hacken auf \"Immer\"\nDadurch erhälst du Punkte fürs einchecken ohne die App zu öffnen!"
                                                                               delegate:self
                                                                      cancelButtonTitle:@"Nicht jetzt"
                                                                      otherButtonTitles:@"Ja", nil];
                            alertView.tag = 3;
                            [alertView show];
                        }
                        else if(status == kCLAuthorizationStatusDenied){
                            NSLog(@"denied");
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Locationservice erlauben"
                                                                                message:@"Möchtest du Locationservice in den Einstellungen erlauben?\nDadurch kann die Distanz und die Route zu Clubs angezeigt werden und du erhälst Punkte fürs einchecken!"
                                                                               delegate:self
                                                                      cancelButtonTitle:@"Nicht jetzt"
                                                                      otherButtonTitles:@"Ja", nil];
                            alertView.tag = 3;
                            [alertView show];
                            
                            
                        }
                        
                        else if (status == kCLAuthorizationStatusNotDetermined) {
                            NSLog(@"notdetermined");
                            
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Locationservice erlauben"
                                                                                message:@"Möchtest Locationservice erlauben?\nDadurch kann die Distanz und die Route zu Clubs angezeigt werden und du erhälst Punkte fürs einchecken!"
                                                                               delegate:self
                                                                      cancelButtonTitle:@"Nicht jetzt"
                                                                      otherButtonTitles:@"Ja", nil];
                            alertView.tag = 2;
                            [alertView show];
                            
                        }
                        else{
                            NSLog(@"always on erlaubt status: %d",status);
                            
                        }
                    }
                    [_locationManager startUpdatingLocation];
                    
                    
                }
                
                /*
                UITabBarController *tabb = (UITabBarController *)self.window.rootViewController;
                tabb.selectedIndex = 2;
                 */
                

                
            }
            else
            {
                NSLog(@"app first time launched 2");
                /*
                 
                 UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                 
                 UIViewController *vc =[storyboard instantiateViewControllerWithIdentifier:@"CityPickerViewController"];
                 
                 
                 self.window.rootViewController = vc;
                 [self.window makeKeyAndVisible];
                 */
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                
                UIViewController *vc =[storyboard instantiateViewControllerWithIdentifier:@"CityPickerViewController"];
                
                //Prompt push notification
                /*
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Push Benachrichtigung miss 2"
                                                                    message:@"Möchtest Benachrichtigungen erlauben?\nDadurch erhälst du spannende Informationen und Angebote"
                                                                   delegate:self
                                                          cancelButtonTitle:@"Nicht jetzt"
                                                          otherButtonTitles:@"Ja", nil];
                alertView.tag = 1;
                [alertView show];
                
                */
                self.window.rootViewController = vc;
                [self.window makeKeyAndVisible];
                
                
                
                
            }
        }
    }];
    
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : @"YOUR_CLIENT_ID_FOR_PRODUCTION",
                                                           PayPalEnvironmentSandbox : @"AS02lxCq6QDcSdYKO-ViXB8PKRqYKyS0P8993Yx3-u6vU8mNjzlH3XIdOf6V"}];
    
    [Stripe setDefaultPublishableKey:StripePublishableKey];
    
    
    // Configure table builder default error messages
    [PAYFormDefaultErrorHandler setButtonText:@"Ok"];
    [PAYFormDefaultErrorHandler setErrorMessage:[PAYFormErrorMessage errorMessageWithTitle:@"Missing"
                                                                                   message:@"Field %@ is missing"]
                                   forErrorCode:PAYFormMissingErrorCode];
    [PAYFormDefaultErrorHandler setErrorMessage:[PAYFormErrorMessage errorMessageWithTitle:@"To long"
                                                                                   message:@"Content of field %@ is to long"]
                                   forErrorCode:PAYFormTextFieldAboveMaxLengthErrorCode];
    [PAYFormTextField setErrorMessage:[PAYFormErrorMessage errorMessageWithTitleBlock:^NSString *(id formView) {
        return @"To short";
    } messageBlock:^NSString *(id formView) {
        PAYFormTextField *textField = (PAYFormTextField *)formView;
        return [NSString stringWithFormat:@"Content of field %%@ is to short. Please enter a minimum of %tu characters", textField.minTextLength];
    }]
                         forErrorCode:PAYFormTextFieldBelowMinLengthErrorCode];
    [PAYFormTextField setErrorMessage:[PAYFormErrorMessage errorMessageWithTitleBlock:^NSString *(id formView) {
        return @"To long";
    } messageBlock:^NSString *(id formView) {
        PAYFormTextField *textField = (PAYFormTextField *)formView;
        return [NSString stringWithFormat:@"Content of field %%@ is to long. Please enter a maximum of %tu characters", textField.maxTextLength];
    }]
                         forErrorCode:PAYFormTextFieldAboveMaxLengthErrorCode];
    
    [PAYFormField setErrorMessage:[PAYFormErrorMessage errorMessageWithTitle:@"No integer" message:@"Please enter an integer to field %@."]
                     forErrorCode:PAYFormIntegerValidationErrorCode];
    
    [PAYFormSwitch setErrorMessage:[PAYFormErrorMessage errorMessageWithTitle:@"Missing" message:@"Please check %@"]
                      forErrorCode:PAYFormMissingErrorCode];
    
    //! fehlt
    /*
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        NSLog(@"app first time launched");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        UIViewController *vc =[storyboard instantiateViewControllerWithIdentifier:@"CityPickerViewController"];
        
        
        self.window.rootViewController = vc;
        [self.window makeKeyAndVisible];
        
    }
    
    */

    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startRanging:) name:@"startRanging" object: nil];
    


    
    return YES;
}




- (void)startRanging:(NSNotification *) notification
{
    
    
    
    NSLog(@"ranging!!!");
    NSLog(@"status am anfang: %i", _status);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int stat = (int) [defaults integerForKey:@"status"];
    
    NSLog(@"stat: %i",stat);

    _status = 3;
    
    // Store the data
    
    [defaults setInteger:_status forKey:@"status"];
    [defaults synchronize];
    
    
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Monitoring not available_3" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
      //  UILocalNotification *notification2 = [[UILocalNotification alloc] init];
        
     //   notification2.alertBody = NSLocalizedString(@"Monitoring not available_4", @"");
     //   [[UIApplication sharedApplication] presentLocalNotificationNow:notification2];
        
    }
    
    else{
    
    if (_locationManager!=nil) {
        if(_beaconRegion){
            NSLog(@"uuid schon vorhanden");
            _beaconRegion.notifyOnEntry = YES;
            _beaconRegion.notifyOnExit = YES;
            _beaconRegion.notifyEntryStateOnDisplay = YES;
            [_locationManager startMonitoringForRegion:_beaconRegion];
            
            [_locationManager requestStateForRegion:_beaconRegion];
            
            
            
        }
        else{
            _uuid = [[NSUUID alloc] initWithUUIDString:@"f7826da6-4fa2-4e98-8024-bc5b71e0893e"];
            NSLog(@"uuid laden");
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.delegate = self;
            _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid identifier:@"com.wernerkohn.clubbeacon"];
            if(_beaconRegion){
                _beaconRegion.notifyOnEntry = YES;
                _beaconRegion.notifyOnExit = YES;
                _beaconRegion.notifyEntryStateOnDisplay = YES;
                [_locationManager startMonitoringForRegion:_beaconRegion];
                [_locationManager startRangingBeaconsInRegion:_beaconRegion];
                
                [_locationManager requestStateForRegion:_beaconRegion];
                
                
            }
            
        }
    }
    else{
        _uuid = [[NSUUID alloc] initWithUUIDString:@"f7826da6-4fa2-4e98-8024-bc5b71e0893e"];
        
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid identifier:@"com.wernerkohn.clubbeacon"];
        if(_beaconRegion){
            //   NSLog(@"beaconregion");
            _beaconRegion.notifyOnEntry = YES;
            _beaconRegion.notifyOnExit = YES;
            _beaconRegion.notifyEntryStateOnDisplay = YES;
            [_locationManager stopMonitoringForRegion:_beaconRegion];
            
            [_locationManager startMonitoringForRegion:_beaconRegion];
            
            [_locationManager requestStateForRegion:_beaconRegion];
            
            [_locationManager startRangingBeaconsInRegion:_beaconRegion];
            
            
            
        }
        
    }
    
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        
        if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
            
            [_locationManager requestAlwaysAuthorization];

            /*
            NSString *title;
            title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
            NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Settings", nil];
            [alertView show];
             
             */
        }
        
        else if (status == kCLAuthorizationStatusNotDetermined) {
            [_locationManager requestAlwaysAuthorization];
        }
        
        else{
            NSLog(@"erlaubnis erteilt");
            [_locationManager startUpdatingLocation];

        }
    }
  //  [_locationManager startUpdatingLocation];
        
    }
    
    
    
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    _status = 1;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:_status forKey:@"status"];
    [defaults synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    _status = 2;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:_status forKey:@"status"];
    [defaults synchronize];
    NSLog(@"App in Hintergrund gesetzt");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *oldNotifications = [app scheduledLocalNotifications];
    if([oldNotifications count] > 0){
        [app cancelAllLocalNotifications];
    }
    app.applicationIconBadgeNumber = 0;
    _status = 1;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:_status forKey:@"status"];
    [defaults synchronize];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *oldNotifications = [app scheduledLocalNotifications];
    if([oldNotifications count] > 0){
        [app cancelAllLocalNotifications];
    }
    app.applicationIconBadgeNumber = 0;
    _status = 1;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:_status forKey:@"status"];
    [defaults synchronize];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    NSLog(@"schluss");
    _status = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:_status forKey:@"status"];
    [defaults synchronize];
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    [[Branch getInstance] handleDeepLink:url];

    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (application.applicationState == UIApplicationStateActive) {
        // The application was already running.
    } else {
        // The application was just brought from the background to the foreground,
        // so we consider the app as having been "opened by a push notification."
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
        
    }
    
    NSDictionary *aps = (NSDictionary *)[userInfo objectForKey:@"aps"];
    NSMutableString *alert = [NSMutableString stringWithString:@""];
    if ([aps objectForKey:@"alert"])
    {
        [alert appendString:(NSString *)[aps objectForKey:@"alert"]];
    }
    if ([userInfo objectForKey:@"push_id"])
    {
        
        //int jobID = [[userInfo objectForKey:@"push_id"] intValue];
        NSLog(@"id: %@",[userInfo objectForKey:@"push_id"]);
        
        _eventId =[userInfo objectForKey:@"push_id"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showEvent" object:nil userInfo:userInfo];
        
        UITabBarController *tabb = (UITabBarController *)self.window.rootViewController;
        tabb.selectedIndex = 0;
        
        
        

        
        
    }
    else if ([userInfo objectForKey:@"eventId"])
    {
        
        //int jobID = [[userInfo objectForKey:@"push_id"] intValue];
        NSLog(@"id: %@",[userInfo objectForKey:@"eventId"]);
        
        _eventId =[userInfo objectForKey:@"eventId"];
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showEvent" object:nil userInfo:userInfo];
        
        UITabBarController *tabb = (UITabBarController *)self.window.rootViewController;
        tabb.selectedIndex = 0;
        
        

        
        
    }
    else if ([userInfo objectForKey:@"clubId"])
    {
        
        //int jobID = [[userInfo objectForKey:@"push_id"] intValue];
        NSLog(@"id: %@",[userInfo objectForKey:@"clubId"]);
        
        _clubId =[userInfo objectForKey:@"clubId"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showClub" object:nil userInfo:userInfo];
        
        
        UITabBarController *tabb = (UITabBarController *)self.window.rootViewController;
        tabb.selectedIndex = 1;
        
        

        
    }
    else if ([userInfo objectForKey:@"barId"])
    {
        
        //int jobID = [[userInfo objectForKey:@"push_id"] intValue];
        NSLog(@"id: %@",[userInfo objectForKey:@"barId"]);
        
        _barId =[userInfo objectForKey:@"barId"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showBar" object:nil userInfo:userInfo];
        
        UITabBarController *tabb = (UITabBarController *)self.window.rootViewController;
        tabb.selectedIndex = 3;
        
        

        
        
    }
    else if ([userInfo objectForKey:@"dayTicket_3"])
    {
        
        //int jobID = [[userInfo objectForKey:@"push_id"] intValue];
        NSLog(@"id: %@",[userInfo objectForKey:@"dayTicket_3"]);
        
        _dayTicket =[[userInfo objectForKey:@"dayTicket_3"] intValue];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showDayTicket" object:nil userInfo:userInfo];
        
        UITabBarController *tabb = (UITabBarController *)self.window.rootViewController;
        tabb.selectedIndex = 2;
        
        
        

        
        
    }
    else if ([userInfo objectForKey:@"memberTicket_3"])
    {
        
        //int jobID = [[userInfo objectForKey:@"push_id"] intValue];
        NSLog(@"id: %@",[userInfo objectForKey:@"memberTicket_3"]);
        
        _memberTicket =[[userInfo objectForKey:@"memberTicket_3"] intValue];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showMemberTicket" object:nil userInfo:userInfo];
        
        
        UITabBarController *tabb = (UITabBarController *)self.window.rootViewController;
        tabb.selectedIndex = 2;
        
        
        

        
    }
    
    [PFPush handlePush:userInfo];
    
    
    
}


#pragma ibeacon ranging

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    /*
     A user can transition in or out of a region while the application is not running. When this happens CoreLocation will launch the application momentarily, call this delegate method and we will let the user know via a local notification.
     */
    // NSLog(@"app geschlossen");
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int stat = (int)[defaults integerForKey:@"status"];
    
    
    
    if(state == CLRegionStateInside)
    
    {
        
        /*
         UILocalNotification *notification2 = [[UILocalNotification alloc] init];
         
         notification2.alertBody = NSLocalizedString(@"test", @"");
         [[UIApplication sharedApplication] presentLocalNotificationNow:notification2];
         */
        
        /*
         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
         int stat = [defaults integerForKey:@"status"];
         
         
         NSString *nachricht = [NSString stringWithFormat:@"Status: %i",stat];
         notification.alertBody = NSLocalizedString(nachricht, @"");
         [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
         */
        
        
        if (stat==0) {
            notification.alertBody = NSLocalizedString(@"Bitte öffne jetzt NightGuider", @"");
            NSLog(@"app geschlossen");
          //  [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            
        }
        //notification.alertBody = NSLocalizedString(@"You're inside the region", @"");
        else if (stat==2){
            
            notification.alertBody = NSLocalizedString(@"App läuft im Hintergrund", @"");
            NSLog(@"hintergrund");
          //  [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            //   [self sendLoci];
            
            
        }
        else if (stat== 3){
            NSLog(@"aktiv");
            notification.alertBody = NSLocalizedString(@"App ist geschlossen", @"");
            NSLog(@"hintergrund");
        //    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            //  [self sendLoci];
            
            
        }
        else if(stat == 1){
            notification.alertBody = NSLocalizedString(@"app ist da", @"");
          //  [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            
        }
        
        // [self sendLoci];
        
    }
    else if(state == CLRegionStateOutside)
    {
        notification.alertBody = NSLocalizedString(@"You're outside the region", @"");
      //  [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        
    }
    else
    {
        return;
    }
    
    /*
     If the application is in the foreground, it will get a callback to application:didReceiveLocalNotification:.
     If it's not, iOS will display the notification to the user.
     */
    //[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

-(void)sendLoci{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = NSLocalizedString(@"yeah funktion aufgerufen", @"");
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    
    
    
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    // If the application is in the foreground, we will notify the user of the region's state via an alert.
    NSString *cancelButtonTitle = NSLocalizedString(@"OK", @"Title for cancel button in local notification");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:notification.alertBody message:nil delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    [alert show];
}

-(void)setupLocationManager{
    if (![CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Monitoring not available" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        UILocalNotification *notification2 = [[UILocalNotification alloc] init];
        
        notification2.alertBody = NSLocalizedString(@"monitoring not available", @"");
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification2];
        
        return;
    }
    
    if (_locationManager!=nil) {
        if(_beaconRegion){
            NSLog(@"uuid schon vorhanden");
            _beaconRegion.notifyOnEntry = YES;
            _beaconRegion.notifyOnExit = YES;
            _beaconRegion.notifyEntryStateOnDisplay = YES;
            [_locationManager startMonitoringForRegion:_beaconRegion];
            //   [_locationManager startRangingBeaconsInRegion:_beaconRegion];
            
            [_locationManager requestStateForRegion:_beaconRegion];
            //    [_locationManager startUpdatingLocation];
            
            
            
        }
        else{
            _uuid = [[NSUUID alloc] initWithUUIDString:@"F2037E44-13BF-4083-A3A6-514A17BBBA10"];
            NSLog(@"uuid laden");
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.delegate = self;
            _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid identifier:@"com.wernerkohn.clubbeacon"];
            if(_beaconRegion){
                _beaconRegion.notifyOnEntry = YES;
                _beaconRegion.notifyOnExit = YES;
                _beaconRegion.notifyEntryStateOnDisplay = YES;
                [_locationManager startMonitoringForRegion:_beaconRegion];
                [_locationManager startRangingBeaconsInRegion:_beaconRegion];
                
                [_locationManager requestStateForRegion:_beaconRegion];
                
                
            }
            //   [_locationManager startUpdatingLocation];
            
        }
    }
    else{
        _uuid = [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
        //   _uuid = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
        //    _uuid = [[NSUUID alloc] initWithUUIDString:@"f7826da6-4fa2-4e98-8024-bc5b71e0893e"];
        
        
        //  NSLog(@"uuid laden 2");
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid identifier:@"com.wernerkohn.clubbeacon"];
        if(_beaconRegion){
            //   NSLog(@"beaconregion");
            _beaconRegion.notifyOnEntry = YES;
            _beaconRegion.notifyOnExit = YES;
            _beaconRegion.notifyEntryStateOnDisplay = YES;
            [_locationManager stopMonitoringForRegion:_beaconRegion];
            
            [_locationManager startMonitoringForRegion:_beaconRegion];
            
            [_locationManager requestStateForRegion:_beaconRegion];
            
            [_locationManager startRangingBeaconsInRegion:_beaconRegion];
            
            
            
        }
        //   [_locationManager startUpdatingLocation];
        
    }
    
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        
        if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
            NSString *title;
            title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
            NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Settings", nil];
            [alertView show];
        }
        // [_locationManager requestWhenInUseAuthorization];
        
        else if (status == kCLAuthorizationStatusNotDetermined) {
            [_locationManager requestAlwaysAuthorization];
        }
    }
    [_locationManager startUpdatingLocation];
    
    
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"Beacon Found");
    UILocalNotification *notification2 = [[UILocalNotification alloc] init];
    
    notification2.alertBody = NSLocalizedString(@"did enter region", @"");
   // [[UIApplication sharedApplication] presentLocalNotificationNow:notification2];
    
    [_locationManager startRangingBeaconsInRegion:_beaconRegion];
    [self sendLocalNotificationForReqgionConfirmationWithText:@"REGION INSIDE"];
    
}
-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"left Region");
    UILocalNotification *notification2 = [[UILocalNotification alloc] init];
    
    notification2.alertBody = NSLocalizedString(@"did exit region", @"");
  //  [[UIApplication sharedApplication] presentLocalNotificationNow:notification2];
    
    [_locationManager stopRangingBeaconsInRegion:_beaconRegion];
    //[self sendLocalNotificationForReqgionConfirmationWithText:@"REGION OUTSIDE"];
    
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    
    
    if (beacons.count == 0) {
        //   NSLog(@"beacon nicht da");
        return;
    }
    else{
        UILocalNotification *notification2 = [[UILocalNotification alloc] init];
        
        notification2.alertBody = NSLocalizedString(@"beacon gefunden", @"");
        // [[UIApplication sharedApplication] presentLocalNotificationNow:notification2];
        
        
        
    }
    
    
    
    CLBeacon *beacon = [[CLBeacon alloc] init];
    beacon = [beacons lastObject];
    
    NSString *uuid = beacon.proximityUUID.UUIDString;
    NSString *major = [NSString stringWithFormat:@"%@", beacon.major];
    NSString *minor = [NSString stringWithFormat:@"%@", beacon.minor];
    
    _uuid_string = uuid;
    _major = major;
    _minor = minor;

    
    
    if (beacon.proximity == CLProximityUnknown) {
        
        
    } else if (beacon.proximity == CLProximityImmediate) {
        
      //  NSString *message = [NSString stringWithFormat:@"Du bist gaaanz nah!"];
        UILocalNotification *notification2 = [[UILocalNotification alloc] init];
        
        notification2.alertBody = NSLocalizedString(@"beacon ist gaaaanz nah", @"");
        // [[UIApplication sharedApplication] presentLocalNotificationNow:notification2];
        
        NSLog(@"immediate major: %@",major);

        
        // [self sendLocalNotificationForReqgionConfirmationWithText:message];
        
        UIAlertView *meldung = [[UIAlertView alloc]initWithTitle:@"Hallo" message:@"Wenn du innerhalb der nächsten 30 Minuten bei uns einkaufst erhältst du 30% (außer auf Tiernahrung)!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [meldung show];
        
        

    } else if (beacon.proximity == CLProximityNear) {
        //[_view setBackgroundColor:[UIColor orangeColor]];
        NSLog(@"near major: %@",major);

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"test_1.plist"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if (![fileManager fileExistsAtPath: path])
        {
            path = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"test_1.plist"] ];
        }
        
        
        
        NSMutableDictionary *data;
        
        if ([fileManager fileExistsAtPath: path])
        {
            data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
        }
        else
        {
            // If the file doesn’t exist, create an empty dictionary
            data = [[NSMutableDictionary alloc] init];
        }
        
        
        
        //To reterive the data from the plist
        NSMutableDictionary *savedStock = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
        
        NSDate *today = [NSDate date];
        
        
        NSDate *dateA =[[savedStock objectForKey:major] objectForKey:minor];
        NSDate *dateC = today;
        
        // NSDate *dateC = [today dateByAddingTimeInterval:60*60*8];
        
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        
        NSDateComponents *components = [calendar components:unitFlags  fromDate:dateA toDate:dateC options:0];
        
        NSLog(@"Difference in date components: %li/%li/%li/%li/%li", (long)components.hour,(long)components.minute, (long)components.day, (long)components.month, (long)components.year);
        /*
         NSLog(@"User noch nicht bei event eingeloggt");
         NSMutableDictionary *major_1 = [[NSMutableDictionary alloc] init];
         NSDate *resetDate = [today dateByAddingTimeInterval:-60*60*8];
         
         [major_1 setValue:resetDate forKey:minor];
         
         [data setObject:major_1 forKey:major];
         
         [data writeToFile: path atomically:YES];
         NSLog(@"zeit wird auf %@ zurückgesetzt",resetDate);
         */
        
        
        if (components.hour>7 || dateA == nil) {
            //iBeacon Infos
            /*
            NSString *major = [NSString stringWithFormat:@"%@", beacon.major];
            NSString *minor = [NSString stringWithFormat:@"%@", beacon.minor];
            NSString *accuracy = [NSString stringWithFormat:@"%f", beacon.accuracy];
            NSString *rssi = [NSString stringWithFormat:@"%li", (long)beacon.rssi];
             NSLog(@"major %@, minor %@ \naccuracy %@\nuudid %@\nrssi %@",major,minor,accuracy,uuid,rssi);
             */
            
            
            NSLog(@"Eingeloggt vor mehr als 7 Stunden!");
            //To insert the data into the plist
            NSMutableDictionary *major_1 = [[NSMutableDictionary alloc] init];
            [major_1 setValue:today forKey:minor];
            
            [data setObject:major_1 forKey:major];
            
            [data writeToFile: path atomically:YES];
            
            PFUser *currentUser = [PFUser currentUser];
            
            NSLog(@"1");
            if(currentUser){
                NSDictionary *checkInInfo = @{
                                              
                                              @"user": currentUser.objectId,
                                              @"major": major,
                                              @"minor": minor
                                              
                                              };
                
                
                [PFCloud callFunctionInBackground:@"checkIn" withParameters:checkInInfo block:^(id object, NSError *error) {
                    if(!error){
                        NSLog(@"erfolgreich");

                        NSLog(@"Result: %@", object);
                        
                        
                        
                        UIAlertView *meldung2 = [[UIAlertView alloc]initWithTitle:@"Check In" message:object delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                        [meldung2 show];
                        
                        UILocalNotification *notification2 = [[UILocalNotification alloc] init];
                        
                        NSString *checkInText = [NSString stringWithFormat:@"Major: %@ Minor: %@", beacon.major,beacon.minor];
                        notification2.alertBody = NSLocalizedString(checkInText, @"");
                        [[UIApplication sharedApplication] presentLocalNotificationNow:notification2];
                        
                        UILocalNotification *notification3 = [[UILocalNotification alloc] init];
                        
                        notification3.alertBody = NSLocalizedString(object, @"");
                      //  [[UIApplication sharedApplication] presentLocalNotificationNow:notification3];
                        
                        
                        
                        // [self sendLocalNotificationForReqgionConfirmationWithText:message];
                        
                        
                    }
                    else{
                        
                        NSLog(@"Coins konnten nicht addiert werden");
                        // NSLog(@"-----result: %@",object);
                        
                        NSMutableDictionary *major_1 = [[NSMutableDictionary alloc] init];
                        NSDate *resetDate = [today dateByAddingTimeInterval:-60*60*8];
                        
                        [major_1 setValue:resetDate forKey:minor];
                        
                        [data setObject:major_1 forKey:major];
                        
                        [data writeToFile: path atomically:YES];
                        NSLog(@"zeit wird auf %@ zurückgesetzt",resetDate);
                        
                        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                    message:[[error userInfo] objectForKey:@"error"]
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                          otherButtonTitles:nil] show];
                        
                        
                        
                    }
                }];
                
                
            }
            else{
                NSLog(@"User nicht eingeloggt");
                NSMutableDictionary *major_1 = [[NSMutableDictionary alloc] init];
                NSDate *resetDate = [today dateByAddingTimeInterval:-60*60*8];
                
                [major_1 setValue:resetDate forKey:minor];
                
                [data setObject:major_1 forKey:major];
                
                [data writeToFile: path atomically:YES];
                NSLog(@"zeit wird auf %@ zurückgesetzt",resetDate);
                
                
                UIAlertView *meldung = [[UIAlertView alloc]initWithTitle:@"Fehler" message:@"User ist nicht eingeloggt" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [meldung show];
                
                UILocalNotification *notification2 = [[UILocalNotification alloc] init];
                
                notification2.alertBody = NSLocalizedString(@"user nicht eingeloggt", @"");
                [[UIApplication sharedApplication] presentLocalNotificationNow:notification2];
                
                
            }
            
            NSLog(@"4");
            
            
            
            
        }
        else{
            NSLog(@"Du bist schon im event eingeloggt, plist");
        }
        
        
        
        
    } else if (beacon.proximity == CLProximityFar) {
        

        NSLog(@"Far major: %@",major);
        
            }
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [_locationManager startRangingBeaconsInRegion:_beaconRegion];
    
    
}




-(void)sendLocalNotificationForReqgionConfirmationWithText:(NSString *)text {
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
    return;
    
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.alertBody = [NSString stringWithFormat:NSLocalizedString(@"%@", nil),
                            text];
    localNotif.alertAction = NSLocalizedString(@"View Details", nil);
    
    localNotif.applicationIconBadgeNumber = 1;
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:text forKey:@"KEY"];
    localNotif.userInfo = infoDict;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
    
}

- (BOOL)application:(UIApplication *)application
continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    BOOL handledByBranch = [[Branch getInstance] continueUserActivity:userActivity];
    
    return handledByBranch;
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    
    if (actionSheet.tag == 1) {
        
        if (buttonIndex == 1) {
            [defaults setBool:YES forKey:@"notificationAllowed"];
            [defaults synchronize];
            
#pragma oder doch vlt jlpermissions?
            UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                            UIUserNotificationTypeBadge |
                                                            UIUserNotificationTypeSound);
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                     categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        else{
                [defaults setInteger:0 forKey:@"notificationOpenings"];
                [defaults synchronize];

        }
    }
    else if (actionSheet.tag == 2) {
        
        if (buttonIndex == 1) {
            [_locationManager requestAlwaysAuthorization];
          //  [_locationManager startUpdatingLocation];


        }
        else{
            
        }
    }
    else if (actionSheet.tag == 3) {
        
        if (buttonIndex == 1) {
            //open settings
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:settingsURL];
            
        }
        else{
            
        }
    }
}



@end
