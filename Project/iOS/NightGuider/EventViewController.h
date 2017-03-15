//
//  EventViewController.h
//  Nightlife_2
//
//  Created by Werner Kohn on 03.04.13.
//  Copyright (c) 2013 Werner. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>


@interface EventViewController : PFQueryTableViewController

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *art;
//@property (nonatomic, strong) NSDateFormatter *df;
//@property (nonatomic, strong) NSDateFormatter *dfi;

@property (nonatomic, strong) NSString *dateSwitch;
@property (nonatomic, strong) NSString *club;
@property (nonatomic, strong) NSString *stadt;
@property (nonatomic, strong) NSString *club_id;


@end
