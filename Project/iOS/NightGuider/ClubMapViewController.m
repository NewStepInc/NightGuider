//
//  ClubMapViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 20.10.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import "ClubMapViewController.h"
#import "GeoPointAnnotation.h"
#import <MapKit/MapKit.h>
#import "ClubDetailViewController.h"
#import "BarDetailViewController.h"

#import <AddressBook/AddressBook.h>
#import <CoreLocation/CoreLocation.h>

@interface ClubMapViewController ()<MKMapViewDelegate,UIActionSheetDelegate,CLLocationManagerDelegate> {
    
    NSMutableArray *_geoPoints;
    NSMutableArray *_objects;
    
    MKPolyline *_mapPolyline;
    GeoPointAnnotation *_selectedStation;
}

typedef NS_ENUM(NSInteger, RWMapMode) {
    RWMapModeNormal = 0,
    RWMapModeLoading,
    RWMapModeDirections,
};

@property (nonatomic, assign) RWMapMode mapMode;


@end

@implementation ClubMapViewController {
    
    CLLocationManager *locationManager;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setMapMode:(RWMapMode)mapMode {
    _mapMode = mapMode;
    
    switch (mapMode) {
        case RWMapModeNormal: {
            self.title = @"Karte";
            [self.mapView addAnnotations:_geoPoints];
        }
            break;
        case RWMapModeLoading: {
            self.title = @"Loading...";
        }
            break;
        case RWMapModeDirections: {
            self.title = @"Directions";
        }
            break;
    }
}

- (void)showInMaps:(id)sender {
    // 1
    NSMutableArray *mapItems = [[NSMutableArray alloc] init];
    for (GeoPointAnnotation *object in _geoPoints) {
        [mapItems addObject:[object mapItem]];
    }
    [mapItems addObject:[MKMapItem mapItemForCurrentLocation]];
    
    // 2
    
    //////!!!!!!!!!!!!!!!!!/////
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
#pragma  ios8 location erlaubnis
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        
        if (status == kCLAuthorizationStatusDenied) {
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
        }
        // [_locationManager requestWhenInUseAuthorization];
        
        else if (status == kCLAuthorizationStatusNotDetermined) {
            [locationManager requestWhenInUseAuthorization];
        }
    }
    
    
    [locationManager startUpdatingLocation];
    
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude);
    
    //CLLocationCoordinate2D center = CLLocationCoordinate2DMake(48.375680, 10.92684);
    
    
    MKMapRect boundingBox = [_mapPolyline boundingMapRect];
    
    MKCoordinateRegion boundingBoxRegion = MKCoordinateRegionForMapRect(boundingBox);
    
    
    // 3
    // NSValue *centerAsValue = [NSValue valueWithMKCoordinate:boundingBoxRegion.center];
    NSValue *centerAsValue = [NSValue valueWithMKCoordinate:center];
    
    NSValue *spanAsValue = [NSValue valueWithMKCoordinateSpan:boundingBoxRegion.span];
    
    // 4
    NSDictionary *launchOptions = @{MKLaunchOptionsMapTypeKey : @(MKMapTypeHybrid), MKLaunchOptionsMapCenterKey : centerAsValue, MKLaunchOptionsMapSpanKey : spanAsValue};
    
    // 5
    [MKMapItem openMapsWithItems:mapItems launchOptions:launchOptions];
}


- (void)loadData {
    
    _geoPoints = [[NSMutableArray alloc] init];
    _objects = [[NSMutableArray alloc] init];
    
    
    NSString *city = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/stadt", NSHomeDirectory()] encoding:NSUTF8StringEncoding error:nil];
    
    NSString *className;
    
    if ([_hostType isEqualToString:@"bar"]) {
        className = @"Bars";
    }
    else{
        className = @"Clubs";

    }
    PFQuery *query = [PFQuery queryWithClassName:className];
    
    [query whereKey:@"city_pick" equalTo:city];
    
    [query setLimit:1000];
    
    
    //self.title = @"Karte";
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                
                PFGeoPoint *geoPoint = [object objectForKey:@"location"];
                
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
                GeoPointAnnotation *point = [[GeoPointAnnotation alloc] init];
                point.title = [object objectForKey:@"name"];
                //point.subtitle = [NSString stringWithFormat:@"Rating: %@", [object objectForKey:@"rating"]];
                point.coordinate = coordinate;
                
                NSString * country2 = [object objectForKey:@"name"];

                NSDictionary *addressDict2 = @{
                                               
                                               (NSString*)kABPersonAddressCountryKey : country2,
                                               (NSString*)kABPersonAddressCityKey : country2,
                                               (NSString*)kABPersonAddressStreetKey : country2,
                                               (NSString*)kABPersonAddressZIPKey : country2};
                
                
                
                
                point.address = addressDict2;

                [_geoPoints addObject:point];
                [_objects addObject:object];
                
                
            }
            
            [self.mapView addAnnotations:_geoPoints];
            
            
        }
        
        else NSLog(@"GeoPoints konnten nicht geladen werden!");
    }];

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _mapView.delegate = self;
    
    
    [self loadData];
    self.mapMode = RWMapModeNormal;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wechsel:) name:@"stadtWechseln" object:nil];
    
    
    
    //Zuhause
    //  CLLocationCoordinate2D center = CLLocationCoordinate2DMake(48.375680, 10.92684);
    //////!!!!!!!!!!!!!!!!!/////
    
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [locationManager startUpdatingLocation];
    
    NSLog(@"mein standort: %f breite: %f", locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude);
    
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude);
    
    
    //London
    // CLLocationCoordinate2D center = CLLocationCoordinate2DMake(51.525635, -0.081985);
    
    //original
    //MKCoordinateSpan span = MKCoordinateSpanMake(0.05649, 0.05405);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.15849, 0.15605);
    
    MKCoordinateRegion regionToDisplay = MKCoordinateRegionMake(center, span);
    [self.mapView setRegion:regionToDisplay animated:NO];
    
    // Do any additional setup after loading the view.
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        NSLog(@"länge: %f", currentLocation.coordinate.longitude);
        NSLog(@"breite: %f", currentLocation.coordinate.latitude);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[GeoPointAnnotation class]]) {
        static NSString *const kPinIdentifier = @"Geopoint";
        MKAnnotationView *view = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:kPinIdentifier];
        if (!view) {
            view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPinIdentifier];
            view.canShowCallout = YES;
            view.calloutOffset = CGPointMake(-5, 5);
            // view.animatesDrop = YES;
        }

        view.image = [UIImage imageNamed:@"mapPin"];
        view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        
        return view;
    }
    
    
    return nil;
}


- (MKOverlayView*)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    
    MKPolylineView *overlayView = [[MKPolylineView alloc] initWithPolyline:overlay];
    overlayView.lineWidth = 10.0f;
    overlayView.strokeColor = [UIColor blueColor];
    
    return overlayView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    _selectedStation = (GeoPointAnnotation*)view.annotation;
    
    // 1
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Route anzeigen", @"Details anzeigen", nil];

    [sheet addButtonWithTitle:@"Cancel"];
    sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
    
    // 4
    [sheet showInView:self.view];

}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // 1
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (buttonIndex == 0) {
            // 2
            MKMapItem *mapItem = [_selectedStation mapItem];
            NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking};
            [mapItem openInMapsWithLaunchOptions:launchOptions];
            
            
        }
        

        else if (buttonIndex == 1) {

            if ([_hostType isEqualToString:@"bar"]) {
                [self performSegueWithIdentifier:@"showBar" sender:self];

            }
            else{
                [self performSegueWithIdentifier:@"showClub" sender:self];
            }
            
            
        }
        
    }
    
    // 5
    _selectedStation = nil;
}

//Detailansicht öffnen
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    
    if ([segue.identifier isEqualToString:@"showClub"])
    {
        ClubDetailViewController *detailController =segue.destinationViewController;
        
        MKMapItem *mapItem = [_selectedStation mapItem];
        
        NSString*title2 =  mapItem.name;
        
        int i=0;
        
        for (i=0; i<_objects.count; i++) {
            NSLog(@"suchdurchgang %i",i);
            NSString *club = [[_objects objectAtIndex:i] objectForKey:@"name"];
            if ([club isEqualToString:title2]) {
                
                PFObject * selectedObject = [_objects objectAtIndex:i];
                NSString *title = [selectedObject objectForKey:@"name"];
                
                detailController.club = selectedObject;
                
                [detailController setTitle:title];
            }
        }
        
    }
    
    else if ([segue.identifier isEqualToString:@"showBar"])
    {
        BarDetailViewController *detailController =segue.destinationViewController;
        
        MKMapItem *mapItem = [_selectedStation mapItem];
        
        NSString*title2 =  mapItem.name;
        
        int i=0;
        
        for (i=0; i<_objects.count; i++) {
            NSLog(@"suchdurchgang %i",i);
            NSString *club = [[_objects objectAtIndex:i] objectForKey:@"name"];
            if ([club isEqualToString:title2]) {
                
                PFObject * selectedObject = [_objects objectAtIndex:i];
                NSString *title = [selectedObject objectForKey:@"name"];
                
                detailController.bar = selectedObject;
                
                [detailController setTitle:title];
            }
        }
        
    }
    
    
}

-(void) wechsel:(NSNotification *) notification{
    NSMutableArray * annotationsToRemove = [ _mapView.annotations mutableCopy ] ;
    [ annotationsToRemove removeObject:_mapView.userLocation ] ;
    [ _mapView removeAnnotations:annotationsToRemove ] ;
    //[self.mapView removeAnnotations:[self.mapView annotations]];
    
    
    [self loadData];
    //  [self.tableView reloadData];
    // [self loadObjects];
    NSLog(@"stadt wechsel");
    
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




@end
