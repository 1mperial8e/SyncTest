//
//  WLICategorySelectTableViewCell.m
//  MyDrive
//
//  Created by Geir Eliassen on 03/11/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLICategorySelectTableViewCell.h"

@implementation WLICategorySelectTableViewCell

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
    self.marketBtn.selected = [[self.catDict objectForKey:@"market"] boolValue];
    self.capabilityBtn.selected = [[self.catDict objectForKey:@"capability"] boolValue];
    self.customerBtn.selected = [[self.catDict objectForKey:@"customer"] boolValue];
    self.peopleBtn.selected = [[self.catDict objectForKey:@"people"] boolValue];
}

//- (void)prepareForReuse {
//
//}

#pragma mark - Action methods


- (IBAction)switchMAValueChanged:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if (btn.selected)
    {
        btn.selected = NO;
    }
    else
    {
        btn.selected = YES;
    }
    [self.catDict setObject:[NSNumber numberWithBool:btn.selected] forKey:@"market"];
}
- (IBAction)switchCAValueChanged:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if (btn.selected)
    {
        btn.selected = NO;
    }
    else
    {
        btn.selected = YES;
    }
    [self.catDict setObject:[NSNumber numberWithBool:btn.selected] forKey:@"capability"];
}
- (IBAction)switchCUValueChanged:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if (btn.selected)
    {
        btn.selected = NO;
    }
    else
    {
        btn.selected = YES;
    }
    [self.catDict setObject:[NSNumber numberWithBool:btn.selected] forKey:@"customer"];
}
- (IBAction)switchPEValueChanged:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if (btn.selected)
    {
        btn.selected = NO;
    }
    else
    {
        btn.selected = YES;
    }
    [self.catDict setObject:[NSNumber numberWithBool:btn.selected] forKey:@"people"];
}

@end
