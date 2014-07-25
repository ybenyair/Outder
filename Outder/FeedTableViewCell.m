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
{
    BOOL justStartedLoading;
}

@synthesize feed;
@synthesize videoCtrl;
@synthesize superCtrl;
@synthesize state;

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
    self.activityIndicator.hidden = YES;
    
    [self setTapGesture];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (UIImage*)convertToGrayscale: (UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGRect imageRect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Draw a white background
    CGContextSetRGBFillColor(ctx, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextFillRect(ctx, imageRect);
    
    // Draw the luminosity on top of the white background to get grayscale
    [image drawInRect:imageRect blendMode:kCGBlendModeLuminosity alpha:1.0f];
    
    // Apply the source image's alpha
    [image drawInRect:imageRect blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    
    UIImage* grayscaleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return grayscaleImage;
}

- (void)setImageLocal:(NSString *)filePath
{
    if (justStartedLoading == NO) return;
    
    UIImage *colorImage = [UIImage imageWithContentsOfFile:filePath];
    UIImage *image = [self convertToGrayscale:colorImage];
    
    if (image) {
        
        self.image.hidden = NO;
        [self.image setAlpha:0];
        [self.image setImage:image];
        
        [UIView animateWithDuration:1.0f
                         animations:^{
                             [self.image setAlpha:0.75];
                         }];
    } else {
        NSLog(@"Cannot load user shot image from URL");
    }
}

- (void)setImageRemote:(NSString *)urlPath
{
    NSURL *url = [NSURL URLWithString:urlPath];
    
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

}


- (void) setStateFeedReady
{
    self.labelProgress.hidden = YES;
    self.activityIndicator.hidden = YES;
    self.progressBar.hidden = YES;
    self.cameraButton.enabled = YES;
    self.sharedButton.enabled = YES;
    self.progressBar.hidden = YES;
    [self setImageRemote:feed.imageURL];
}

- (void) setStateFeedLoading
{
    self.labelProgress.hidden = NO;
    self.progressBar.hidden = NO;
    self.cameraButton.enabled = NO;
    self.sharedButton.enabled = NO;
    CGFloat progress = [feed.progress floatValue];
    self.progressBar.progress = progress/100;
    self.labelProgress.text = [NSString stringWithFormat:@"%ld", (long)[feed.progress intValue]];
    [self setImageLocal:feed.imageURL];
    
    if (self.activityIndicator.hidden == YES) {
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
    }
}

- (void) setStateFeedProcessing
{
    [self setStateFeedLoading];
    
    /*
    self.progressBar.hidden = YES;

    if (self.activityIndicator.hidden == YES) {
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
    }
    self.cameraButton.enabled = NO;
    self.sharedButton.enabled = NO;
    [self setImageLocal:feed.imageURL];
     */
    
}

- (void) restoreState
{
    NSInteger progress = [self.feed.progress integerValue];
    NSInteger feedID = [self.feed.feedID integerValue];
    
    if (feedID > 0) {
        // Uploading the file to server
        state = kFeedReady;
        NSLog(@"Feed state is kFeedReady");
        return;
    }
    
    if (progress == 100 && feedID == 0) {
        // Uploading the file to server
        state = kFeedProcessing;
        NSLog(@"Feed state is kFeedProcessing");
        return;
    }
    
    if (progress < 100) {
        // Uploading the file to server
        if (state != kFeedLoading) {
            justStartedLoading = YES;
        } else {
            justStartedLoading = NO;
        }
        state = kFeedLoading;
        NSLog(@"Feed state is kFeedLoading");
        return;
    }
    
}

- (void)configureCell:(Feed *)feedInfo
{
    feed = feedInfo;
    self.title.text = feed.title;
    
    [self restoreState];
    
    switch (self.state) {
        case kFeedReady:
        case kFeedUnknown:
            [self setStateFeedReady];
            break;
        case kFeedLoading:
            [self setStateFeedLoading];
            break;
        case kFeedProcessing:
            [self setStateFeedProcessing];
            break;
    }

    if (videoCtrl && (videoCtrl.videoState != kVideoClosed)) {
        [videoCtrl stopVideo:YES];
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
    
    if (self.activityIndicator.hidden == NO) return;
    
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
