//
//  MasterCell.m
//  Nightlife_2
//
//  Created by Werner on 19.11.12.
//  Copyright (c) 2012 Werner. All rights reserved.
//

#import "MasterCell.h"

@implementation MasterCell

@synthesize BgImageView;
@synthesize DisclosureImageView;
@synthesize FlyerImageView;
@synthesize TitleLabel;
@synthesize SubtitleLabel;
@synthesize DateLabel;
@synthesize IconImageView;
@synthesize TestImageView;
@synthesize sp;
@synthesize testView;
@synthesize AvailableLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (!selected) {
        if (self.sp) {
            NSLog(@"-----special");
            UIColor* bgColor3 = [UIColor colorWithRed:0.93 green:0.56 blue:0.00 alpha:1.0];
            
        //    UIImage *bg4 = [UIImage imageNamed:@"special-list-element.png"];
            UIImage *bg4 = [UIImage imageNamed:@"backgroundSp"];


            self.backgroundColor = bgColor3;
         //   self.backgroundColor = [UIColor greenColor];

            self.BgImageView.hidden = NO;
            [self.BgImageView setImage:bg4];
        }
        
        else{
    
            
            
        }

    }
    /*
  
    if(selected)
    {
        UIImage* bg = [UIImage imageNamed:@"ipad-list-item-selected.png"];
        UIImage* disclosureImage = [UIImage imageNamed:@"ipad-arrow-selected.png"];
        
        [self.BgImageView setImage:bg];
        [self.DisclosureImageView setImage:disclosureImage];
        
        [self.TitleLabel setTextColor:[UIColor whiteColor]];
        [self.TitleLabel setShadowColor:[UIColor colorWithRed:25.0/255 green:96.0/255 blue:148.0/255 alpha:1.0]];
        [self.TitleLabel setShadowOffset:CGSizeMake(0, -1)];
        
        
        [self.SubtitleLabel setTextColor:[UIColor whiteColor]];
        [self.SubtitleLabel setShadowColor:[UIColor colorWithRed:25.0/255 green:96.0/255 blue:148.0/255 alpha:1.0]];
        [self.SubtitleLabel setShadowOffset:CGSizeMake(0, -1)];
        
        [self.DateLabel setTextColor:[UIColor whiteColor]];
        [self.DateLabel setShadowColor:[UIColor colorWithRed:25.0/255 green:96.0/255 blue:148.0/255 alpha:1.0]];
        [self.DateLabel setShadowOffset:CGSizeMake(0, -1)];
        
        self.imageView.frame = CGRectMake( 20.0f, 9.0f, 52.0f, 52.0f);
        self.imageView.backgroundColor = [UIColor blackColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
    }
    else
    {
        UIImage* bg = [UIImage imageNamed:@"ipad-list-element.png"];
       // UIImage *bg2 = [UIImage imageNamed:@"special-list-element.png"];
        //UIImage* bg3 = [UIImage imageNamed:@"ipad-list-item-selected.png"];
       // UIImage* bg4 = [UIImage imageNamed:@"backgroundSp.png"];


        UIImage* disclosureImage = [UIImage imageNamed:@"ipad-arrow.png"];
        
        UIImage* disclosureImageSp = [UIImage imageNamed:@"ipad-arrow-selected.png"];

        
        if ([self.sp isEqual: @"YES"]) {
            UIColor* bgColor3 = [UIColor colorWithRed:0.93 green:0.56 blue:0.00 alpha:1.0];

            self.backgroundColor = bgColor3;
          //  [self.BgImageView setImage:bg4];
            [self.TitleLabel setTextColor:[UIColor whiteColor]];
           // [self.TitleLabel setShadowColor:[UIColor colorWithRed:0.0 green:68.0/255 blue:118.0/255 alpha:1.0]];

            [self.TitleLabel setShadowColor:[UIColor blackColor]];

            [self.TitleLabel setShadowOffset:CGSizeMake(0, 1)];
            
            [self.SubtitleLabel setTextColor:[UIColor whiteColor]];
            [self.SubtitleLabel setShadowColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
            [self.SubtitleLabel setShadowOffset:CGSizeMake(0, 1)];
            
            [self.DateLabel setTextColor:[UIColor whiteColor]];
            [self.DateLabel setShadowColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
            [self.DateLabel setShadowOffset:CGSizeMake(0, 1)];
            
            [self.DisclosureImageView setImage:disclosureImageSp];


            NSLog(@"special!!!");

        }
        else {
            
        [self.BgImageView setImage:bg];
        [self.TitleLabel setTextColor:[UIColor colorWithRed:0.0 green:68.0/255 blue:118.0/255 alpha:1.0]];
//        [self.TitleLabel setShadowColor:[UIColor whiteColor]];
//        [self.TitleLabel setShadowOffset:CGSizeMake(0, 1)];
            
            [self.SubtitleLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
            [self.SubtitleLabel setShadowColor:[UIColor whiteColor]];
            [self.SubtitleLabel setShadowOffset:CGSizeMake(0, 1)];
            
            [self.DateLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
            [self.DateLabel setShadowColor:[UIColor whiteColor]];
            [self.DateLabel setShadowOffset:CGSizeMake(0, 1)];
            
            [self.DisclosureImageView setImage:disclosureImage];
            
            [self.TitleLabel setShadowColor:Nil];

            
            

        }


        
        self.imageView.frame = CGRectMake( 2.0f, 9.0f, 52.0f, 52.0f);
        self.imageView.backgroundColor = [UIColor blackColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
    }
    
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
     */
   
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    
    /*
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithRed:0.00 green:0.60 blue:0.80 alpha:1.0];
        [self.TitleLabel setTextColor:[UIColor whiteColor]];
        [self.SubtitleLabel setTextColor:[UIColor whiteColor]];
        [self.DateLabel setTextColor:[UIColor whiteColor]];




    } else {
        self.backgroundColor = [UIColor whiteColor];
      //  [self.TitleLabel setTextColor:[UIColor colorWithRed:0.00 green:0.60 blue:0.80 alpha:1.0]];
        [self.TitleLabel setTextColor:[UIColor colorWithRed:0.0 green:68.0/255 blue:118.0/255 alpha:1.0]];

        [self.SubtitleLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
        [self.DateLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
    }
     */
}


@end
