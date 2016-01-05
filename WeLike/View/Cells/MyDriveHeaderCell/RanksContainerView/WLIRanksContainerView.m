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
		NSArray *viewArray = [[NSBundle mainBundle] loadNibNamed:@"WLIRanksContainerView" owner:self options:nil];
		UIView *subView = [viewArray firstObject];
		subView.frame = frame;
		[self addSubview:subView];
	}
	return self;
}

- (void)awakeFromNib
{		
	self.collectionView.dataSource = self;
	self.collectionView.delegate = self;
	self.collectionView.backgroundColor = [UIColor clearColor];
	self.countLabelArray = [NSMutableArray new];

	[self.collectionView registerNib:[UINib nibWithNibName:@"WLIRanksContainerViewCell"  bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([WLIRanksContainerViewCell class])];
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
	[self.countLabelArray addObject:cell.countLabel];
	return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14 weight:5]};
	CGRect textRect = [self.dataArray[indexPath.item] boundingRectWithSize:CGSizeMake(MAXFLOAT, 20)
											  options:NSStringDrawingUsesLineFragmentOrigin
										   attributes:attributes
											  context:nil];
	//return CGSizeMake(CGRectGetWidth(textRect), 40);
	return CGSizeMake(60, 40);
}

@end
