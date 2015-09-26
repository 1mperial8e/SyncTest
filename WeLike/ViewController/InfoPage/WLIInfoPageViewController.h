//
//  WLIInfoPageViewController.h
//  MyDrive
//
//  Created by Geir Eliassen on 16/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface WLIInfoPageViewController : WLIViewController {
    IBOutlet UIScrollView *scrollView;
}


- (IBAction)marketButtonTouchUpInside:(id)sender;
- (IBAction)customerButtonTouchUpInside:(id)sender;
- (IBAction)capabilityButtonTouchUpInside:(id)sender;
- (IBAction)peopleButtonTouchUpInside:(id)sender;
- (IBAction)buttonPlayVideoTouchUpInside:(id)sender;

@end
