//
//  WLIPeopleListViewController.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/17/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIPeopleListViewController.h"

// Cells
#import "WLIUserCell.h"
#import "WLILoadingCell.h"

@interface WLIPeopleListViewController ()

@end

@implementation WLIPeopleListViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.people = [NSMutableArray array];
    self.tableViewRefresh.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableViewRefresh registerNib:WLIUserCell.nib forCellReuseIdentifier:WLIUserCell.ID];
    [self.tableViewRefresh registerNib:WLILoadingCell.nib forCellReuseIdentifier:WLILoadingCell.ID];
    [self reloadData:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followedUserNotification:) name:FollowerUserNotification object:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if ([self.tableViewRefresh respondsToSelector:@selector(layoutMargins)]) {
        self.tableViewRefresh.layoutMargins = UIEdgeInsetsZero;
    }
    self.tableViewRefresh.separatorInset = UIEdgeInsetsZero;
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
    for (int i = 0; i < self.people.count; i++) {
        WLIUser *user = self.people[i];
        if (user.userID == userId) {
            [idPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
            user.followingUser = followed;
        }
    }
    if (idPaths.count) {
        [self.tableViewRefresh beginUpdates];
        [self.tableViewRefresh reloadRowsAtIndexPaths:idPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableViewRefresh endUpdates];
    }
}

#pragma mark - Data loading methods

- (void)reloadData:(BOOL)reloadAll
{
    NSAssert(YES, @"Override");
    // dumny
}

#pragma mark - TableView Update

- (void)removePeople:(NSArray *)people
{
    NSMutableArray *oldIdPaths = [NSMutableArray array];
    NSInteger index = [self.people indexOfObject:people.firstObject];
    for (int i = 0; i < people.count; i++) {
        [oldIdPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
        index++;
    }
    [self.people removeObjectsInArray:people];
    [self.tableViewRefresh beginUpdates];
    [self.tableViewRefresh deleteRowsAtIndexPaths:oldIdPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableViewRefresh endUpdates];
}

- (void)addPeople:(NSArray *)people
{
    NSMutableArray *newIdPaths = [NSMutableArray array];
    NSInteger index = self.people.count;
    for (int i = 0; i < people.count; i++) {
        [newIdPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
        index++;
    }
    [self.people addObjectsFromArray:people];
    [self.tableViewRefresh beginUpdates];
    [self.tableViewRefresh insertRowsAtIndexPaths:newIdPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableViewRefresh endUpdates];
}

- (void)downloadedPeople:(NSArray *)people serverResponse:(ServerResponse)serverResponseCode reloadAll:(BOOL)reloadAll
{
    if (serverResponseCode == OK) {
        if (reloadAll && self.people.count) {
            [self removePeople:self.people];
        }
        [self addPeople:people];
    }
    loadMore = people.count == kDefaultPageSize;
    if (!loadMore) {
        [self.tableViewRefresh deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [refreshManager tableViewReloadFinishedAnimated:YES];
    loading = NO;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = loadMore;
    if (section == 0) {
        rows = self.people.count;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        WLIUserCell *userCell = [tableView dequeueReusableCellWithIdentifier:WLIUserCell.ID forIndexPath:indexPath];
        userCell.delegate = self;
        userCell.user = self.people[indexPath.row];
        cell = userCell;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:WLILoadingCell.ID forIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.separatorInset = UIEdgeInsetsZero;
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    if (indexPath.section == 1 && loadMore && !loading) {
        [self reloadData:NO];
    }
}

#pragma mark - WLIUserCellDelegate

- (void)follow:(BOOL)follow user:(WLIUser *)user cellToReload:(WLIUserCell *)cell
{
    __block NSIndexPath *indexPath = [self.tableViewRefresh indexPathForCell:cell];
    __weak typeof(self) weakSelf = self;
	cell.buttonFollow.userInteractionEnabled = NO;
    void (^followUserCompletion)(WLIFollow *, ServerResponse) = ^(WLIFollow *wliFollow, ServerResponse serverResponseCode) {
		cell.buttonFollow.userInteractionEnabled = YES;
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
