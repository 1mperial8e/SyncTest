//
//  WLIMyDriveHeaderCell.h
//  MyDrive
//
//  Created by Geir Eliassen on 28/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLITableViewCell.h"
#import "UIImageView+AFNetworking.h"

#import "WLIUser.h"

@class WLIMyDriveHeaderCell;

@interface WLIMyDriveHeaderCell : WLITableViewCell

@property (strong, nonatomic) WLIUser *user;

@end
