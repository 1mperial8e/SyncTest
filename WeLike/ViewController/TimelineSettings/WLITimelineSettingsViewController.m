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
	
	[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([WLITimelineSettingsTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WLITimelineSettingsTableViewCell class])];	
	
	self.navigationItem.title = @"Timeline Settings";
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(settingsAcceptAction:)];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [WLICountrySettings sharedSource].countries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	WLITimelineSettingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WLITimelineSettingsTableViewCell class]) forIndexPath:indexPath];
	cell.countryLabel.text = [WLICountrySettings sharedSource].countries[indexPath.row];
	cell.countryStateSwitch.tag = indexPath.row;
	[cell.countryStateSwitch setOn: [[WLICountrySettings sharedSource].countriesEnabledState[indexPath.row] integerValue]];
	cell.delegate = self;
	return cell;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	NSArray *viewArray =  [[NSBundle mainBundle] loadNibNamed:@"WLITimelineSettingsHeaderView" owner:self options:nil];
	UIView *header = [viewArray firstObject];
	return header;
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
