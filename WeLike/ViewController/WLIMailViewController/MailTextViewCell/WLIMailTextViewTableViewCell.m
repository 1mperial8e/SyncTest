//
//  WLIMailTextViewTableViewCell.m
//  MyDrive
//
//  Created by Stas Volskyi on 08.12.15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIMailTextViewTableViewCell.h"

@implementation WLIMailTextViewTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
	self.textView.textContainer.lineFragmentPadding = 0;
}

@end
