//
//  WLINewPostTableViewController.h
//  MyDrive
//
//  Created by Geir Eliassen on 19/10/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIViewController.h"

@import MediaPlayer;
@import AVFoundation;

@interface WLINewPostTableViewController : UITableViewController
        
@property (weak, nonatomic) UIButton *addPicture;
@property (weak, nonatomic) UIButton *addVideo;
@property (weak, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) UITextView *contentTextView;

@end
