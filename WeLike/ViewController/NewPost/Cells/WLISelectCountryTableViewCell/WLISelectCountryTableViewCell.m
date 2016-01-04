//
//  WLISelectCountryTableViewCell.m
//  MyDrive
//
//  Created by Geir Eliassen on 03/11/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLISelectCountryTableViewCell.h"

@implementation WLISelectCountryTableViewCell

#pragma mark - Cell methods

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.nordicBtn.selected = [self.countryDict[@"Nordic"] boolValue];
    self.denmarkBtn.selected = [self.countryDict[@"Denmark"] boolValue];
    self.finlandBtn.selected = [self.countryDict[@"Finland"] boolValue];
    self.norwayBtn.selected = [self.countryDict[@"Norway"] boolValue];
    self.swedenBtn.selected = [self.countryDict[@"Sweden"] boolValue];
}

#pragma mark - Actions

- (IBAction)switchNordicValueChanged:(UIButton *)sender
{
	if ([self enabledCountriesCount] > 1 || !sender.selected) {
		sender.selected = !sender.selected;
		[self.countryDict setObject:@(sender.selected) forKey:@"Nordic"];
	}
}

- (IBAction)switchDValueChanged:(UIButton *)sender
{
	if ([self enabledCountriesCount] > 1 || !sender.selected) {
		sender.selected = !sender.selected;
		[self.countryDict setObject:@(sender.selected) forKey:@"Denmark"];
	}
}

- (IBAction)switchFValueChanged:(UIButton *)sender
{
	if ([self enabledCountriesCount] > 1 || !sender.selected) {
		sender.selected = !sender.selected;
		[self.countryDict setObject:@(sender.selected) forKey:@"Finland"];
	}
}

- (IBAction)switchNValueChanged:(UIButton *)sender
{
	if ([self enabledCountriesCount] > 1 || !sender.selected) {
		sender.selected = !sender.selected;
		[self.countryDict setObject:@(sender.selected) forKey:@"Norway"];
	}
}

- (IBAction)switchSValueChanged:(UIButton *)sender
{
	if ([self enabledCountriesCount] > 1 || !sender.selected) {
		sender.selected = !sender.selected;
		[self.countryDict setObject:@(sender.selected) forKey:@"Sweden"];
	}
}

#pragma mark - Utils

- (NSInteger)enabledCountriesCount
{
	NSInteger enabledCountriesCount = 0;
	for (NSNumber *countryState in self.countryDict.allValues) {
		if (![countryState isEqualToNumber:@0]) {
			enabledCountriesCount++;
		}
	}
	return enabledCountriesCount;
}

@end
