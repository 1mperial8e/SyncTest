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
    self.textView.layer.cornerRadius = CGRectGetHeight(self.textView.frame) / 15;
	self.textView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
	self.textView.layer.borderWidth = 1.0f;
}

#pragma mark - Actions

- (IBAction)loginAction:(id)sender
{
    if (self.registerHandler) {
        self.registerHandler();
    }
}

@end
