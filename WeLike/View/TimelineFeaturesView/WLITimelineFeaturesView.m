//
//  WLITimelineFeaturesView.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/30/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLITimelineFeaturesView.h"
#import "WLITimelineFeaturesViewCell.h"
#import "WLIAppDelegate.h"

@interface WLITimelineFeaturesView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic)  UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *dataArray;

@end

@implementation WLITimelineFeaturesView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {		
		self.collectionView.backgroundColor = [UIColor clearColor];
		self.collectionView.dataSource = self;
		self.collectionView.delegate = self;
		[self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([WLITimelineFeaturesViewCell class])  bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([WLITimelineFeaturesViewCell class])];
		
		self.dataArray = @[@"most popular", @"#my idea", @"put your activity here"];
	}
	return self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	WLITimelineFeaturesViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([WLITimelineFeaturesViewCell class]) forIndexPath:indexPath];
	
	[cell.layer setCornerRadius:8];
	if (indexPath.item == 1) {
		NSString *imageName = [(NSString *)self.dataArray[indexPath.item] substringFromIndex:1];
		cell.imageView.image = [UIImage imageNamed:imageName];
	} else {
		NSString *imageName = (NSString *)self.dataArray[indexPath.item];
		cell.imageView.image = [UIImage imageNamed:imageName];
	}
	cell.label.text = self.dataArray[indexPath.item];
	return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.item == 1) {
		WLIAppDelegate *appDelegate = (WLIAppDelegate *)[UIApplication sharedApplication].delegate;
		[appDelegate.timelineViewController showTimelineForSearchString:self.dataArray[indexPath.item]];
	} else if (indexPath.item == 0) {
		if ([self.delegate respondsToSelector:@selector(showMostPopular)]) {
			[self.delegate showMostPopular];
		}
	}
}

@end
