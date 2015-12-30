//
//  WLITimelineFeaturesViewCell.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/30/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLITimelineFeaturesViewCell.h"

@implementation WLITimelineFeaturesViewCell

- (void)prepareForReuse
{
	self.imageView.image = nil;
	self.iconImageView.image =  nil;
}

@end
