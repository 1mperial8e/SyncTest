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
#import "WLICountryFilterTableViewCell.h"

@interface WLICategoryPostsViewController ()

@property (assign, nonatomic) NSInteger selectedCountry;

@end

@implementation WLICategoryPostsViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectedCountry = 0;
    
    [self.tableViewRefresh registerNib:WLICountryFilterTableViewCell.nib forCellReuseIdentifier:WLICountryFilterTableViewCell.ID];
    [self reloadData:YES];
}

#pragma mark - Data loading methods

- (void)reloadData:(BOOL)reloadAll
{
    loading = YES;
    NSUInteger page = reloadAll ? 2 : (self.posts.count / kDefaultPageSize) + 1;
    __weak typeof(self) weakSelf = self;
    [sharedConnect timelineForUserID:sharedConnect.currentUser.userID withCategory:self.categoryID countryID:self.selectedCountry searchString:@"" page:(int)page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *posts, ServerResponse serverResponseCode) {
        loading = NO;
        if (reloadAll) {
            [weakSelf.posts removeAllObjects];
        }
        [weakSelf.posts addObjectsFromArray:posts];
        loadMore = posts.count == kDefaultPageSize;
        [weakSelf.tableViewRefresh reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationAutomatic];
        [refreshManager tableViewReloadFinishedAnimated:YES];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return self.posts.count;
    } else {
        return loadMore;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            id cell;
            static NSString *CellIdentifier;
            switch (_categoryID) {
                case 1:
                    CellIdentifier = @"WLICategoryMarketCell";
                    break;
                    
                case 2:
                    CellIdentifier = @"WLICategoryCapabilitiesCell";
                    break;
                    
                case 4:
                    CellIdentifier = @"WLICategoryCustomerCell";
                    break;
                    
                case 8:
                    CellIdentifier = @"WLICategoryPeopleCell";
                    break;
                    
                default:
                    CellIdentifier = @"WLILoadingCell";
                    break;
            }
            cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] lastObject];
            }
            return cell;

        } else {
            WLICountryFilterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:WLICountryFilterTableViewCell.ID forIndexPath:indexPath];
            __weak typeof(self) weakSelf = self;
            cell.countrySelectedHandler = ^(NSInteger country) {
                weakSelf.selectedCountry = country;
                [weakSelf reloadData:YES];
            };
            cell.segmentControl.selectedSegmentIndex = self.selectedCountry;
            return cell;
        }
    } else if (indexPath.section == 1) {
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

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return indexPath.row ? 50 : 125;
    } else if (indexPath.section == 1) {
        return [WLIPostCell sizeWithPost:self.posts[indexPath.row]  withWidth:self.view.frame.size.width].height;
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && loadMore && !loading) {
        [self reloadData:NO];
    }
}

@end
