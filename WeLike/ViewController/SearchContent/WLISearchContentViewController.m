//
//  WLISearchContentViewController.m
//  MyDrive
//
//  Created by Geir Eliassen on 19/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLISearchContentViewController.h"

// Cells
#import "WLISearchTableViewCell.h"
#import "WLILoadingCell.h"

// Models
#import "WLIHashtag.h"
#import "WLIAppDelegate.h"

@interface WLISearchContentViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *dataSource;

@property (strong, nonatomic) AFHTTPRequestOperation *searchOperation;
@property (strong, nonatomic) NSString *searchString;
@property (strong, nonatomic) NSString *searchTerm;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@end

@implementation WLISearchContentViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = [NSMutableArray array];
    [self.tableViewRefresh registerNib:WLISearchTableViewCell.nib forCellReuseIdentifier:WLISearchTableViewCell.ID];
    [self.tableViewRefresh registerNib:WLILoadingCell.nib forCellReuseIdentifier:WLILoadingCell.ID];
    
    self.tableViewRefresh.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.searchTerm = @"mix";
    self.navigationItem.title = @"Search";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonAction:)];
    [self reloadData:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.searchOperation cancel];
    [self.tableViewRefresh endEditing:YES];
}

#pragma mark - Actions

- (void)cancelButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)segmentControlValueChanged:(id)sender
{
    if (self.segmentControl.selectedSegmentIndex == 0) {
        self.searchTerm = @"mix";
    } else if (self.segmentControl.selectedSegmentIndex == 1) {
        self.searchTerm = @"user";
    } else if (self.segmentControl.selectedSegmentIndex == 2) {
        self.searchTerm = @"hashtag";
    }
    [self reloadData:YES];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowsCount = 1;
    if (section == 0) {
        rowsCount = self.dataSource.count;
    }
    return rowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        id object = self.dataSource[indexPath.row];
        if ([object isKindOfClass:WLIHashtag.class]) {
            cell = [self hashtagCellForIndexPath:indexPath];
        } else {
            cell = [self userCellForIndexPath:indexPath];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:WLILoadingCell.ID];
    }
    return cell;
}

#pragma mark - ConfigureCells

- (WLISearchTableViewCell *)hashtagCellForIndexPath:(NSIndexPath *)indexPath
{
    WLISearchTableViewCell *cell = [self.tableViewRefresh dequeueReusableCellWithIdentifier:WLISearchTableViewCell.ID forIndexPath:indexPath];
    cell.hashtag = self.dataSource[indexPath.row];
    return cell;
}

- (WLISearchTableViewCell *)userCellForIndexPath:(NSIndexPath *)indexPath
{
    WLISearchTableViewCell *cell = [self.tableViewRefresh dequeueReusableCellWithIdentifier:WLISearchTableViewCell.ID forIndexPath:indexPath];
    cell.user = self.dataSource[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id object = self.dataSource[indexPath.row];
    if ([object isKindOfClass:WLIHashtag.class]) {
        [self showResultForHashtag:object];
    } else {
        [self showResultForUser:object];
    }
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return loadMore ? 44 : 0;
    }
    return 50;
}

#pragma mark - Data loading methods

- (void)reloadData:(BOOL)reloadAll
{
    [self.searchOperation cancel];
    loading = YES;
    if (reloadAll) {
        loadMore = YES;
    }
    NSUInteger page = reloadAll ? 1 : (self.dataSource.count / kDefaultPageSize) + 1;
    __weak typeof(self) weakSelf = self;
    self.searchOperation = [sharedConnect search:self.searchString term:self.searchTerm pageNumber:page onCompletion:^(NSMutableArray *items, ServerResponse serverResponseCode) {
        [weakSelf downloadedItems:items serverResponse:serverResponseCode reloadAll:reloadAll];
    }];
}

#pragma mark - TableView Update

- (void)removeItems:(NSArray *)items
{
    NSMutableArray *oldIdPaths = [NSMutableArray array];
    NSInteger index = [self.dataSource indexOfObject:items.firstObject];
    for (int i = 0; i < items.count; i++) {
        [oldIdPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
        index++;
    }
    [self.dataSource removeObjectsInArray:items];
    [self.tableViewRefresh beginUpdates];
    [self.tableViewRefresh deleteRowsAtIndexPaths:oldIdPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableViewRefresh endUpdates];
}

- (void)addItems:(NSArray *)items
{
    NSMutableArray *newIdPaths = [NSMutableArray array];
    NSInteger index = self.dataSource.count;
    for (int i = 0; i < items.count; i++) {
        [newIdPaths addObject:[NSIndexPath indexPathForItem:index inSection:0]];
        index++;
    }
    [self.dataSource addObjectsFromArray:items];
    [self.tableViewRefresh beginUpdates];
    [self.tableViewRefresh insertRowsAtIndexPaths:newIdPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableViewRefresh endUpdates];
}

- (void)downloadedItems:(NSArray *)items serverResponse:(ServerResponse)serverResponseCode reloadAll:(BOOL)reloadAll
{
    if (serverResponseCode == OK) {
        if (reloadAll && self.dataSource.count) {
            [self removeItems:self.dataSource];
        }
        [self addItems:items];
        loadMore = items.count == kDefaultPageSize;
        [refreshManager tableViewReloadFinishedAnimated:YES];
        loading = NO;
    }
}

#pragma mark - Logic

- (void)searchString:(NSString *)searchString
{
    self.searchString = [searchString lowercaseString];
    [self reloadData:YES];
}

- (void)showResultForHashtag:(WLIHashtag *)hashtag
{
    [self.tableViewRefresh endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    WLIAppDelegate *appDelegate = (WLIAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.tabBarController.timelineViewController showTimelineForSearchString:hashtag.tagname];
    appDelegate.tabBarController.selectedIndex = 1;
}

- (void)showResultForUser:(WLIUser *)user
{
    [self.tableViewRefresh endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    WLIAppDelegate *appDelegate = (WLIAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.tabBarController.timelineViewController showUser:user userID:user.userID sender:nil];
    appDelegate.tabBarController.selectedIndex = 1;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchString:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

@end
