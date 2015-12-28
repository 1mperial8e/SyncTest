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
#import "NSLocale+WLILocale.h"
#warning delete NSLocale category after test

@interface WLITimelineSettingsViewController () <WLITimelineSettingsTableViewCellDelegate>

@property (strong, nonatomic) NSMutableArray *countryCells;

@end

@implementation WLITimelineSettingsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
	[self setupTableView];
	self.countryCells = [[NSMutableArray alloc] init];
}

#pragma mark - Setup

- (void)setupUI
{
    self.navigationItem.title = @"Timeline Settings";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(settingsAcceptAction:)];
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
    return [WLICountrySettings sharedSource].countries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [self countrySwitchCellForIndexPath:indexPath];
}

#pragma mark - Cells

- (UITableViewCell *)countrySwitchCellForIndexPath:(NSIndexPath *)indexPath
{
    WLITimelineSettingsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:WLITimelineSettingsTableViewCell.ID forIndexPath:indexPath];
    cell.countryLabel.text = [WLICountrySettings sharedSource].countries[indexPath.row];
    cell.countryStateSwitch.tag = indexPath.row;
    [cell.countryStateSwitch setOn: [[WLICountrySettings sharedSource].countriesEnabledState[indexPath.row] integerValue]];
    cell.delegate = self;
	[self.countryCells addObject:cell];
    return cell;
}

#pragma mark - Actions

- (void)settingsAcceptAction:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - WLITimelineSettingsTableViewCellDelegate

- (void)stateSwitched:(BOOL)state forCountryIndex:(NSInteger)index
{
	[[WLICountrySettings sharedSource] setState:state forCountryIndex:index];
	WLITimelineSettingsTableViewCell *lastCell;
	NSInteger enabledCountriesCount = 0;
	for (WLITimelineSettingsTableViewCell *cell in self.countryCells) {
		if (cell.countryStateSwitch.isOn) {
			lastCell = cell;
			enabledCountriesCount++;
			cell.countryStateSwitch.userInteractionEnabled = YES;
		}
	}
	if (enabledCountriesCount == 1) {
		lastCell.countryStateSwitch.userInteractionEnabled = NO;
	}
}

@end
