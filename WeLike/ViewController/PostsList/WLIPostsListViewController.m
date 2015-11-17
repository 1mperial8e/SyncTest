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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav-btn-search"] style:UIBarButtonItemStylePlain target:self action:@selector(searchButtonAction:)];

    [self reloadData:YES];
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
    loading = YES;
    if (reloadAll && !loadMore) {
        loadMore = YES;
        [self.tableViewRefresh insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:self.postsSectionNumber + 1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    NSUInteger page = reloadAll ? 1 : (self.posts.count / kDefaultPageSize) + 1;
    __weak typeof(self) weakSelf = self;
    [sharedConnect timelineForUserID:sharedConnect.currentUser.userID page:page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *posts, ServerResponse serverResponseCode) {
        [weakSelf downloadedPosts:posts serverResponse:serverResponseCode reloadAll:reloadAll];
    }];
}

#pragma mark - TableViewUpdating

- (void)downloadedPosts:(NSArray *)posts serverResponse:(ServerResponse)serverResponseCode reloadAll:(BOOL)reloadAll
{
    if (serverResponseCode == OK) {
        if (reloadAll && self.posts.count) {
            [self removePosts:self.posts];
        }
        [self addPosts:posts];
    }
    loadMore = posts.count == kDefaultPageSize;
    if (!loadMore) {
        [self.tableViewRefresh deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:self.postsSectionNumber + 1]] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    [self.tableViewRefresh beginUpdates];
    [self.tableViewRefresh deleteRowsAtIndexPaths:oldIdPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableViewRefresh endUpdates];
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
        return loadMore;
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
    cell.showDeleteButton = YES;
    cell.post = self.posts[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == self.postsSectionNumber) {
        return [WLIPostCell sizeWithPost:self.posts[indexPath.row] withWidth:self.view.frame.size.width].height;
    } else {
        return 44;
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

- (void)toggleLikeForPost:(WLIPost*)post sender:(WLIPostCell*)senderCell
{
    if (post.likedThisPost) {
        [sharedConnect removeLikeWithLikeID:post.postID onCompletion:^(ServerResponse serverResponseCode) {
            if (serverResponseCode == OK) {
                senderCell.buttonLike.selected = NO;
                post.postLikesCount--;
                post.likedThisPost = NO;
                if (post.postLikesCount == 0) {
                    senderCell.labelLikes.hidden = YES;
                }
                senderCell.labelLikes.text = [NSString stringWithFormat:@"%zd", post.postLikesCount];
            }
        }];
    } else {
        [sharedConnect setLikeOnPostID:post.postID onCompletion:^(WLILike *like, ServerResponse serverResponseCode) {
            if (serverResponseCode == OK) {
                senderCell.buttonLike.selected = YES;
                post.postLikesCount++;
                post.likedThisPost = YES;
                if (post.postLikesCount > 0) {
                    senderCell.labelLikes.hidden = NO;
                }
                senderCell.labelLikes.text = [NSString stringWithFormat:@"%zd", post.postLikesCount];
            }
        }];
    }
}

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
    __block NSIndexPath *indexPath = [self.tableViewRefresh indexPathForCell:cell];
    __weak typeof(self) weakSelf = self;
    void (^followUserCompletion)(WLIFollow *, ServerResponse) = ^(WLIFollow *wliFollow, ServerResponse serverResponseCode) {
        if (serverResponseCode == OK) {
            user.followingUser = follow;
            cell.post.user = user;
            if (indexPath) {
                [weakSelf.tableViewRefresh reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
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
