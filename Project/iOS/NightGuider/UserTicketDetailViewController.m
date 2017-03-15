//
//  UserTicketDetailViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 26.10.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import "UserTicketDetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import "SCLAlertView.h"
#import "Branch.h"
#import "BranchUniversalObject.h"
#import "BranchLinkProperties.h"
#import "MBProgressHUD.h"


#define kText @"http://nightguider.de"


@interface UserTicketDetailViewController ()<UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *downButtonLabel;
@property (nonatomic,weak)IBOutlet UIImageView *qrImageView;
@property (nonatomic, assign) BOOL showQr;
@property (weak, nonatomic) IBOutlet UIView *imageLayerView;
@property (nonatomic, strong) NSString *imageUrlString;
@property (nonatomic, strong) MBProgressHUD *hud;



@end

@implementation UserTicketDetailViewController {
    UIView *holeView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self addHoleSubview];
    
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"Ticket wird geladen", @"Ticket wird geladen...");
    /*
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    //    NSLog(@"filterAttributes:%@", filter.attributes);
    
    [filter setDefaults];
    
    NSData *data = [kText dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    
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
    
    self.qrImageView.image = resized;
    
    CGImageRelease(cgImage);
    */
    
    
    NSLog(@"wird geladennnn");
    _showQr = false;
    NSLog(@"1");

    _smallHeadline.text = [_ticket objectForKey:@"host"];
    _bigHeadline.text = [_ticket objectForKey:@"title"];
    NSLog(@"2");

    
  //  PFImageView *profileImageView = (PFImageView*)[cell viewWithTag:3];
    _bannerImageView.contentMode = UIViewContentModeScaleAspectFill;

    
    PFFile *applicantResume = [_ticket objectForKey:@"image"];
    _bannerImageView.file = applicantResume;
    _imageUrlString = applicantResume.url;
    [_bannerImageView loadInBackground];
    
     
    NSLog(@"3");
    
    _upperLeftLabel.text = [NSString stringWithFormat:@"Name: %@ %@", [_ticket objectForKey:@"firstName"],[_ticket objectForKey:@"lastName"] ];
    NSLog(@"4");

    NSNumber *amount = @0;

    switch (_ticketType){
        case 0:{
            amount = [_ticket objectForKey:@"ticketAmount"];
        } break;
        case 1:{
            amount = [_ticket objectForKey:@"guestlistAmount"];
        } break;
        case 2:{
            int summe =[[_ticket objectForKey:@"guestlistAmount"]intValue] + [[_ticket objectForKey:@"ticketAmount"]intValue];
            amount = [NSNumber numberWithInt:summe];
        }break;
        default:
            break;
    }
    NSString *amountText = [NSString stringWithFormat:@"Anzahl: %@", amount];

    
    _upperRightLabel.text = amountText;

    
    //preis wird nicht gespeichert
    //_downLeftLabel.text = [_ticket objectForKey:@"Preis:\nN/A"];
    _downLeftLabel.text = @"Preis:\nN/A";

    NSDateFormatter *dfd = [[NSDateFormatter alloc] init];
    dfd.dateStyle = NSDateFormatterShortStyle;
    dfd.timeStyle = NSDateFormatterNoStyle;
    dfd.timeZone = [NSTimeZone localTimeZone];
    NSString *dateText = [dfd stringFromDate:[_ticket objectForKey:@"startTime"]];
    //dateformatter
    _downMiddleLabel.text = [NSString stringWithFormat:@"Datum:\n%@", dateText];;
    
    NSDateFormatter *dft = [[NSDateFormatter alloc] init];
    dft.dateStyle = NSDateFormatterNoStyle;
    dft.timeStyle = NSDateFormatterShortStyle;
    dft.timeZone = [NSTimeZone localTimeZone];
    NSString *timeText = [dft stringFromDate:[_ticket objectForKey:@"startTime"]];
    //dateformatter
    _downRightLabel.text = [NSString stringWithFormat:@"Uhrzeit:\n%@",timeText];;
    
    NSLog(@"5");


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addHoleSubview {
    holeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10000, 10000)];
    holeView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    holeView.autoresizingMask = 0;
    [self.view addSubview:holeView];
    [self addMaskToHoleView];
}

- (void)addMaskToHoleView {
    CGRect bounds = holeView.bounds;
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = bounds;
    maskLayer.fillColor = [UIColor blackColor].CGColor;
    
    static CGFloat const kRadius = 100;
    CGRect const circleRect = CGRectMake(CGRectGetMidX(bounds) - kRadius,
                                         CGRectGetMidY(bounds) - kRadius,
                                         2 * kRadius, 2 * kRadius);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:circleRect];
    [path appendPath:[UIBezierPath bezierPathWithRect:bounds]];
    maskLayer.path = path.CGPath;
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    
    holeView.layer.mask = maskLayer;
}

- (void)viewDidLayoutSubviews {
    CGRect const bounds = self.view.bounds;
    holeView.center = CGPointMake(CGRectGetMidX(bounds), 0);
    
    // Defer this because `viewDidLayoutSubviews` can happen inside an
    // autorotation animation block, which overrides the duration I set.
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:2 delay:0
                            options:UIViewAnimationOptionRepeat
         | UIViewAnimationOptionAutoreverse
                         animations:^{
                             holeView.center = CGPointMake(CGRectGetMidX(bounds),
                                                           CGRectGetMaxY(bounds));
                         } completion:nil];
    });
}


/*
- (void)drawRect:(CGRect)rect {
    
    [backgroundColor setFill];
    UIRectFill(rect);
    
    for (NSValue *holeRectValue in rectsArray) {
        CGRect holeRect = [holeRectValue CGRectValue];
        CGRect holeRectIntersection = CGRectIntersection( holeRect, rect );
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        if( CGRectIntersectsRect( holeRectIntersection, rect ) )
        {
            CGContextAddEllipseInRect(context, holeRectIntersection);
            CGContextClip(context);
            CGContextClearRect(context, holeRectIntersection);
            CGContextSetFillColorWithColor( context, [UIColor clearColor].CGColor );
            CGContextFillRect( context, holeRectIntersection);
        }
    }
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
- (IBAction)buttonPressed:(id)sender {
    
    //qr code anzeigen
    if( !_showQr ){
      //  NSLog(@"zeige QR Code");

        CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        
        //    NSLog(@"filterAttributes:%@", filter.attributes);
        
        [filter setDefaults];
        
        NSData *data = [[_ticket objectId] dataUsingEncoding:NSUTF8StringEncoding];
        [filter setValue:data forKey:@"inputMessage"];
        
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
        
        _bannerImageView.contentMode = UIViewContentModeScaleAspectFit;
        _bannerImageView.image = resized;
        
        CGImageRelease(cgImage);
        
        _smallHeadline.hidden = YES;
        _bigHeadline.hidden = YES;
        _imageLayerView.hidden = YES;

        //ids anzeigen
        _upperLeftLabel.text = [NSString stringWithFormat:@"Id: %@", [_ticket objectId] ];
        //schauen was root is
        _upperRightLabel.text = @"";
        //preis wird nicht gespeichert
        _downLeftLabel.text = [NSString stringWithFormat:@"EventId: %@", [_ticket objectForKey:@"eventId"] ];
        //dateformatter
        _downMiddleLabel.text = @"";
        //dateformatter
        _downRightLabel.text = [NSString stringWithFormat:@"UserId: %@", [_ticket objectForKey:@"userId"] ];
        _showQr = true;

        
    }
    
    //normales Bilde anzeigen
    else{
        
       // NSLog(@"zeige normales Bild");
        //  PFImageView *profileImageView = (PFImageView*)[cell viewWithTag:3];
        NSNumber *amount = @0;
        
        switch (_ticketType){
            case 0:{
                amount = [_ticket objectForKey:@"ticketAmount"];
            } break;
            case 1:{
                amount = [_ticket objectForKey:@"guestlistAmount"];
            } break;
            case 2:{
                int summe =[[_ticket objectForKey:@"guestlistAmount"]intValue] + [[_ticket objectForKey:@"ticketAmount"]intValue];
                amount = [NSNumber numberWithInt:summe];
            }break;
            default:
                break;
        }
        NSString *amountText = [NSString stringWithFormat:@"Anzahl: %@", amount];
        
        
        _upperRightLabel.text = amountText;
        _bannerImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        _smallHeadline.hidden = NO;
        _bigHeadline.hidden = NO;
        _imageLayerView.hidden = NO;
        
        PFFile *applicantResume = [_ticket objectForKey:@"image"];
        _bannerImageView.file = applicantResume;
        [_bannerImageView loadInBackground];
        
        NSLog(@"3");
        
        _upperLeftLabel.text = [NSString stringWithFormat:@"Name: %@ %@", [_ticket objectForKey:@"firstName"],[_ticket objectForKey:@"lastName"] ];
        NSLog(@"4");
        
        //schauen was root is
        _upperRightLabel.text = [_ticket objectForKey:@""];
        
        //preis wird nicht gespeichert
        _downLeftLabel.text = @"Preis:\nN/A";
        NSDateFormatter *dfd = [[NSDateFormatter alloc] init];
        dfd.dateStyle = NSDateFormatterShortStyle;
        dfd.timeStyle = NSDateFormatterNoStyle;
        dfd.timeZone = [NSTimeZone localTimeZone];
        NSString *dateText = [dfd stringFromDate:[_ticket objectForKey:@"startTime"]];
        //dateformatter
        _downMiddleLabel.text = [NSString stringWithFormat:@"Datum:\n%@", dateText];
        
        NSDateFormatter *dft = [[NSDateFormatter alloc] init];
        dft.dateStyle = NSDateFormatterNoStyle;
        dft.timeStyle = NSDateFormatterShortStyle;
        dft.timeZone = [NSTimeZone localTimeZone];
        NSString *timeText = [dft stringFromDate:[_ticket objectForKey:@"startTime"]];
        //dateformatter
        _downRightLabel.text = [NSString stringWithFormat:@"Uhrzeit:\n%@", timeText];;
        _showQr = false;
        
    }
    
    
}
- (IBAction)rightBarButtonPressed:(id)sender {
    
    [self.hud show:YES];

    NSString *identifier = [NSString stringWithFormat:@"ticket/%@",_ticket.objectId];
    BranchUniversalObject *branchUniversalObject = [[BranchUniversalObject alloc] initWithCanonicalIdentifier:identifier];
    // Facebook OG tags -- this will overwrite any defaults you set up on the Branch Dashboard
    branchUniversalObject.title = [_ticket objectForKey:@"title"];
    branchUniversalObject.contentDescription = @"Öffne NightGuider und zeige den QR-Code in deinem Profil vor für den Einlass, viel Spaß!";
    
    //userinfo anhängen
    [branchUniversalObject addMetadataKey:@"eventId" value:[_ticket objectForKey:@"eventId"]];
    if ([PFUser currentUser]) {
        [branchUniversalObject addMetadataKey:@"user" value:[PFUser currentUser].objectId];
        
    }
    else {
        [branchUniversalObject addMetadataKey:@"user" value:@"not logged in"];
        
    }
    
    // Add any additional custom OG tags here
    [branchUniversalObject addMetadataKey:@"$og_title" value:[_ticket objectForKey:@"name"]];
    [branchUniversalObject addMetadataKey:@"$og_description" value:@"Öffne NightGuider und zeige den QR-Code in deinem Profil vor für den Einlass, viel Spaß!"];
    
    
    BranchLinkProperties *linkProperties = [[BranchLinkProperties alloc] init];
    linkProperties.feature = @"ticket_share";
    //   linkProperties.channel = @"facebook";
    //  [linkProperties addControlParam:@"$ios_deepview" withValue:@"default_template"];
    //  [linkProperties addControlParam:@"$android_deepview" withValue:@"default_template"];
    
    

    
    
    if ([_imageUrlString isEqualToString:@""]) {
        
        NSLog(@"Bild Url noch nicht gespeichert");
        PFFile *applicantResume = [_ticket objectForKey:@"image"];
        // NSData *resumeData = [applicantResume getData];
        _imageUrlString = applicantResume.url;
        [branchUniversalObject addMetadataKey:@"$og_image_url" value:_imageUrlString];
        
        
        
        
        branchUniversalObject.imageUrl = _imageUrlString;
        [branchUniversalObject registerView];
        
        [branchUniversalObject getShortUrlWithLinkProperties:linkProperties andCallback:^(NSString *url, NSError *error) {
            if (!error) {
                NSLog(@"success getting url! %@", url);

                
                NSNumber *amount = @0;
                NSString *initalTextString;
                switch (_ticketType){
                    case 0:{
                        amount = [_ticket objectForKey:@"ticketAmount"];
                        if ([amount  isEqual: @1]) {
                            initalTextString = [NSString stringWithFormat:@"1 Ticket für %@\n\nName: %@ %@\n%@\n%@\nId: %@\n\n\n Zeige den QR-Code bei Einlass vor, es gelten die Geschäftsbedingungen des Eventbetreibers.\nViel Spaß beim Feiern wünscht Dir dein NightGuider Team ;)",[_ticket objectForKey:@"title"],[_ticket objectForKey:@"firstName"],[_ticket objectForKey:@"lastName"],_downMiddleLabel.text, _downRightLabel.text ,_ticket.objectId];
                        }
                        else{
                            initalTextString = [NSString stringWithFormat:@"%@ Tickets für %@\n\nName: %@ %@\n%@\n%@\nId: %@\n\n\n Zeige den QR-Code bei Einlass vor, es gelten die Geschäftsbedingungen des Eventbetreibers.\nViel Spaß beim Feiern wünscht Dir dein NightGuider Team ;)",amount,[_ticket objectForKey:@"title"],[_ticket objectForKey:@"firstName"],[_ticket objectForKey:@"lastName"],_downMiddleLabel.text, _downRightLabel.text ,_ticket.objectId];
                        }
                        
                    } break;
                    case 1:{
                        amount = [_ticket objectForKey:@"guestlistAmount"];
                        if ([amount  isEqual: @1]) {
                            initalTextString = [NSString stringWithFormat:@"1 Gästenlistenplatz für %@\n\nName: %@ %@\n%@\n%@\nId: %@\n\n\n Zeige den QR-Code bei Einlass vor, es gelten die Geschäftsbedingungen des Eventbetreibers.\nViel Spaß beim Feiern wünscht Dir dein NightGuider Team ;)",[_ticket objectForKey:@"title"],[_ticket objectForKey:@"firstName"],[_ticket objectForKey:@"lastName"],_downMiddleLabel.text, _downRightLabel.text ,_ticket.objectId];
                        }
                        else{
                            initalTextString = [NSString stringWithFormat:@"%@ Gästelistenplätze für %@\n\nName: %@ %@\n%@\n%@\nId: %@\n\n\n Zeige den QR-Code bei Einlass vor, es gelten die Geschäftsbedingungen des Eventbetreibers.\nViel Spaß beim Feiern wünscht Dir dein NightGuider Team ;)",amount,[_ticket objectForKey:@"title"],[_ticket objectForKey:@"firstName"],[_ticket objectForKey:@"lastName"],_downMiddleLabel.text, _downRightLabel.text ,_ticket.objectId];
                        }
                    } break;
                    case 2:{
                        int summe =[[_ticket objectForKey:@"guestlistAmount"]intValue] + [[_ticket objectForKey:@"ticketAmount"]intValue];
                        amount = [NSNumber numberWithInt:summe];
                        if ([amount  isEqual: @1]) {
                            initalTextString = [NSString stringWithFormat:@"1 Kombiticket für %@\n\nName: %@ %@\n%@\n%@\nId: %@\n\n\n Zeige den QR-Code bei Einlass vor, es gelten die Geschäftsbedingungen des Eventbetreibers.\nViel Spaß beim Feiern wünscht Dir dein NightGuider Team ;)",[_ticket objectForKey:@"title"],[_ticket objectForKey:@"firstName"],[_ticket objectForKey:@"lastName"],_downMiddleLabel.text, _downRightLabel.text ,_ticket.objectId];
                        }
                        else{
                            initalTextString = [NSString stringWithFormat:@"%@ Kombitickets für %@\n\nName: %@ %@\n%@\n%@\nId: %@\n\n\n Zeige den QR-Code bei Einlass vor, es gelten die Geschäftsbedingungen des Eventbetreibers.\nViel Spaß beim Feiern wünscht Dir dein NightGuider Team ;)",amount,[_ticket objectForKey:@"title"],[_ticket objectForKey:@"firstName"],[_ticket objectForKey:@"lastName"],_downMiddleLabel.text, _downRightLabel.text ,_ticket.objectId];
                        }
                    }break;
                    default:
                        break;
                }


                
                
                NSURL *link = [NSURL URLWithString:url];
                
                //generate qr code
                CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
                
                //    NSLog(@"filterAttributes:%@", filter.attributes);
                
                [filter setDefaults];
                
                NSData *data = [[_ticket objectId] dataUsingEncoding:NSUTF8StringEncoding];
                [filter setValue:data forKey:@"inputMessage"];
                
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
                

                

                
                NSArray* dataToShare = @[initalTextString,link,resized];
                
                UIActivityViewController* activityViewController =
                [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                                  applicationActivities:nil];
                
                [self presentViewController:activityViewController animated:YES completion:^{
                    
                    CGImageRelease(cgImage);
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];


                }];
               // [self presentViewController:activityViewController animated:YES completion:^{}];
            }
        }];
        
        /*
        [branchUniversalObject showShareSheetWithLinkProperties:linkProperties
                                                   andShareText:@"Super amazing thing I want to share!"
                                             fromViewController:self
                                                    andCallback:^{
                                                        NSLog(@"finished presenting");
                                                    }];
         */
        
        
    }
    else{
        branchUniversalObject.imageUrl = _imageUrlString;
        [branchUniversalObject addMetadataKey:@"$og_image_url" value:_imageUrlString];
        
        [branchUniversalObject registerView];

        
        [branchUniversalObject getShortUrlWithLinkProperties:linkProperties andCallback:^(NSString *url, NSError *error) {
            if (!error) {
                NSLog(@"success getting url! %@", url);
                
                
                NSNumber *amount = @0;
                NSString *initalTextString;
                switch (_ticketType){
                    case 0:{
                        amount = [_ticket objectForKey:@"ticketAmount"];
                        if ([amount  isEqual: @1]) {
                            initalTextString = [NSString stringWithFormat:@"1 Ticket für %@\n\nName: %@ %@\n%@\n%@\nId: %@\n\n\n Zeige den QR-Code bei Einlass vor, es gelten die Geschäftsbedingungen des Eventbetreibers.\nViel Spaß beim Feiern wünscht Dir dein NightGuider Team ;)",[_ticket objectForKey:@"title"],[_ticket objectForKey:@"firstName"],[_ticket objectForKey:@"lastName"],_downMiddleLabel.text, _downRightLabel.text ,_ticket.objectId];
                        }
                        else{
                            initalTextString = [NSString stringWithFormat:@"%@ Tickets für %@\n\nName: %@ %@\n%@\n%@\nId: %@\n\n\n Zeige den QR-Code bei Einlass vor, es gelten die Geschäftsbedingungen des Eventbetreibers.\nViel Spaß beim Feiern wünscht Dir dein NightGuider Team ;)",amount,[_ticket objectForKey:@"title"],[_ticket objectForKey:@"firstName"],[_ticket objectForKey:@"lastName"],_downMiddleLabel.text, _downRightLabel.text ,_ticket.objectId];
                        }
                        
                    } break;
                    case 1:{
                        amount = [_ticket objectForKey:@"guestlistAmount"];
                        if ([amount  isEqual: @1]) {
                            initalTextString = [NSString stringWithFormat:@"1 Gästenlistenplatz für %@\n\nName: %@ %@\n%@\n%@\nId: %@\n\n\n Zeige den QR-Code bei Einlass vor, es gelten die Geschäftsbedingungen des Eventbetreibers.\nViel Spaß beim Feiern wünscht Dir dein NightGuider Team ;)",[_ticket objectForKey:@"title"],[_ticket objectForKey:@"firstName"],[_ticket objectForKey:@"lastName"],_downMiddleLabel.text, _downRightLabel.text ,_ticket.objectId];
                        }
                        else{
                            initalTextString = [NSString stringWithFormat:@"%@ Gästelistenplätze für %@\n\nName: %@ %@\n%@\n%@\nId: %@\n\n\n Zeige den QR-Code bei Einlass vor, es gelten die Geschäftsbedingungen des Eventbetreibers.\nViel Spaß beim Feiern wünscht Dir dein NightGuider Team ;)",amount,[_ticket objectForKey:@"title"],[_ticket objectForKey:@"firstName"],[_ticket objectForKey:@"lastName"],_downMiddleLabel.text, _downRightLabel.text ,_ticket.objectId];
                        }
                    } break;
                    case 2:{
                        int summe =[[_ticket objectForKey:@"guestlistAmount"]intValue] + [[_ticket objectForKey:@"ticketAmount"]intValue];
                        amount = [NSNumber numberWithInt:summe];
                        if ([amount  isEqual: @1]) {
                            initalTextString = [NSString stringWithFormat:@"1 Kombiticket für %@\n\nName: %@ %@\n%@\n%@\nId: %@\n\n\n Zeige den QR-Code bei Einlass vor, es gelten die Geschäftsbedingungen des Eventbetreibers.\nViel Spaß beim Feiern wünscht Dir dein NightGuider Team ;)",[_ticket objectForKey:@"title"],[_ticket objectForKey:@"firstName"],[_ticket objectForKey:@"lastName"],_downMiddleLabel.text, _downRightLabel.text ,_ticket.objectId];
                        }
                        else{
                            initalTextString = [NSString stringWithFormat:@"%@ Kombitickets für %@\n\nName: %@ %@\n%@\n%@\nId: %@\n\n\n Zeige den QR-Code bei Einlass vor, es gelten die Geschäftsbedingungen des Eventbetreibers.\nViel Spaß beim Feiern wünscht Dir dein NightGuider Team ;)",amount,[_ticket objectForKey:@"title"],[_ticket objectForKey:@"firstName"],[_ticket objectForKey:@"lastName"],_downMiddleLabel.text, _downRightLabel.text ,_ticket.objectId];
                        }
                    }break;
                    default:
                        break;
                }
                
                
                
                
                NSURL *link = [NSURL URLWithString:url];
                
                //generate qr code
                CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
                
                //    NSLog(@"filterAttributes:%@", filter.attributes);
                
                [filter setDefaults];
                
                NSData *data = [[_ticket objectId] dataUsingEncoding:NSUTF8StringEncoding];
                [filter setValue:data forKey:@"inputMessage"];
                
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
                
                
                
                
                
                NSArray* dataToShare = @[initalTextString,link,resized];
                
                UIActivityViewController* activityViewController =
                [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                                  applicationActivities:nil];
                
                [self presentViewController:activityViewController animated:YES completion:^{
                    
                    CGImageRelease(cgImage);
                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

                    
                }];
                // [self presentViewController:activityViewController animated:YES completion:^{}];
            }
        }];
        
        
    }
    
    
    
     

     
    

}

@end
