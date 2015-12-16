//
//  WLIHashtagTableViewCell.h
//  MyDrive
//
//  Created by Geir Eliassen on 08/10/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIBaseTableViewCell.h"
#import "WLIHashtag.h"
#import "WLIUser.h"

@interface WLISearchTableViewCell : WLIBaseTableViewCell

@property (weak, nonatomic) WLIHashtag *hashtag;
@property (weak, nonatomic) WLIUser *user;

@end
