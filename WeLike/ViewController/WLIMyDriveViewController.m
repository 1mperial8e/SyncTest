//
//  WLIMyDriveViewController.m
//  MyDrive
//
//  Created by Geir Eliassen on 19/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIMyDriveViewController.h"

@interface WLIMyDriveViewController ()

@property (strong, nonatomic) WLIPost *morePost;
@property (assign, nonatomic) NSInteger deleteButtonIndex;

@end

@implementation WLIMyDriveViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    self.user = sharedConnect.currentUser;
    
    [super viewDidLoad];
    self.title = @"My Energy";
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
        }
        [self.tableViewRefresh reloadData];
    }
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
                if (postIndex != NSNotFound) {
                    [weakSelf.posts removeObject:weakSelf.morePost];
                    [weakSelf.tableViewRefresh beginUpdates];
                    [weakSelf.tableViewRefresh deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:postIndex inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [weakSelf.tableViewRefresh endUpdates];
                }
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete post" message:@"An error occoured when deleting!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
            }
        }];
    }
}

@end
