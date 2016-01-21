//
//  WLITimelineFeaturesView.h
//  MyDrive
//
//  Created by Stas Volskyi on 11/30/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

@protocol TimelineFeaturesViewDelegate <NSObject>

@optional

- (void)showMostPopular;

@end

@interface WLITimelineFeaturesView : UIView

@property (weak, nonatomic) id<TimelineFeaturesViewDelegate> delegate;

@end
