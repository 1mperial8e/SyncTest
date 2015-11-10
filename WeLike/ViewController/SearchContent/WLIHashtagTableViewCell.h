//
//  WLIHashtagTableViewCell.h
//  MyDrive
//
//  Created by Geir Eliassen on 08/10/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIHashtag.h"

@class WLIHashtagTableViewCell;

@protocol WLIHashtagTableViewCellDelegate <NSObject>

- (void)hashTagClicked:(WLIHashtag*)hashtag sender:(id)senderCell;

@end

@interface WLIHashtagTableViewCell : UITableViewCell

@property (strong, nonatomic) WLIHashtag *hashtag;
@property (weak, nonatomic) id<WLIHashtagTableViewCellDelegate> delegate;

+ (NSString *)ID;
+ (UINib *)nib;

@end
