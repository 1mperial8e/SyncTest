//
//  WLISelectOnOffSwitchCell.m
//  MyDrive
//
//  Created by Geir Eliassen on 26/10/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLISelectOnOffSwitchCell.h"

@implementation WLISelectOnOffSwitchCell

#pragma mark - Cell methods

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.attribName setText:[self.cellContent objectForKey:@"name"]];
    [self.attribSwitch setOn:[[self.cellContent objectForKey:@"isOn"] boolValue]];
}

#pragma mark - Actions

- (IBAction)switchValueChanged:(id)sender
{
    [self.cellContent setObject:[NSNumber numberWithBool:self.attribSwitch.on] forKey:@"isOn"];
}

@end
