//
//  WLINewPostViewController.h
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIViewController.h"
#import <AviarySDK/AviarySDK.h>

@import MediaPlayer;
@import AVFoundation;

@interface WLINewPostViewController : WLIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVYPhotoEditorControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageViewPost;
@property (strong, nonatomic) NSData *video;
@property (strong, nonatomic) IBOutlet UIButton *buttonPostImage;
@property (strong, nonatomic) IBOutlet UITextView *textViewPost;
@property (strong, nonatomic) IBOutlet UIButton *buttonSend;

- (IBAction)buttonPostImageTouchUpInside:(id)sender;
- (IBAction)buttonSendTouchUpInside:(id)sender;

@end
