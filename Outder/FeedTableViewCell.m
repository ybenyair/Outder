//
//  FeedTableViewCell.m
//  Outder
//
//  Created by Yossi on 6/14/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "FeedTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SharingInfo.h"
#import "SharingActivities.h"

@implementation FeedTableViewCell

@synthesize feed;
@synthesize videoCtrl;
@synthesize superCtrl;

- (void) layoutSubviews{
    
    [super layoutSubviews];
}

- (void)awakeFromNib
{
    // Initialization code
    
    [self setUserInteractionEnabled:YES];
    [self.image setUserInteractionEnabled:YES];
    [self.image setHighlighted:YES];
    [self.sharedButton setShowsTouchWhenHighlighted:YES];
    [self.cameraButton setShowsTouchWhenHighlighted:YES];
    // Configure the tapping
    self.image.contentMode = UIViewContentModeScaleAspectFit;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.title setFont:[UIFont fontWithName:@"AvenirNextCondensed-Heavy" size:36.0]];
    self.title.shadowColor = [UIColor blackColor];
    self.title.shadowOffset = CGSizeMake(0, -1.0);
    self.title.numberOfLines = 0;
    self.title.lineBreakMode = NSLineBreakByCharWrapping;
    self.title.textAlignment = NSTextAlignmentNatural;
    [self setTapGesture];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)configureCell:(Feed *)feedInfo
{
    feed = feedInfo;
    self.title.text = feed.title;
    
    NSURL *url = [NSURL URLWithString:feed.imageURL];
    
    [self.image setImageWithURL:url
                 placeholderImage:nil
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                            if (image)
                            {
                                self.image.alpha = 0.0;
                                [UIView animateWithDuration:1.0
                                                 animations:^{
                                                     self.image.alpha = 1.0;
                                                 }];
                            }
                        }];
    
    if (videoCtrl && (videoCtrl.videoState != kVideoClosed)) {
        [videoCtrl stopVideo];
        videoCtrl = nil;
    }
    
}

- (void)setTapGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(feedTap:)];
    [self addGestureRecognizer:tap];
}

- (void)feedTap:(UIGestureRecognizer *)sender
{
    NSLog(@"Tapped on feed: %@", feed.title);
    if (!videoCtrl) {
        videoCtrl = [[VideoPlayerViewController alloc] init];
    }
    
    [videoCtrl playVideo:feed.videoURL inView:self.feedContentView];
    
 }


- (void) imageClicked {
    [self.image.layer setOpacity:0.6];
    [self.image.layer setBackgroundColor:[UIColor whiteColor].CGColor];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.image.layer setOpacity:1.0];
                     }];

}


- (IBAction)sharedButtonClicked:(id)sender {
    NSLog(@"shared clicked");
    /*
    NSString *msg = NSLocalizedString(@"Watch my movie from OUTDER:", nil);
    NSString *whatsappMsg = @"whatsapp://send?text=";
    NSString *fullMsg = [NSString stringWithFormat:@"%@%@\n%@ \n",whatsappMsg, msg, feed.pageURL];
    NSString *urlString = [fullMsg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *whatsappURL = [NSURL URLWithString:urlString];
    
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    }
    */

    /*
    NSString *msg = NSLocalizedString(@"Watch my movie from OUTDER:", nil);
    NSString *fullMsg = [NSString stringWithFormat:@"%@\n%@ \n", msg, feed.pageURL];
    NSString *urlString = [fullMsg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSArray* dataToShare = @[urlString];  // ...or whatever pieces of data you want to share.
    
    UIActivityViewController* activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                      applicationActivities:nil];
    
    [self.superCtrl presentViewController:activityViewController animated:YES completion:^{}];
    */
    NSString *text = NSLocalizedString(@"Watch my movie from OUTDER:", nil);
    NSString *fullMsg = [NSString stringWithFormat:@"%@\n%@\n", text, feed.pageURL];
    
    SharingInfo *message = [[SharingInfo alloc] init];
    message.text = fullMsg;
    
    NSArray *applicationActivities = @[[[WhatsAppActivity alloc] init]];
    NSArray *excludedActivities    = @[UIActivityTypePrint, UIActivityTypeAirDrop];
    NSArray *activityItems         = @[message.text, message];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
    activityViewController.excludedActivityTypes = excludedActivities;
    
    [self.superCtrl presentViewController:activityViewController animated:YES completion:^{}];
}

- (IBAction)cameraButtonClicked:(id)sender {
    NSLog(@"camera clicked");
}

@end
