//
//  WLIRegisterTableViewCell.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/9/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIMyGoalsTableViewCell.h"

@implementation WLIMyGoalsTableViewCell

#pragma mark - Lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.textView.layer.cornerRadius = 5;
	self.textView.layer.borderColor = [UIColor colorWithWhite:0.80 alpha:1.0].CGColor;
	self.textView.layer.borderWidth = 0.5f;
}

@end
