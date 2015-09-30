//
//  WLIPostCell.m
//  WeLike
//
//  Created by Planet 1107 on 20/11/13.
//  Copyright (c) 2013 Planet 1107. All rights reserved.
//

#import "WLIPostCell.h"
#import "WLIConnect.h"

static WLIPostCell *sharedCell = nil;

@implementation WLIPostCell

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
    frameDefaultLabelPostTitle = self.labelPostTitle.frame;
    frameDefaultLabelPostText = self.labelPostText.frame;
    //frameDefaultImageViewPost = self.imageViewPostImage.frame;
    
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
    [self.imageViewPostImage cancelImageRequestOperation];
    self.imageViewPostImage.image = nil;
    self.labelPostTitle.frame = frameDefaultLabelPostTitle;
    self.labelPostText.frame = frameDefaultLabelPostText;
    [self.buttonVideo setHidden:YES];
    [_buttonConnect setHidden:NO];
    [self.buttonDelete setHidden:YES];
    self.showDeleteButton = NO;
}

+ (CGSize)sizeWithPost:(WLIPost*)post {
    
    if (!sharedCell) {
        sharedCell = [[[NSBundle mainBundle] loadNibNamed:@"WLIPostCell" owner:nil options:nil] lastObject];
    }
    [sharedCell prepareForReuse];
    sharedCell.post = post;
    [sharedCell updateFramesAndDataWithDownloads:NO];
    
    CGSize size = CGSizeMake(sharedCell.frame.size.width, CGRectGetMaxY(sharedCell.labelPostText.frame) + 8.0f +10.0f);
    
    return size;
}

- (void)updateFramesAndDataWithDownloads:(BOOL)downloads {
    
    if (self.post) {
        if (downloads) {
            [self.imageViewUser setImageWithURL:[NSURL URLWithString:self.post.user.userAvatarPath]];
            if (self.post.postVideoPath.length)
            {
                [self.buttonVideo setHidden:NO];
            }
        }
        self.labelUserName.text = self.post.user.userFullName;
        self.labelTimeAgo.text = self.post.postTimeAgo;
        
        //Set and resize
        self.labelPostTitle.text = self.post.postTitle;
        [self.labelPostTitle sizeToFit];
        if (self.labelPostTitle.frame.size.width < frameDefaultLabelPostTitle.size.width) {
            self.labelPostTitle.frame = CGRectMake(self.labelPostTitle.frame.origin.x, self.labelPostTitle.frame.origin.y, frameDefaultLabelPostTitle.size.width, self.labelPostTitle.frame.size.height);
        }
        if (self.labelPostTitle.frame.size.height < frameDefaultLabelPostTitle.size.height) {
            self.labelPostTitle.frame = CGRectMake(self.labelPostTitle.frame.origin.x, self.labelPostTitle.frame.origin.y, self.labelPostTitle.frame.size.width, frameDefaultLabelPostTitle.size.height);
        }
        
        NSString *descriptionText = self.post.postText;
        CGSize tempSize;
        tempSize.width = self.labelPostText.bounds.size.width;
        tempSize.height = 9999;
        
        CGRect theRect = [descriptionText boundingRectWithSize:tempSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.labelPostText.font} context:nil];
        self.labelPostText.bounds = CGRectMake(self.labelPostText.bounds.origin.x, self.labelPostText.bounds.origin.y, self.labelPostText.bounds.size.width, theRect.size.height);
        [self.labelPostText setNumberOfLines:100];
        self.labelPostText.text = self.post.postText;
        
        if (self.post.postImagePath.length) {
//            self.buttonLike.frame = CGRectMake(self.buttonLike.frame.origin.x, CGRectGetMaxY(self.imageViewPostImage.frame) + 18, self.buttonLike.frame.size.width, self.buttonLike.frame.size.height);
//            self.buttonComment.frame = CGRectMake(self.buttonComment.frame.origin.x, CGRectGetMaxY(self.imageViewPostImage.frame) + 16, self.buttonComment.frame.size.width, self.buttonComment.frame.size.height);
//            self.buttonLikes.frame = CGRectMake(self.buttonLikes.frame.origin.x, CGRectGetMaxY(self.imageViewPostImage.frame) -self.buttonLike.frame.size.height, self.buttonLikes.frame.size.width, self.buttonLikes.frame.size.height);
            
            if (downloads) {
                [self.imageViewPostImage setImageWithURL:[NSURL URLWithString:self.post.postImagePath]];
                if (self.post.postVideoPath.length)
                {
                    [self.buttonVideo setHidden:NO];
                }
            }
        } else {
//            self.buttonLike.frame = CGRectMake(self.buttonLike.frame.origin.x, CGRectGetMinY(self.imageViewPostImage.frame), self.buttonLike.frame.size.width, self.buttonLike.frame.size.height);
//            self.buttonComment.frame = CGRectMake(self.buttonComment.frame.origin.x, CGRectGetMinY(self.imageViewPostImage.frame), self.buttonComment.frame.size.width, self.buttonComment.frame.size.height);
//            self.buttonLikes.frame = CGRectMake(self.buttonLikes.frame.origin.x, CGRectGetMinY(self.imageViewPostImage.frame), self.buttonLikes.frame.size.width, self.buttonLikes.frame.size.height);
        }
        
        if (self.post.likedThisPost) {
             [self.buttonLike setSelected:YES];
        } else {
            [self.buttonLike setSelected:NO];
        }
        if (self.post.isConnected) {
            [self.buttonConnect setSelected:YES];
        } else {
            [self.buttonConnect setSelected:NO];
        }
        
        if (!self.post.categoryMarket) {
            [self.buttonCatMarket setHidden:YES];
        } else {
            [self.buttonCatMarket setHidden:NO];
        }
        if (!self.post.categoryCapabilities) {
            [self.buttonCatCapabilities setHidden:YES];
        } else {
            [self.buttonCatCapabilities setHidden:NO];
        }
        if (!self.post.categoryCustomer) {
            [self.buttonCatCustomer setHidden:YES];
        } else {
            [self.buttonCatCustomer setHidden:NO];
        }
        if (!self.post.categoryPeople) {
            [self.buttonCatPeople setHidden:YES];
        } else {
            [self.buttonCatPeople setHidden:NO];
        }
        
        [self.labelLikes setText:[NSString stringWithFormat:@"%d", self.post.postLikesCount]];
        [self.labelComments setText:[NSString stringWithFormat:@"%d", self.post.postCommentsCount]];
        if (self.post.user.userID == [WLIConnect sharedConnect].currentUser.userID)
        {
            [_buttonConnect setHidden:YES];
            if (self.showDeleteButton)
                [_buttonDelete setHidden:NO];

        }
        else
        {
            [_buttonConnect setHidden:NO];
            [_buttonDelete setHidden:YES];
            if (self.post.isConnected)
            {
                [_buttonConnect setSelected:YES];
            }
        }
    }
}


#pragma mark - Action methods

- (IBAction)buttonUserTouchUpInside:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(showUser:sender:)]) {
        [self.delegate showUser:self.post.user sender:self];
    }
}

- (IBAction)buttonPostTouchUpInside:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(showImageForPost:sender:)] && self.post.postImagePath.length) {
        [self.delegate showImageForPost:self.post sender:self];
    }
}
- (IBAction)buttonVideoTouchUpInside:(id)sender {
    NSLog(@"Trying to play: %@", self.post.postVideoPath);
    if (self.post.postVideoPath.length)
    {
    NSURL *movieURL = [NSURL URLWithString:self.post.postVideoPath];
    movieController = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
    [self.delegate presentMoviePlayerViewControllerAnimated:movieController];
    [movieController.moviePlayer play];
    }
    else
    {
        [self buttonPostTouchUpInside:self];
    }
}

- (IBAction)buttonLikeTouchUpInside:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(toggleLikeForPost:sender:)]) {
        [self.delegate toggleLikeForPost:self.post sender:self];
    }
}

- (IBAction)buttonCommentTouchUpInside:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(showCommentsForPost:sender:)]) {
        [self.delegate showCommentsForPost:self.post sender:self];
    }
}

- (IBAction)buttonShareTouchUpInside:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(showShareForPost:sender:)]) {
        [self.delegate showShareForPost:self.post sender:self];
    }
}

- (IBAction)buttonCatMarketTouchUpInside:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(showCatMarketForPost:sender:)]) {
        [self.delegate showCatMarketForPost:self.post sender:self];
    }
}

- (IBAction)buttonCatCustomerTouchUpInside:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(showCatCustomersForPost:sender:)]) {
        [self.delegate showCatCustomersForPost:self.post sender:self];
    }
}

- (IBAction)buttonCatCapabilitiesTouchUpInside:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(showCatCapabilitiesForPost:sender:)]) {
        [self.delegate showCatCapabilitiesForPost:self.post sender:self];
    }
}

- (IBAction)buttonCatPeopleTouchUpInside:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(showCatPeopleForPost:sender:)]) {
        [self.delegate showCatPeopleForPost:self.post sender:self];
    }
}

- (IBAction)buttonDeleteTouchUpInside:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(deletePost:sender:)]) {
        [self.delegate deletePost:self.post sender:self];
    }
}
- (IBAction)buttonConnectTouchUpInside:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(followUser:sender:)]) {
        [self.delegate showConnectForPost:self.post sender:sender];
    }
}


- (IBAction)buttonMoreTouchUpInside:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(showMoreForPost:sender:)]) {
        [self.delegate showMoreForPost:self.post sender:self];
    }
}

//- (IBAction)buttonLikesTouchUpInside:(id)sender {
//    
//    if ([self.delegate respondsToSelector:@selector(showLikesForPost:sender:)]) {
//        [self.delegate showLikesForPost:self.post sender:self];
//    }
//}

@end
