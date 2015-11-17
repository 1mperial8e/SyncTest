//
//  WLILoadingCell.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLILoadingCell.h"

@implementation WLILoadingCell

#pragma mark - Lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.refreshControl startAnimating];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.refreshControl startAnimating];
}

@end
