//
//  WLITabBarController.h
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

@class WLITimelineViewController;

@interface WLITabBarController : UITabBarController

@property (weak, nonatomic) WLITimelineViewController *timelineViewController;

- (void)showUI;

@end
