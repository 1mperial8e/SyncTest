//
//  WLITabBarController.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLITabBarController.h"
#import "WLIWelcomeViewController.h"
#import "WLINewPostTableViewController.h"
#import "WLIFollowingsViewController.h"
#import "WLIMyDriveViewController.h"
#import "WLITimelineViewController.h"
#import "WLIWhatIsNewViewController.h"
#import "WLIStartPageViewController.h"

#import "WLIConnect.h"

#import <SafariServices/SafariServices.h>

@interface WLITabBarController () <WLIWelcomeViewControllerDelegate, SFSafariViewControllerDelegate>

@property (strong, nonatomic) WLIWelcomeViewController *welcomeViewController;

@end

@implementation WLITabBarController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createControllers];
    }
    return self;
}

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
    [self showUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    if ([WLIUtils shouldShowNewFeatures]) {
//        WLIWhatIsNewViewController *whatIsNewVC = [WLIWhatIsNewViewController new];
//        [self presentViewController:whatIsNewVC animated:YES completion:nil];
//    }
}

#pragma mark - UI

- (void)createControllers
{
    WLIStartPageViewController *startPageViewController = [WLIStartPageViewController new];
    UINavigationController *startPageNavigationController = [[UINavigationController alloc] initWithRootViewController:startPageViewController];
    startPageNavigationController.navigationBar.translucent = NO;
    
    WLITimelineViewController *timelineViewController = [WLITimelineViewController new];
    UINavigationController *timelineNavigationController = [[UINavigationController alloc] initWithRootViewController:timelineViewController];
    timelineNavigationController.navigationBar.translucent = NO;
    
    WLINewPostTableViewController *newPostViewController = [WLINewPostTableViewController new];
    UINavigationController *newPostNavigationController = [[UINavigationController alloc] initWithRootViewController:newPostViewController];
    newPostNavigationController.navigationBar.translucent = NO;
    
    WLIFollowingsViewController *followingsViewController = [WLIFollowingsViewController new];
    UINavigationController *followingNavigationController = [[UINavigationController alloc] initWithRootViewController:followingsViewController];
    followingNavigationController.navigationBar.translucent = NO;
    
    WLIMyDriveViewController *myDriveViewController = [WLIMyDriveViewController new];
    UINavigationController *myDriveNavigationController = [[UINavigationController alloc] initWithRootViewController:myDriveViewController];
    myDriveNavigationController.navigationBar.translucent = NO;
    self.viewControllers = @[startPageNavigationController, timelineNavigationController, newPostNavigationController, followingNavigationController, myDriveNavigationController];
    
    UITabBarItem *startPageTabBarItem = [[UITabBarItem alloc] initWithTitle:@"20by2020" image:[[UIImage imageNamed:@"tabbar-20-h"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tabbar-20"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    startPageViewController.tabBarItem = startPageTabBarItem;
    
    UITabBarItem *timelineTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Timeline" image:[[UIImage imageNamed:@"tabbar-timeline-h"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tabbar-timeline"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    timelineViewController.tabBarItem = timelineTabBarItem;
    
    UITabBarItem *newPostTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Add Energy" image:[[UIImage imageNamed:@"tabbar-newpost-h"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tabbar-newpost"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    newPostViewController.tabBarItem = newPostTabBarItem;
    
    UITabBarItem *followingTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Following" image:[[UIImage imageNamed:@"tabbar-following-h"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tabbar-following"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    followingNavigationController.tabBarItem = followingTabBarItem;
    
    UITabBarItem *myDriveTabBarItem = [[UITabBarItem alloc] initWithTitle:@"My Energy" image:[[UIImage imageNamed:@"tabbar-mydrive-h"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tabbar-mydrive"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    myDriveViewController.tabBarItem = myDriveTabBarItem;
}

- (void)configureTabBar
{
    self.tabBar.translucent = NO;
    self.tabBar.barTintColor = [UIColor colorWithRed:249.0f/255.0f green:249.0f/255.0f blue:249.0f/255.0f alpha:1.0f];
    self.tabBar.tintColor = [UIColor redColor];
    
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

- (void)showUI
{
    if (![WLIConnect sharedConnect].currentUser) {
        [self createControllers];
        self.welcomeViewController.view.alpha = 1.0f;
    } else {
        self.welcomeViewController.view.alpha = 0.0f;
    }
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

#pragma mark - SFSafariViewControllerDelegate

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

@end
