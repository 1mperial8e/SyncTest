//
//  WLIHashtagTableViewCell.m
//  MyDrive
//
//  Created by Geir Eliassen on 08/10/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIHashtagTableViewCell.h"

@interface WLIHashtagTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *tagNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagCountLabel;

@end

@implementation WLIHashtagTableViewCell

#pragma mark - Accessors

- (void)setHashtag:(WLIHashtag *)hashtag
{
    _hashtag = hashtag;
    [self updateInfo];
}

#pragma mark - Info

- (void)updateInfo
{
    self.tagNameLabel.text = self.hashtag.tagname;
    self.tagCountLabel.text = [NSString stringWithFormat:@"%zd", self.hashtag.tagcount];
}

#pragma mark - Actions

- (IBAction)hashTagClickedTouchUpInside:(WLIHashtag*)hashtag sender:(id)senderCell
{
    [self.delegate hashTagClicked:hashtag sender:self];
}

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
