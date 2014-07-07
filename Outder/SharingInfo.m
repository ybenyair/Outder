//
//  SharingInfo.m
//  Outder
//
//  Created by Yossi on 7/5/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "SharingInfo.h"

@implementation SharingInfo

@synthesize text, url, image;

- (NSString *)getEncodedText
{
    CFStringRef encodedString = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self.text, NULL,
                                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    return CFBridgingRelease(encodedString);
}

@end
