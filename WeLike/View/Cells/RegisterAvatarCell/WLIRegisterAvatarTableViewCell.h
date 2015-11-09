//
//  WLIRegisterAvatarTableViewCell.h
//  MyDrive
//
//  Created by Stas Volskyi on 11/9/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

@interface WLIRegisterAvatarTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIButton *chooseAvatarButton;

+ (NSString *)ID;
+ (UINib *)nib;

@end
