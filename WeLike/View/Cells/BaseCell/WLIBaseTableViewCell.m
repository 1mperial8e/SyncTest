//
//  WLIBaseTableViewCell.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/17/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIBaseTableViewCell.h"

@implementation WLIBaseTableViewCell

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
