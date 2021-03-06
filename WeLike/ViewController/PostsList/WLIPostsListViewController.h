//
//  WLIPostsListViewController.h
//  MyDrive
//
//  Created by Geir Eliassen on 19/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIViewController.h"

@interface WLIPostsListViewController : WLIViewController <WLIViewControllerRefreshProtocol, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate, WLICellDelegate>

@property (strong, nonatomic) NSMutableArray *posts;

@property (assign, nonatomic) NSInteger postsSectionNumber;
@property (weak, nonatomic) AFHTTPRequestOperation *loadTimelineOperation;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

- (void)removePosts:(NSArray *)posts;
- (void)addPosts:(NSArray *)posts;
- (void)downloadedPosts:(NSArray *)posts serverResponse:(ServerResponse)serverResponseCode reloadAll:(BOOL)reloadAll;
- (void)followedUserNotification:(NSNotification *)notification;
- (void)searchButtonAction:(id)sender;

@end
