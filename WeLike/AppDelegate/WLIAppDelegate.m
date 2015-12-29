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
		[WLIAnalytics eventAutoLoginWithUser:[WLIConnect sharedConnect].currentUser];
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
		[WLIAnalytics eventAutoLoginWithUser:[WLIConnect sharedConnect].currentUser];
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

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if ([self.tabBarController.presentedViewController isKindOfClass:[MPMoviePlayerViewController class]]) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return UIInterfaceOrientationMaskPortrait;
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
    } else if ([navigationViewController.topViewController isKindOfClass:[WLITimelineViewController class]]) {
        if (navigationViewController.viewControllers.count == 1) {
            [self.timelineViewController scrollToTop];
        }
        return YES;
    }
    return YES;
}

#pragma mark - Other methods

- (void)createViewHierarchy
{   
    self.tabBarController = [[WLITabBarController alloc] init];
    self.tabBarController.delegate = self;
    self.timelineViewController = (id)((UINavigationController *)[self.tabBarController.viewControllers objectAtIndex:1]).topViewController;
    
    self.window.rootViewController = self.tabBarController;
}

@end
