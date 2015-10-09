//
//  WLIHashtagTableViewCell.m
//  MyDrive
//
//  Created by Geir Eliassen on 08/10/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIHashtagTableViewCell.h"

//static WLIHashtagTableViewCell *sharedCell = nil;

@implementation WLIHashtagTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - Object lifecycle

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}



#pragma mark - Cell methods

- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self updateFrame];
}

- (void)updateFrame {
    tagName.text = self.hashtag.tagname;
    tagCount.text = [NSString stringWithFormat:@"%d", self.hashtag.tagcount];
}

- (IBAction)hashTagClickedTouchUpInside:(WLIHashtag*)hashtag sender:(id)senderCell
{
    [self.delegate hashTagClicked:hashtag sender:self];
}

@end
