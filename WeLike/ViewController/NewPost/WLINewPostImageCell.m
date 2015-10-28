//
//  WLINewPostImageCell.m
//  MyDrive
//
//  Created by Geir Eliassen on 27/10/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLINewPostImageCell.h"

@implementation WLINewPostImageCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}


#pragma mark - Cell methods

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imgView.image = self.img;
}

//-(void)


@end
