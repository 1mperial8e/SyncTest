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

@interface WLINewPostViewController : WLIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVYPhotoEditorControllerDelegate> {
}

@property (strong, nonatomic) IBOutlet UIImageView *imageViewPost;
@property (strong, nonatomic) NSData *video;
@property (strong, nonatomic) IBOutlet UIButton *buttonPostImage;
@property (strong, nonatomic) IBOutlet UITextField *titleFieldPost;
@property (strong, nonatomic) IBOutlet UITextView *textViewPost;
@property (strong, nonatomic) IBOutlet UIButton *buttonSend;


@property (strong, nonatomic) IBOutlet UIButton *buttonCategoryCapability;
@property (strong, nonatomic) IBOutlet UIButton *buttonCategoryCustomer;
@property (strong, nonatomic) IBOutlet UIButton *buttonCategoryMarket;
@property (strong, nonatomic) IBOutlet UIButton *buttonCategoryPeople;

@property (strong, nonatomic) IBOutlet UIButton *buttonCategoryStateCapability;
@property (strong, nonatomic) IBOutlet UIButton *buttonCategoryStateCustomer;
@property (strong, nonatomic) IBOutlet UIButton *buttonCategoryStateMarket;
@property (strong, nonatomic) IBOutlet UIButton *buttonCategoryStatePeople;







- (IBAction)buttonPostImageTouchUpInside:(id)sender;
- (IBAction)buttonSendTouchUpInside:(id)sender;

@end
