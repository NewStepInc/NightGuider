//
//  PassItemController.m
//  NightGuider
//
//  Created by Werner Kohn on 10.11.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import "PassItemController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>

@interface PassItemController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;
@property (weak, nonatomic) IBOutlet UILabel *middleLeftLabel;

@property (weak, nonatomic) IBOutlet UILabel *downLeftLabel;
@property (weak, nonatomic) IBOutlet UILabel *upLeftLabel;
@property (weak, nonatomic) IBOutlet UILabel *downRightLabel;
@property (weak, nonatomic) IBOutlet UILabel *upRightLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;



@end

@implementation PassItemController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadQrCode];

    //locations einbaun
    
    if (_passType == 1) {
        //Zeitram und Datum angeben
        _titleLabel.text = @"3-Tagesticket";
        _upLeftLabel.text = [NSString stringWithFormat:@"%@ %@", [_pass objectForKey:@"firstName"],[_pass objectForKey:@"lastName"] ] ;
        NSArray *regions =  [_pass objectForKey:@"locations"];

        _upRightLabel.text = [regions objectAtIndex:0];
        
        NSDateFormatter *dfd = [[NSDateFormatter alloc] init];
        dfd.dateStyle = NSDateFormatterShortStyle;
        dfd.timeStyle = NSDateFormatterNoStyle;
        dfd.timeZone = [NSTimeZone localTimeZone];
        NSString *startText = [dfd stringFromDate:[_pass objectForKey:@"startTime"]];
        NSString *endText = [dfd stringFromDate:[_pass objectForKey:@"endTime"]];

        //dateformatter
        _downLeftLabel.text = [NSString stringWithFormat:@"Datum:\n%@ - %@", startText, endText];;
        
        NSDateFormatter *dft = [[NSDateFormatter alloc] init];
        dft.dateStyle = NSDateFormatterNoStyle;
        dft.timeStyle = NSDateFormatterShortStyle;
        dft.timeZone = [NSTimeZone localTimeZone];
        NSString *timeText = [dft stringFromDate:[_pass objectForKey:@"startTime"]];
        //dateformatter
        _downRightLabel.text = [NSString stringWithFormat:@"Uhrzeit:\n%@",timeText];;
        
     //   _downLeftLabel.text = [_pass objectForKey:@""];
     //   _downRightLabel.text = [_pass objectForKey:@""];
    }
    else if(_passType == 0){
        _titleLabel.text = @"Premiumpass";
        _upLeftLabel.text = [NSString stringWithFormat:@"%@ %@", [_pass objectForKey:@"firstName"],[_pass objectForKey:@"lastName"] ] ;
        NSArray *regions =  [_pass objectForKey:@"locations"];
        
        _upRightLabel.text = [regions objectAtIndex:0];
        
        _downRightLabel.text = [_pass objectForKey:@""];
        _downLeftLabel.text = [NSString stringWithFormat:@"UserId:\n%@",[_pass objectForKey:@"userId"]];
    }
    else if(_passType == 2){
        _titleLabel.text = [_pass objectForKey:@"title"];
        _upLeftLabel.text = [_pass objectForKey:@"hostName"];
        _downLeftLabel.text = [_pass objectForKey:@"description"];
        _downRightLabel.text = @"";
        _upRightLabel.text = [NSString stringWithFormat:@"Id: %@",_pass.objectId];


        
    }
    else{
        //testzwecke
      //  NSLog(@"test laden");
        _titleLabel.text = @"Premiumpass";

        _upLeftLabel.text = @"Name: Werner Ko";
      //  _middleLeftLabel.text =@"Augsburg";
        _upRightLabel.text = @"Augsburg";
        _downRightLabel.text = @"ID:\n1234568";
        _downLeftLabel.text = @"Seit:\n25/07/2015";
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)loadQrCode{
    NSLog(@"zeige QR Code");
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //    NSLog(@"filterAttributes:%@", filter.attributes);
    
    [filter setDefaults];
    
    NSData *data = [[_pass objectId] dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
  
    /*
    NSData *data = [@"test" dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
     */


    
    CIImage *outputImage = [filter outputImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage
                                       fromRect:[outputImage extent]];
    
    UIImage *image = [UIImage imageWithCGImage:cgImage
                                         scale:1.
                                   orientation:UIImageOrientationUp];
    
    // Resize without interpolating
    UIImage *resized = [self resizeImage:image
                             withQuality:kCGInterpolationNone
                                    rate:5.0];
    
    // self.qrImageView.image = resized;
    
    _qrImageView.contentMode = UIViewContentModeScaleAspectFit;
    _qrImageView.image = resized;
    
    CGImageRelease(cgImage);

}


- (UIImage *)resizeImage:(UIImage *)image
             withQuality:(CGInterpolationQuality)quality
                    rate:(CGFloat)rate
{
    UIImage *resized = nil;
    CGFloat width = image.size.width * rate;
    CGFloat height = image.size.height * rate;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, quality);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resized;
}

@end
