//
//  WLIFullScreenPhotoViewController.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/25/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIFullScreenPhotoViewController.h"
#import "WLIAppDelegate.h"
#import "WLIHitView.h"

static CGFloat const DefaultScrollViewZoomScale = 1.01f;

@interface WLIFullScreenPhotoViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewHeight;
@property (weak, nonatomic) IBOutlet WLIHitView *backgroundView;

@property (strong, nonatomic) UIImageView *imageView;

@property (assign, nonatomic) BOOL isShown;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *successMessageViewTopConstraint;

@end

@implementation WLIFullScreenPhotoViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isShown = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.scrollView.minimumZoomScale = DefaultScrollViewZoomScale;
    self.backgroundView.viewForTouches = self.scrollView;
    [self buildImageView]; 
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (!self.isShown) {
        self.isShown = YES;
        [self animateAppearance];
    }
}

#pragma mark - Gestures

- (IBAction)doubleTapGesture:(UITapGestureRecognizer *)sender
{
    CGFloat newScale = DefaultScrollViewZoomScale;
    if (self.scrollView.zoomScale <= DefaultScrollViewZoomScale) {
        newScale = self.scrollView.maximumZoomScale;
    }
    [self.scrollView setZoomScale:newScale animated:YES];
}

- (IBAction)longPressGesture:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIAlertView *saveImageAlert = [[UIAlertView alloc] initWithTitle:@"Save image" message:@"Do you want to save this image?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        saveImageAlert.tag = 1;
        [saveImageAlert show];
    }
}

#pragma mark - UI

- (void)buildImageView
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
    CGRect frame = self.presentationRect;
    frame.origin.y += CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + self.navBarHeight;
    imageView.frame = frame;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [self.view addSubview:imageView];
    self.imageView = imageView;
}

#pragma mark - Animations

- (void)animateAppearance
{
    CGFloat duration = 0.3;
    CABasicAnimation *boundsAnim = [CABasicAnimation animationWithKeyPath:@"bounds"];
    boundsAnim.fromValue = [NSValue valueWithCGRect:self.imageView.bounds];
    boundsAnim.toValue = [NSValue valueWithCGRect:[self newBoundsForImageView]];
    
    CABasicAnimation *positionAnim = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnim.fromValue = [NSValue valueWithCGPoint:self.imageView.layer.position];
    positionAnim.toValue = [NSValue valueWithCGPoint:self.view.center];
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = @[boundsAnim, positionAnim];
    animGroup.duration = duration;
    animGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animGroup.removedOnCompletion = NO;
    animGroup.delegate = self;
    [self.imageView.layer addAnimation:animGroup forKey:@"present"];
    
    self.imageView.layer.bounds = [boundsAnim.toValue CGRectValue];
    self.imageView.layer.position = [positionAnim.toValue CGPointValue];
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration animations:^{
        weakSelf.backgroundView.alpha = 1;
    }];
}

- (void)animateHide
{
    CGFloat duration = 0.2;
    CABasicAnimation *boundsAnim = [CABasicAnimation animationWithKeyPath:@"bounds"];
    boundsAnim.fromValue = [NSValue valueWithCGRect:self.imageView.bounds];
    CGRect originBounds = self.presentationRect;
    originBounds.origin = CGPointZero;
    boundsAnim.toValue = [NSValue valueWithCGRect:originBounds];
    
    CGPoint originPosition = CGPointMake(CGRectGetMidX(self.presentationRect), CGRectGetMidY(self.presentationRect));
    originPosition.y += CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + self.navBarHeight;
    CABasicAnimation *positionAnim = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnim.fromValue = [NSValue valueWithCGPoint:self.imageView.layer.position];
    positionAnim.toValue = [NSValue valueWithCGPoint:originPosition];
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = @[boundsAnim, positionAnim];
    animGroup.duration = duration;
    animGroup.removedOnCompletion = NO;
    animGroup.delegate = self;
    [self.imageView.layer addAnimation:animGroup forKey:@"hide"];
    
    self.imageView.layer.bounds = [boundsAnim.toValue CGRectValue];
    self.imageView.layer.position = [positionAnim.toValue CGPointValue];
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration animations:^{
        weakSelf.backgroundView.alpha = 0;
    }];
}

#pragma mark - AnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (anim == [self.imageView.layer animationForKey:@"present"]) {
        [self.imageView.layer removeAllAnimations];
        [self.imageView removeFromSuperview];
        [self.scrollView addSubview:self.imageView];
        self.scrollView.zoomScale = DefaultScrollViewZoomScale;
    } if (anim == [self.imageView.layer animationForKey:@"hide"]) {
        [self.imageView.layer removeAllAnimations];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark - Private

- (CGRect)newBoundsForImageView
{
    CGRect bounds = CGRectZero;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat coef = 1.0;
    CGSize imageSize = self.image.size;
    if (imageSize.width > imageSize.height) {
        coef = screenWidth / imageSize.height;
    } else if (imageSize.width < imageSize.height) {
        coef = screenWidth / imageSize.width;
    } else {
        coef = screenWidth / imageSize.width;
    }
    bounds.size = CGSizeMake(imageSize.width * coef, imageSize.height * coef);
    while (bounds.size.width > screenWidth || bounds.size.height > screenHeight) {
        bounds.size = CGSizeMake(bounds.size.width * 0.98, bounds.size.height * 0.98);
    }
    self.scrollViewWidth.constant = bounds.size.width;
    self.scrollViewHeight.constant = bounds.size.height;
    
    return bounds;
}

- (void)closeController
{
    CGRect frame = self.imageView.frame;
    frame.origin = CGPointMake(self.scrollView.frame.origin.x - self.scrollView.contentOffset.x, self.scrollView.frame.origin.y - self.scrollView.contentOffset.y);
    [self.imageView removeFromSuperview];
    self.imageView.frame = frame;
    [self.view addSubview:self.imageView];
    [self animateHide];
}

- (CGFloat)navBarHeight
{
    UITabBarController *tabBarCOntroller = (UITabBarController *)self.presentingViewController;
    UINavigationController *navController = tabBarCOntroller.viewControllers.firstObject;
    return navController.navigationBar.frame.size.height;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = MAX((scrollView.bounds.size.width - scrollView.contentSize.width) / 2, 0.0);
    CGFloat offsetY = MAX((scrollView.bounds.size.height - scrollView.contentSize.height) / 2, 0.0);
    
    self.imageView.center = CGPointMake(scrollView.contentSize.width / 2 + offsetX, scrollView.contentSize.height / 2 + offsetY);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.zoomScale == DefaultScrollViewZoomScale && self.scrollView.subviews.count) {
        CGFloat offset = MAX(ABS(scrollView.contentOffset.x), ABS(scrollView.contentOffset.y));
        CGFloat newAlpha = ((300 - offset) / 300);
        self.backgroundView.alpha = newAlpha > 0.5 ? newAlpha : 0.5;
        if (offset >= 70 && !self.scrollView.isDragging) {
            [self closeController];
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), nil);
        }
    } else if (alertView.tag == 2) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

#pragma mark - Utils

- (void)image:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void *)ctxInfo
{
    if (error) {
        if (error.code == -3310) {
            UIAlertView *accessAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please provide access to your photos in settings" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
            accessAlert.tag = 2;
            [accessAlert show];
        }
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            weakSelf.successMessageViewTopConstraint.constant = 0;
            [weakSelf.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 delay:1.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.successMessageViewTopConstraint.constant = -20;
                [weakSelf.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            }];
        }];
    }
}

@end
