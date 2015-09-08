//
//  WLITabBarController.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLITabBarController.h"
#import "WLIWelcomeViewController.h"
#import "WLIConnect.h"

@implementation WLITabBarController


#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tabBar.translucent = NO;
    self.tabBar.barTintColor = [UIColor colorWithRed:226/255.0f green:7/255.0f blue:21/255.0f alpha:1.0f];
    self.tabBar.tintColor = [UIColor blackColor];
    self.tabBar.selectedImageTintColor = [UIColor whiteColor];
    
    UIColor *colorUnselected = [[UIColor whiteColor] colorWithAlphaComponent:0.8f];
    UIFont *fontUnselected = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
    NSDictionary *attributesUnselected = @{NSFontAttributeName : fontUnselected, NSForegroundColorAttributeName : colorUnselected};
    [[UITabBarItem appearance] setTitleTextAttributes:attributesUnselected forState:UIControlStateNormal];
    
    UIColor *colorSelected = [UIColor whiteColor];
    UIFont *fontSelected = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
    NSDictionary *attributesSelected = @{NSFontAttributeName : fontSelected, NSForegroundColorAttributeName : colorSelected};
    [[UITabBarItem appearance] setTitleTextAttributes:attributesSelected forState:UIControlStateSelected];
    
    welcomeViewController = [[WLIWelcomeViewController alloc] initWithNibName:@"WLIWelcomeViewController" bundle:nil];
    welcomeViewController.delegate = self;
    [welcomeViewController loadView];
    [self.view addSubview:welcomeViewController.view];
    welcomeViewController.view.frame = self.view.frame;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    if (![WLIConnect sharedConnect].currentUser) {
        welcomeViewController.view.alpha = 1.0f;
    } else {
        welcomeViewController.view.alpha = 0.0f;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - WLIWelcomeViewControllerDelegate methods

- (void)showLogin {
    
    WLILoginViewController *loginViewController = [[WLILoginViewController alloc] initWithNibName:@"WLILoginViewController" bundle:nil];
    UINavigationController *loginNavigationViewController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    loginNavigationViewController.navigationBar.translucent = NO;
    [self presentViewController:loginNavigationViewController animated:YES completion:^{ }];
}

- (void)showRegister {
    
    WLIRegisterViewController *registerViewController = [[WLIRegisterViewController alloc] initWithNibName:@"WLIRegisterViewController" bundle:nil];
    UINavigationController *registerNavigationViewController = [[UINavigationController alloc] initWithRootViewController:registerViewController];
    registerNavigationViewController.navigationBar.translucent = NO;
    [self presentViewController:registerNavigationViewController animated:YES completion:^{ }];
}

@end
