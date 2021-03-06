//
//  WLIMyDriveViewController.m
//  MyDrive
//
//  Created by Geir Eliassen on 19/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIMyDriveViewController.h"

@interface WLIMyDriveViewController ()

@property (weak, nonatomic) WLIPost *morePost;
@property (assign, nonatomic) NSInteger deleteButtonIndex;

@end

@implementation WLIMyDriveViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    self.user = sharedConnect.currentUser;
    [super viewDidLoad];
    self.title = @"My Energy";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_email"] style:UIBarButtonItemStylePlain target:self action:@selector(sendFeedBack:)];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newPostNotificationRecieved:) name:NewPostNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postDeletedNotificationRecieved:) name:PostDeletedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.user = sharedConnect.currentUser;
    if (self.user) {
        self.navigationItem.title = self.user.userUsername;
        for (WLIPost *post in self.posts) {
            post.user.userFullName = self.user.userFullName;
            post.user.userUsername = self.user.userUsername;
            post.user.userAvatarPath = self.user.userAvatarPath;
            post.user.userAvatarThumbPath = self.user.userAvatarThumbPath;
        }
        [self.tableViewRefresh reloadData];
    }
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - WLITableViewCellDelegate

- (void)deletePost:(WLIPost *)post sender:(id)senderCell
{
    self.morePost = post;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete post" message:@"Are you sure you want to delete this post?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alert show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        __weak typeof(self) weakSelf = self;
        [sharedConnect deletePostID:self.morePost.postID onCompletion:^(ServerResponse serverResponseCode) {
            if (serverResponseCode == OK) {
                NSInteger postIndex = [weakSelf.posts indexOfObject:weakSelf.morePost];
//set proper country id
				[WLIAnalytics eventDeletePostWithUserId:[WLIConnect sharedConnect].currentUser.userID withPostId:weakSelf.morePost.postID withPostCategory:weakSelf.morePost.postCategoryID withCountry:0];
                if (postIndex != NSNotFound) {
                    [weakSelf.posts removeObject:weakSelf.morePost];
                    [weakSelf.tableViewRefresh beginUpdates];
                    [weakSelf.tableViewRefresh deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:postIndex inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [weakSelf.tableViewRefresh endUpdates];
                    
                    weakSelf.user.myPostsCount--;
                    [weakSelf.headerCell updateCollectionView];
                }
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete post" message:@"An error occoured when deleting!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
            }
        }];
    }
}

#pragma mark - Notifications handle

- (void)newPostNotificationRecieved:(NSNotification *)notification
{
	WLIPost *post = [[notification userInfo] objectForKey:@"newPost"];
	[self.posts insertObject:post atIndex:0];
	[self.tableViewRefresh beginUpdates];
	[self.tableViewRefresh insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self.tableViewRefresh endUpdates];
}

- (void)postDeletedNotificationRecieved:(NSNotification *)notification
{
	NSNumber *postID = [[notification userInfo] valueForKey:@"postId"];
	for (WLIPost *post in self.posts)	{
		if (post.postID == [postID integerValue]) {
			NSInteger postIndex = [self.posts indexOfObject:post];
			[self.posts removeObjectAtIndex:postIndex];
			[self.tableViewRefresh beginUpdates];
			[self.tableViewRefresh deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:postIndex inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
			[self.tableViewRefresh endUpdates];
			break;
		}
	}
}

@end
