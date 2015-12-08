//
//  WLIMailTextViewTableViewCell.m
//  MyDrive
//
//  Created by Roman R on 08.12.15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIMailTextViewTableViewCell.h"

@interface WLIMailTextViewTableViewCell ()

@property (weak , nonatomic) IBOutlet UITextView * textView;
@end


@implementation WLIMailTextViewTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
	self.textView.textContainer.lineFragmentPadding = 0;

    // Configure the view for the selected state
}

@end
