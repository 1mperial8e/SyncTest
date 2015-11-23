//
//  WLITableViewCell.h
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIBaseTableViewCell.h"
#import "WLIUser.h"
#import "WLIPost.h"

@import MediaPlayer;

@class WLITableViewCell;

@protocol WLICellDelegate <NSObject>

@optional
- (void)showUser:(WLIUser *)user userID:(NSInteger)userID sender:(id)senderCell;
- (void)showImageForPost:(WLIPost *)post sender:(id)senderCell;
- (void)toggleLikeForPost:(WLIPost *)post sender:(id)senderCell;
- (void)showCommentsForPost:(WLIPost *)post sender:(id)senderCell;
- (void)showLikesForPost:(WLIPost *)post sender:(id)senderCell;
- (void)followUser:(WLIUser *)user sender:(id)senderCell;
- (void)unfollowUser:(WLIUser *)user sender:(id)senderCell;
- (void)presentMoviePlayerViewControllerAnimated:(MPMoviePlayerViewController *)moviePlayerViewController;

- (void)showShareForPost:(WLIPost *)post sender:(id)senderCell;
- (void)showDeleteForPost:(WLIPost *)post sender:(id)senderCell;
- (void)deletePost:(WLIPost *)post sender:(id)senderCell;
- (void)showMoreForPost:(WLIPost *)post sender:(id)senderCell;
- (void)showConnectForPost:(WLIPost *)post sender:(id)senderCell;

- (void)showCatMarketForPost:(WLIPost *)post sender:(id)senderCell;
- (void)showCatCustomersForPost:(WLIPost *)post sender:(id)senderCell;
- (void)showCatCapabilitiesForPost:(WLIPost *)post sender:(id)senderCell;
- (void)showCatPeopleForPost:(WLIPost *)post sender:(id)senderCell;

- (void)showTimelineForSearchString:(NSString *)searchString;

@end

@interface WLITableViewCell : WLIBaseTableViewCell

@end
