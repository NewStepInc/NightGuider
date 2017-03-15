//
//  HighlightViewController.h
//  NightGuider
//
//  Created by Werner Kohn on 20.10.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@interface HighlightViewController : PFQueryTableViewController
@property (nonatomic, strong) NSString *stadt;
@property (nonatomic, strong) NSString *cityName;


@property (nonatomic, assign) NSInteger anzahl;
@property (nonatomic, assign) NSInteger sektion;
@property (nonatomic, assign) NSInteger reihe;
@property (nonatomic, assign) NSInteger anzahlObjekte;
@property (nonatomic, assign) NSInteger hideNextPage;
@property (nonatomic, assign) NSInteger secondPage;


@property (nonatomic, retain) NSMutableDictionary *sections;
@property (nonatomic, retain) NSMutableDictionary *sectionToSportTypeMap;

@property (strong, nonatomic) UITableView *settingsTableView;

@property (strong) NSDictionary * profileDictionary;


@end

