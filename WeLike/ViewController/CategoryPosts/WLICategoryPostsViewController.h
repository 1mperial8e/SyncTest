//
//  WLICategoryPostsViewController.h
//  MyDrive
//
//  Created by Geir Eliassen on 29/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIPostsListViewController.h"

@interface WLICategoryPostsViewController : WLIPostsListViewController {
    WLIPost *morePost;
    NSInteger deleteButtonIndex;
    
}

@property NSInteger categoryID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withTitle:(NSString*)myTitle;


@end
