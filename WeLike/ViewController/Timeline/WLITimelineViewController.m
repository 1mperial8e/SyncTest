//
//  WLITimelineViewController.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLITimelineViewController.h"
#import "WLITimelineSettingsViewController.h"

@interface WLITimelineViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *filterSegmentTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *filterContainer;
@property (assign, nonatomic) CGPoint prevOffset;

@property (assign, nonatomic) NSInteger countryId;

@end

@implementation WLITimelineViewController

#pragma mark - Init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.searchString = @"";
        self.navigationItem.title = @"Timeline";
        self.prevOffset = CGPointZero;
        self.countryId = 0;
    }
    return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.searchString.length)  {
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav-btn-search"] style:UIBarButtonItemStylePlain target:self action:@selector(searchButtonAction:)];
		
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav-btn-edit"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonAction:)];
	}
}

#pragma mark - Data loading methods

- (void)reloadData:(BOOL)reloadAll
{
    if (reloadAll) {
        [self.loadTimelineOperation cancel];
    }
    loading = YES;
    if (reloadAll) {
        loadMore = YES;
    }
    NSUInteger page = reloadAll ? 1 : (self.posts.count / kDefaultPageSize) + 1;
    __weak typeof(self) weakSelf = self;
    self.loadTimelineOperation = [sharedConnect timelineForUserID:sharedConnect.currentUser.userID withCategory:15 countryID:self.countryId searchString:self.searchString page:(int)page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *posts, ServerResponse serverResponseCode) {
        [weakSelf downloadedPosts:posts serverResponse:serverResponseCode reloadAll:reloadAll];
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super scrollViewDidScroll:scrollView];
    if (scrollView.contentOffset.y >= 0) {
        if (self.prevOffset.y + 10 < scrollView.contentOffset.y) {
            [self showSegmentView:NO];
        } else if (self.prevOffset.y > scrollView.contentOffset.y + 10) {
            [self showSegmentView:YES];
        }
        self.prevOffset = scrollView.contentOffset;
    }
}

#pragma mark - Actions

- (void)settingsButtonAction:(id)sender
{
	WLITimelineSettingsViewController *settingsViewController = [WLITimelineSettingsViewController new];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
	navController.navigationBar.backgroundColor = [UIColor redColor];
    [[WLIUtils rootController] presentViewController:navController animated:YES completion:nil];
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
    self.countryId = sender.selectedSegmentIndex + 1;
    [self reloadData:YES];
}

#pragma mark - Public

- (void)scrollToTop
{
    [self.tableViewRefresh setContentOffset:CGPointZero animated:YES];
}

@end
