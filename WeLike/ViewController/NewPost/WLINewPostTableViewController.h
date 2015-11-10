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

@interface WLINewPostTableViewController : UITableViewController {
        
    IBOutlet UIButton *addPicture;
    IBOutlet UIButton *addVideo;
    IBOutlet UIButton *addAttachment;
    IBOutlet UIImageView *imageView;
    IBOutlet UITextView *contentTextView;
    IBOutlet UILabel *strategyHeader;
    IBOutlet UILabel *strategyContent;
    IBOutlet UILabel *countryHeader;
    IBOutlet UILabel *countryContent;
}

@end
