//
//  WLITimelineSettingsTableViewCell.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/30/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLITimelineSettingsTableViewCell.h"

@interface WLITimelineSettingsTableViewCell ()

@end

@implementation WLITimelineSettingsTableViewCell

- (IBAction)countryStateSwitched:(UISwitch *)sender
{
	if ([self.delegate respondsToSelector:@selector(stateSwitched:forCountryIndex:)]) {
		[self.delegate stateSwitched:self.countryStateSwitch.isOn forCountryIndex:sender.tag];
	}	
}

@end
