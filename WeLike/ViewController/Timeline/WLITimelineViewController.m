//
//  WLITimelineViewController.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLITimelineViewController.h"
#import "GlobalDefines.h"

@interface WLITimelineViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filterSegmentTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *filterContainer;
@property (assign, nonatomic) CGPoint prevOffset;

@property (assign, nonatomic) NSInteger countryId;

@end

@implementation WLITimelineViewController

#pragma mark - Object Lifecycle

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.searchString = @"";
    }
    return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Timeline";
    self.prevOffset = CGPointZero;
    self.countryId = 0;
}

#pragma mark - Data loading methods

- (void)reloadData:(BOOL)reloadAll
{    
    loading = YES;
    NSUInteger page;
    if (reloadAll) {
        loadMore = YES;
        page = 1;
    } else {
        page = (self.posts.count / kDefaultPageSize) + 1;
    }
    
    __weak typeof(self) weakSelf = self;
    [sharedConnect timelineForUserID:sharedConnect.currentUser.userID withCategory:0 countryID:self.countryId searchString:self.searchString page:(int)page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *posts, ServerResponse serverResponseCode) {
        loading = NO;
        if (serverResponseCode == OK) {
            if (reloadAll) {
                [weakSelf.posts removeAllObjects];
                [weakSelf.tableViewRefresh setContentOffset:CGPointZero];
            }
            [weakSelf.posts addObjectsFromArray:posts];
        }
        loadMore = (posts.count == kDefaultPageSize);
        [weakSelf.tableViewRefresh reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationAutomatic];
        [refreshManager tableViewReloadFinishedAnimated:YES];
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y >= 0) {
        if (self.prevOffset.y + 10 < scrollView.contentOffset.y) {
            [self showSegmentView:NO];
        } else if (self.prevOffset.y > scrollView.contentOffset.y + 10) {
            [self showSegmentView:YES];
        }
        self.prevOffset = scrollView.contentOffset;
    }
}

#pragma mark - Animation

- (void)showSegmentView:(BOOL)show
{
    CGFloat constant = -CGRectGetHeight(self.filterContainer.frame);
    if (show) {
        constant = 0;
    }
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.15 animations:^{
        weakSelf.filterSegmentTopConstraint.constant = constant;
        [weakSelf.view layoutIfNeeded];
    }];
}

#pragma mark - Segment

- (IBAction)segmentValueChanged:(UISegmentedControl *)sender
{
    self.countryId = sender.selectedSegmentIndex;
    [self reloadData:YES];
}

@end
