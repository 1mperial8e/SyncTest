//
//  WLIViewController.m
//  WeLike
//
//  Created by Planet 1107 on 9/30/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIViewController.h"
#import "WLICommentsViewController.h"
#import "WLIPostViewController.h"
#import "WLIUserDriveViewController.h"
#import "WLILikersViewController.h"
#import "WLIFullScreenPhotoViewController.h"
#import "WLIMyDriveViewController.h"

@interface WLIViewController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSIndexPath *indexPathToReload;

@end

@implementation WLIViewController

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        sharedConnect = [WLIConnect sharedConnect];
        toolbar = [PNTToolbar defaultToolbar];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self conformsToProtocol:@protocol(WLIViewControllerRefreshProtocol)]) {
        refreshManager = [[MNMPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:self.tableViewRefresh withClient:self];
    }
    loadMore = YES;
    
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav-btn-back"] style:UIBarButtonItemStylePlain target:self action:@selector(barButtonItemBackTouchUpInside:)];
    } else if (self.presentingViewController) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav-btn-close"] style:UIBarButtonItemStylePlain target:self action:@selector(barButtonItemCancelTouchUpInside:)];
    }
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    
//    if (self.navigationController.viewControllers.count == 1) {
//        self.navigationController.interactivePopGestureRecognizer.delegate = self;
//    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([UIApplication sharedApplication].statusBarOrientation != UIInterfaceOrientationPortrait) {
        [UIView setAnimationsEnabled:NO];
    }
    if (self.indexPathToReload) {
        [self.tableViewRefresh beginUpdates];
        [self.tableViewRefresh reloadRowsAtIndexPaths:@[self.indexPathToReload] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableViewRefresh endUpdates];
        self.indexPathToReload = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    [UIView setAnimationsEnabled:YES];
}

#pragma mark - Actions methods

- (void)barButtonItemBackTouchUpInside:(UIButton *)backButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)barButtonItemCancelTouchUpInside:(UIButton *)backButton
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendFeedBack:(id)sender
{	
	[WLIUtils showCustomEmailControllerWithToRecepient:@"support@santanderconsumer.no"];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
    switch (result) {
        case MFMailComposeResultFailed:
            NSLog(@"%@", error);
            break;
        default:
            break;
    }
}

#pragma mark - WLIPostCellDelegate methods

- (void)showImageForPost:(WLIPost *)post sender:(id)senderCell
{
	if (!post.postVideoPath.length) {
		[self showFullImageForCell:senderCell];
	}
}

- (void)showCommentsForPost:(WLIPost*)post sender:(WLIPostCell *)senderCell
{
    self.indexPathToReload = [self.tableViewRefresh indexPathForCell:senderCell];
    WLICommentsViewController *commentsViewController = [WLICommentsViewController new];
    commentsViewController.post = post;
    [self.navigationController pushViewController:commentsViewController animated:YES];
}

- (void)showUser:(WLIUser *)user userID:(NSInteger)userID sender:(WLIPostCell *)senderCell
{
	WLIUserDriveViewController *userDrive;
	if ((user.userID == [WLIConnect sharedConnect].currentUser.userID) || (userID == [WLIConnect sharedConnect].currentUser.userID)) {
		userDrive = [WLIMyDriveViewController new];
	} else {
		userDrive = [WLIUserDriveViewController new];
	}	
    if (user) {
        userDrive.user = user;
    } else {
        WLIUser *tmpUser = [WLIUser new];
        tmpUser.userID = userID;
        userDrive.user = tmpUser;
    }
    [self.navigationController pushViewController:userDrive animated:YES];
}

#pragma mark - MNMPullToRefreshClient methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [refreshManager tableViewScrolled];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [refreshManager tableViewReleased];
}

- (void)pullToRefreshTriggered:(MNMPullToRefreshManager *)manager
{
    if (!loading) {
        id<WLIViewControllerRefreshProtocol> objectConformsToProtocol = (id<WLIViewControllerRefreshProtocol>)self;
        [objectConformsToProtocol reloadData:YES];
    } else {
        [refreshManager tableViewReloadFinishedAnimated:YES];
    }
}

#pragma mark - GestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return [gestureRecognizer isKindOfClass:UIScreenEdgePanGestureRecognizer.class];
}

#pragma mark - WLIPostCellDelegate

- (void)toggleLikeForPost:(WLIPost *)post sender:(WLIPostCell *)senderCell
{
    if (post.likedThisPost) {
        post.likedThisPost = NO;
        post.postLikesCount--;
        [[WLIConnect sharedConnect] removeLikeWithLikeID:post.postID onCompletion:^(ServerResponse serverResponseCode) {
			senderCell.buttonLike.userInteractionEnabled = YES;
            if (serverResponseCode != OK) {
                post.postLikesCount++;
                post.likedThisPost = YES;
                [senderCell updateLikesInfo];
            }
        }];
    } else {
        post.postLikesCount++;
        post.likedThisPost = YES;
        [[WLIConnect sharedConnect] setLikeOnPostID:post.postID onCompletion:^(WLILike *like, ServerResponse serverResponseCode) {
			senderCell.buttonLike.userInteractionEnabled = YES;
            if (serverResponseCode != OK) {
                post.likedThisPost = NO;
                post.postLikesCount--;
                [senderCell updateLikesInfo];
            }
        }];
    }
    [senderCell updateLikesInfo];
}

- (void)followUser:(WLIUser *)user sender:(id)senderCell
{
	[self follow:YES user:user cellToReload:senderCell];
}

- (void)unfollowUser:(WLIUser *)user sender:(id)senderCell
{
	[self follow:NO user:user cellToReload:senderCell];
}

- (void)follow:(BOOL)follow user:(WLIUser *)user cellToReload:(WLIPostCell *)cell
{
	__block NSIndexPath *indexPath = [self.tableViewRefresh indexPathForCell:cell];
	__weak typeof(self) weakSelf = self;
	cell.buttonFollow.userInteractionEnabled = NO;
	void (^followUserCompletion)(WLIFollow *, ServerResponse) = ^(WLIFollow *wliFollow, ServerResponse serverResponseCode) {
		cell.buttonFollow.userInteractionEnabled = YES;
		if (serverResponseCode == OK) {
			user.followingUser = follow;
			cell.post.user = user;
			if (indexPath) {
				[weakSelf.tableViewRefresh reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			}
		} else {
			NSString *message = @"An error occured, user was not followed.";
			if (!follow) {
				message = @"An error occured, user was not unfollowed.";
			}
			[[[UIAlertView alloc] initWithTitle:@"Error"
										message:message
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil]
			 performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
		}
	};
	if (follow) {
		[sharedConnect setFollowOnUserID:user.userID onCompletion:followUserCompletion];
	} else {
		[sharedConnect removeFollowWithFollowID:user.userID onCompletion:^(ServerResponse serverResponseCode) {
			followUserCompletion(nil, serverResponseCode);
		}];
	}
}

- (void)showLikersListForPost:(WLIPost *)post
{
	WLILikersViewController *likersViewController = [WLILikersViewController new];
	likersViewController.post = post;
	[self.navigationController pushViewController:likersViewController animated:YES];
}

#pragma mark - FullImage

- (void)showFullImageForCell:(WLIPostCell *)cell
{
	if (cell.originalImage) {
        CGRect cellFrame = [self.view convertRect:cell.frame fromView:self.tableViewRefresh];
		CGRect imageViewRect = cell.imageViewPostImage.superview.frame;
		imageViewRect.origin.x = ([UIScreen mainScreen].bounds.size.width - imageViewRect.size.width) / 2;
		imageViewRect.origin.y += cellFrame.origin.y + imageViewRect.origin.x;
		WLIFullScreenPhotoViewController *imageController = [WLIFullScreenPhotoViewController new];
		imageController.image = cell.originalImage;
		imageController.presentationRect = imageViewRect;
		imageController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
		[self.tabBarController presentViewController:imageController animated:NO completion:nil];
	}
}

@end
