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
        
@property (strong, nonatomic) UIButton *addPicture;
@property (strong, nonatomic) UIButton *addVideo;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UITextView *contentTextView;

@end
