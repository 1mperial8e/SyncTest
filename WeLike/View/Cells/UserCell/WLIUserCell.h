//
//  WLIUserCell.h
//  WeLike
//
//  Created by Planet 1107 on 07/01/14.
//  Copyright (c) 2014 Planet 1107. All rights reserved.
//

#import "WLIUser.h"
#import "WLITableViewCell.h"

@interface WLIUserCell : WLITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *buttonFollow;

@property (strong, nonatomic) WLIUser *user;
@property (weak, nonatomic) id<WLICellDelegate> delegate;

@end
