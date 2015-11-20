//
//  WLIUserDriveViewController.h
//  MyDrive
//
//  Created by Stas Volskyi on 11/20/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIPostsListViewController.h"
#import "WLIFollowersViewController.h"
#import "WLIFollowingViewController.h"

// Cells
#import "WLIMyDriveHeaderCell.h"
#import "WLIPostCell.h"
#import "WLILoadingCell.h"

@interface WLIUserDriveViewController : WLIPostsListViewController <UITableViewDelegate, UITableViewDataSource, MyDriveHeaderCellDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) WLIUser *user;

@end
