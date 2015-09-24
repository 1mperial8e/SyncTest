//
//  WLINewPostViewController.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLINewPostViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation WLINewPostViewController


#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"New post";
        self.video = nil;
//        [AFPhotoEditorController setAPIKey:kAviaryKey secret:kAviarySecret];
    }
    return self;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, 8, self.contentView.frame.size.width, self.contentView.frame.size.height);

    postType = postTypeText;
    self.buttonPostImage.imageView.layer.cornerRadius = 3.0f;
    self.buttonPostImage.imageView.layer.masksToBounds = YES;
    self.textViewPost.layer.cornerRadius = 3.0f;
//    self.buttonSend.layer.cornerRadius = CGRectGetHeight(self.buttonSend.frame)/2;
    
    UIButton *publishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    publishButton.adjustsImageWhenHighlighted = NO;
    publishButton.frame = CGRectMake(0.0f, 0.0f, 60.0f, 30.0f);
    [publishButton setTitle:@"Publish" forState:UIControlStateNormal];
    [publishButton addTarget:self action:@selector(buttonSendTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:publishButton];
    
//    [self.textViewPost becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Buttons methods

- (IBAction)buttonPostImageTouchUpInside:(id)sender {
    
    if ([self.textViewPost isFirstResponder]) {
        [self.textViewPost resignFirstResponder];
    }
    if ([self.titleFieldPost isFirstResponder]) {
        [self.titleFieldPost resignFirstResponder];
    }
    [[[UIActionSheet alloc] initWithTitle:@"Where do you want to choose your image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo Gallery", @"Photo Camera", @"Video Gallery", @"Video Camera", nil] showInView:self.view];
}

- (IBAction)buttonSendTouchUpInside:(id)sender {
    
    NSInteger categoryCode = 0;
    
    if (self.buttonCategoryStateMarket.selected)
        categoryCode += 1;
    if (self.buttonCategoryStateCapability.selected)
        categoryCode += 2;
    if (self.buttonCategoryStateCustomer.selected)
        categoryCode += 4;
    if (self.buttonCategoryStatePeople.selected)
        categoryCode += 8;
    
    
    if (!self.textViewPost.text.length) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter text." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else if (!self.buttonPostImage.imageView.image) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please choose image." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        [hud show:YES];
        if ([self.textViewPost isFirstResponder]) {
            [self.textViewPost resignFirstResponder];
        }
        if (self.video == nil)
        {
            [sharedConnect sendPostWithTitle:self.titleFieldPost.text postText:self.textViewPost.text postKeywords:nil postCategory:[NSNumber numberWithInteger:categoryCode] postImage:self.buttonPostImage.imageView.image onCompletion:^(WLIPost *post, ServerResponse serverResponseCode) {
                [hud hide:YES];
                [self.buttonPostImage setImage:nil forState:UIControlStateNormal];
                self.textViewPost.text = @"";
                self.titleFieldPost.text = @"";
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }
        else
        {
            [sharedConnect sendPostWithTitle:self.titleFieldPost.text postText:self.textViewPost.text postKeywords:nil postCategory:[NSNumber numberWithInteger:categoryCode] postImage:self.buttonPostImage.imageView.image postVideo:self.video onCompletion:^(WLIPost *post, ServerResponse serverResponseCode) {
                [hud hide:YES];
                [self.buttonPostImage setImage:nil forState:UIControlStateNormal];
                self.textViewPost.text = @"";
                self.titleFieldPost.text = @"";
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }
    }
}


#pragma mark - UIImagePickerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image;
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"kUTTypeImage"])
    {
        image = [info objectForKey:UIImagePickerControllerEditedImage];
        
        AFPhotoEditorController *photoEditorController = [[AFPhotoEditorController alloc] initWithImage:image];
        photoEditorController.delegate = self;
        [self dismissViewControllerAnimated:YES completion:^{
            [self presentViewController:photoEditorController animated:YES completion:nil];
        }];
    }
    else
    {
        _video = [NSData dataWithContentsOfURL:[info objectForKey:UIImagePickerControllerMediaURL]];
        AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:[info objectForKey:UIImagePickerControllerMediaURL] options:nil];
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:videoAsset];
        generator.appliesPreferredTrackTransform = YES;
        NSError *err = NULL;
        CMTime thumbTime = CMTimeMakeWithSeconds(0,30);
        CGSize maxSize = CGSizeMake(640,480);
        generator.maximumSize = maxSize;
        
        CGImageRef imgRef = [generator copyCGImageAtTime:thumbTime actualTime:NULL error:&err];
        image = [[UIImage alloc] initWithCGImage:imgRef];
        
        [self dismissViewControllerAnimated:YES completion:^{
            [self.buttonPostImage setImage:image forState:UIControlStateNormal];
            [self.buttonPostImage setTitle:@"" forState:UIControlStateNormal];
            if (![self.textViewPost isFirstResponder]) {
                [self.textViewPost becomeFirstResponder];
            }
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (![self.textViewPost isFirstResponder]) {
            [self.textViewPost becomeFirstResponder];
        }
    }];
}


#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Video Gallery"]) {
        UIImagePickerController *videoPickerController = [[UIImagePickerController alloc] init];
        videoPickerController.delegate = self;
        videoPickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
//        videoPickerController.allowsEditing = NO;
        videoPickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        videoPickerController.mediaTypes = @[(NSString *) kUTTypeMovie,
                                             (NSString *) kUTTypeVideo,
                                             (NSString *) kUTTypeQuickTimeMovie,
                                             (NSString *) kUTTypeMPEG,
                                             (NSString *) kUTTypeMPEG4];
        
        [self presentViewController:videoPickerController animated:YES completion:nil];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Video Camera"]) {
        UIImagePickerController *videoPickerController = [[UIImagePickerController alloc] init];
        videoPickerController.delegate = self;
//        videoPickerController.allowsEditing = NO;
        videoPickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        videoPickerController.mediaTypes = @[(NSString *) kUTTypeMovie,
                                             (NSString *) kUTTypeVideo,
                                             (NSString *) kUTTypeQuickTimeMovie,
                                             (NSString *) kUTTypeMPEG,
                                             (NSString *) kUTTypeMPEG4];
        videoPickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        videoPickerController.videoQuality = UIImagePickerControllerQualityType640x480;
        videoPickerController.videoMaximumDuration = 60;
        [self presentViewController:videoPickerController animated:YES completion:nil];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Photo Gallery"]) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    } else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Photo Camera"]) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

#pragma mark - Buttons for post type
-(IBAction)buttonTextPostTouchUpInside:(id)sender
{
    self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, 8, self.contentView.frame.size.width, self.contentView.frame.size.height);
    postType = postTypeText;
}

-(IBAction)buttonPhotoPostTouchUpInside:(id)sender
{
    self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, 88, self.contentView.frame.size.width, self.contentView.frame.size.height);
    postType = postTypePhoto;
}

-(IBAction)buttonVideoPostTouchUpInside:(id)sender
{
    self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, 88, self.contentView.frame.size.width, self.contentView.frame.size.height);
    postType = postTypeVideo;
}


#pragma mark - Buttons for category

-(IBAction)buttonCatMarketTouchUpInside:(id)sender
{
    [self.buttonCategoryStateMarket setSelected:!self.buttonCategoryStateMarket.selected];
    
}

-(IBAction)buttonCatCustomerTouchUpInside:(id)sender
{
    [self.buttonCategoryStateCustomer setSelected:!self.buttonCategoryStateCustomer.selected];

}

-(IBAction)buttonCatCapabilityTouchUpInside:(id)sender
{
    [self.buttonCategoryStateCapability setSelected:!self.buttonCategoryStateCapability.selected];

}

-(IBAction)buttonCatPeopleTouchUpInside:(id)sender
{
    [self.buttonCategoryStatePeople setSelected:!self.buttonCategoryStatePeople.selected];

}



#pragma - AFPhotoEditorController methods

- (void)photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image {
    
    [self.buttonPostImage setImage:image forState:UIControlStateNormal];
    [self.buttonPostImage setTitle:@"" forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:^{
        if (![self.textViewPost isFirstResponder]) {
            [self.textViewPost becomeFirstResponder];
        }
    }];
}

- (void)photoEditorCanceled:(AFPhotoEditorController *)editor {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
