//
//  GeoPointAnnotation.h
//  Nightlife_2
//
//  Created by Werner on 28.11.12.
//  Copyright (c) 2012 Werner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>


@interface GeoPointAnnotation : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *countryKey;
@property (nonatomic, copy) NSString *cityKey;
@property (nonatomic, copy) NSString *streetKey;
@property (nonatomic, copy) NSString *zipKey;

@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, copy) NSString *url;


@property (nonatomic, strong) PFObject *club2;
@property (nonatomic, strong) NSDictionary * address;



@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *subtitle;

- (MKMapItem*)mapItem;


@end
