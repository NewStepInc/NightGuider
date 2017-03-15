//
//  FbSegmentCell.h
//  NightGuider
//
//  Created by Werner Kohn on 18.10.13.
//  Copyright (c) 2013 Werner. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface FbSegmentCell : PFTableViewCell
@property (weak, nonatomic) IBOutlet UISegmentedControl *fbSegment;

@end
