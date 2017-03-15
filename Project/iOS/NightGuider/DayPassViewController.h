//
//  DayPassViewController.h
//  NightGuider
//
//  Created by Werner Kohn on 24.10.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THDatePickerViewController.h"


@interface DayPassViewController : UIViewController <THDatePickerDelegate>

@property (nonatomic, strong) THDatePickerViewController * datePicker;

@end
