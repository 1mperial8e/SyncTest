//
//  WLINewPostTableViewController.m
//  MyDrive
//
//  Created by Geir Eliassen on 19/10/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLINewPostTableViewController.h"

// Cells
#import "WLISelectCountryTableViewCell.h"
#import "WLICategorySelectTableViewCell.h"
#import "WLINewPostAttachmentCell.h"
#import "WLINewPostTextCell.h"
#import "WLINewPostImageCell.h"
#import "WLICountrySettings.h"

#import "ALAsset+Copy.h"
#import "VideoConversionService.h"

static NSInteger const captureVideoDuration = 60;

@interface WLINewPostTableViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) WLIConnect *sharedConnect;

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
    [self setupDefaults];
    [self setupTableView];
	[self setupNavigationBar];
	[self setupVideoHUD];
}

#pragma mark - Defaults

- (void)setupNavigationBar
{
	self.navigationItem.title = @"ADD ENERGY";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Publish" style:UIBarButtonItemStylePlain target:self action:@selector(publishButtonAction:)];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonAction:)];
}

- (void)setupVideoHUD
{
	self.videoHud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:self.videoHud];
	self.videoHud.dimBackground = YES;
	self.videoHud.mode = MBProgressHUDModeIndeterminate;
	self.videoHud.labelText = @"Converting video";
}

- (void)setupDefaults
{
    self.sharedConnect = [WLIConnect sharedConnect];
    self.textContent = @"";
	self.countryStates = [NSMutableDictionary new];
	
	NSInteger index = 0;
	for (NSNumber *state in [WLICountrySettings sharedSettings].countriesEnabledState)
	{
		NSString *countryKey = [WLICountrySettings sharedSettings].countries[index];
		self.countryStates[countryKey] = state;
		index++;
	}
    self.catStates = [@{@"market" : @NO, @"capability" : @NO, @"customer" : @NO, @"people" : @NO} mutableCopy];
    
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
}

- (void)setupTableView
{
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.tableView registerNib:WLINewPostAttachmentCell.nib forCellReuseIdentifier:[WLINewPostAttachmentCell ID]];
    [self.tableView registerNib:WLINewPostTextCell.nib forCellReuseIdentifier:[WLINewPostTextCell ID]];
    [self.tableView registerNib:WLINewPostImageCell.nib forCellReuseIdentifier:[WLINewPostImageCell ID]];
    [self.tableView registerNib:WLISelectCountryTableViewCell.nib forCellReuseIdentifier:[WLISelectCountryTableViewCell ID]];
    [self.tableView registerNib:WLICategorySelectTableViewCell.nib forCellReuseIdentifier:[WLICategorySelectTableViewCell ID]];
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
	if (indexPath.row == 0) {
		return [self newPostAttachmentCellForTableView:tableView];
	} else if (indexPath.row == 1) {
		return [self newPostTextCellForTableView:tableView];
	} else if (indexPath.row == 2) {
		return [self newPostImageCellForTableView:tableView];
	} else if (indexPath.row == 3) {
		return [self selectCountryTableViewCellForTableView:tableView];
	} else if (indexPath.row == 4) {
		return [self categorySelectTableViewCellForTableView:tableView];
	}
	return nil;
}

#pragma mark - Setup Cells

- (WLINewPostAttachmentCell *)newPostAttachmentCellForTableView:(UITableView *)tableView
{
	WLINewPostAttachmentCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WLINewPostAttachmentCell class])];
	self.addPicture = cell.addPhotoButton;
	self.addVideo = cell.addVideoButton;
	[self.addPicture addTarget:self action:@selector(buttonAttachTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
	[self.addVideo addTarget:self action:@selector(buttonAttachTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
	return cell;
}

- (WLINewPostTextCell *)newPostTextCellForTableView:(UITableView *)tableView
{
	WLINewPostTextCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WLINewPostTextCell class])];
	self.contentTextView = cell.contentTextView;
	self.contentTextView.text = self.textContent;
	self.contentTextView.delegate = self;
	return cell;
}

- (WLINewPostImageCell *)newPostImageCellForTableView:(UITableView *)tableView
{
	WLINewPostImageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WLINewPostImageCell class])];
    self.imageView = cell.imgView;
	if (self.image) {
		self.imageView.image = [self croppedImageForPreview:self.image];
	}
	return cell;
}

- (WLISelectCountryTableViewCell *)selectCountryTableViewCellForTableView:(UITableView *)tableView
{
	WLISelectCountryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WLISelectCountryTableViewCell class])];
	cell.countryDict = self.countryStates;
	return cell;
}

- (WLICategorySelectTableViewCell *)categorySelectTableViewCellForTableView:(UITableView *)tableView
{
	WLICategorySelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WLICategorySelectTableViewCell class])];
	cell.catDict = self.catStates;
	return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray *heightsArray = @[@44, @135, @([[UIScreen mainScreen] bounds].size.width * (245 / 292.f)), @52, @99];
	if (indexPath.row < heightsArray.count) {
		return [heightsArray[indexPath.row] floatValue];
	}
    return 44;
}

#pragma mark - Actions

- (void)buttonAttachTouchUpInside:(UIButton *)sender
{
	NSString *shootButtonTitle = @"Shoot photo";
	NSString *selectButtonTitle = @"Select photo";
	if (sender == self.addVideo) {
		shootButtonTitle = @"Shoot video";
		selectButtonTitle = @"Select video";
	}
	UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	__weak typeof(self) weakSelf = self;
	
	void (^getContentBlock)(UIImagePickerControllerSourceType) = ^(UIImagePickerControllerSourceType sourceType){
		AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
		if (status == AVAuthorizationStatusAuthorized || status == ALAuthorizationStatusNotDetermined) {
			[weakSelf getContentWithSourceType:sourceType videoContent:(sender == self.addVideo)];
		} else {
			if (sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
				[weakSelf showMediaAccessAlert:@"Please provide access to your content in settings" ];
			} else {
				[weakSelf showMediaAccessAlert:@"Please provide access to your camera in settings" ];
			}
		}
	};
	
	[actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	[actionSheet addAction:[UIAlertAction actionWithTitle:shootButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		getContentBlock(UIImagePickerControllerSourceTypeCamera);
	}]];
	
	[actionSheet addAction:[UIAlertAction actionWithTitle:selectButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		getContentBlock(UIImagePickerControllerSourceTypePhotoLibrary);
	}]];
	[self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)publishButtonAction:(id)sender
{
	[self.tableView endEditing:YES];
	
	if (self.textContent.length != 0 || self.image || self.video) {
		[self.sharedConnect sendPostWithCountries:[self setSelectedCountriesId] postText:self.textContent postKeywords:nil postCategory:[self setCategoriesCode] postImage:self.image postVideo:self.video onCompletion:nil];
		[self dismissViewControllerAnimated:YES completion:nil];
	} else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please add some content" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	}
}

- (void)cancelButtonAction:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Add content

- (void)getContentWithSourceType:(UIImagePickerControllerSourceType)sourceType videoContent:(BOOL)isVideo
{
	if ((sourceType == UIImagePickerControllerSourceTypeCamera) && ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No Camera Available." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		return;
	}

	UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
	pickerController.delegate = self;
	pickerController.sourceType = sourceType;
	if (isVideo) {
		pickerController.mediaTypes = @[(NSString *)kUTTypeMovie,
										(NSString *)kUTTypeVideo,
										(NSString *)kUTTypeQuickTimeMovie,
										(NSString *)kUTTypeMPEG,
										(NSString *)kUTTypeMPEG4];
		if (sourceType == UIImagePickerControllerSourceTypeCamera ) {
			pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
			pickerController.videoQuality = UIImagePickerControllerQualityTypeIFrame1280x720;
			pickerController.videoMaximumDuration = captureVideoDuration;
		}
	}
	[self presentViewController:pickerController animated:YES completion:nil];	
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
        NSURL *assetUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
        if (assetUrl) {
            [self convertAssetAtUrl:assetUrl];
        } else {
            NSString *tmpFilePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:[NSUUID UUID].UUIDString] stringByAppendingPathExtension:@"mp4"];
            [self copyFileAtUrl:info[UIImagePickerControllerMediaURL] toPath:tmpFilePath];
        }
    }
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	__weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        if (![weakSelf.contentTextView isFirstResponder]) {
            [weakSelf.contentTextView becomeFirstResponder];
        }
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}

#pragma mark - Utils

- (NSNumber *)setCategoriesCode
{
	NSInteger categoryCode = 0;
	if ([self.catStates[@"market"] boolValue]) {
		categoryCode += 1;
	}
	if ([self.catStates[@"capability"] boolValue]) {
		categoryCode += 2;
	}
	if ([self.catStates[@"customer"] boolValue]) {
		categoryCode += 4;
	}
	if ([self.catStates[@"people"] boolValue]) {
		categoryCode += 8;
	}
	return @(categoryCode);
}

- (NSString *)setSelectedCountriesId
{
	NSString *selectedCountriesId = @"";
	NSInteger index = 0;
	for (NSString *currentKey in [WLICountrySettings sharedSettings].countries)
	{
		NSString *currentValue = [NSString stringWithFormat:@"%li",(long)index+1];
		if ([self.countryStates[currentKey] boolValue]) {
			if (selectedCountriesId.length > 0) {
			 selectedCountriesId = [selectedCountriesId stringByAppendingString:@","];
			}
			selectedCountriesId = [selectedCountriesId stringByAppendingString:currentValue];
		}
		index++;
	}
	return selectedCountriesId;
}

- (UIImage *)croppedImageForPreview:(UIImage *)srcImage
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat viewWidth = screenSize.width - 8;
    CGFloat viewHeight = (viewWidth * 245) / 292;
    CGFloat coef = 1;
    CGRect drawRect = CGRectZero;
    if (srcImage.size.height >= srcImage.size.width) {
        coef = srcImage.size.width / viewWidth;
        drawRect.origin.x = 0;
        drawRect.origin.y = -(srcImage.size.height - ((srcImage.size.width * 245) / 292)) / 2;
    } else {
        coef = srcImage.size.height / viewHeight;
        drawRect.origin.y = 0;
        drawRect.origin.x = -(srcImage.size.width - ((srcImage.size.height * 292) / 245)) / 2;
    }
    drawRect.size = srcImage.size;
    UIGraphicsBeginImageContext(CGSizeMake(viewWidth * coef, viewHeight * coef));
    [srcImage drawInRect:drawRect];
    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return croppedImage;
}

- (UIImage *)scaledImage:(UIImage *)srcImage
{
    CGFloat coef = ScaledImageSize.width / MAX(srcImage.size.width, srcImage.size.width);
    CGSize drawSize = CGSizeMake(srcImage.size.width * coef, srcImage.size.height * coef);
    UIGraphicsBeginImageContext(drawSize);
    [srcImage drawInRect:CGRectMake(0, 0, drawSize.width, drawSize.height)];
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

- (void)showMediaAccessAlert:(NSString *)alertMessage
{
	UIAlertView *accessAlert = [[UIAlertView alloc] initWithTitle:nil message:alertMessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
	[accessAlert show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != alertView.cancelButtonIndex) {
		NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
		[[UIApplication sharedApplication] openURL:url];
	}
}

@end
