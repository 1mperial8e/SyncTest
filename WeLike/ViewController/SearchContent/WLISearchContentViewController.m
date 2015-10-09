//
//  WLISearchContentViewController.m
//  MyDrive
//
//  Created by Geir Eliassen on 19/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLISearchContentViewController.h"
#import "WLIAppDelegate.h"

@interface WLISearchContentViewController ()

@end

@implementation WLISearchContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Timeline";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self reloadData:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*s
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"WLIHashtagTableViewCell";
    WLIHashtagTableViewCell *cell = (WLIHashtagTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WLIHashtagTableViewCell" owner:self options:nil] lastObject];
    }
    cell.hashtag = self.hashtags[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.hashtags.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WLIHashtag *hashtag = self.hashtags[indexPath.row];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    WLIAppDelegate *appDelegate = (WLIAppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.timelineViewController.searchString = hashtag.tagname;
    [appDelegate.timelineViewController reloadData:YES];
    appDelegate.tabBarController.selectedViewController = [appDelegate.tabBarController.viewControllers objectAtIndex:1];
}

#pragma mark - Data loading methods

- (void)reloadData:(BOOL)reloadAll {
    
    [sharedConnect hashtagsInSearch:@"" pageSize:50 onCompletion:^(NSMutableArray *hashtags, ServerResponse serverResponseCode) {
        loading = NO;
        self.hashtags = hashtags;
        [self.tableViewRefresh reloadData];
        [refreshManager tableViewReloadFinishedAnimated:YES];
    }];
}
- (void)searchString:(NSString*)searchString {
    
    [sharedConnect hashtagsInSearch:searchString pageSize:50 onCompletion:^(NSMutableArray *hashtags, ServerResponse serverResponseCode) {
        loading = NO;
        self.hashtags = hashtags;
        [self.tableViewRefresh reloadData];
        [refreshManager tableViewReloadFinishedAnimated:YES];
    }];
}
- (void)hashTagClicked:(WLIHashtag*)hashtag sender:(id)senderCell
{
    [self dismissViewControllerAnimated:YES completion:nil];
    WLIAppDelegate *appDelegate = (WLIAppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.timelineViewController.searchString = hashtag.tagname;
    [appDelegate.timelineViewController reloadData:YES];
    UITabBarItem *selItem = [appDelegate.tabBarController.tabBar.items objectAtIndex:1];
    appDelegate.tabBarController.tabBar.selectedItem = selItem;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchString:searchText];
//    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // Close window and open result and do the search.
    [self dismissViewControllerAnimated:YES completion:nil];
    WLIAppDelegate *appDelegate = (WLIAppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.timelineViewController.searchString = searchBar.text;
    [appDelegate.timelineViewController reloadData:YES];
    UITabBarItem *selItem = [appDelegate.tabBarController.tabBar.items objectAtIndex:1];
    appDelegate.tabBarController.tabBar.selectedItem = selItem;
}
//- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
//{
//    
//}

@end
