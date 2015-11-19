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

#import "ALAsset+Copy.h"
#import "VideoConversionService.h"

static NSString *const AttachmentCellId = @"WLINewPostAttachmentCell";
static NSString *const TextCellId = @"WLINewPostTextCell";
static NSString *const ImageCellId = @"WLINewPostImageCell";
static NSString *const CountryCellId = @"WLISelectCountryTableViewCell";
static NSString *const CategoryCellId = @"WLICategorySelectTableViewCell";

@interface WLINewPostTableViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) WLIConnect *sharedConnect;

// MARK: Sharing content
@property (strong, nonatomic) NSString *textContent;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSData *video;

@property (strong, nonatomic) NSMutableDictionary *countryStates;
@property (strong, nonatomic) NSMutableDictionary *catStates;

@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (strong, nonatomic) MBProgressHUD *videoHud;

@end

@implementation WLINewPostTableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"ADD ENERGY";
    
    [self setupDefaults];
    [self setupTableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Publish" style:UIBarButtonItemStylePlain target:self action:@selector(publishButtonAction:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonAction:)];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
    
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    self.videoHud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.videoHud];
    self.videoHud.dimBackground = YES;
    self.videoHud.mode = MBProgressHUDModeIndeterminate;
    self.videoHud.labelText = @"Converting video";
}

#pragma mark - Defaults

- (void)setupDefaults
{
    self.sharedConnect = [WLIConnect sharedConnect];
    self.textContent = @"";
    self.countryStates = [@{@"all" : @YES, @"denmark" : @NO, @"finland" : @NO, @"norway" : @NO, @"sweden" : @NO} mutableCopy];
    self.catStates = [@{@"market" : @NO, @"capability" : @NO, @"customer" : @NO, @"people" : @NO} mutableCopy];
}

- (void)setupTableView
{
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.tableView registerNib:[UINib nibWithNibName:AttachmentCellId bundle:nil] forCellReuseIdentifier:AttachmentCellId];
    [self.tableView registerNib:[UINib nibWithNibName:TextCellId bundle:nil] forCellReuseIdentifier:TextCellId];
    [self.tableView registerNib:[UINib nibWithNibName:ImageCellId bundle:nil] forCellReuseIdentifier:ImageCellId];
    [self.tableView registerNib:[UINib nibWithNibName:CountryCellId bundle:nil] forCellReuseIdentifier:CountryCellId];
    [self.tableView registerNib:[UINib nibWithNibName:CategoryCellId bundle:nil] forCellReuseIdentifier:CategoryCellId];
}

#pragma mark - Gestures

- (void)dismissKeyboard:(id)sender
{
    [self.tableView endEditing:NO];
}

#pragma mark - Actions

- (IBAction)buttonAddImageTouchUpInside:(id)sender
{
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
        categoryCode = categoryCode + 2;
    if ([[self.catStates objectForKey:@"customer"] boolValue])
        categoryCode = categoryCode + 4;
    if ([[self.catStates objectForKey:@"people"] boolValue])
        categoryCode = categoryCode + 8;
    NSString *countries = @"";
    if ([[self.countryStates objectForKey:@"all"] boolValue]) {
        countries = [countries stringByAppendingString:@"0"];
    } else {
        BOOL addComa = NO;
        if ([[self.countryStates objectForKey:@"denmark"] boolValue]) {
            countries = [countries stringByAppendingString:@"1"];
            addComa = YES;
        }
        if ([[self.countryStates objectForKey:@"finland"] boolValue]) {
            if (addComa) {
                countries = [countries stringByAppendingString:@","];
            }
            addComa = YES;
            countries = [countries stringByAppendingString:@"2"];
        }
        if ([[self.countryStates objectForKey:@"norway"] boolValue]){
            if (addComa) {
                countries = [countries stringByAppendingString:@","];
            }
            addComa = YES;
            countries = [countries stringByAppendingString:@"3"];
        }
        if ([[self.countryStates objectForKey:@"sweden"] boolValue]){
            if (addComa) {
                countries = [countries stringByAppendingString:@","];
            }
            addComa = YES;
            countries = [countries stringByAppendingString:@"4"];
        }
    }
    
    [self.sharedConnect sendPostWithCountries:countries postText:self.textContent postKeywords:nil postCategory:@(categoryCode) postImage:self.image postVideo:self.video onCompletion:nil];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowNumber = indexPath.row;

    UITableViewCell *cell;
    
    switch (rowNumber) {
        case 0: { // Select image button
            cell = [tableView dequeueReusableCellWithIdentifier:AttachmentCellId];
            addPicture = [cell viewWithTag:1];
            addVideo = [cell viewWithTag:2];
            [addPicture addTarget:self action:@selector(buttonAddImageTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            [addVideo addTarget:self action:@selector(buttonAddVideoTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            break;
        }
        case 1: { // Text View
            cell = [tableView dequeueReusableCellWithIdentifier:TextCellId];
            contentTextView = [cell viewWithTag:1];
            contentTextView.text = self.textContent;
            contentTextView.delegate = self;
            break;
        }
        case 2: {// Image display
            cell = [tableView dequeueReusableCellWithIdentifier:ImageCellId];
            imageView = [cell viewWithTag:1];
            if (self.image != nil) {
                imageView.image = self.image;
            }
            break;
        }
        case 3: {
            cell = [tableView dequeueReusableCellWithIdentifier:CountryCellId];
            ((WLISelectCountryTableViewCell *)cell).countryDict = self.countryStates;
            break;
        }
        case 4: {
            cell = [tableView dequeueReusableCellWithIdentifier:CategoryCellId];
            ((WLICategorySelectTableViewCell *)cell).catDict = self.catStates;
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat ret;
    NSInteger rowNumber = indexPath.row;

    switch (rowNumber) {
        case 0: // Select image button
            return 44;
            break;
        case 2: // Image display
            ret = [[UIScreen mainScreen] bounds].size.width * (480.0f / 640.0f);
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
    imagePickerController.allowsEditing = YES;
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
    videoPickerController.videoQuality = UIImagePickerControllerQualityTypeIFrame1280x720;
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
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        if (!image) {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        self.image = [self scaledImage:image];
        self.video = nil;
    } else {
//        self.video = [NSData dataWithContentsOfURL:info[UIImagePickerControllerMediaURL]];

        NSURL *assetUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
        if (assetUrl) {
            [self convertAssetAtUrl:assetUrl];
        } else {
            NSString *tmpFilePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:[NSUUID UUID].UUIDString] stringByAppendingPathExtension:@"mp4"];
            [self copyFileAtUrl:info[UIImagePickerControllerMediaURL] toPath:tmpFilePath];
        }
//        self.video = [NSData dataWithContentsOfURL:[info objectForKey:UIImagePickerControllerMediaURL]];
//        AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:[info objectForKey:UIImagePickerControllerMediaURL] options:nil];
//        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:videoAsset];
//        generator.appliesPreferredTrackTransform = YES;
//        NSError *error = NULL;
//        CMTime time = [videoAsset duration];
//        time.value = 1000;
//        generator.maximumSize = ScaledImageSize;
//        
//        CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:NULL error:&error];
//        if (error) {
//            NSLog(@"%@", error);
//        } else {
//            self.image = [UIImage imageWithCGImage:imgRef];
//            CGImageRelease(imgRef);
//        }
    }
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (![contentTextView isFirstResponder]) {
            [contentTextView becomeFirstResponder];
        }
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}

#pragma mark - Utils

- (UIImage *)scaledImage:(UIImage *)srcImage
{
    UIGraphicsBeginImageContext(ScaledImageSize);
    [srcImage drawInRect:CGRectMake(0, -(srcImage.size.height - ScaledImageSize.height) / 2, srcImage.size.width, srcImage.size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (void)convertAssetAtUrl:(NSURL *)url
{
    [self.videoHud show:YES];
    __weak typeof(self) weakSelf = self;
    void (^copyAssetBlock)(ALAsset *) = ^(ALAsset *asset) {
        NSString *tmpFilePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:[NSUUID UUID].UUIDString] stringByAppendingPathExtension:@"mp4"];
        [asset asyncCopyToFileWithPath:tmpFilePath completion:^(BOOL success) {
            if (success) {
                [weakSelf decodeVideoAtPath:tmpFilePath];
            } else {
                NSLog(@"Can't copy asset");
            }
        }];
    };
    
    [self.assetsLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
        copyAssetBlock(asset);
    } failureBlock:^(NSError *error) {
        NSLog(@"Can't find asset");
    }];
}

- (void)copyFileAtUrl:(NSURL *)inputUrl toPath:(NSString *)newFilePath
{
    NSError *error;
    [[NSFileManager defaultManager] copyItemAtPath:inputUrl.path toPath:newFilePath error:&error];
    if (!error) {
        [self decodeVideoAtPath:newFilePath];
    } else {
        NSLog(@"error: %@", error);
        [[NSFileManager defaultManager] removeItemAtPath:inputUrl.path error:&error];
    }
}

- (void)decodeVideoAtPath:(NSString *)filePath
{
    [self.videoHud show:YES];
    __weak typeof(self) weakSelf = self;
    NSString *newPath = [[filePath.stringByDeletingPathExtension stringByAppendingFormat:@"_encoded"] stringByAppendingPathExtension:@"mp4"];
    [[VideoConversionService sharedService] convertVideoToLowQuailtyWithInputURL:[NSURL fileURLWithPath:filePath] outputURL:[NSURL fileURLWithPath:newPath] fileId:[NSUUID UUID].UUIDString withCompletion:^(NSString *path) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf convertionFinished:filePath copressed:path];
        });
    }];
}

- (void)convertionFinished:(NSString *)srcVideoPath copressed:(NSString *)compressedVideoPath
{
    self.video = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:compressedVideoPath]];
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:compressedVideoPath] options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:videoAsset];
    generator.appliesPreferredTrackTransform = YES;
    NSError *error = nil;
    CMTime time = [videoAsset duration];
    time.value = 1000;
    generator.maximumSize = ScaledImageSize;
    
    CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:NULL error:&error];
    if (error) {
        NSLog(@"%@", error);
    } else {
        self.image = [UIImage imageWithCGImage:imgRef];
        CGImageRelease(imgRef);
    }
    [self.videoHud hide:YES];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:srcVideoPath error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:compressedVideoPath error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
}

@end
