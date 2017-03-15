//
//  EventDetailViewController.h
//  NightGuider
//
//  Created by Werner Kohn on 15.10.13.
//  Copyright (c) 2013 Werner. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import "RMPickerViewController.h"
#import <ParseUI/ParseUI.h>





@interface EventDetailViewController : UITableViewController <RMPickerViewControllerDelegate,PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>





@property (nonatomic, strong) PFObject *event;
@property (nonatomic, strong) PFObject *club;
@property (nonatomic, strong) PFGeoPoint *geoPoint;

@property (nonatomic, strong) NSString *stadt;


@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *clubName;
@property (nonatomic, strong) NSURL *imgURL;
@property (strong, nonatomic) UIImage *bigPic;
@property (nonatomic, strong)  UIImage *thumbnail;
@property (nonatomic, assign) double distance;
@property (nonatomic, assign) BOOL favorite;



@property (weak, nonatomic) IBOutlet UISegmentedControl *fbSegment;
@property (weak, nonatomic) IBOutlet UIButton *infoBtn;
@property (weak, nonatomic) IBOutlet UIButton *locationBtn;
@property (weak, nonatomic) IBOutlet UIButton *priceBtn;
@property (weak, nonatomic) IBOutlet UIButton *extendBtn;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *streetLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *routeBtn;



@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *bannerView;
@property (weak, nonatomic) IBOutlet UIButton *favBtn;
@property (weak, nonatomic) IBOutlet UIButton *remindBtn;
@property (weak, nonatomic) IBOutlet UILabel *host;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *eventTableView;


@end
