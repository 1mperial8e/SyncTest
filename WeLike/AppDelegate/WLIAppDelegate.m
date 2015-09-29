//
//  WLIAppDelegate.m
//  WeLike
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIAppDelegate.h"
#import "WLINewPostViewController.h"
//#import "WLINearbyViewController.h"
//#import "WLIPopularViewController.h"
//#import "WLIProfileViewController.h"
#import "WLITimelineViewController.h"
#import "WLIInfoPageViewController.h"
//#import "WLIFavoritesViewController.h"
#import "WLIFollowingsViewController.h"
#import "WLIMyDriveViewController.h"


#import "WLIConnect.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>



@implementation WLIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Fabric with:@[[Crashlytics class]]];

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [self createViewHierarchy];
    
    // navigation bar appearance
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:255.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0f];
    NSDictionary *attributes = @{NSFontAttributeName : font, NSForegroundColorAttributeName : [UIColor whiteColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav-back64"] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    } else {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav-back44"] forBarMetrics:UIBarMetricsDefault];
    }
    
    // status bar appearance
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - UITabBarControllerDelegate methods

- (BOOL)tabBarController:(UITabBarController *)tabBarController  shouldSelectViewController:(UIViewController *)viewController {
    
    UINavigationController *navigationViewController = (UINavigationController *)viewController;
    if ([navigationViewController.topViewController isKindOfClass:[WLINewPostViewController class]]) {
        WLINewPostViewController *newPostViewController = [[WLINewPostViewController alloc] initWithNibName:@"WLINewPostViewController" bundle:nil];
        UINavigationController *newPostNavigationController = [[UINavigationController alloc] initWithRootViewController:newPostViewController];
        newPostNavigationController.navigationBar.translucent = NO;
        [tabBarController presentViewController:newPostNavigationController animated:YES completion:nil];
        return NO;
    } else {
        return YES;
    }
}


#pragma mark - Other methods

- (void)createViewHierarchy {
    
    WLIInfoPageViewController *infoPageViewController = [[WLIInfoPageViewController alloc] initWithNibName:@"WLIInfoPageViewController" bundle:nil];
    UINavigationController *infoPageNavigationController = [[UINavigationController alloc] initWithRootViewController:infoPageViewController];
    infoPageNavigationController.navigationBar.translucent = NO;
    
    WLITimelineViewController *timelineViewController = [[WLITimelineViewController alloc] initWithNibName:@"WLITimelineViewController" bundle:nil];
    UINavigationController *timelineNavigationController = [[UINavigationController alloc] initWithRootViewController:timelineViewController];
    timelineNavigationController.navigationBar.translucent = NO;
    
    WLINewPostViewController *newPostViewController = [[WLINewPostViewController alloc] initWithNibName:@"WLINewPostViewController" bundle:nil];
    UINavigationController *newPostNavigationController = [[UINavigationController alloc] initWithRootViewController:newPostViewController];
    newPostNavigationController.navigationBar.translucent = NO;
    
    WLIFollowingsViewController *followingsViewController = [[WLIFollowingsViewController alloc] initWithNibName:@"WLIFollowingsViewController" bundle:nil];
    UINavigationController *followingNavigationController = [[UINavigationController alloc] initWithRootViewController:followingsViewController];
    followingNavigationController.navigationBar.translucent = NO;
    
    WLIMyDriveViewController *myDriveViewController = [[WLIMyDriveViewController alloc] initWithNibName:@"WLIMyDriveViewController" bundle:nil];
    UINavigationController *myDriveNavigationController = [[UINavigationController alloc] initWithRootViewController:myDriveViewController];
    myDriveNavigationController.navigationBar.translucent = NO;
    
    self.tabBarController = [[WLITabBarController alloc] init];
    self.tabBarController.delegate = self;
    self.tabBarController.viewControllers = @[infoPageNavigationController, timelineNavigationController, newPostNavigationController, followingNavigationController, myDriveNavigationController];
    
    UITabBarItem *infoPageTabBarItem = [[UITabBarItem alloc] initWithTitle:@"20by2020" image:[[UIImage imageNamed:@"tabbar-20-h"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tabbar-20"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    infoPageViewController.tabBarItem = infoPageTabBarItem;

    UITabBarItem *timelineTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Timeline" image:[[UIImage imageNamed:@"tabbar-timeline-h"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tabbar-timeline"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    timelineViewController.tabBarItem = timelineTabBarItem;

    UITabBarItem *newPostTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Add Energy" image:[[UIImage imageNamed:@"tabbar-newpost-h"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tabbar-newpost"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    newPostViewController.tabBarItem = newPostTabBarItem;
    
    UITabBarItem *followingTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Connect" image:[[UIImage imageNamed:@"tabbar-following-h"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tabbar-following"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    followingNavigationController.tabBarItem = followingTabBarItem;

    UITabBarItem *myDriveTabBarItem = [[UITabBarItem alloc] initWithTitle:@"MyDrive" image:[[UIImage imageNamed:@"tabbar-mydrive-h"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tabbar-mydrive"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    myDriveViewController.tabBarItem = myDriveTabBarItem;
    
    self.window.rootViewController = self.tabBarController;
}

@end
