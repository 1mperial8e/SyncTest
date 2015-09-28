//
//  WLIMyDriveHeaderCell.h
//  MyDrive
//
//  Created by Geir Eliassen on 28/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLITableViewCell.h"
#import "UIImageView+AFNetworking.h"

#import "WLIUser.h"

@class WLIMyDriveHeaderCell;

@interface WLIMyDriveHeaderCell : WLITableViewCell {
    
    CGRect frameDefaultLabelPostTitle;
    CGRect frameDefaultLabelPostText;
    CGRect frameDefaultImageViewPost;
    MPMoviePlayerViewController *movieController;
    
    IBOutlet UIView *topView;
    IBOutlet UIView *middleView;
    IBOutlet UIView *bottomView;
    
}

@property (strong, nonatomic) IBOutlet UIImageView *imageViewUser;
@property (strong, nonatomic) IBOutlet UILabel *labelUserName;
@property (strong, nonatomic) IBOutlet UILabel *labelUserEmail;
@property (strong, nonatomic) IBOutlet UIButton *buttonFollow;



@property (strong, nonatomic) WLIUser *userr;
//@property (weak, nonatomic) id<WLICellDelegate> delegate;




@end
