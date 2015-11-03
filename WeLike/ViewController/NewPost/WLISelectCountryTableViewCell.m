//
//  WLISelectCountryTableViewCell.m
//  MyDrive
//
//  Created by Geir Eliassen on 03/11/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLISelectCountryTableViewCell.h"

@implementation WLISelectCountryTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}


#pragma mark - Cell methods

- (void)layoutSubviews {
    [super layoutSubviews];
    self.allBtn.selected = [[self.countryDict objectForKey:@"all"] boolValue];
    self.denmarkBtn.selected = [[self.countryDict objectForKey:@"denmark"] boolValue];
    self.finlandBtn.selected = [[self.countryDict objectForKey:@"finland"] boolValue];
    self.norwayBtn.selected = [[self.countryDict objectForKey:@"norway"] boolValue];
    self.swedenBtn.selected = [[self.countryDict objectForKey:@"sweden"] boolValue];
}

//- (void)prepareForReuse {
//
//}

#pragma mark - Action methods

- (IBAction)switchAValueChanged:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if (btn.selected)
    {
        btn.selected = NO;
    }
    else
    {
        btn.selected = YES;
    }
    [self.countryDict setObject:[NSNumber numberWithBool:btn.selected] forKey:@"all"];
}
- (IBAction)switchDValueChanged:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if (btn.selected)
    {
        btn.selected = NO;
    }
    else
    {
        btn.selected = YES;
    }
    [self.countryDict setObject:[NSNumber numberWithBool:btn.selected] forKey:@"denmark"];
}
- (IBAction)switchFValueChanged:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if (btn.selected)
    {
        btn.selected = NO;
    }
    else
    {
        btn.selected = YES;
    }
    [self.countryDict setObject:[NSNumber numberWithBool:btn.selected] forKey:@"finland"];
}
- (IBAction)switchNValueChanged:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if (btn.selected)
    {
        btn.selected = NO;
    }
    else
    {
        btn.selected = YES;
    }
    [self.countryDict setObject:[NSNumber numberWithBool:btn.selected] forKey:@"norway"];
}
- (IBAction)switchSValueChanged:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if (btn.selected)
    {
        btn.selected = NO;
    }
    else
    {
        btn.selected = YES;
    }
    [self.countryDict setObject:[NSNumber numberWithBool:btn.selected] forKey:@"sweden"];
}


@end
