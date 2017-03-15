//
//  TicketPopOverView.m
//  NightGuider
//
//  Created by Werner Kohn on 07.07.15.
//  Copyright (c) 2015 Werner. All rights reserved.
//

#import "TicketPopOverView.h"

@interface TicketPopOverView() {
    CGSize _intrinsicContentSize;
    
}
@property (nonatomic, weak) UIViewController <TicketPopOverViewDelegate> *delegateViewController;

@end

@implementation TicketPopOverView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


@synthesize delegate; //synthesise  MyClassDelegate delegate

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        
        NSLog(@"initwith frame");
        // 1. Load .xib
        [[NSBundle mainBundle] loadNibNamed:@"TicketPopOverView" owner:self options:nil];
        // 2. Adjust bounds
        self.bounds = self.mainView.bounds;
        _intrinsicContentSize = self.bounds.size;
        
        // set backgroundcolor alpha
        [self.mainView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
        // 3. add as subview
        [self addSubview:self.mainView];
        
     //   [_bannerImageView loadInBackground];

        
        int maxValue = _amountStepper.maximumValue;
        
        if (maxValue == 1) {
            _freeTicketsLabel.hidden = NO;
            
            _freeTicketsLabel.text = [NSString stringWithFormat:@"%i Platz frei!", maxValue];
        }
        else if (maxValue <= 10) {
            _freeTicketsLabel.hidden = NO;

            _freeTicketsLabel.text = [NSString stringWithFormat:@"%i Plätze frei!", maxValue];
        }

        else{
            _freeTicketsLabel.hidden = YES;
        }



    }
    return self;
}




- (IBAction)amountStepperPressed:(id)sender {
    NSLog(@"anzahl geändert");
    _amountLabel.text = [NSString stringWithFormat:@"%.f Plätze", _amountStepper.value];


}
- (IBAction)closeButtonPressed:(id)sender {
    
    [self removeFromSuperview];
    [self.delegate ticketPopOverViewDidDismiss:self];

}
- (IBAction)purchaseButtonPressed:(id)sender {
    
    [self removeFromSuperview];
    [self.delegate ticketPopOverViewPurchase:self ticketAmount:(int)_amountStepper.value];


    

}

-(CGSize)intrinsicContentSize{
    
    return _intrinsicContentSize;
}

@end
