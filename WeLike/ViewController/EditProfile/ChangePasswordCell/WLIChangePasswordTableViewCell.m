//
//  WLIChangePasswordTableViewCell.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/19/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIChangePasswordTableViewCell.h"

@implementation WLIChangePasswordTableViewCell

#pragma mark - Lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.changePasswordButton.layer.cornerRadius = CGRectGetHeight(self.changePasswordButton.frame) / 2;
}

#pragma mark - Actions

- (IBAction)changePasswordAction:(id)sender
{
    if (self.changePasswordHandler) {
        self.changePasswordHandler();
    }
}

@end
