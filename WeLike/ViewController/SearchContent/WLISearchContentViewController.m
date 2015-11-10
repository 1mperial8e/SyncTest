//
//  WLISearchContentViewController.m
//  MyDrive
//
//  Created by Geir Eliassen on 19/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLISearchContentViewController.h"

// Cells
#import "WLIHashtagTableViewCell.h"
#import "WLILoadingCell.h"

// Models
#import "WLIHashtag.h"
#import "WLIAppDelegate.h"

@interface WLISearchContentViewController () <UISearchBarDelegate, WLIHashtagTableViewCellDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableViewRefresh;

@property (strong, nonatomic) NSArray *hashtags;

@end

@implementation WLISearchContentViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableViewRefresh registerNib:WLIHashtagTableViewCell.nib forCellReuseIdentifier:WLIHashtagTableViewCell.ID];
    
    self.navigationItem.title = @"Search";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonAction:)];
    [self reloadData:YES];
}

#pragma mark - Actions

- (void)cancelButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WLIHashtagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:WLIHashtagTableViewCell.ID forIndexPath:indexPath];
    cell.hashtag = self.hashtags[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    return self.hashtags.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WLIHashtag *hashtag = self.hashtags[indexPath.row];
    [self showResultForHashtag:hashtag];
}

#pragma mark - Data loading methods

- (void)reloadData:(BOOL)reloadAll
{
    __weak typeof(self) weakSelf = self;
    [sharedConnect hashtagsInSearch:@"" pageSize:50 onCompletion:^(NSMutableArray *hashtags, ServerResponse serverResponseCode) {
        loading = NO;
        weakSelf.hashtags = hashtags;
        [weakSelf.tableViewRefresh reloadData];
        [refreshManager tableViewReloadFinishedAnimated:YES];
    }];
}

- (void)searchString:(NSString*)searchString
{
    __weak typeof(self) weakSelf = self;
    [sharedConnect hashtagsInSearch:searchString pageSize:50 onCompletion:^(NSMutableArray *hashtags, ServerResponse serverResponseCode) {
        loading = NO;
        weakSelf.hashtags = hashtags;
        [weakSelf.tableViewRefresh reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [refreshManager tableViewReloadFinishedAnimated:YES];
    }];
}

- (void)hashTagClicked:(WLIHashtag *)hashtag sender:(id)senderCell
{
    [self.tableViewRefresh endEditing:YES];
    [self showResultForHashtag:hashtag];
}

- (void)showResultForHashtag:(WLIHashtag *)hashtag
{
    [self dismissViewControllerAnimated:YES completion:nil];
    WLIAppDelegate *appDelegate = (WLIAppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.timelineViewController.searchString = hashtag.tagname;
    [appDelegate.timelineViewController reloadData:YES];
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
    [self dismissViewControllerAnimated:YES completion:nil];
    WLIAppDelegate *appDelegate = (WLIAppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.timelineViewController.searchString = searchBar.text;
    [appDelegate.timelineViewController reloadData:YES];
    appDelegate.tabBarController.selectedIndex = 1;
}

@end
