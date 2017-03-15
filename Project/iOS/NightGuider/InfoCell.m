//
//  InfoCell.m
//  Nightlife_2
//
//  Created by Werner Kohn on 06.04.13.
//  Copyright (c) 2013 Werner. All rights reserved.
//

#import "InfoCell.h"

@implementation InfoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    
    
    if(selected)
    {
        UIImage* bg = [UIImage imageNamed:@"ipad-list-item-selected.png"];
        UIImage* disclosureImage = [UIImage imageNamed:@"ipad-arrow-selected.png"];
        
        [self.bgImageView setImage:bg];
        [self.bgImageView setHidden:NO];
        
        _iconImageView = _selectedIconImageView;
        if (_iconImageView.image == nil) {
            NSLog(@"bild is da");

        }

        
        [self.disclosureImageView setImage:disclosureImage];
        
        
        [self.titleLabel setTextColor:[UIColor whiteColor]];
        
        [self.titleLabel setShadowColor:[UIColor colorWithRed:25.0/255 green:96.0/255 blue:148.0/255 alpha:1.0]];


        [self.titleLabel setShadowOffset:CGSizeMake(0, -1)];
         
         
        
        
        [self.subtitleLabel setTextColor:[UIColor whiteColor]];
        
        [self.subtitleLabel setShadowColor:[UIColor colorWithRed:25.0/255 green:96.0/255 blue:148.0/255 alpha:1.0]];
        [self.subtitleLabel setShadowOffset:CGSizeMake(0, -1)];
         
        
        [self.mainLabel setTextColor:[UIColor whiteColor]];
        
         //[self.mainLabel setShadowColor:[UIColor blackColor]];

        [self.mainLabel setShadowColor:[UIColor colorWithRed:25.0/255 green:96.0/255 blue:148.0/255 alpha:1.0]];
        [self.mainLabel setShadowOffset:CGSizeMake(0, -1)];
         
        
        /*
        [self.DateLabel setTextColor:[UIColor whiteColor]];
        [self.DateLabel setShadowColor:[UIColor colorWithRed:25.0/255 green:96.0/255 blue:148.0/255 alpha:1.0]];
        [self.DateLabel setShadowOffset:CGSizeMake(0, -1)];
         
        
        
        self.imageView.frame = CGRectMake( 20.0f, 9.0f, 52.0f, 52.0f);
        self.imageView.backgroundColor = [UIColor blackColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
         
         */
        
    }
    else
    {
       // UIImage* bg = [UIImage imageNamed:@"ipad-list-element.png"];
        // UIImage *bg2 = [UIImage imageNamed:@"special-list-element.png"];
        //UIImage* bg3 = [UIImage imageNamed:@"ipad-list-item-selected.png"];
       // UIImage* bg4 = [UIImage imageNamed:@"backgroundSp.png"];
        
        
        UIImage* disclosureImage = [UIImage imageNamed:@"ipad-arrow.png"];
        
        _iconImageView = _icon;
        
       // UIImage* disclosureImageSp = [UIImage imageNamed:@"ipad-arrow-selected.png"];
        

            
            //[self.bgImageView setImage:bg];
        
        [self.bgImageView setHidden:YES];

        
            [self.titleLabel setTextColor:[UIColor colorWithRed:0.0 green:68.0/255 blue:118.0/255 alpha:1.0]];
            [self.titleLabel setShadowColor:[UIColor whiteColor]];
            [self.titleLabel setShadowOffset:CGSizeMake(0, 1)];
            
            [self.subtitleLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
            [self.subtitleLabel setShadowColor:[UIColor whiteColor]];
            [self.subtitleLabel setShadowOffset:CGSizeMake(0, 1)];
        
        [self.mainLabel setTextColor:[UIColor colorWithRed:0.0 green:68.0/255 blue:118.0/255 alpha:1.0]];
        [self.mainLabel setShadowColor:[UIColor whiteColor]];
        [self.mainLabel setShadowOffset:CGSizeMake(0, 1)];
        
        [self.disclosureImageView setImage:disclosureImage];

        /*
            [self.DateLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
            [self.DateLabel setShadowColor:[UIColor whiteColor]];
            [self.DateLabel setShadowOffset:CGSizeMake(0, 1)];
            
            [self.DisclosureImageView setImage:disclosureImage];
            
         */
            
        
        
        
        /*
         // [self.TitleLabel setTextColor:[UIColor colorWithRed:0.0 green:68.0/255 blue:118.0/255 alpha:1.0]];
         [self.TitleLabel setShadowColor:[UIColor whiteColor]];
         [self.TitleLabel setShadowOffset:CGSizeMake(0, 1)];
         
         
         [self.SubtitleLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
         [self.SubtitleLabel setShadowColor:[UIColor whiteColor]];
         [self.SubtitleLabel setShadowOffset:CGSizeMake(0, 1)];
         
         [self.DateLabel setTextColor:[UIColor colorWithRed:113.0/255 green:133.0/255 blue:148.0/255 alpha:1.0]];
         [self.DateLabel setShadowColor:[UIColor whiteColor]];
         [self.DateLabel setShadowOffset:CGSizeMake(0, 1)];
         
         */
        
        self.imageView.frame = CGRectMake( 2.0f, 9.0f, 52.0f, 52.0f);
        self.imageView.backgroundColor = [UIColor blackColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
    }
    
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    
}

@end