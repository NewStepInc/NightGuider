//
//  BannerCell.m
//  NightGuider
//
//  Created by Werner Kohn on 18.10.13.
//  Copyright (c) 2013 Werner. All rights reserved.
//

#import "BannerCell.h"

@implementation BannerCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (IBAction)favBtnPressed:(id)sender {
    NSLog(@"favorit wurde gepressed");
    //_favBtn.selected = !_favBtn.selected;

}

-(void)favBtnSelected{
    NSLog(@"wurde aufgerufen");
    _favBtn.selected = !_favBtn.selected;

}

@end
