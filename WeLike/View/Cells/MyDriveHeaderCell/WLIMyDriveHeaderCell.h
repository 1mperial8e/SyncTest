//
//  WLIMyDriveHeaderCell.h
//  MyDrive
//
//  Created by Geir Eliassen on 28/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIBaseTableViewCell.h"
#import "UIImageView+AFNetworking.h"

#import "WLIUser.h"

@protocol MyDriveHeaderCellDelegate <NSObject>

@optional
- (void)showFollowingsList;
- (void)showFollowersList;
- (void)follow:(BOOL)follow user:(WLIUser *)user;

@end

@interface WLIMyDriveHeaderCell : WLIBaseTableViewCell

@property (strong, nonatomic) WLIUser *user;
@property (weak, nonatomic) id<MyDriveHeaderCellDelegate> delegate;

- (void)updateRank:(NSInteger)rank;
- (void)updatePoints:(NSInteger)points;

@end
