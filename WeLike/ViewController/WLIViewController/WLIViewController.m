//
//  WLIViewController.m
//  WeLike
//
//  Created by Planet 1107 on 9/30/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIViewController.h"
#import "WLICommentsViewController.h"
#import "WLIPostViewController.h"

@interface WLIViewController ()

@property (strong, nonatomic) NSIndexPath *indexPathToReload;
@property (strong, nonatomic) UITableView *tableViewRefresh;

@end

@implementation WLIViewController

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        sharedConnect = [WLIConnect sharedConnect];
        toolbar = [PNTToolbar defaultToolbar];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self conformsToProtocol:@protocol(WLIViewControllerRefreshProtocol)]) {
        id<WLIViewControllerRefreshProtocol> objectConformsToProtocol = (id<WLIViewControllerRefreshProtocol>)self;
        refreshManager = [[MNMPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:objectConformsToProtocol.tableViewRefresh withClient:self];
    }
    loadMore = YES;
    
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav-btn-back"] style:UIBarButtonItemStylePlain target:self action:@selector(barButtonItemBackTouchUpInside:)];
    } else if (self.presentingViewController) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav-btn-close"] style:UIBarButtonItemStylePlain target:self action:@selector(barButtonItemCancelTouchUpInside:)];
    }
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.indexPathToReload) {
        [self.tableViewRefresh reloadRowsAtIndexPaths:@[self.indexPathToReload] withRowAnimation:UITableViewRowAnimationAutomatic];
        self.indexPathToReload = nil;
    }
}

#pragma mark - Actions methods

- (void)barButtonItemBackTouchUpInside:(UIButton*)backButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)barButtonItemCancelTouchUpInside:(UIButton*)backButton
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - WLIPostCellDelegate methods

- (void)showImageForPost:(WLIPost*)post sender:(WLIPostCell*)senderCell
{
    if (![self isMemberOfClass:[WLIPostViewController class]]) {
        self.indexPathToReload = [self.tableViewRefresh indexPathForCell:senderCell];
        WLIPostViewController *postViewController = [WLIPostViewController new];
        postViewController.post = post;
        [self.navigationController pushViewController:postViewController animated:YES];
    }
}

- (void)showCommentsForPost:(WLIPost*)post sender:(WLIPostCell*)senderCell
{
    self.indexPathToReload = [self.tableViewRefresh indexPathForCell:senderCell];
    WLICommentsViewController *commentsViewController = [WLICommentsViewController new];
    commentsViewController.post = post;
    [self.navigationController pushViewController:commentsViewController animated:YES];
}

#pragma mark - MNMPullToRefreshClient methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [refreshManager tableViewScrolled];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [refreshManager tableViewReleased];
}

- (void)pullToRefreshTriggered:(MNMPullToRefreshManager *)manager
{
    if (!loading) {
        id<WLIViewControllerRefreshProtocol> objectConformsToProtocol = (id<WLIViewControllerRefreshProtocol>)self;
        [objectConformsToProtocol reloadData:YES];
    } else {
        [refreshManager tableViewReloadFinishedAnimated:YES];
    }
}

@end
