//
//  WLICategoryPostsViewController.m
//  MyDrive
//
//  Created by Geir Eliassen on 29/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLICategoryPostsViewController.h"

// Cells
#import "WLICategoryMarketCell.h"
#import "WLICategoryCustomerCell.h"
#import "WLICategoryCapabilitiesCell.h"
#import "WLICategoryPeopleCell.h"
#import "WLIPostCell.h"
#import "WLILoadingCell.h"
#import "WLICountrySettings.h"

@interface WLICategoryPostsViewController ()

@end

@implementation WLICategoryPostsViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.postsSectionNumber = 1;
    
    [super viewDidLoad];
	
    [self.tableViewRefresh registerNib:WLICategoryMarketCell.nib forCellReuseIdentifier:WLICategoryMarketCell.ID];
    [self.tableViewRefresh registerNib:WLICategoryCustomerCell.nib forCellReuseIdentifier:WLICategoryCustomerCell.ID];
    [self.tableViewRefresh registerNib:WLICategoryCapabilitiesCell.nib forCellReuseIdentifier:WLICategoryCapabilitiesCell.ID];
    [self.tableViewRefresh registerNib:WLICategoryPeopleCell.nib forCellReuseIdentifier:WLICategoryPeopleCell.ID];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChangedNotificationRecieved:) name:CountriesFilterSettingsChangeNotification object:nil];
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
	NSString *countriesStringId = [[WLICountrySettings sharedSource] getEnabledCountriesStringID];
    self.loadTimelineOperation = [sharedConnect timelineForUserID:sharedConnect.currentUser.userID withCategory:self.categoryID countryID:countriesStringId searchString:@"" page:(int)page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *posts, ServerResponse serverResponseCode) {
        [weakSelf downloadedPosts:posts serverResponse:serverResponseCode reloadAll:reloadAll];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 1) {
        return self.posts.count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            NSString *cellID = [self categoryCellID];;
            cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
        }
    } else if (indexPath.section == 1) {
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
    cell.showDeleteButton = NO;
    cell.post = self.posts[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return indexPath.row ? 50 : 125;
    } else if (indexPath.section == 1) {
        return [WLIPostCell sizeWithPost:self.posts[indexPath.row]  withWidth:self.view.frame.size.width].height;
    } else {
        return loadMore ? 44 : 0;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && loadMore && !loading) {
        [self reloadData:NO];
    }
}

#pragma mark - Private

- (NSString *)categoryCellID
{
    NSString *cellID;
    switch (self.categoryID) {
        case 1:
            cellID = WLICategoryMarketCell.ID;
            break;
        case 2:
            cellID = WLICategoryCapabilitiesCell.ID;
            break;
        case 4:
            cellID = WLICategoryCustomerCell.ID;
            break;
        case 8:
            cellID = WLICategoryPeopleCell.ID;
            break;
        default:
            cellID = WLICategoryMarketCell.ID;
            break;
    }
    return cellID;
}

#pragma mark - Notification

- (void) settingsChangedNotificationRecieved:(NSNotification *)notification
{
	[self reloadData:YES];
}

@end
