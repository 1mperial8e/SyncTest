//
//  WLICountrySelectTableViewController.h
//  MyDrive
//
//  Created by Geir Eliassen on 22/10/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WLINewPostTableViewController;

@interface WLICountrySelectTableViewController : UITableViewController {
    NSMutableArray *switches;
}


-(void)setPostViewController:(WLINewPostTableViewController*)vc;

//-(IBAction)selector:(id)sender

@end
