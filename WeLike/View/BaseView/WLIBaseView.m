//
//  WLIBaseView.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/30/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIBaseView.h"

@interface WLIBaseView ()

@property (strong, nonatomic) UIView *subView;

@end

@implementation WLIBaseView

- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		[self prepareView];
	}
	return self;	
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self prepareView];
	}
	return self;
}


#pragma mark - Private

- (void)prepareView
{
	NSArray *nibsArray = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
	UIView *view = [nibsArray firstObject];
	
	view.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:view];
	[self addConstraintsForView:view];
}

#pragma mark - Add constraints

- (void)addConstraintsForView:(UIView *)view
{
	[self addConstraints:@[[NSLayoutConstraint constraintWithItem:view
														attribute:NSLayoutAttributeBottom
														relatedBy:NSLayoutRelationEqual
														   toItem:self attribute:NSLayoutAttributeBottom
													   multiplier:1.0
														 constant:0],
						   [NSLayoutConstraint constraintWithItem:view
														attribute:NSLayoutAttributeTop
														relatedBy:NSLayoutRelationEqual
														   toItem:self attribute:NSLayoutAttributeTop
													   multiplier:1.0
														 constant:0],
						   [NSLayoutConstraint constraintWithItem:view
														attribute:NSLayoutAttributeLeft
														relatedBy:NSLayoutRelationEqual
														   toItem:self attribute:NSLayoutAttributeLeft
													   multiplier:1.0
														 constant:0],
						   [NSLayoutConstraint constraintWithItem:view
														attribute:NSLayoutAttributeRight
														relatedBy:NSLayoutRelationEqual
														   toItem:self attribute:NSLayoutAttributeRight
													   multiplier:1.0
														 constant:0]
						   ]];
}

@end
