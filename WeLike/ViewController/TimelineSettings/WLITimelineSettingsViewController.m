//
//  WLITimelineSettingsViewControllerTableViewController.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/30/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLITimelineSettingsViewController.h"
#import "WLITimelineSettingsTableViewCell.h"
#import "WLICountrySettings.h"

@interface WLITimelineSettingsViewController () <WLITimelineSettingsTableViewCellDelegate>

@property (assign, nonatomic) BOOL isChanged;

@end

@implementation WLITimelineSettingsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isChanged = NO;
    
    [self setupUI];
	[self setupTableView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.isChanged) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CountriesFilterSettingsChangeNotification object:self userInfo:nil];
    }
}

#pragma mark - Setup

- (void)setupUI
{
    self.navigationItem.title = @"Timeline Settings";
    self.navigationController.navigationBar.topItem.title = @"";
}

- (void)setupTableView
{
    [self.tableView registerNib:WLITimelineSettingsTableViewCell.nib forCellReuseIdentifier:WLITimelineSettingsTableViewCell.ID];

    NSArray *viewArray = [[NSBundle mainBundle] loadNibNamed:@"WLITimelineSettingsHeaderView" owner:self options:nil];
    UIView *header = [viewArray firstObject];
    self.tableView.tableHeaderView = header;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [WLICountrySettings sharedSettings].countries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self countrySwitchCellForIndexPath:indexPath];
}

#pragma mark - Cells

- (UITableViewCell *)countrySwitchCellForIndexPath:(NSIndexPath *)indexPath
{
    WLITimelineSettingsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:WLITimelineSettingsTableViewCell.ID forIndexPath:indexPath];
    cell.countryLabel.text = [WLICountrySettings sharedSettings].countries[indexPath.row];
    cell.countryStateSwitch.tag = indexPath.row;
    [cell.countryStateSwitch setOn: [[WLICountrySettings sharedSettings].countriesEnabledState[indexPath.row] integerValue]];
    cell.delegate = self;
    return cell;
}

#pragma mark - WLITimelineSettingsTableViewCellDelegate

- (void)stateSwitched:(BOOL)state forCountryIndex:(NSInteger)index fromCell:(id)senderCell
{
	WLITimelineSettingsTableViewCell *currentCell = (WLITimelineSettingsTableViewCell *)senderCell;
	NSInteger enabledCountriesCount = [[WLICountrySettings sharedSettings] getEnabledCountriesCount];	
	if (enabledCountriesCount == 1 && !currentCell.countryStateSwitch.isOn) {
        [currentCell.countryStateSwitch setOn:YES animated:YES];
	} else {
		self.isChanged = YES;
		[[WLICountrySettings sharedSettings] setState:state forCountryIndex:index];
	}
}

@end
