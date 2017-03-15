//
//  CityViewController.h
//  NightGuider
//
//  Created by Werner Kohn on 13.09.13.
//  Copyright (c) 2013 Werner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *cityTableView;
@property (nonatomic, assign) NSInteger anzahl;


@end
