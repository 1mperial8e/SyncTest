//
//  WLIPostsListViewController.m
//  MyDrive
//
//  Created by Geir Eliassen on 19/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

// Controllers
#import "WLIPostsListViewController.h"
#import "WLISearchContentViewController.h"
#import "WLICategoryPostsViewController.h"
#import "WLITimelineViewController.h"

// Cells
#import "WLIPostCell.h"
#import "WLILoadingCell.h"

@interface WLIPostsListViewController ()

@end

@implementation WLIPostsListViewController

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Timeline";
        self.posts = [NSMutableArray array];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{    
    [super viewDidLoad];
    
    [self.tableViewRefresh registerNib:WLIPostCell.nib forCellReuseIdentifier:WLIPostCell.ID];
    [self.tableViewRefresh registerNib:WLILoadingCell.nib forCellReuseIdentifier:WLILoadingCell.ID];

    [self reloadData:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followedUserNotification:) name:FollowerUserNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications

- (void)followedUserNotification:(NSNotification *)notification
{
    NSMutableArray *idPaths = [NSMutableArray array];
    NSInteger userId = [notification.userInfo[@"userId"] integerValue];
    BOOL followed = [notification.userInfo[@"followed"]  boolValue];
    for (int i = 0; i < self.posts.count; i++) {
        WLIPost *post = self.posts[i];
        if (post.user.userID == userId) {
            [idPaths addObject:[NSIndexPath indexPathForItem:i inSection:self.postsSectionNumber]];
            post.user.followingUser = followed;
        }
    }
    
    if (idPaths.count) {
        [self.tableViewRefresh beginUpdates];
        [self.tableViewRefresh reloadRowsAtIndexPaths:idPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableViewRefresh endUpdates];
    }
}

#pragma mark - Actions

- (void)searchButtonAction:(id)sender
{
    WLISearchContentViewController *searchViewController = [WLISearchContentViewController new];
    UINavigationController *searchNavigationController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:searchNavigationController animated:YES completion:nil];
}

#pragma mark - Data loading methods

- (void)reloadData:(BOOL)reloadAll
{
    if (reloadAll) {
        loadMore = YES;
        [self.loadTimelineOperation cancel];
    }
    loading = YES;
    NSUInteger page = reloadAll ? 1 : (self.posts.count / kDefaultPageSize) + 1;
    __weak typeof(self) weakSelf = self;
    self.loadTimelineOperation = [sharedConnect timelineForUserID:sharedConnect.currentUser.userID page:page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *posts, ServerResponse serverResponseCode) {
        [weakSelf downloadedPosts:posts serverResponse:serverResponseCode reloadAll:reloadAll];
    }];
}

#pragma mark - TableViewUpdating

- (void)downloadedPosts:(NSArray *)posts serverResponse:(ServerResponse)serverResponseCode reloadAll:(BOOL)reloadAll
{
    loadMore = posts.count == kDefaultPageSize;
    if (serverResponseCode == OK) {
        if (reloadAll && self.posts.count) {
            [self removePosts:self.posts];
        }
        [self addPosts:posts];
    }
    if (self.posts.count) {
        self.tableViewRefresh.backgroundColor = [UIColor whiteColor];
    } else {
        if (serverResponseCode == OK) {
            self.messageLabel.text = @"No posts found.";
        } else {
            self.messageLabel.text = @"Oops… It seems that there aren't any posts or Internet connection is not established.\nPull down to refresh.";
        }
        self.tableViewRefresh.backgroundColor = [UIColor clearColor];
    }
    [refreshManager tableViewReloadFinishedAnimated:YES];
    loading = NO;
}

- (void)removePosts:(NSArray *)posts
{
    NSMutableArray *oldIdPaths = [NSMutableArray array];
    NSInteger index = [self.posts indexOfObject:posts.firstObject];
    for (int i = 0; i < posts.count; i++) {
        [oldIdPaths addObject:[NSIndexPath indexPathForItem:index inSection:self.postsSectionNumber]];
        index++;
    }
    [self.posts removeObjectsInArray:posts];
    [self.tableViewRefresh reloadData];
}

- (void)addPosts:(NSArray *)posts
{
    NSMutableArray *newIdPaths = [NSMutableArray array];
    NSInteger index = self.posts.count;
    for (int i = 0; i < posts.count; i++) {
        [newIdPaths addObject:[NSIndexPath indexPathForItem:index inSection:self.postsSectionNumber]];
        index++;
    }
    [self.posts addObjectsFromArray:posts];
    [self.tableViewRefresh beginUpdates];
    [self.tableViewRefresh insertRowsAtIndexPaths:newIdPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableViewRefresh endUpdates];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == self.postsSectionNumber) {
        return self.posts.count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == self.postsSectionNumber) {
        cell = [self postCellForIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:WLILoadingCell.ID forIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - Configure cells

- (UITableViewCell *)postCellForIndexPath:(NSIndexPath *)indexPath
{
    WLIPostCell *cell = [self.tableViewRefresh dequeueReusableCellWithIdentifier:WLIPostCell.ID forIndexPath:indexPath];
    cell.delegate = self;
    cell.showDeleteButton = NO;
    cell.post = self.posts[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == self.postsSectionNumber) {
        return [WLIPostCell sizeWithPost:self.posts[indexPath.row] withWidth:self.view.frame.size.width].height;
    } else {
        return loadMore ? 44 : 0;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == self.postsSectionNumber + 1 && loadMore && !loading) {
        [self reloadData:NO];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[WLIPostCell class]]) {
        WLIPostCell *postCell = (WLIPostCell *)cell;
        [postCell.imageViewPostImage cancelImageRequestOperation];
    }
}

#pragma mark - WLIPostCellDelegate methods

- (void)showCatMarketForPost:(WLIPost *)post sender:(id)senderCell
{
    WLICategoryPostsViewController *categoryViewController = [WLICategoryPostsViewController new];
    categoryViewController.title = @"Market";
    categoryViewController.categoryID = 1;
    [self.navigationController pushViewController:categoryViewController animated:YES];
}

- (void)showCatCustomersForPost:(WLIPost *)post sender:(id)senderCell
{
    WLICategoryPostsViewController *categoryViewController = [WLICategoryPostsViewController new];
    categoryViewController.title = @"Customer";
    categoryViewController.categoryID = 4;
    [self.navigationController pushViewController:categoryViewController animated:YES];
}

- (void)showCatCapabilitiesForPost:(WLIPost *)post sender:(id)senderCell
{
    WLICategoryPostsViewController *categoryViewController = [WLICategoryPostsViewController new];
    categoryViewController.title = @"Capabilities";
    categoryViewController.categoryID = 2;
    [self.navigationController pushViewController:categoryViewController animated:YES];
}

- (void)showCatPeopleForPost:(WLIPost *)post sender:(id)senderCell
{
    WLICategoryPostsViewController *categoryViewController = [WLICategoryPostsViewController new];
    categoryViewController.title = @"People";
    categoryViewController.categoryID = 8;
    [self.navigationController pushViewController:categoryViewController animated:YES];
}

- (void)showTimelineForSearchString:(NSString *)searchString
{
    WLITimelineViewController *timeline = [WLITimelineViewController new];
    timeline.searchString = searchString;
    timeline.navigationItem.title = searchString;
    [self.navigationController pushViewController:timeline animated:YES];
}

#pragma mark - Follow

- (void)followUser:(WLIUser *)user sender:(id)senderCell
{
    [self follow:YES user:user cellToReload:senderCell];
}

- (void)unfollowUser:(WLIUser *)user sender:(id)senderCell
{
    [self follow:NO user:user cellToReload:senderCell];
}

- (void)follow:(BOOL)follow user:(WLIUser *)user cellToReload:(WLIPostCell *)cell
{
    __weak typeof(cell) weakCell = cell;
	cell.buttonFollow.userInteractionEnabled = NO;
    void (^followUserCompletion)(WLIFollow *, ServerResponse) = ^(WLIFollow *wliFollow, ServerResponse serverResponseCode) {
		weakCell.buttonFollow.userInteractionEnabled = YES;
        if (serverResponseCode == OK) {
            user.followingUser = follow;
            weakCell.post.user = user;
            weakCell.buttonFollow.selected = user.followingUser;
        } else {
            NSString *message = @"An error occured, user was not followed.";
            if (!follow) {
                message = @"An error occured, user was not unfollowed.";
            }
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:message
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil]
             performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        }
    };
    if (follow) {
        [sharedConnect setFollowOnUserID:user.userID onCompletion:followUserCompletion];
    } else {
        [sharedConnect removeFollowWithFollowID:user.userID onCompletion:^(ServerResponse serverResponseCode) {
            followUserCompletion(nil, serverResponseCode);
        }];
    }
}

@end
