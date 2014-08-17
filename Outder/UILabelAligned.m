//
//  UILabelAligned.m
//  Outder
//
//  Created by Yossi on 8/16/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "UILabelAligned.h"

@implementation UILabelAligned

- (void) setText:(NSString *)text
{
    [super setText:text];
    
    if (self.textAlignment != NSTextAlignmentCenter) {
        NSTextAlignment align = [UILabelAligned alignmentForString:text];
        self.textAlignment = align;
    }
}


+ (NSTextAlignment)alignmentForString:(NSString *)astring
{
    
    if (astring.length) {
        
        NSArray *rightLeftLanguages = @[@"ar",@"he"];
        
        NSString *lang = CFBridgingRelease(CFStringTokenizerCopyBestStringLanguage((CFStringRef)astring,CFRangeMake(0,[astring length])));
        
        if ([rightLeftLanguages containsObject:lang]) {
            NSLog(@"%@: Right alignment", astring);
            return NSTextAlignmentRight;
            
        }
    }
    
    NSLog(@"%@: Left alignment", astring);
    return NSTextAlignmentLeft;
}

@end
