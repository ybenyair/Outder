//
//  Defines.m
//  Outder
//
//  Created by Yossi on 6/17/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "Defines.h"

@implementation FontHelpers

// Assumes input like "#00FF00" (#RRGGBB).
+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+(NSTextAlignment)alignmentForString:(NSString *)astring
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

