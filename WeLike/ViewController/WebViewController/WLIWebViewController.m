//
//  WLIWebViewController.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/30/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIWebViewController.h"

@interface WLIWebViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSURL *url;

@property (strong, nonatomic) UIButton *goBackButton;
@property (strong, nonatomic) UIButton *goForwardButton;

@end

@implementation WLIWebViewController

#pragma mark - Lifecycle

- (instancetype)initWithUrl:(NSURL *)url
{
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    
    [self setupNavigationButtons];
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:self.goForwardButton],
                                                [[UIBarButtonItem alloc] initWithCustomView:self.goBackButton]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:13],
                                                                      NSForegroundColorAttributeName : [UIColor whiteColor]}];
}

#pragma mark - Configure

- (void)setupNavigationButtons
{
    CGRect buttonFrame = CGRectMake(0, 0, 30, 30);
    self.goBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.goBackButton.frame = buttonFrame;
    [self.goBackButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [self.goBackButton setImage:[UIImage imageNamed:@"goBackDisabled"] forState:UIControlStateNormal];
    [self.goBackButton setImage:[UIImage imageNamed:@"goBackIcon"] forState:UIControlStateSelected];
    self.goBackButton.userInteractionEnabled = NO;

    self.goForwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.goForwardButton.frame = buttonFrame;
    [self.goForwardButton addTarget:self action:@selector(goForward:) forControlEvents:UIControlEventTouchUpInside];
    [self.goForwardButton setImage:[UIImage imageNamed:@"goForwardDisabled"] forState:UIControlStateNormal];
    [self.goForwardButton setImage:[UIImage imageNamed:@"goForwardIcon"] forState:UIControlStateSelected];
    self.goForwardButton.userInteractionEnabled = NO;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    self.navigationItem.title = request.URL.absoluteString;
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.goBackButton.selected = self.webView.canGoBack;
    self.goBackButton.userInteractionEnabled = self.webView.canGoBack;
    self.goForwardButton.selected = self.webView.canGoForward;
    self.goForwardButton.userInteractionEnabled = self.webView.canGoForward;
}

#pragma mark - Actions

- (void)goForward:(id)sender
{
    [self.webView goForward];
}

- (void)goBack:(id)sender
{
    [self.webView goBack];
}

@end
