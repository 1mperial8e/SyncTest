//
//  WLIRanksContainerView.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/30/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIRanksContainerView.h"
#import "WLIRanksContainerViewCell.h"

@interface WLIRanksContainerView() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *dataArray;

@end

@implementation WLIRanksContainerView 

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		NSArray *viewArray = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
		UIView *subView = [viewArray firstObject];
		subView.frame = frame;
		[self addSubview:subView];
	}
	return self;
}

- (void)awakeFromNib
{
	self.collectionView.backgroundColor = [UIColor clearColor];
	self.collectionView.dataSource = self;
	self.collectionView.delegate = self;

	[self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([WLIRanksContainerViewCell class])  bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([WLIRanksContainerViewCell class])];
	self.dataArray = @[@"likes", @"posts", @"followers", @"following", @"points"];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	WLIRanksContainerViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([WLIRanksContainerViewCell class]) forIndexPath:indexPath];
//
//	[cell.layer setCornerRadius:8];
//	if (indexPath.item == 0) {
//		NSString *imageName = [(NSString *)self.dataArray[indexPath.item] substringFromIndex:1];
//		cell.imageView.image = [UIImage imageNamed:imageName];
//	} else {
//		NSString *imageName = [(NSString *)self.dataArray[indexPath.item] substringFromIndex:1];
//		cell.iconImageView.image = [UIImage imageNamed:imageName];
//	}
//	cell.label.text =
	cell.rankLabel.text = self.dataArray[indexPath.item];
	return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//	WLIAppDelegate *appDelegate = (WLIAppDelegate *)[UIApplication sharedApplication].delegate;
//	[appDelegate.timelineViewController showTimelineForSearchString:self.dataArray[indexPath.item]];
}

#pragma mark - UICollectionViewDelegateFlowLayout

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//	return CGSizeMake(20, 20);
//}

@end
