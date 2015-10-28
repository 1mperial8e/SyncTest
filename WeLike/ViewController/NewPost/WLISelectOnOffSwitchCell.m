//
//  WLISelectOnOffSwitchCell.m
//  MyDrive
//
//  Created by Geir Eliassen on 26/10/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLISelectOnOffSwitchCell.h"

@implementation WLISelectOnOffSwitchCell

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
    [self.attribName setText:[self.cellContent objectForKey:@"name"]];
    [self.attribSwitch setOn:[[self.cellContent objectForKey:@"isOn"] boolValue]];
}

//- (void)prepareForReuse {
//    
//}

#pragma mark - Action methods

- (IBAction)switchValueChanged:(id)sender {
    [self.cellContent setObject:[NSNumber numberWithBool:self.attribSwitch.on] forKey:@"isOn"];
}

@end
