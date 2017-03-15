//
//  MapCell.h
//  NightGuider
//
//  Created by Werner Kohn on 18.10.13.
//  Copyright (c) 2013 Werner. All rights reserved.
//

#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import <ParseUI/ParseUI.h>


@interface MapCell : PFTableViewCell <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end
