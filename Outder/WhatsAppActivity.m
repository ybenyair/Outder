//
//  WhatsAppActivity.m
//  Outder
//
//  Created by Yossi on 7/5/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "WhatsAppActivity.h"
#import "SharingInfo.h"

@interface WhatsAppActivity ()

@end


@implementation WhatsAppActivity

@synthesize shareInfo;


- (id)initWithMessage:(SharingInfo *)message
{
    if (self = [super init]) {
        self.shareInfo = message;
    }
    
    return self;
}

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

- (NSString *)activityType {
    return @"com.outder.whatsapp";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"Icon_Whatsapp"];
}

- (NSString *)activityTitle
{
    return @"WhatsApp";
}

- (NSURL *)getURLFromMessage:(SharingInfo *)message
{
    NSString *url = @"whatsapp://";
    
    if (message.text)
    {
        url = [NSString stringWithFormat:@"%@send?text=%@",url ,message.getEncodedText];
    }
    
    return [NSURL URLWithString:url];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems)
    {
        if ([activityItem isKindOfClass:[SharingInfo class]])
        {
            self.shareInfo = activityItem;
            NSURL *whatsAppURL = [self getURLFromMessage:shareInfo];
            return [[UIApplication sharedApplication] canOpenURL: whatsAppURL];
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems)
    {
        if ([activityItem isKindOfClass:[shareInfo class]])
        {
            NSURL *whatsAppURL = [self getURLFromMessage:shareInfo];
            
            if ([[UIApplication sharedApplication] canOpenURL: whatsAppURL]) {
                [[UIApplication sharedApplication] openURL: whatsAppURL];
            }
            
            break;
        }
    }
}


@end
