//
//  WLIMyDriveViewController.m
//  MyDrive
//
//  Created by Geir Eliassen on 19/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIMyDriveViewController.h"
#import "WLIMyDriveHeaderCell.h"
#import "WLIPostCell.h"
#import "WLILoadingCell.h"

@interface WLIMyDriveViewController ()

@end

@implementation WLIMyDriveViewController

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"MyDrive";
//        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 105, 22)];
//        [titleView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav-title-mydrive"]]];
//        self.navigationItem.titleView = titleView;
    }
    return self;
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
    [sharedConnect mydriveTimelineForUserID:sharedConnect.currentUser.userID page:(int)page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *posts, WLIUser *user, ServerResponse serverResponseCode) {
        loading = NO;
        self.posts = posts;
        self.user = user;
        loadMore = posts.count == kDefaultPageSize;
        [self.tableViewRefresh reloadData];
        [refreshManager tableViewReloadFinishedAnimated:YES];
    }];
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1){
        static NSString *CellIdentifier = @"WLIMyDriveHeaderCell";
        WLIMyDriveHeaderCell *cell = (WLIMyDriveHeaderCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WLIMyDriveHeaderCell" owner:self options:nil] lastObject];
//            cell.delegate = self;
        }
        cell.userr = self.user;
        return cell;
    } else if (indexPath.section == 2){
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
        
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 1) {
        return 1;
    } else if (section == 2) {
            return self.posts.count;
    } else {
        if (loadMore) {
            return 1;
        } else {
            return 0;
        }
    }
}


#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        return 202;
    } else if (indexPath.section == 2) {
            return [WLIPostCell sizeWithPost:self.posts[indexPath.row]].height;
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

- (void)deletePost:(WLIPost *)post sender:(id)senderCell {

    // Husk alert her.
    [sharedConnect deletePostID:post.postID onCompletion:^(ServerResponse serverResponseCode) {
        if (serverResponseCode == OK)
        {
            [self.posts removeObject:post];
            [self.tableViewRefresh reloadData];
        }
        else
        {
            // Alert melding som forteller at noe gikk galt.
        }
    }];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
