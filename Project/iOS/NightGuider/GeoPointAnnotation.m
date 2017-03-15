//
//  GeoPointAnnotation.m
//  Nightlife_2
//
//  Created by Werner on 28.11.12.
//  Copyright (c) 2012 Werner. All rights reserved.
//

#import "GeoPointAnnotation.h"

#import <AddressBook/AddressBook.h>


@implementation GeoPointAnnotation

- (MKMapItem*)mapItem {
    // 1
    
    /*
    NSDictionary *addressDict = @{
    
    (NSString*)kABPersonAddressCountryKey : @"Germany",
    (NSString*)kABPersonAddressCityKey : @"Augsburg",
    (NSString*)kABPersonAddressStreetKey : @"Maxstraße 10",
    (NSString*)kABPersonAddressZIPKey : @"86165"};
    */
    /*
    (NSString*)kABPersonAddressCountryKey : self.countryKey,
    (NSString*)kABPersonAddressCityKey : self.cityKey,
    (NSString*)kABPersonAddressStreetKey : self.streetKey,
    (NSString*)kABPersonAddressZIPKey : self.zipKey};
     */

  /*
NSDictionary *addressDict2 = @{

    (NSString*)kABPersonAddressCountryKey : _countryKey,
    (NSString*)kABPersonAddressCityKey : _cityKey,
    (NSString*)kABPersonAddressStreetKey : _streetKey,
    (NSString*)kABPersonAddressZIPKey : _zipKey};
   */




    // 2
    //MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.coordinate addressDictionary:_address];

    /*
    if (!_address) {
        NSLog(@"keine ganze andresse übergebem");
         MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.coordinate addressDictionary:addressDict2];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        mapItem.name = self.title;
        
        mapItem.phoneNumber = @"0176 38922404";
        mapItem.url = [NSURL URLWithString:@"http://www.ostwerk.de/"];
        return mapItem;

    }
    else {
        NSLog(@"Ganze andresse übergebem");

        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.coordinate addressDictionary:_address];

        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        mapItem.name = self.title;
        
        mapItem.phoneNumber = @"0176 38922404";
        mapItem.url = [NSURL URLWithString:@"http://www.ostwerk.de/"];
        return mapItem;
        
    }
     */
    
   // MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.coordinate addressDictionary:nil];


    NSLog(@"Ganze adresse übergeben");
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.coordinate addressDictionary:_address];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.title;
    
    if (_phoneNumber.length == 0 || _url.length ==0 ) {
       // mapItem.phoneNumber = @"0176 38922404";
        //mapItem.url = [NSURL URLWithString:@"http://www.ostwerk.de/"];
        return mapItem;

    }
    else {
    mapItem.phoneNumber = _phoneNumber;
    mapItem.url = [NSURL URLWithString:_url];
    return mapItem;
    }

    
    // 3
    /*
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.title;
    
    mapItem.phoneNumber = @"0176 38922404";
    mapItem.url = [NSURL URLWithString:@"http://www.ostwerk.de/"];
     */
    
    /*
    mapItem.phoneNumber = _phoneNumber;
    mapItem.name = [NSURL URLWithString:_url];
     */


    //return mapItem;
}


@end
