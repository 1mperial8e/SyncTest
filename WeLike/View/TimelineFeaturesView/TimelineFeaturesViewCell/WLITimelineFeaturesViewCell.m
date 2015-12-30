//
//  WLITimelineFeaturesViewCell.m
//  MyDrive
//
//  Created by Roman R on 30.12.15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLITimelineFeaturesViewCell.h"

@implementation WLITimelineFeaturesViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)prepareForReuse
{
	self.imageView.image = nil;
	self.iconImageView.image =  nil;
}

@end
