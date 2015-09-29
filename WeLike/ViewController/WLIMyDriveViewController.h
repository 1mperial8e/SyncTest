//
//  WLIMyDriveViewController.h
//  MyDrive
//
//  Created by Geir Eliassen on 19/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIPostsListViewController.h"

@interface WLIMyDriveViewController : WLIPostsListViewController {
    WLIPost *morePost;
    NSInteger deleteButtonIndex;

}

@property (strong, nonatomic) WLIUser *user;


@end
