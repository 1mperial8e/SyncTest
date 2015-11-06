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

@protocol MyDriveHeaderCellDelegate <NSObject>

@optional
- (void)showFollowingsList;
- (void)showFollowersList;

@end

@interface WLIMyDriveHeaderCell : WLITableViewCell

@property (strong, nonatomic) WLIUser *user;
@property (weak, nonatomic) id<MyDriveHeaderCellDelegate> delegate;

@end
