//
//  WLISearchContentViewController.h
//  MyDrive
//
//  Created by Geir Eliassen on 19/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIViewController.h"
#import "WLIHashtagTableViewCell.h"
#import "WLILoadingCell.h"
#import "WLIHashtag.h"

@interface WLISearchContentViewController : WLIViewController <UISearchBarDelegate, WLIHashtagTableViewCellDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableViewRefresh;
@property (strong, nonatomic) NSArray *hashtags;

@end
