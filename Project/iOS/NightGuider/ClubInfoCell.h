//
//  ClubInfoCell.h
//  NightGuider
//
//  Created by Werner Kohn on 28.04.14.
//  Copyright (c) 2014 Werner. All rights reserved.
//

#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import <ParseUI/ParseUI.h>


@interface ClubInfoCell : PFTableViewCell <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *streetNameButton;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *phoneNumberButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *websiteButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *streetNameLabel;

@end
