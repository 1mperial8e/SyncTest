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

@interface WLITabBarController () <WLIWelcomeViewControllerDelegate>

@property (strong, nonatomic) WLIWelcomeViewController *welcomeViewController;

@end

@implementation WLITabBarController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureTabBar];
    [self addWelcomeView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![WLIConnect sharedConnect].currentUser) {
        self.welcomeViewController.view.alpha = 1.0f;
    } else {
        self.welcomeViewController.view.alpha = 0.0f;
    }
}

#pragma mark - UI

- (void)configureTabBar
{
    self.tabBar.translucent = NO;
    self.tabBar.barTintColor = [UIColor colorWithRed:249.0f/255.0f green:249.0f/255.0f blue:249.0f/255.0f alpha:1.0f];
    self.tabBar.tintColor = [UIColor blackColor];
    self.tabBar.selectedImageTintColor = [UIColor redColor];
    
    UIColor *colorUnselected = [UIColor colorWithRed:176/255.0f green:162/255.0f blue:162/255.0f alpha:1.0f];
    UIFont *fontUnselected = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
    NSDictionary *attributesUnselected = @{NSFontAttributeName : fontUnselected, NSForegroundColorAttributeName : colorUnselected};
    [[UITabBarItem appearance] setTitleTextAttributes:attributesUnselected forState:UIControlStateNormal];
    
    UIColor *colorSelected = [UIColor colorWithRed:255/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f];
    UIFont *fontSelected = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
    NSDictionary *attributesSelected = @{NSFontAttributeName : fontSelected, NSForegroundColorAttributeName : colorSelected};
    [[UITabBarItem appearance] setTitleTextAttributes:attributesSelected forState:UIControlStateSelected];
}

- (void)addWelcomeView
{
    self.welcomeViewController = [[WLIWelcomeViewController alloc] initWithNibName:@"WLIWelcomeViewController" bundle:nil];
    self.welcomeViewController.delegate = self;
    [self.welcomeViewController loadView];
    self.welcomeViewController.view.frame = [UIScreen mainScreen].bounds;
    [self.view addSubview:self.welcomeViewController.view];
    self.welcomeViewController.view.frame = self.view.frame;
}

#pragma mark - WLIWelcomeViewControllerDelegate

- (void)showLogin
{
    WLILoginViewController *loginViewController = [WLILoginViewController new];
    UINavigationController *loginNavigationViewController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    loginNavigationViewController.navigationBar.translucent = NO;
    [self presentViewController:loginNavigationViewController animated:YES completion:nil];
}

- (void)showRegister
{
    WLIRegisterViewController *registerViewController = [WLIRegisterViewController new];
    UINavigationController *registerNavigationViewController = [[UINavigationController alloc] initWithRootViewController:registerViewController];
    registerNavigationViewController.navigationBar.translucent = NO;
    [self presentViewController:registerNavigationViewController animated:YES completion:nil];
}

@end
