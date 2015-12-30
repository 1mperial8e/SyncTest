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
@property (strong, nonatomic) UIButton *addAttachment;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UITextView *contentTextView;
@property (strong, nonatomic) UILabel *strategyHeader;
@property (strong, nonatomic) UILabel *strategyContent;
@property (strong, nonatomic) UILabel *countryHeader;
@property (strong, nonatomic) UILabel *countryContent;

@end
