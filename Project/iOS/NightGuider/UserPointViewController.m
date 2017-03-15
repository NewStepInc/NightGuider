//
//  UserPointViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 16.11.15.
//  Copyright © 2015 Werner Kohn. All rights reserved.
//

#import "UserPointViewController.h"
#import <SCLAlertView.h>

#import "PassItemController.h"
#import "MBProgressHUD.h"

@interface UserPointViewController () <UIPageViewControllerDataSource>

@property (nonatomic, strong) NSMutableArray *bonuses;
@property (nonatomic, strong) NSMutableArray *pointArray;
@property (nonatomic, strong) NSMutableArray *constraints;
@property (nonatomic, strong) NSLayoutConstraint *constraint;


@property (strong, nonatomic) IBOutlet UITableView *pointTableView;
@property (nonatomic, assign) NSInteger pointCount;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation UserPointViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
  //  [self.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
   // [self.view addSubview:self.backgroundImageView];
    /*
    int i = 0;
    for (NSLayoutConstraint *con in self.pointTableView.constraints) {
        i++;
        NSLog(@"%i", i);
            [self.constraints addObject:con];
        
    }
    
    NSLog(@"Constraints %li",_pointTableView.constraints.count);
    
   // _constraints = _pointTableView.constraints;
    
      [self.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
     [self.view addSubview:self.backgroundImageView];
     
     */
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"Wird geladen...", @"Wird geladen...");
    [self.hud show:YES];
    
    
    _segmentedControl.selectedSegmentIndex = 0;
    [self load];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)load{
    
    //PFquery anschließend alle alten dinge löschen und createpage aufrufen
    
    if(_segmentedControl.selectedSegmentIndex == 0){
        //Premiumpass ausgewählt
        _pointTableView.hidden = NO;
        
        /*
      _pointTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        
        [_pointTableView addConstraints:_constraints];
        
        */

        
        NSLog(@"hosts laden");
        PFQuery *query = [PFQuery queryWithClassName:@"Points"];
        [query orderByDescending:@"amount"];
      //  [query whereKey:@"user" equalTo:[PFUser currentUser]];
        [query whereKey:@"userId" equalTo:[PFUser currentUser].objectId];


        
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            if(!error){
                
                NSLog(@"Anzahl der Hosts: %lu", (unsigned long)objects.count);
                
                
                _pointCount = objects.count;
                self.pointArray = [[NSMutableArray alloc] initWithArray:objects];
                
                //  [self.cityTableView reloadData];
                [_pointTableView setDelegate:self];
                [_pointTableView setDataSource:self];
                [self.view addSubview:self.pointTableView];

                
                [self.pointTableView reloadData];
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
                
                [alert showInfo:self title:@"Fehler" subTitle:@"Noch keine Punkte erhalten" closeButtonTitle:@"OK" duration:0.0f];
            }
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                

            }];
            
            
            


            
            
        }];
    }
    else{
        //tagestickt ausgewählt
        _pointTableView.hidden = YES;
        NSLog(@"prämien laden");
        PFQuery *query = [PFQuery queryWithClassName:@"UserBonus"];
        [query orderByAscending:@"createdAt"];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        [query whereKey:@"fulfilled" equalTo:@NO];

        
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            
            if(!error){
                NSLog(@"Bonusanzahl: %lu", (unsigned long)objects.count);
                
                self.bonuses = [[NSMutableArray alloc] initWithArray:objects];
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
                
                [alert showInfo:self title:@"Fehler" subTitle:@"Keine Prämie vorhanden" closeButtonTitle:@"OK" duration:0.0f];
            }
            
            
        }];
        
    }
    
    
    
}


- (void) createPageViewController
{
    
    //query nach passes auf segmented controller achten
    
    
    UIPageViewController *pageController = [self.storyboard instantiateViewControllerWithIdentifier: @"PageController"];
    pageController.dataSource = self;
    
    if([_bonuses count])
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
    self.pageViewController.view.frame = self.view.frame;
    self.pageViewController.view.tag = 2;
    
    [self addChildViewController: self.pageViewController];
    NSLog(@"subviews davor: %li", self.view.subviews.count);
    
    [self.view addSubview: self.pageViewController.view];
    NSLog(@"subviews danach: %li", self.view.subviews.count);

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
    
    if (itemController.itemIndex+1 < [_bonuses count])
    {
        return [self itemControllerForIndex: itemController.itemIndex+1];
    }
    
    return nil;
}

- (PassItemController *) itemControllerForIndex: (NSUInteger) itemIndex
{
    
    //passes übergeben
    if (itemIndex < [_bonuses count])
    {
        PassItemController *passItemController = [self.storyboard instantiateViewControllerWithIdentifier: @"PassController"];
        passItemController.itemIndex = itemIndex;
        passItemController.pass = _bonuses[itemIndex];
        
        
        

      passItemController.passType = 2;
            
        
        
        return passItemController;
    }
    
    return nil;
}

#pragma mark -
#pragma mark Page Indicator

- (NSInteger) presentationCountForPageViewController: (UIPageViewController *) pageViewController
{
    return [_bonuses count];
}

- (NSInteger) presentationIndexForPageViewController: (UIPageViewController *) pageViewController
{
    return 0;
}

- (IBAction)segmentControlPressed:(id)sender {
    NSLog(@"segment control pressed");
    
   // [[self.view.subviews objectAtIndex:2] removeFromSuperview];
    /*
    UIView *viewToRemove = [self.view viewWithTag:2];
    [viewToRemove removeFromSuperview];
    */
    
    [self.pageViewController.view removeFromSuperview];

    /*
    [self.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    [self.view addSubview:self.backgroundImageView];
    
    
    [self.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"Wird geladen...", @"Wird geladen...");
    
    */
    [self.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"Wird geladen...", @"Wird geladen...");
    [self.hud show:YES];
    
    
    [self load];
    
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return _pointArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    NSLog(@"cell wurde geladen");
    PFObject *host = [self.pointArray objectAtIndex:indexPath.row];
    
    NSNumber *point = [host objectForKey:@"amount"];

    NSString *pointString = [point stringValue];

    cell.textLabel.text = [host objectForKey:@"hostName"];
     cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ Punkte", pointString];
    

    return cell;
}


@end
