//
//  WLICategoryPostsViewController.m
//  MyDrive
//
//  Created by Geir Eliassen on 29/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLICategoryPostsViewController.h"
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


#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withTitle:(NSString*)myTitle {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = myTitle;
        self.selectedCountry = 0;
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
    [sharedConnect timelineForUserID:sharedConnect.currentUser.userID withCategory:[[NSNumber numberWithInteger:_categoryID] intValue] countryID:self.selectedCountry searchString:@"" page:(int)page pageSize:kDefaultPageSize onCompletion:^(NSMutableArray *posts, ServerResponse serverResponseCode) {
        loading = NO;
        if (reloadAll) {
            [self.posts removeAllObjects];
        }
        [self.posts addObjectsFromArray:posts];
        loadMore = posts.count == kDefaultPageSize;
        [self.tableViewRefresh reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 4)] withRowAnimation:UITableViewRowAnimationAutomatic];
        [refreshManager tableViewReloadFinishedAnimated:YES];
    }];
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 1) {
        return 2;
    } else if (section == 2) {
        return self.posts.count;
    } else {
        return loadMore;
    }
}


#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        return indexPath.row ? 50 : 125;
    } else if (indexPath.section == 2) {
        return [WLIPostCell sizeWithPost:self.posts[indexPath.row]  withWidth:self.view.frame.size.width].height;
    } else if (indexPath.section == 0){
        return 0; //44 * loading * self.posts.count == 0;
    } else {
        return 44 * loadMore;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 3 && loadMore && !loading) {
        [self reloadData:NO];
    }
}

- (void)deletePost:(WLIPost *)post sender:(id)senderCell {
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Delete post" message:@"Are you sure you want to delete this post" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
    deleteButtonIndex = [alert addButtonWithTitle:@"Yes"];
    [alert show];
    
    
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == deleteButtonIndex) {
        [sharedConnect deletePostID:morePost.postID onCompletion:^(ServerResponse serverResponseCode) {
            if (serverResponseCode == OK)
            {
                [self.posts removeObject:morePost];
                [self.tableViewRefresh reloadData];
            }
            else
            {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Delete post" message:@"An error occoured when deleting!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }];
    }
}
- (void)showMoreForPost:(WLIPost*)post sender:(id)senderCell
{
    morePost = post;
    [[[UIActionSheet alloc] initWithTitle:post.postTitle delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Delete post", nil] showInView:self.view];
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete post"]) {
        // Delete
        [self deletePost:morePost sender:self];
        
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Share"]) {
        [self showShareForPost:morePost sender:self];
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableViewRefresh registerNib:WLICountryFilterTableViewCell.nib forCellReuseIdentifier:WLICountryFilterTableViewCell.ID];
    [self reloadData:YES];
}

@end
