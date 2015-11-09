//
//  WLIRegisterAvatarTableViewCell.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/9/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIRegisterAvatarTableViewCell.h"

@implementation WLIRegisterAvatarTableViewCell

#pragma mark - Static

+ (NSString *)ID
{
    return NSStringFromClass(self.class);
}

+ (UINib *)nib
{
    return [UINib nibWithNibName:self.ID bundle:nil];
}

@end
