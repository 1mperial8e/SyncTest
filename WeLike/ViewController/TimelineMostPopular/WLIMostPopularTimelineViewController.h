//
//  WLIMostPopularTimelineViewController.h
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIPostsListViewController.h"

@interface WLIMostPopularTimelineViewController : WLIPostsListViewController

@property (strong, nonatomic) NSString *searchString;

- (void)scrollToTop;

@end
