//
//  WLILoginTableViewCell.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/9/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLILoginTableViewCell.h"

@implementation WLILoginTableViewCell

#pragma mark - Static

+ (NSString *)ID
{
    return NSStringFromClass(self.class);
}

+ (UINib *)nib
{
    return [UINib nibWithNibName:self.ID bundle:nil];
}

#pragma mark - Lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.loginButton.layer.cornerRadius = CGRectGetHeight(self.loginButton.frame) / 2;
}

#pragma mark - Actions

- (IBAction)loginAction:(id)sender
{
    if (self.loginHandler) {
        self.loginHandler();
    }
}

@end
