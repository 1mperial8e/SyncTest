//
//  WLIHashTextView.m
//  MyDrive
//
//  Created by Geir Eliassen on 21/10/15.
//  Copyright © 2015 Goran Vuksic. All rights reserved.
//

#import "WLIHashTextView.h"

@implementation WLIHashTextView
//
//
//-(void)drawRect:(CGRect)rect {
//    if(self.attributedText.string.length<=0) {
//        self.text = EMPTY;
//        return;
//    }
//    
//    //Prepare View for drawing
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetTextMatrix(context,CGAffineTransformIdentity);
//    CGContextTranslateCTM(context,0,([self bounds]).size.height);
//    CGContextScaleCTM(context,1.0,-1.0);
//    
//    //Get the view frame size
//    CGSize size = self.frame.size;
//    
//    //Determine default text color
//    
//    //Set line height, font, color and break mode
//    CGFloat minimumLineHeight = [self.text sizeWithFont:self.font].height,maximumLineHeight = minimumLineHeight;
//    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName,self.font.pointSize,NULL);
//    CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
//    
//    
//    //Apply paragraph settings
//    CTParagraphStyleRef style = CTParagraphStyleCreate((CTParagraphStyleSetting[3]){
//        {kCTParagraphStyleSpecifierMinimumLineHeight,sizeof(minimumLineHeight),&minimumLineHeight},
//        {kCTParagraphStyleSpecifierMaximumLineHeight,sizeof(maximumLineHeight),&maximumLineHeight},
//        {kCTParagraphStyleSpecifierLineBreakMode,sizeof(CTLineBreakMode),&lineBreakMode}
//    },3);
//    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)self.font,(NSString*)kCTFontAttributeName,(__bridge id)self.textColor.CGColor,(NSString*)kCTForegroundColorAttributeName,(__bridge id)style,(NSString*)kCTParagraphStyleAttributeName,nil];
//    
//    //Create path to work with a frame with applied margins
//    CGMutablePathRef path = CGPathCreateMutable();
//    CGPathAddRect(path,NULL,CGRectMake(MARGIN+0.0,(-self.contentOffset.y+0),(size.width-2*MARGIN),(size.height+self.contentOffset.y-MARGIN)));
//    
//    
//    //Create attributed string, with applied syntax highlighting
//    CFAttributedStringRef attributedString = (__bridge CFAttributedStringRef)[self highlightText:[[NSAttributedString alloc] initWithString:self.text attributes:attributes]];
//    
//    //Draw the frame
//    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
//    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0,CFAttributedStringGetLength(attributedString)),path,NULL);
//    CTFrameDraw(frame,context);
//}
//
//-(NSRange)visibleRangeOfTextView:(UITextView *)textView {
//    CGRect bounds = textView.bounds;
//    //Get start and end bouns for text position
//    UITextPosition *start = [textView characterRangeAtPoint:bounds.origin].start,*end = [textView characterRangeAtPoint:CGPointMake(CGRectGetMaxX(bounds),CGRectGetMaxY(bounds))].end;
//    //Make a range out of it and return
//    return NSMakeRange([textView offsetFromPosition:textView.beginningOfDocument toPosition:start],[textView offsetFromPosition:start toPosition:end]);
//}
//
//-(NSAttributedString*)highlightText:(NSAttributedString*)attributedString {
//    //Create a mutable attribute string to set the highlighting
//    NSString* string = attributedString.string; NSRange range = NSMakeRange(0,[string length]);
//    NSMutableAttributedString* coloredString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
//    
//    //Define the definition to use
//    NSDictionary* definition = nil;
//    if(!(definition=self.highlightDefinition))
//        definition = [RegexHighlightView defaultDefinition];
//    
//    //For each definition entry apply the highlighting to matched ranges
//    for(NSString* key in definition) {
//        NSString* expression = [definition objectForKey:key];
//        if(!expression||[expression length]<=0) continue;
//        NSArray* matches = [[NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionDotMatchesLineSeparators error:nil] matchesInString:string options:0 range:range];
//        for(NSTextCheckingResult* match in matches) {
//            UIColor* textColor = nil;
//            //Get the text color, if it is a custom key and no color was defined, choose black
//            if(!self.highlightColor||!(textColor=([self.highlightColor objectForKey:key])))
//                if(!(textColor=[[RegexHighlightView highlightTheme:kRegexHighlightViewThemeDefault] objectForKey:key]))
//                    textColor = [UIColor blackColor];
//            [coloredString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)textColor.CGColor range:[match rangeAtIndex:0]];
//        }
//    }
//    
//    return coloredString.copy;
//}


@end
