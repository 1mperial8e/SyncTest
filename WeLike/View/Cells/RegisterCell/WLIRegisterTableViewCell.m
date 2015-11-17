//
//  WLIRegisterTableViewCell.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/9/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIRegisterTableViewCell.h"

@implementation WLIRegisterTableViewCell

#pragma mark - Lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.registerButton.layer.cornerRadius = CGRectGetHeight(self.registerButton.frame) / 2;
}

#pragma mark - Actions

- (IBAction)loginAction:(id)sender
{
    if (self.registerHandler) {
        self.registerHandler();
    }
}

@end
