//
//  UserPassViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 09.11.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import "UserPassViewController.h"
#import <SCLAlertView.h>

#import "PassItemController.h"
#import "MBProgressHUD.h"

@interface UserPassViewController () <UIPageViewControllerDataSource>


@property (nonatomic, strong) NSMutableArray *passes;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UISegmentedControl *passTypeControl;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;


@end

@implementation UserPassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //ladebalken anzeigen
    [self.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    [self.view addSubview:self.backgroundImageView];
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"Wird geladen...", @"Wird geladen...");
    [self.hud show:YES];
    
    
    _passTypeControl.selectedSegmentIndex = 0;
    [self loadPasses];
    
    
    /*
    _passes = @[@"nature_pic_1.png",
                @"nature_pic_2.png",
                @"nature_pic_3.png",
                @"nature_pic_4.png"];
    
    */
    
    
   // [self createPageViewController];
  //  [self setupPageControl];
    
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

-(void)loadPasses{
    
    //PFquery anschließend alle alten dinge löschen und createpage aufrufen
    
    if(_passTypeControl.selectedSegmentIndex == 0){
        //Premiumpass ausgewählt
        NSLog(@"premiumpass laden");
        PFQuery *query = [PFQuery queryWithClassName:@"Membership"];
        [query orderByAscending:@"createdAt"];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        [query whereKey:@"dayTicket" notEqualTo:@YES];
        [query whereKey:@"active" equalTo:@YES];

        
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            

            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

            if(!error){
                
                NSLog(@"Premiumanzahl: %lu", (unsigned long)objects.count);
                self.passes = [[NSMutableArray alloc] initWithArray:objects];
             //   [self.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
                [self createPageViewController];
                [self setupPageControl];
            }
            else{
                SCLAlertView *alert = [[SCLAlertView alloc] init];
                
                //Hide animation type (Default is FadeOut)
                alert.hideAnimationType = SlideOutToTop;
                
                //Show animation type (Default is SlideInFromTop)
                alert.showAnimationType = SlideInFromTop;
                
                //Set background type (Default is Shadow)
                alert.backgroundType = Blur;
                
                [alert alertIsDismissed:^{
                    NSLog(@"SCLAlertView dismissed!");
                    [self dismissViewControllerAnimated:YES completion:NULL];
                    
                }];
                
                [alert showInfo:self title:@"Fehler" subTitle:@"Kein Premiumpass vorhanden" closeButtonTitle:@"OK" duration:0.0f];
            }

            
        }];
    }
    else{
        //tagestickt ausgewählt
        NSLog(@"tagesticket laden");
        PFQuery *query = [PFQuery queryWithClassName:@"Membership"];
        [query orderByAscending:@"createdAt"];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        [query whereKey:@"dayTicket" equalTo:@YES];
        [query whereKey:@"active" equalTo:@YES];
        NSDate *today = [NSDate date];
        [query whereKey:@"endTime" greaterThanOrEqualTo:today];
        
        
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

            
            if(!error){
                NSLog(@"Tagesticketanzahl: %lu", (unsigned long)objects.count);

                self.passes = [[NSMutableArray alloc] initWithArray:objects];
            //    [self.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
                [self createPageViewController];
                [self setupPageControl];
            }
            else{
                SCLAlertView *alert = [[SCLAlertView alloc] init];
                
                //Hide animation type (Default is FadeOut)
                alert.hideAnimationType = SlideOutToTop;
                
                //Show animation type (Default is SlideInFromTop)
                alert.showAnimationType = SlideInFromTop;
                
                //Set background type (Default is Shadow)
                alert.backgroundType = Blur;
                
                [alert alertIsDismissed:^{
                    NSLog(@"SCLAlertView dismissed!");
                    [self dismissViewControllerAnimated:YES completion:NULL];
                    
                }];
                
                [alert showInfo:self title:@"Fehler" subTitle:@"Kein Tagesticket vorhanden" closeButtonTitle:@"OK" duration:0.0f];
            }
            
            
        }];
        
    }
    

    
}


- (void) createPageViewController
{
    
    //query nach passes auf segmented controller achten

    
    UIPageViewController *pageController = [self.storyboard instantiateViewControllerWithIdentifier: @"PageController"];
    pageController.dataSource = self;
    
    if([_passes count])
    {
    
    //    NSMutableArray *startingViewControllers = [NSMutableArray arrayWithArray:@[[self itemControllerForIndex: 0]]];
        NSArray *startingViewControllers = @[[self itemControllerForIndex: 0]];

        NSLog(@"viewcontroller: %@", [startingViewControllers objectAtIndex:0]);
        [pageController setViewControllers: startingViewControllers
                                 direction: UIPageViewControllerNavigationDirectionForward
                                  animated: NO
                                completion: nil];
    }
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

    self.pageViewController = pageController;
#warning text gets cut off sometimes
    
    self.pageViewController.view.frame = self.view.frame;

    [self addChildViewController: self.pageViewController];
    [self.view addSubview: self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController: self];
}

- (void) setupPageControl
{
    [[UIPageControl appearance] setPageIndicatorTintColor: [UIColor lightGrayColor]];
    [[UIPageControl appearance] setCurrentPageIndicatorTintColor: [UIColor whiteColor]];
 //   [[UIPageControl appearance] setBackgroundColor: [UIColor darkGrayColor]];
}

#pragma mark -
#pragma mark UIPageViewControllerDataSource

- (UIViewController *) pageViewController: (UIPageViewController *) pageViewController viewControllerBeforeViewController:(UIViewController *) viewController
{
    PassItemController *itemController = (PassItemController *) viewController;
    
    if (itemController.itemIndex > 0)
    {
        return [self itemControllerForIndex: itemController.itemIndex-1];
    }
    
    return nil;
}

- (UIViewController *) pageViewController: (UIPageViewController *) pageViewController viewControllerAfterViewController:(UIViewController *) viewController
{
    PassItemController *itemController = (PassItemController *) viewController;
    
    if (itemController.itemIndex+1 < [_passes count])
    {
        return [self itemControllerForIndex: itemController.itemIndex+1];
    }
    
    return nil;
}

- (PassItemController *) itemControllerForIndex: (NSUInteger) itemIndex
{
    
    //passes übergeben
    if (itemIndex < [_passes count])
    {
        PassItemController *passItemController = [self.storyboard instantiateViewControllerWithIdentifier: @"PassController"];
        passItemController.itemIndex = itemIndex;
        passItemController.pass = _passes[itemIndex];


        
        if(_passTypeControl.selectedSegmentIndex == 0){
            //premiumpass
            passItemController.passType = 0;

        }
        else{
            //tagesticket
            passItemController.passType = 1;

        }
        
        return passItemController;
    }
    
    return nil;
}

#pragma mark -
#pragma mark Page Indicator

- (NSInteger) presentationCountForPageViewController: (UIPageViewController *) pageViewController
{
    return [_passes count];
}

- (NSInteger) presentationIndexForPageViewController: (UIPageViewController *) pageViewController
{
    return 0;
}

- (IBAction)passTypeControlPressed:(id)sender {
    NSLog(@"segment control pressed");
    [self.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    [self.view addSubview:self.backgroundImageView];

    
    [self.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"Wird geladen...", @"Wird geladen...");
    [self.hud show:YES];
    
    
    [self loadPasses];
    

    
}

@end
