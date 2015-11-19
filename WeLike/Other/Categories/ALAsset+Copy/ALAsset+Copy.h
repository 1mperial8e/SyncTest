//
//  ALAsset+Copy.h
//  MyDrive
//
//  Created by Stas Volskyi on 11/18/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAsset (Copy)

- (BOOL)syncCopyToFileWithPath:(NSString *)filePath;
- (void)asyncCopyToFileWithPath:(NSString *)filePath completion:(void(^)(BOOL success))completion;

@end
