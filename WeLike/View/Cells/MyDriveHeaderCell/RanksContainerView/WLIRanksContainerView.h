//
//  WLIRanksContainerView.h
//  MyDrive
//
//  Created by Stas Volskyi on 11/30/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIBaseView.h"

@protocol MyDriveHeaderCellRanksDelegate <NSObject>

@optional

- (void)followingsTap;
- (void)followersTap;

@end

@interface WLIRanksContainerView : WLIBaseView

@property (weak, nonatomic) id<MyDriveHeaderCellRanksDelegate> delegate;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) WLIUser *user;

@end
