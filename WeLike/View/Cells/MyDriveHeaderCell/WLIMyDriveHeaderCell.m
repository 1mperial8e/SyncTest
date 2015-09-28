//
//  WLIMyDriveHeaderCell.m
//  MyDrive
//
//  Created by Geir Eliassen on 28/09/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIMyDriveHeaderCell.h"
#import "WLIConnect.h"

static WLIMyDriveHeaderCell *sharedCell = nil;

@implementation WLIMyDriveHeaderCell
@synthesize userr = _userr;

#pragma mark - Object lifecycle

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.imageViewUser.layer.cornerRadius = self.imageViewUser.frame.size.height/2;
    self.imageViewUser.layer.masksToBounds = YES;
}


#pragma mark - Cell methods

- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self updateFramesAndDataWithDownloads:YES];
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    [self.imageViewUser cancelImageRequestOperation];
    self.imageViewUser.image = nil;
    [_buttonFollow setHidden:NO];
}


- (void)updateFramesAndDataWithDownloads:(BOOL)downloads {
    
    if (self.userr)
    {
        if (downloads)
        {
            WLIConnect *sharedConnect = [WLIConnect sharedConnect];
            [self.imageViewUser setImageWithURL:[NSURL URLWithString:self.userr.userAvatarPath]];
            if (self.userr.userID == sharedConnect.currentUser.userID)
            {
                [_buttonFollow setHidden:YES];
            }
        }
        self.labelUserName.text = self.userr.userFullName;
        self.labelUserEmail.text = self.userr.userEmail;
    }
}



@end
