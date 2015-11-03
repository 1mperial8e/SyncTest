//
//  WLINewPostTableViewController.m
//  MyDrive
//
//  Created by Geir Eliassen on 19/10/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLINewPostTableViewController.h"
#import "WLICountrySelectTableViewController.h"
#import "WLIStrategySelectTableViewController.h"
#import "WLINewPostImageCell.h"
#import "WLISelectCountryTableViewCell.h"
#import "WLICategorySelectTableViewCell.h"

#import <QuartzCore/QuartzCore.h>


@interface WLINewPostTableViewController ()

@end

@implementation WLINewPostTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    cellIdentifiers = [NSArray arrayWithObjects:@"WLINewPostAttachmentCell", @"WLINewPostTextCell", @"WLINewPostImageCell", @"WLISelectCountryTableViewCell", @"WLICategorySelectTableViewCell", @"WLINewPostCategoryCell", nil];
    
//    self.countries = [NSMutableArray arrayWithObjects:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Denmark", @"name", [NSNumber numberWithBool:NO], @"isOn", nil], [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Finland", @"name", [NSNumber numberWithBool:NO], @"isOn", nil], [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Norway", @"name", [NSNumber numberWithBool:NO], @"isOn", nil], [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Sweden", @"name", [NSNumber numberWithBool:NO], @"isOn", nil], nil];
    
    self.countryStates = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"all", [NSNumber numberWithBool:NO], @"denmark", [NSNumber numberWithBool:NO], @"finldand", [NSNumber numberWithBool:NO], @"norway", [NSNumber numberWithBool:NO], @"sweden", [NSNumber numberWithBool:NO], nil];
    self.catStates = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"market", [NSNumber numberWithBool:NO], @"capability", [NSNumber numberWithBool:NO], @"customer", [NSNumber numberWithBool:NO], @"people", [NSNumber numberWithBool:NO], nil];

    
//    self.strategies = [NSMutableArray arrayWithObjects:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Market", @"name", [NSNumber numberWithBool:NO], @"isOn", [NSNumber numberWithInteger:1], @"catCode", nil], [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Customer", @"name", [NSNumber numberWithBool:NO], @"isOn", [NSNumber numberWithInteger:2], @"catCode", nil], [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Capabilities", @"name", [NSNumber numberWithBool:NO], @"isOn", [NSNumber numberWithInteger:4], @"catCode", nil], [NSMutableDictionary dictionaryWithObjectsAndKeys:@"People", @"name", [NSNumber numberWithBool:NO], @"isOn", [NSNumber numberWithInteger:8], @"catCode", nil], nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.image = [UIImage imageNamed:@"postPlaceholder"];
    imageSet = NO;
    
    UIButton *publishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    publishButton.adjustsImageWhenHighlighted = NO;
    publishButton.frame = CGRectMake(0.0f, 0.0f, 70.0f, 30.0f);
//    [backButton setImage:[UIImage imageNamed:@"nav-btn-search"] forState:UIControlStateNormal];
    [publishButton setTitle:@"Publish" forState:UIControlStateNormal];
    [publishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [publishButton addTarget:self action:@selector(publishButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:publishButton];
    
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.adjustsImageWhenHighlighted = NO;
    cancelButton.frame = CGRectMake(0.0f, 0.0f, 70.0f, 30.0f);
    //    [backButton setImage:[UIImage imageNamed:@"nav-btn-search"] forState:UIControlStateNormal];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];

    
    [tableViewRefresh reloadData];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"View Did Appear");
    [tableViewRefresh reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dismissKeyboard
{
    if ([contentTextView isFirstResponder]) {
        [contentTextView resignFirstResponder];
    }
}

- (IBAction)buttonAddImageTouchUpInside:(id)sender
{
    NSLog(@"AddImage");
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // Cancel button tappped do nothing.
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Shoot photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self shootPhoto];
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
        [self shootVideo];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Select video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self selectVideo];
    }]];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (IBAction)buttonAddAttachmentTouchUpInside:(id)sender
{
    NSLog(@"AddAttachment");
}


- (IBAction)publishButtonTouchUpInside:(id)sender
{
    WLIConnect *sharedConnect;
    
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
        [sharedConnect sendPostWithTitle:@"" postText:self.textContent postKeywords:nil postCategory:[NSNumber numberWithInteger:categoryCode] postImage:self.image onCompletion:^(WLIPost *post, ServerResponse serverResponseCode) {
            NSLog(@"Server resp: %d", serverResponseCode);
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    else
    {
        [sharedConnect sendPostWithTitle:@"" postText:self.textContent postKeywords:nil postCategory:[NSNumber numberWithInteger:categoryCode] postImage:self.image postVideo:self.video onCompletion:^(WLIPost *post, ServerResponse serverResponseCode) {
            NSLog(@"Server resp: %d", serverResponseCode);
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)cancelButtonTouchUpInside:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    self.textContent = textView.text;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Testing testing testing");

//    if (!imageSet)
//    {
//        return 4;
//    }
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger rowNumber = indexPath.row;
    NSMutableArray *stratArray = [[NSMutableArray alloc] initWithCapacity:6];
    NSMutableArray *countryArray = [[NSMutableArray alloc] initWithCapacity:10];

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
        case 0:
            addPicture = (UIButton *)[cell viewWithTag:1];
            addVideo = (UIButton *)[cell viewWithTag:2];
//            addAttachment = (UIButton *)[cell viewWithTag:3];
            [addPicture addTarget:self action:@selector(buttonAddImageTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            [addVideo addTarget:self action:@selector(buttonAddVideoTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
//            [addAttachment addTarget:self action:@selector(buttonAddAttachmentTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case 2:
            imageView = (UIImageView *)[cell viewWithTag:1];
            if (self.image != nil)
            {
                WLINewPostImageCell *cell2 = (WLINewPostImageCell*)cell;
                cell2.img = self.image;
            }
            break;
        case 1:
            contentTextView = (UITextView *)[cell viewWithTag:1];
            [contentTextView setText:self.textContent];
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
        case 0:
            return 44;
            break;
        case 2:
            ret = [[UIScreen mainScreen] bounds].size.width * (430.0f / 600.0f);
            NSLog(@"Ret: %f", ret);
            return ret;
            break;
        case 1:
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
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    NSInteger rowNumber = indexPath.row;
////    if (rowNumber > 0 && !imageSet)
////    {
////        rowNumber = rowNumber + 1;
////    }
//    if (rowNumber == 4)
//    {
//        WLICountrySelectTableViewController *countrySelectViewController = [[WLICountrySelectTableViewController alloc] initWithNibName:@"WLICountrySelectTableViewController" bundle:nil];
//        //    profileNavigationController.navigationBar.translucent = NO;
//        [self.navigationController pushViewController:countrySelectViewController animated:YES];
//        [countrySelectViewController setPostViewController:self];
//    }
//    else if (rowNumber == 3)
//    {
//        WLIStrategySelectTableViewController *strategySelectViewController = [[WLIStrategySelectTableViewController alloc] initWithNibName:@"WLIStrategySelectTableViewController" bundle:nil];
//        //    profileNavigationController.navigationBar.translucent = NO;
//        [self.navigationController pushViewController:strategySelectViewController animated:YES];
//        [strategySelectViewController setPostViewController:self];
//    }
//    if ([contentTextView isFirstResponder]) {
//        [contentTextView resignFirstResponder];
//    }
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void)shootPhoto
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

-(void)selectPhoto
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

-(void)shootVideo
{
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
}

-(void)selectVideo
{
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
}
#pragma mark - UIImagePickerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //    UIImage *image;
    NSLog(@"Image type: %@ - %@", [info objectForKey:UIImagePickerControllerMediaType], kUTTypeImage);
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeImage])
    {
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
//        self.image = [info objectForKey:UIImagePickerControllerEditedImage];
        NSLog(@"Ferdig med bildet");
        imageSet = YES;
        
        //        AFPhotoEditorController *photoEditorController = [[AFPhotoEditorController alloc] initWithImage:image];
        //        photoEditorController.delegate = self;
        [self dismissViewControllerAnimated:YES completion:^{
            NSLog(@"Should reload");
            [tableViewRefresh reloadData];
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
        self.image = [[UIImage alloc] initWithCGImage:imgRef];
        NSLog(@"Ferdig med bildet2");
        imageSet = YES;
        
        [self dismissViewControllerAnimated:YES completion:^{
            [tableViewRefresh reloadData];
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (![contentTextView isFirstResponder]) {
            [contentTextView becomeFirstResponder];
        }
    }];
}

@end
