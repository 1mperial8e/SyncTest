//
//  WLIRegisterTableViewCell.h
//  MyDrive
//
//  Created by Stas Volskyi on 11/9/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIBaseTableViewCell.h"

@interface WLIRegisterTableViewCell : WLIBaseTableViewCell

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@property (copy, nonatomic) void (^registerHandler)();

@end
