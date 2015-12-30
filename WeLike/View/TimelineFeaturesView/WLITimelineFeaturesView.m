//
//  WLITimelineFeaturesView.m
//  MyDrive
//
//  Created by Roman R on 30.12.15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLITimelineFeaturesView.h"
#import "WLITimelineFeaturesViewCell.h"

@interface WLITimelineFeaturesView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *dataArray;

@end

@implementation WLITimelineFeaturesView

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	NSArray *viewArray = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
	UIView *subView = [viewArray firstObject];
	subView.frame = frame;
	[self addSubview:subView];
	return self;
}

- (void)awakeFromNib {
	self.collectionView.backgroundColor = [UIColor clearColor];
	self.collectionView.dataSource = self;
	self.collectionView.delegate = self;
	
	[self.collectionView registerNib:[UINib nibWithNibName:@"WLITimelineFeaturesViewCell"  bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([WLITimelineFeaturesViewCell class])];
	
	self.dataArray = [NSArray arrayWithObjects:@"digitalweek", @"marketing", @"customer", @"capability", @"people", nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	WLITimelineFeaturesViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([WLITimelineFeaturesViewCell class]) forIndexPath:indexPath];
	cell.backgroundColor = [UIColor redColor];
	[cell.layer setCornerRadius:8];
	
	if (indexPath.item == 0) {
		cell.imageView.image = [UIImage imageNamed:@"digitalWeek"];
	} else {
		cell.iconImageView.image = [UIImage imageNamed:self.dataArray[indexPath.item]];
	}
	cell.label.text = [@"#" stringByAppendingString: self.dataArray[indexPath.item]];
	return cell;
}

@end
