//
//  WLINewPostTableViewController.h
//  MyDrive
//
//  Created by Geir Eliassen on 19/10/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLIViewController.h"

@import MediaPlayer;
@import AVFoundation;

@interface WLINewPostTableViewController : UITableViewController <UITextViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    NSArray *cellIdentifiers;
    
    IBOutlet UIButton *addPicture;
    IBOutlet UIButton *addVideo;
    IBOutlet UIButton *addAttachment;
    IBOutlet UIImageView *imageView;
    IBOutlet UITextView *contentTextView;
    IBOutlet UILabel *strategyHeader;
    IBOutlet UILabel *strategyContent;
    IBOutlet UILabel *countryHeader;
    IBOutlet UILabel *countryContent;
    IBOutlet UITableView *tableViewRefresh;
    BOOL imageSet;

}

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) NSString *textContent;

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSData *video;

//@property BOOL strategyMarket;
//@property BOOL strategyCustomer;
//@property BOOL strategyCapabilities;
//@property BOOL strategyPeople;
//
//@property BOOL countryDenmark;
//@property BOOL countryFinland;
//@property BOOL countryNorway;
//@property BOOL countrySweden;

@property (strong, nonatomic) NSMutableDictionary *countryStates;
@property (strong, nonatomic) NSMutableDictionary *catStates;
//@property (strong, nonatomic) NSMutableArray *countries;
//@property (strong, nonatomic) NSMutableArray *strategies;

@property (strong, nonatomic) NSArray *countryIDs;


- (IBAction)buttonAddImageTouchUpInside:(id)sender;
- (IBAction)buttonAddVideoTouchUpInside:(id)sender;
- (IBAction)buttonAddAttachmentTouchUpInside:(id)sender;

- (IBAction)publishButtonTouchUpInside:(id)sender;
-(IBAction)cancelButtonTouchUpInside:(id)sender;

-(void)shootPhoto;
-(void)selectPhoto;
-(void)shootVideo;
-(void)selectVideo;


//- (IBAction)buttonAddImageTouchUpInside:(id)sender;
//- (IBAction)buttonAddImageTouchUpInside:(id)sender;
//- (IBAction)buttonAddImageTouchUpInside:(id)sender;

@end
