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

@end

@implementation WLITimelineSettingsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
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
}

@end
