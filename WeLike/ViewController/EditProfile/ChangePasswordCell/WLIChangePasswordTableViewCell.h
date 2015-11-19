//
//  WLIChangePasswordTableViewCell.h
//  MyDrive
//
//  Created by Stas Volskyi on 11/19/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIBaseTableViewCell.h"

@interface WLIChangePasswordTableViewCell : WLIBaseTableViewCell

@property (weak, nonatomic) IBOutlet UIButton *changePasswordButton;

@property (copy, nonatomic) void (^changePasswordHandler)();

@end
