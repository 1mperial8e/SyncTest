//
//  WLINewPostTableViewController.m
//  MyDrive
//
//  Created by Geir Eliassen on 19/10/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLINewPostTableViewController.h"

// Cells
#import "WLINewPostImageCell.h"
#import "WLISelectCountryTableViewCell.h"
#import "WLICategorySelectTableViewCell.h"

@interface WLINewPostTableViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) WLIConnect *sharedConnect;

// MARK: Sharing content
@property (strong, nonatomic) NSString *textContent;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSData *video;

@property (strong, nonatomic) NSMutableDictionary *countryStates;
@property (strong, nonatomic) NSMutableDictionary *catStates;

@end

@implementation WLINewPostTableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"ADD ENERGY";
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    self.sharedConnect = [WLIConnect sharedConnect];
    self.textContent = @"";
    cellIdentifiers = [NSArray arrayWithObjects:@"WLINewPostAttachmentCell", @"WLINewPostTextCell", @"WLINewPostImageCell", @"WLISelectCountryTableViewCell", @"WLICategorySelectTableViewCell", @"WLINewPostCategoryCell", nil];
    
    self.countryStates = [@{@"all" : @NO,
                           @"denmark" : @NO,
                           @"finldand" : @NO,
                           @"norway" : @NO,
                           @"sweden" : @NO} mutableCopy];
    self.catStates = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"market", [NSNumber numberWithBool:NO], @"capability", [NSNumber numberWithBool:NO], @"customer", [NSNumber numberWithBool:NO], @"people", [NSNumber numberWithBool:NO], nil];

    
    self.image = [UIImage imageNamed:@"postPlaceholder"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Publish" style:UIBarButtonItemStylePlain target:self action:@selector(publishButtonAction:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonAction:)];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

#pragma mark - Gestures

- (void)dismissKeyboard:(id)sender
{
    [self.tableView endEditing:NO];
}

#pragma mark - Actions

- (IBAction)buttonAddImageTouchUpInside:(id)sender
{
    NSLog(@"AddImage");
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // Cancel button tappped do nothing.
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Shoot photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self takePhoto];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Select photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self selectPhoto];
    }]];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (IBAction)buttonAddVideoTouchUpInside:(id)sender
{
    NSLog(@"AddVideo");
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // Cancel button tappped do nothing.
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Shoot video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self takeVideo];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Select video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self selectVideo];
    }]];
    [self presentViewController:actionSheet animated:YES completion:nil];
}


- (void)publishButtonAction:(id)sender
{
//    WLIConnect *sharedConnect;
    
    NSInteger categoryCode = 0;

    if ([[self.catStates objectForKey:@"market"] boolValue])
        categoryCode = categoryCode + 1;
    if ([[self.catStates objectForKey:@"capability"] boolValue])
        categoryCode = categoryCode + 1;
    if ([[self.catStates objectForKey:@"customer"] boolValue])
        categoryCode = categoryCode + 1;
    if ([[self.catStates objectForKey:@"people"] boolValue])
        categoryCode = categoryCode + 1;
    
//    if ([[self.countryStates objectForKey:@"all"] boolValue])
//        categoryCode = categoryCode + 1;
//    if ([[self.countryStates objectForKey:@"market"] boolValue])
//        categoryCode = categoryCode + 1;
//    if ([[self.countryStates objectForKey:@"capability"] boolValue])
//        categoryCode = categoryCode + 1;
//    if ([[self.countryStates objectForKey:@"customer"] boolValue])
//        categoryCode = categoryCode + 1;
//    if ([[self.countryStates objectForKey:@"people"] boolValue])
//        categoryCode = categoryCode + 1;
    

    
    if (self.video == nil)
    {
        NSLog(@"Publishing without video");
        [self.sharedConnect sendPostWithTitle:@"" postText:self.textContent postKeywords:nil postCategory:[NSNumber numberWithInteger:categoryCode] postImage:self.image onCompletion:^(WLIPost *post, ServerResponse serverResponseCode) {
            NSLog(@"Server resp: %d", serverResponseCode);
//            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    else
    {
        NSLog(@"Publishing with video");
        [self.sharedConnect sendPostWithTitle:@"" postText:self.textContent postKeywords:nil postCategory:[NSNumber numberWithInteger:categoryCode] postImage:self.image postVideo:self.video onCompletion:^(WLIPost *post, ServerResponse serverResponseCode) {
            NSLog(@"Server resp: %d", serverResponseCode);
//            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    self.textContent = textView.text;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger rowNumber = indexPath.row;
//    NSMutableArray *stratArray = [[NSMutableArray alloc] initWithCapacity:6];
//    NSMutableArray *countryArray = [[NSMutableArray alloc] initWithCapacity:10];

//    if (rowNumber > 0 && !imageSet)
//    {
//        rowNumber = rowNumber + 1;
//    }
    NSLog(@"Hei1: %ld", (long)rowNumber);
    NSString *cellID = [cellIdentifiers objectAtIndex:rowNumber];
    NSLog(@"Hei2");
    UITableViewCell *cell = (UITableViewCell*) [tableView dequeueReusableCellWithIdentifier:cellID];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:cellID owner:self options:nil] lastObject];
    }
    WLISelectCountryTableViewCell *cell3 = (WLISelectCountryTableViewCell*)cell;
    WLICategorySelectTableViewCell *cell4 = (WLICategorySelectTableViewCell*)cell;
    
    switch (rowNumber) {
        case 0: // Select image button
            addPicture = (UIButton *)[cell viewWithTag:1];
            addVideo = (UIButton *)[cell viewWithTag:2];
//            addAttachment = (UIButton *)[cell viewWithTag:3];
            [addPicture addTarget:self action:@selector(buttonAddImageTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            [addVideo addTarget:self action:@selector(buttonAddVideoTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
//            [addAttachment addTarget:self action:@selector(buttonAddAttachmentTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case 2: // Image display
            imageView = (UIImageView *)[cell viewWithTag:1];
            if (self.image != nil)
            {
                WLINewPostImageCell *cell2 = (WLINewPostImageCell*)cell;
                cell2.imgView.image = self.image;
            }
            break;
        case 1: // Text View
            contentTextView = (UITextView *)[cell viewWithTag:1];
            [contentTextView setText:self.textContent];
            contentTextView.delegate = self;

            break;
        case 3:
            cell3.countryDict = self.countryStates;
            break;
        case 4:
            cell4.catDict = self.catStates;
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat ret;
    NSInteger rowNumber = indexPath.row;
//    if (rowNumber > 0 && !imageSet)
//    {
//        rowNumber = rowNumber + 1;
//    }
    switch (rowNumber) {
        case 0: // Select image button
            return 44;
            break;
        case 2: // Image display
            ret = [[UIScreen mainScreen] bounds].size.width * (430.0f / 600.0f);
            NSLog(@"Ret: %f", ret);
            return ret;
            break;
        case 1: // Text View
            return 135;
            break;
        case 3:
            return 52;
            break;
        case 4:
            return 99;
            break;
            
        default:
            return 44;
            break;
    }
    return 44;
}

#pragma mark - Add content

- (void)takePhoto
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)selectPhoto
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)takeVideo
{
    UIImagePickerController *videoPickerController = [[UIImagePickerController alloc] init];
    videoPickerController.delegate = self;
    videoPickerController.mediaTypes = @[(NSString *) kUTTypeMovie,
                                         (NSString *) kUTTypeVideo,
                                         (NSString *) kUTTypeQuickTimeMovie,
                                         (NSString *) kUTTypeMPEG,
                                         (NSString *) kUTTypeMPEG4];
    videoPickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    videoPickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    videoPickerController.videoQuality = UIImagePickerControllerQualityType640x480;
    videoPickerController.videoMaximumDuration = 60;
    [self presentViewController:videoPickerController animated:YES completion:nil];
}

- (void)selectVideo
{
    UIImagePickerController *videoPickerController = [[UIImagePickerController alloc] init];
    videoPickerController.delegate = self;
    videoPickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    videoPickerController.mediaTypes = @[(NSString *) kUTTypeMovie,
                                         (NSString *) kUTTypeVideo,
                                         (NSString *) kUTTypeQuickTimeMovie,
                                         (NSString *) kUTTypeMPEG,
                                         (NSString *) kUTTypeMPEG4];
    [self presentViewController:videoPickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage]) {
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    } else {
        self.video = [NSData dataWithContentsOfURL:[info objectForKey:UIImagePickerControllerMediaURL]];
        AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:[info objectForKey:UIImagePickerControllerMediaURL] options:nil];
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:videoAsset];
        generator.appliesPreferredTrackTransform = YES;
        NSError *error = NULL;
        CMTime time = [videoAsset duration];
        time.value = 1000;
        generator.maximumSize = CGSizeMake(640, 480);
        
        CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:NULL error:&error];
        if (error) {
            NSLog(@"%@", error);
        } else {
            self.image = [UIImage imageWithCGImage:imgRef];
            CGImageRelease(imgRef);
        }
    }
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (![contentTextView isFirstResponder]) {
            [contentTextView becomeFirstResponder];
        }
    }];
}

@end
