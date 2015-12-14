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
@end

@interface WLIMyDriveHeaderCell : WLIBaseTableViewCell

@property (strong, nonatomic) WLIUser *user;
@property (weak, nonatomic) id<MyDriveHeaderCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextView *myGoalsTextView;

- (void)updateRank:(NSInteger)rank forUsers:(NSInteger)users;
- (void)updatePoints:(NSInteger)points;

@end
