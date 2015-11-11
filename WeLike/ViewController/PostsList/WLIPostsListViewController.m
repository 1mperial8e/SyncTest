//
//  WLIPostsListViewController.m
//  MyDrive
//
//  Created by Geir Eliassen on 19/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIPostsListViewController.h"
#import "WLIPostCell.h"
#import "WLILoadingCell.h"
#import "GlobalDefines.h"
#import "WLISearchContentViewController.h"
#import "WLICategoryPostsViewController.h"


@interface WLIPostsListViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation WLIPostsListViewController


#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Timeline";
        self.posts = [NSMutableArray array];
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.adjustsImageWhenHighlighted = NO;
    backButton.frame = CGRectMake(0.0f, 0.0f, 40.0f, 30.0f);
    [backButton setImage:[UIImage imageNamed:@"nav-btn-search"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(searchButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];

    [self reloadData:YES];
}

-(IBAction)profileButtonTouchUpInside:(id)sender
{
//    WLIProfileViewController *profileViewController = [[WLIProfileViewController alloc] initWithNibName:@"WLIProfileViewController" bundle:nil];
//    UINavigationController *profileNavigationController = [[UINavigationController alloc] initWithRootViewController:profileViewController];
////    profileNavigationController.navigationBar.translucent = NO;
//    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:profileNavigationController animated:YES completion:nil];
}
-(IBAction)searchButtonTouchUpInside:(id)sender
{
    WLISearchContentViewController *searchViewController = [[WLISearchContentViewController alloc] initWithNibName:@"WLISearchContentViewController" bundle:nil];
    UINavigationController *searchNavigationController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    //    profileNavigationController.navigationBar.translucent = NO;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:searchNavigationController animated:YES completion:nil];
}

#pragma mark - Data loading methods

- (void)reloadData:(BOOL)reloadAll {
    
    loading = YES;
    NSUInteger page;
    if (reloadAll) {
        loadMore = YES;
        page = 1;
    } else {
        page  = (self.posts.count / kDefaultPageSize) + 1;
    }
    [sharedConnect timelineForUserID:sharedConnect.currentUser.userID page:(int)page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *posts, ServerResponse serverResponseCode) {
        loading = NO;
        if (reloadAll) {
            [self.posts removeAllObjects];
        }
        [self.posts addObjectsFromArray:posts];
        loadMore = posts.count == kDefaultPageSize;
        [self.tableViewRefresh reloadData];
        [refreshManager tableViewReloadFinishedAnimated:YES];
    }];
}


#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1){
        static NSString *CellIdentifier = @"WLIPostCell";
        WLIPostCell *cell = (WLIPostCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WLIPostCell" owner:self options:nil] lastObject];
            cell.delegate = self;
        }
        cell.post = self.posts[indexPath.row];
        return cell;
    } else {
        static NSString *CellIdentifier = @"WLILoadingCell";
        WLILoadingCell *cell = (WLILoadingCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WLILoadingCell" owner:self options:nil] lastObject];
        }
        [cell.refreshControl startAnimating];
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 1) {
        return self.posts.count;
    } else if (section == 2) {
        return loadMore;
    }
    return 0;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return [WLIPostCell sizeWithPost:self.posts[indexPath.row] withWidth:self.view.frame.size.width].height;
    } else if (indexPath.section == 0){
        return 0; //44 * loading * self.posts.count == 0;
    } else {
        return 44 * loadMore;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2 && loadMore && !loading) {
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
        [[WLIConnect sharedConnect] removeLikeWithLikeID:post.postID onCompletion:^(ServerResponse serverResponseCode) {
            if (serverResponseCode == OK) {
                senderCell.buttonLike.selected = NO;
                post.postLikesCount--;
                post.likedThisPost = NO;
                if (post.postLikesCount == 0) {
                    senderCell.labelLikes.hidden = YES;
                }
                senderCell.labelLikes.text = [NSString stringWithFormat:@"%d", post.postLikesCount];
            }
        }];
    } else {
        [[WLIConnect sharedConnect] setLikeOnPostID:post.postID onCompletion:^(WLILike *like, ServerResponse serverResponseCode) {
            if (serverResponseCode == OK) {
                senderCell.buttonLike.selected = YES;
                post.postLikesCount++;
                post.likedThisPost = YES;
                if (post.postLikesCount > 0) {
                    senderCell.labelLikes.hidden = NO;
                }
                senderCell.labelLikes.text = [NSString stringWithFormat:@"%d", post.postLikesCount];
            }
        }];
    }
}



- (void)showShareForPost:(WLIPost*)post sender:(id)senderCell
{
    
}
- (void)showDeleteForPost:(WLIPost*)post sender:(id)senderCell
{
    
}
- (void)showConnectForPost:(WLIPost*)post sender:(id)senderCell
{
    WLIConnect *sConnect = [WLIConnect sharedConnect];
    UIButton *btn = (UIButton *)senderCell;
    if ( btn.selected )
    {
        NSLog(@"Disconnecting");
        [sConnect removeFollowWithFollowID:post.user.userID onCompletion:^(ServerResponse serverResponseCode) {
            if (serverResponseCode == OK)
            {
                NSLog(@"Disconnected");
                [btn setSelected:NO];
            }
        }];
    }
    else
    {
        NSLog(@"Connecting");
        [sConnect setFollowOnUserID:post.user.userID onCompletion:^(WLIFollow *follow, ServerResponse serverResponseCode) {
            if (serverResponseCode == OK)
            {
                NSLog(@"Connected");
                [btn setSelected:YES];
            }
        }];
    }
    
}


- (void)showCatMarketForPost:(WLIPost*)post sender:(id)senderCell
{
    WLICategoryPostsViewController *categoryViewController = [[WLICategoryPostsViewController alloc] initWithNibName:@"WLICategoryPostsViewController" bundle:nil withTitle:@"Market"];
    categoryViewController.categoryID = 1;
    [self.navigationController pushViewController:categoryViewController animated:YES];
}
- (void)showCatCustomersForPost:(WLIPost*)post sender:(id)senderCell
{
    WLICategoryPostsViewController *categoryViewController = [[WLICategoryPostsViewController alloc] initWithNibName:@"WLICategoryPostsViewController" bundle:nil withTitle:@"Customer"];
    categoryViewController.categoryID = 4;
    [self.navigationController pushViewController:categoryViewController animated:YES];
}
- (void)showCatCapabilitiesForPost:(WLIPost*)post sender:(id)senderCell
{
    WLICategoryPostsViewController *categoryViewController = [[WLICategoryPostsViewController alloc] initWithNibName:@"WLICategoryPostsViewController" bundle:nil withTitle:@"Capabilities"];
    categoryViewController.categoryID = 2;
    [self.navigationController pushViewController:categoryViewController animated:YES];
}
- (void)showCatPeopleForPost:(WLIPost*)post sender:(id)senderCell
{
    WLICategoryPostsViewController *categoryViewController = [[WLICategoryPostsViewController alloc] initWithNibName:@"WLICategoryPostsViewController" bundle:nil withTitle:@"People"];
    categoryViewController.categoryID = 8;
    [self.navigationController pushViewController:categoryViewController animated:YES];
}

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
