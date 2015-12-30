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
    self.allBtn.selected = [[self.countryDict objectForKey:@"all"] boolValue];
    self.denmarkBtn.selected = [[self.countryDict objectForKey:@"denmark"] boolValue];
    self.finlandBtn.selected = [[self.countryDict objectForKey:@"finland"] boolValue];
    self.norwayBtn.selected = [[self.countryDict objectForKey:@"norway"] boolValue];
    self.swedenBtn.selected = [[self.countryDict objectForKey:@"sweden"] boolValue];
}

#pragma mark - Actions

- (IBAction)switchAValueChanged:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    if (btn.selected) {
        btn.selected = NO;
    }
    else {
        btn.selected = YES;
        [self.countryDict setObject:@NO forKey:@"denmark"];
        [self.countryDict setObject:@NO forKey:@"finland"];
        [self.countryDict setObject:@NO forKey:@"norway"];
        [self.countryDict setObject:@NO forKey:@"sweden"];
        self.denmarkBtn.selected = NO;
        self.finlandBtn.selected = NO;
        self.norwayBtn.selected = NO;
        self.swedenBtn.selected = NO;
    }
    [self.countryDict setObject:[NSNumber numberWithBool:btn.selected] forKey:@"all"];
    [self updateCountriesDict];
}

- (IBAction)switchDValueChanged:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    if (btn.selected) {
        btn.selected = NO;
    }
    else {
        btn.selected = YES;
    }
    [self.countryDict setObject:[NSNumber numberWithBool:btn.selected] forKey:@"denmark"];
    [self updateCountriesDict];
}

- (IBAction)switchFValueChanged:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    if (btn.selected) {
        btn.selected = NO;
    }
    else {
        btn.selected = YES;
    }
    [self.countryDict setObject:[NSNumber numberWithBool:btn.selected] forKey:@"finland"];
    [self updateCountriesDict];
}

- (IBAction)switchNValueChanged:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    if (btn.selected) {
        btn.selected = NO;
    }
    else {
        btn.selected = YES;
    }
    [self.countryDict setObject:[NSNumber numberWithBool:btn.selected] forKey:@"norway"];
    [self updateCountriesDict];
}

- (IBAction)switchSValueChanged:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    if (btn.selected) {
        btn.selected = NO;
    }
    else {
        btn.selected = YES;
    }
    [self.countryDict setObject:[NSNumber numberWithBool:btn.selected] forKey:@"sweden"];
    [self updateCountriesDict];
}

- (void)updateCountriesDict
{
    BOOL denmark = [[self.countryDict objectForKey:@"denmark"] boolValue];
    BOOL norway = [[self.countryDict objectForKey:@"norway"] boolValue];
    BOOL finland = [[self.countryDict objectForKey:@"finland"] boolValue];
    BOOL sweden = [[self.countryDict objectForKey:@"sweden"] boolValue];
    
    if (denmark || norway || sweden || finland) {
        self.allBtn.selected = NO;
        [self.countryDict setObject:@NO forKey:@"all"];
    } else {
        self.allBtn.selected = YES;
        [self.countryDict setObject:@YES forKey:@"all"];
    }
}

@end
