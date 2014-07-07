//
//  FBActivity.m
//  Outder
//
//  Created by Yossi on 7/5/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "FBActivity.h"
#import "SharingInfo.h"
#import <Social/Social.h>

@interface FBActivity ()

@end


@implementation FBActivity

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
    return @"com.outder.facebook";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"Icon_Facebook"];
}

- (NSString *)activityTitle
{
    return @"Facebook";
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems)
    {
        if ([activityItem isKindOfClass:[SharingInfo class]])
        {
            self.shareInfo = activityItem;
            return YES;
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
            [self shareInFB];
            break;
        }
    }
}

- (void)shareInFB
{
    /*
    SLComposeViewController *facebookViewComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    if (!facebookViewComposer) {
        return;
    }
    
    shareInfo.viewCtrl.modalPresentationStyle = UIModalPresentationCurrentContext;

    if (shareInfo.text)
        [facebookViewComposer setInitialText:shareInfo.text];
    if (shareInfo.image)
        [facebookViewComposer addImage:shareInfo.image];
    if (shareInfo.url)
        [facebookViewComposer addURL:shareInfo.url];

    UIViewController *ctrl = [self activityViewController];
    [shareInfo.viewCtrl presentViewController:facebookViewComposer animated:YES completion:nil];
    */
}

@end
