//
//  WLIPostsListViewController.h
//  MyDrive
//
//  Created by Geir Eliassen on 19/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIViewController.h"

@interface WLIPostsListViewController : WLIViewController <WLIViewControllerRefreshProtocol>


@property (strong, nonatomic) IBOutlet UITableView *tableViewRefresh;
@property (strong, nonatomic) NSMutableArray *posts;

-(IBAction)profileButtonTouchUpInside:(id)sender;

@end
