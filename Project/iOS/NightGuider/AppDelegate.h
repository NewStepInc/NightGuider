//
//  AppDelegate.h
//  NightGuider
//
//  Created by Werner Kohn on 20.10.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>


@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *pushID;

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSUUID *uuid;
@property (strong, nonatomic) NSArray *Beacons;


@property (strong, nonatomic) NSString *eventId;
@property (strong, nonatomic) NSString *clubId;
@property (strong, nonatomic) NSString *barId;

@property (assign, nonatomic) BOOL memberTicket;
@property (assign, nonatomic) BOOL dayTicket;





@end

