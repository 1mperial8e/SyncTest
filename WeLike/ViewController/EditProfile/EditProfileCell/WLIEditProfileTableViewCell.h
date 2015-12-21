//
//  WLIEditProfileTableViewCell.h
//  MyDrive
//
//  Created by Stas Volskyi on 12/21/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIBaseTableViewCell.h"

@interface WLIEditProfileTableViewCell : WLIBaseTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *changePasswordButton;

@property (copy, nonatomic) void (^changePasswordHandler)();

@end
