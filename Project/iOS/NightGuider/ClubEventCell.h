//
//  ClubEventCell.h
//  NightGuider
//
//  Created by Werner Kohn on 30.04.14.
//  Copyright (c) 2014 Werner. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface ClubEventCell : PFTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *clubNameLabel;

@end
