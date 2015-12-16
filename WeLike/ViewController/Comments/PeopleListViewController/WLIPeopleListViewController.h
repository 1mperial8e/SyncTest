//
//  WLIPeopleListViewController.h
//  MyDrive
//
//  Created by Stas Volskyi on 11/17/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIViewController.h"

@interface WLIPeopleListViewController : WLIViewController <WLIViewControllerRefreshProtocol>

@property (strong, nonatomic) NSMutableArray *people;

- (void)removePeople:(NSArray *)people;
- (void)addPeople:(NSArray *)people;
- (void)downloadedPeople:(NSArray *)people serverResponse:(ServerResponse)serverResponseCode reloadAll:(BOOL)reloadAll;

@end
