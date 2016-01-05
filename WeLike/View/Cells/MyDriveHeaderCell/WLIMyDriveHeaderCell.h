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

@class WLIMyDriveHeaderCell;

@protocol MyDriveHeaderCellDelegate <NSObject>

@optional
- (void)showFollowingsList;
- (void)showFollowersList;
- (void)showAvatarForCell:(WLIMyDriveHeaderCell *)cell;

@end

@interface WLIMyDriveHeaderCell : WLIBaseTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageViewUser;

@property (strong, nonatomic) WLIUser *user;
@property (weak, nonatomic) id<MyDriveHeaderCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextView *myGoalsTextView;

- (void)updateRank:(NSInteger)rank forUsers:(NSInteger)users;
- (void)updatePoints:(NSInteger)points;
- (void)updateCollectionView;

@end
