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
    self.allBtn.selected = [self.countryDict[@"all"] boolValue];
    self.denmarkBtn.selected = [self.countryDict[@"denmark"] boolValue];
    self.finlandBtn.selected = [self.countryDict[@"finland"] boolValue];
    self.norwayBtn.selected = [self.countryDict[@"norway"] boolValue];
    self.swedenBtn.selected = [self.countryDict[@"sweden"] boolValue];
}

#pragma mark - Actions

- (IBAction)switchAValueChanged:(UIButton *)sender
{
	if (!sender.selected) {
        [self.countryDict setObject:@NO forKey:@"denmark"];
        [self.countryDict setObject:@NO forKey:@"finland"];
        [self.countryDict setObject:@NO forKey:@"norway"];
        [self.countryDict setObject:@NO forKey:@"sweden"];
        self.denmarkBtn.selected = NO;
        self.finlandBtn.selected = NO;
        self.norwayBtn.selected = NO;
        self.swedenBtn.selected = NO;
    }
	sender.selected = !sender.selected;
    [self.countryDict setObject:[NSNumber numberWithBool:sender.selected] forKey:@"all"];
    [self updateCountriesDict];
}

- (IBAction)switchDValueChanged:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [self.countryDict setObject:[NSNumber numberWithBool:sender.selected] forKey:@"denmark"];
    [self updateCountriesDict];
}

- (IBAction)switchFValueChanged:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [self.countryDict setObject:[NSNumber numberWithBool:sender.selected] forKey:@"finland"];
    [self updateCountriesDict];
}

- (IBAction)switchNValueChanged:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [self.countryDict setObject:[NSNumber numberWithBool:sender.selected] forKey:@"norway"];
    [self updateCountriesDict];
}

- (IBAction)switchSValueChanged:(UIButton *)sender
{
	sender.selected = !sender.selected;
    [self.countryDict setObject:[NSNumber numberWithBool:sender.selected] forKey:@"sweden"];
    [self updateCountriesDict];
}

- (void)updateCountriesDict
{
    BOOL denmark = [self.countryDict[@"denmark"] boolValue];
    BOOL norway = [self.countryDict[@"norway"] boolValue];
    BOOL finland = [self.countryDict[@"finland"] boolValue];
    BOOL sweden = [self.countryDict[@"sweden"] boolValue];
    
    if (denmark || norway || sweden || finland) {
        self.allBtn.selected = NO;
        [self.countryDict setObject:@NO forKey:@"all"];
    } else {
        self.allBtn.selected = YES;
        [self.countryDict setObject:@YES forKey:@"all"];
    }
}

@end
