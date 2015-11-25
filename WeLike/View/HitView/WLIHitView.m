//
//  WLIHitView.m
//  MyDrive
//
//  Created by Stas Volskyi on 11/25/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIHitView.h"

@implementation WLIHitView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return self.viewForTouches ? self.viewForTouches : self;
}

@end
