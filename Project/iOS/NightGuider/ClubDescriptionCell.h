//
//  ClubDescriptionCell.h
//  NightGuider
//
//  Created by Werner Kohn on 28.04.14.
//  Copyright (c) 2014 Werner. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>


@interface ClubDescriptionCell : PFTableViewCell
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end
