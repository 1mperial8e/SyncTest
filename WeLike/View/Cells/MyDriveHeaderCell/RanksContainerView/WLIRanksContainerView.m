//
//  WLIRanksContainerView.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/30/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIRanksContainerView.h"
#import "WLIRanksContainerViewCell.h"

static NSInteger const cellsCount = 5;
static NSInteger const cellHeight = 40;

@interface WLIRanksContainerView() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSArray *dataArray;

@end

@implementation WLIRanksContainerView 

#pragma mark - Lifecycle

- (void)awakeFromNib
{
	[super awakeFromNib];
	self.collectionView.backgroundColor = [UIColor clearColor];
	[self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([WLIRanksContainerViewCell class])
													bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([WLIRanksContainerViewCell class])];
	
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
	cell.rankLabel.text = self.dataArray[indexPath.item];
	if (indexPath.item == 0) {
		cell.countLabel.text = [NSString stringWithFormat:@"%zd", self.user.likesCount];
	}
	if (indexPath.item == 1) {
		cell.countLabel.text = [NSString stringWithFormat:@"%zd", self.user.myPostsCount];
	}
	if (indexPath.item == 2) {
		cell.countLabel.text = [NSString stringWithFormat:@"%zd", self.user.followersCount];
	}
	if (indexPath.item == 3) {
		cell.countLabel.text = [NSString stringWithFormat:@"%zd", self.user.followingCount];
	}
	if (indexPath.item == 4) {
		cell.countLabel.text = [NSString stringWithFormat:@"%zd", self.user.points];
	}	
	return cell;
}

#pragma mark - Accessors

- (void)setUser:(WLIUser *)user
{
	_user = user;
	[self.collectionView reloadData];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.item == 2) {
		if ([self.delegate respondsToSelector:@selector(followersTap)]) {
			[self.delegate followersTap];
		}
	} else if (indexPath.item == 3) {
		if ([self.delegate respondsToSelector:@selector(followingsTap)]) {
			[self.delegate followingsTap];
		}
	}
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold]};
	CGRect textRect = [self.dataArray[indexPath.item] boundingRectWithSize:CGSizeMake(MAXFLOAT, cellHeight/2)
											  options:NSStringDrawingUsesLineFragmentOrigin
										   attributes:attributes
											  context:nil];
	CGFloat averageWidth = CGRectGetWidth([UIScreen mainScreen].bounds) / cellsCount;
	return (averageWidth >= CGRectGetWidth(textRect)) ? CGSizeMake(averageWidth, cellHeight) : CGSizeMake(CGRectGetWidth(textRect), cellHeight);
}

@end
