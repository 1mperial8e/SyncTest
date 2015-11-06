//
//  WLIFollowersViewController.m
//  WeLike
//
//  Created by Planet 1107 on 03/01/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "WLIFollowersViewController.h"
#import "GlobalDefines.h"
#import "WLIUserCell.h"
#import "WLILoadingCell.h"

@implementation WLIFollowersViewController

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.followers = [NSMutableArray array];
        self.title = @"Followers";
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableViewRefresh.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self reloadData];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if ([self.tableViewRefresh respondsToSelector:@selector(layoutMargins)]) {
        self.tableViewRefresh.layoutMargins = UIEdgeInsetsZero;
    }
    self.tableViewRefresh.separatorInset = UIEdgeInsetsZero;
}

#pragma mark - Data loading methods

- (void)reloadData {
    
    loading = YES;
    NSUInteger page = (self.followers.count / kDefaultPageSize) + 1;
    [sharedConnect followersForUserID:self.user.userID page:(int)page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *followers, ServerResponse serverResponseCode) {
        loading = NO;
        [self.followers addObjectsFromArray:followers];
        loadMore = followers.count == kDefaultPageSize;
        [self.tableViewRefresh reloadData];
    }];
}


#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1){
        static NSString *CellIdentifier = @"WLIUserCell";
        WLIUserCell *cell = (WLIUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WLIUserCell" owner:self options:nil] lastObject];
            cell.delegate = self;
        }
        cell.user = self.followers[indexPath.row];
        return cell;
    } else {
        static NSString *CellIdentifier = @"WLILoadingCell";
        WLILoadingCell *cell = (WLILoadingCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WLILoadingCell" owner:self options:nil] lastObject];
        }
        
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    if (section == 1) {
        return self.followers.count;
    } else {
        if (loadMore) {
            return 1;
        } else {
            return 0;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        return 44;
    } else if (indexPath.section == 0){
        return 44 * loadMore * self.followers.count == 0;
    } else {
        return 44 * loadMore;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.separatorInset = UIEdgeInsetsZero;
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }

    if (indexPath.section == 2 && loadMore && !loading) {
        [self reloadData];
    }
}


#pragma mark - WLIUserCellDelegate

- (void)followUser:(WLIUser *)user sender:(id)senderCell
{
    [self follow:YES user:user cellToReload:senderCell];
}

- (void)unfollowUser:(WLIUser *)user sender:(id)senderCell
{
    [self follow:NO user:user cellToReload:senderCell];
}

- (void)follow:(BOOL)follow user:(WLIUser *)user cellToReload:(WLIUserCell *)cell
{
    __block NSIndexPath *indexPath = [self.tableViewRefresh indexPathForCell:cell];
    __weak typeof(self) weakSelf = self;
    void (^followUserCompletion)(WLIFollow *, ServerResponse) = ^(WLIFollow *wliFollow, ServerResponse serverResponseCode) {
        if (serverResponseCode == OK) {
            user.followingUser = follow;
            cell.user = user;
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
