//
//  FavoriteViewController.h
//  NightGuider
//
//  Created by Werner Kohn on 20.10.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface FavoriteViewController : PFQueryTableViewController

@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSMutableArray *clubs;
@property (nonatomic, strong) NSMutableArray *listOfClubs;

@property (nonatomic, strong) NSMutableArray *bars;
@property (nonatomic, strong) NSMutableArray *listOfBars;

@property (nonatomic, strong) NSMutableArray *listOfItems;
@property (nonatomic, strong) NSString *sortierung;
@property (nonatomic, strong) NSString *stadt;



-(void) loadData;
-(void) saveData;

@end