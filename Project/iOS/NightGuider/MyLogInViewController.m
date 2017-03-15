//
//  MyLogInViewController.m
//  NightGuider
//
//  Created by Werner Kohn on 09.07.15.
//  Copyright (c) 2015 Werner. All rights reserved.
//

#import "MyLogInViewController.h"
#import "MySignUpViewController.h"


@interface MyLogInViewController ()

@end

@implementation MyLogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];

    
    background.frame = [UIScreen mainScreen].bounds;

    background.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.logInView insertSubview:background atIndex:0];
    

    
    NSArray *permissionsArray = @[@"email",@"user_birthday",@"user_location", @"user_events",@"user_relationships"];
    
    [self setFacebookPermissions:permissionsArray];
    
    [self setFields:PFLogInFieldsUsernameAndPassword
     | PFLogInFieldsFacebook
     | PFLogInFieldsSignUpButton | PFLogInFieldsPasswordForgotten
     | PFLogInFieldsDismissButton];
    
    // Link the sign up view controller
    
    MySignUpViewController *signUpViewController = [[MySignUpViewController alloc] init];
    

  //  [self setSignUpController:signUpViewController];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:signUpViewController];
    
    self.signUpController = navController;


    //    UINavigationController *navController = (UINavigationController*)[segue destinationViewController];
    //   CheckoutViewController *checkoutController = [navController topViewController];
    

//    MySignUpViewController *signUpViewController2 = (MySignUpViewController *)[[segue destinationViewController] topViewController];



    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    NSLog(@"success login");
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    NSLog(@"cancelle login");
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    
    DLog(@"singup aufgerufen");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    DLog(@"singup abgebrochen");

    [self dismissViewControllerAnimated:YES completion:nil];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
