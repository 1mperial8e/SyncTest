//
//  WLIViewController.h
//  WeLike
//
//  Created by Planet 1107 on 9/30/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIPostCell.h"
#import "WLILoadingCell.h"
#import "MNMPullToRefreshManager.h"
#import "WLIConnect.h"
#import "MBProgressHUD.h"
#import "PNTToolbar.h"

@protocol WLIViewControllerRefreshProtocol <NSObject>

- (void)reloadData:(BOOL)reloadAll;

@end

@interface WLIViewController : UIViewController <WLICellDelegate, MNMPullToRefreshManagerClient> {
    PNTToolbar *toolbar;
    MNMPullToRefreshManager *refreshManager;
    MBProgressHUD *hud;
    BOOL loadMore;
    BOOL loading;
    __weak WLIConnect *sharedConnect;
}

@property (weak, nonatomic) UITableView *tableViewRefresh;

- (void)sendFeedBack:(id)sender;

@end
