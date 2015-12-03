//
//  WLIAppDelegate.m
//  WeLike
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIAppDelegate.h"

// Controllers
#import "WLINewPostTableViewController.h"
#import "WLIInfoPageViewController.h"
#import "WLIFollowingsViewController.h"
#import "WLIMyDriveViewController.h"

// Models
#import "WLIConnect.h"

// Frameworks
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@implementation WLIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[WLIAnalytics startSession];
	if ([WLIConnect sharedConnect].currentUser) {
		[WLIAnalytics setUserID:[NSString stringWithFormat:@"%li",(long)[WLIConnect sharedConnect].currentUser.userID]];
	}
	
    [Fabric with:@[[Crashlytics class]]];
	
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self createViewHierarchy];
    [self setupAppearance];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{	
	[WLIAnalytics startSession];
	if ([WLIConnect sharedConnect].currentUser) {
		[WLIAnalytics setUserID:[NSString stringWithFormat:@"%li",(long)[WLIConnect sharedConnect].currentUser.userID]];
	}
}

#pragma mark - Customisation

- (void)setupAppearance
{
    [[UINavigationBar appearance] setBarTintColor:[UIColor redColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f];
    NSDictionary *attributes = @{NSFontAttributeName : font, NSForegroundColorAttributeName : [UIColor whiteColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav-back64"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{	
    UINavigationController *navigationViewController = (UINavigationController *)viewController;
    if ([navigationViewController.topViewController isKindOfClass:[WLINewPostTableViewController class]]) {
        WLINewPostTableViewController *newPostViewController = [WLINewPostTableViewController new];
        UINavigationController *newPostNavigationController = [[UINavigationController alloc] initWithRootViewController:newPostViewController];
        newPostNavigationController.navigationBar.translucent = NO;
        [tabBarController presentViewController:newPostNavigationController animated:YES completion:nil];
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Other methods

- (void)createViewHierarchy
{
    WLIInfoPageViewController *infoPageViewController = [WLIInfoPageViewController new];
    UINavigationController *infoPageNavigationController = [[UINavigationController alloc] initWithRootViewController:infoPageViewController];
    infoPageNavigationController.navigationBar.translucent = NO;
    
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
    
    self.tabBarController = [[WLITabBarController alloc] init];
    self.tabBarController.delegate = self;
    self.tabBarController.viewControllers = @[infoPageNavigationController, timelineNavigationController, newPostNavigationController, followingNavigationController, myDriveNavigationController];
    self.timelineViewController = timelineViewController;
    
    UITabBarItem *infoPageTabBarItem = [[UITabBarItem alloc] initWithTitle:@"20by2020" image:[[UIImage imageNamed:@"tabbar-20-h"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tabbar-20"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    infoPageViewController.tabBarItem = infoPageTabBarItem;

    UITabBarItem *timelineTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Timeline" image:[[UIImage imageNamed:@"tabbar-timeline-h"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tabbar-timeline"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    timelineViewController.tabBarItem = timelineTabBarItem;

    UITabBarItem *newPostTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Add Energy" image:[[UIImage imageNamed:@"tabbar-newpost-h"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tabbar-newpost"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    newPostViewController.tabBarItem = newPostTabBarItem;
    
    UITabBarItem *followingTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Following" image:[[UIImage imageNamed:@"tabbar-following-h"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tabbar-following"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    followingNavigationController.tabBarItem = followingTabBarItem;

    UITabBarItem *myDriveTabBarItem = [[UITabBarItem alloc] initWithTitle:@"My Energy" image:[[UIImage imageNamed:@"tabbar-mydrive-h"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tabbar-mydrive"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    myDriveViewController.tabBarItem = myDriveTabBarItem;
    
    self.window.rootViewController = self.tabBarController;
}

@end
