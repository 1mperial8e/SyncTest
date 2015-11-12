//
//  WLIAppDelegate.h
//  WeLike
//
//  Created by Planet 1107 on 9/20/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLITabBarController.h"
#import "WLITimelineViewController.h"

@interface WLIAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) WLITabBarController *tabBarController;
@property (strong, nonatomic) WLITimelineViewController *timelineViewController;
@property (strong, nonatomic) NSTimer *timer;

- (void)createViewHierarchy;

@end
