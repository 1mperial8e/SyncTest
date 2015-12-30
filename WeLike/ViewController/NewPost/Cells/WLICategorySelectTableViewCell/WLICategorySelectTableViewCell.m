//
//  WLICategorySelectTableViewCell.m
//  MyDrive
//
//  Created by Geir Eliassen on 03/11/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLICategorySelectTableViewCell.h"

@implementation WLICategorySelectTableViewCell

#pragma mark - Cell methods

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.marketBtn.selected = [self.catDict[@"market"] boolValue];
    self.capabilityBtn.selected = [self.catDict[@"capability"] boolValue];
    self.customerBtn.selected = [self.catDict [@"customer"] boolValue];
    self.peopleBtn.selected = [self.catDict[@"people"] boolValue];
}

#pragma mark - Actions

- (IBAction)switchMAValueChanged:(UIButton *)sender
{
	sender.selected = !sender.selected;
    [self.catDict setObject:[NSNumber numberWithBool:sender.selected] forKey:@"market"];
}

- (IBAction)switchCAValueChanged:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [self.catDict setObject:[NSNumber numberWithBool:sender.selected] forKey:@"capability"];
}

- (IBAction)switchCUValueChanged:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [self.catDict setObject:[NSNumber numberWithBool:sender.selected] forKey:@"customer"];
}

- (IBAction)switchPEValueChanged:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [self.catDict setObject:[NSNumber numberWithBool:sender.selected] forKey:@"people"];
}

@end
