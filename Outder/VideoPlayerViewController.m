//
//  VideoPlayerViewController.m
//  Outder
//
//  Created by Yossi on 6/21/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

#pragma mark - VideoOverlay

@implementation VideoOverlay

@end


#pragma mark - VideoOverlayHandler

@interface VideoPlayerViewController ()
{

}

@end

@implementation VideoPlayerViewController
{
    BOOL isMute;
    BOOL isRepeat;

    UITapGestureRecognizer *tapRecognizer;
    NSString *fileURL;
    UIView *playView;
    
    id <VideoPlayerViewControllerDelegate> delegate;
    id delegateInfo;
    CGFloat fadingDuration;
    AVPlayerItem *videoItem;
    AVQueuePlayer *queuePlayer;
    UIImageView *overlayView;
    VideoOverlay *overlayItems;
    AVPlayer *overlayAudioStreamer;
    AVPlayerItem *overlayAudioItem;
    NSMutableArray *overlayImages;
    NSUInteger overlayCurrentImage;
    NSTimer *overlayTimer;
    BOOL getReadyOnly;
    UIDeviceOrientation requestedOrientation;
}

static VideoPlayerViewController *activePlayer = nil;

@synthesize activityIndicator;
@synthesize stopButton;
@synthesize videoState, isMute;
@synthesize playbackErrorLabel, enableAutoRotation, mPlaybackView;

#pragma mark - controller initialization

- (void) initParameters
{
    // Custom initialization
    // Do any additional setup after loading the view from its nib.
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.contentMode = UIViewContentModeScaleAspectFit;
    self.videoState = kVideoClosed;
    self.enableAutoRotation = YES;
    
    [self initStopButton];
    [self initPlaybackErrorLabel];
    fadingDuration = 1.0f;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"VideoPlayerViewController" bundle:nibBundleOrNil];
    
    if (self) {
        [self initParameters];
    }
    
    return self;
}

- (id)initWithView:(UIView *)view andURL:(NSString *) url
{
    if (self = [super init]) {
        // Custom initialization
        // Do any additional setup after loading the view from its nib.
        fileURL = url;
        playView = view;
    }
    
    return self;
}

- (void) setFadingDuration: (CGFloat) duration
{
    fadingDuration = duration;
}

- (void) setDelegate:(id)obj withInfo: (id) info
{
    delegate = obj;
    delegateInfo = info;
}

- (void) setVideoURL: (NSString *)videoURL
{
    fileURL = videoURL;
}

- (void) dealloc {
    NSLog(@"dealloc video player");
    playbackErrorLabel = nil;
    stopButton = nil;
    [self setTapGesture:NO];
    playView = nil;
    fileURL = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initPlaybackErrorLabel
{
    playbackErrorLabel = [[UILabel alloc] init];
    playbackErrorLabel.frame = CGRectMake(0, 0, 200.0, 35.0);
    playbackErrorLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    playbackErrorLabel.text = NSLocalizedString(@"ERROR PLAYING VIDEO", nil);
    playbackErrorLabel.textColor = [UIColor whiteColor];
    playbackErrorLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)initStopButton
{
    stopButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *buttonImage = [UIImage imageNamed:@"mediaStopBtn"];
    [stopButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [stopButton addTarget:self action:@selector(stopButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [stopButton setShowsTouchWhenHighlighted:YES];
    stopButton.hidden = YES;
}

#pragma mark - device orientation handling

- (void) registerToDeviceOrientationNotification
{
    if (self.enableAutoRotation) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationChanged:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        
    }
}

- (void) deregisterToDeviceOrientationNotification
{
    if (self.enableAutoRotation) {
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIDeviceOrientationDidChangeNotification
                                                      object:nil];
    }
}

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationLandscapeLeft:
            /* start special animation */
            NSLog(@"Landscape left");
            requestedOrientation = UIDeviceOrientationLandscapeLeft;
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            [self configurePlayerViewLandscape:(M_PI / 2) withAnimation:YES];
            break;
        
        case UIDeviceOrientationLandscapeRight:
            /* start special animation */
            NSLog(@"Landscape right");
            requestedOrientation = UIDeviceOrientationLandscapeRight;
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:NO];
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            [self configurePlayerViewLandscape:(3 * M_PI / 2) withAnimation:YES];
            break;
            
        case UIDeviceOrientationPortrait:
            requestedOrientation = UIDeviceOrientationPortrait;
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            [self configurePlayerViewBackToPortrait:(0)];
            NSLog(@"Portrait");
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            requestedOrientation = UIDeviceOrientationPortrait;
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            [self configurePlayerViewBackToPortrait:(0)];
            NSLog(@"Portrait UpsideDown");
            break;

        default:
            break;
    };
}

- (void)configurePlayerViewBackToPortrait:(CGFloat)angle
{
    [UIView animateWithDuration:0.2f
                     animations:^{
                         [self.mPlaybackView setTransform:CGAffineTransformMakeRotation(angle)];
                         [overlayView setTransform:CGAffineTransformMakeRotation(angle)];
                     }];
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    CGFloat x = self.view.center.x;
    CGFloat y = self.view.center.y;
    
    [self.mPlaybackView setBounds:CGRectMake(0, 0, width, height)];
    [self.mPlaybackView setCenter:CGPointMake(x, y)];
    
    [overlayView setBounds:CGRectMake(0, 0, width, height)];
    [overlayView setCenter:CGPointMake(x, y)];
    
    [self.mPlaybackView removeFromSuperview];
    [self.view addSubview:self.mPlaybackView];
    [self.view addSubview:overlayView];

    [self positionItemsOnPlayerView];
}

- (void)configurePlayerViewPortrait:(UIView *)videoView
{
    // Set the whole view frame
    // Set the video player frame
    requestedOrientation = UIDeviceOrientationPortrait;
    
    self.mPlaybackView.frame = videoView.bounds;
    overlayView.frame = videoView.bounds;

    self.view.frame = videoView.bounds;

    [self positionItemsOnPlayerView];
    
    [self.view addSubview: self.mPlaybackView];
    
    [self.view addSubview:overlayView];
    
    if (!getReadyOnly) {
        [videoView addSubview:self.view];
    }
}

- (void)configurePlayerViewLandscape:(CGFloat)angle withAnimation:(BOOL)animate
{
    if (getReadyOnly) return;
    
    //[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
    UIView *videoView = [UIApplication sharedApplication].windows.firstObject;
    CGFloat width = videoView.frame.size.height;
    CGFloat height = videoView.frame.size.width;
    
    CGFloat x = videoView.center.x;
    CGFloat y = videoView.center.y;
    
    [self.mPlaybackView setBounds:CGRectMake(0, 0, width, height)];
    [self.mPlaybackView setCenter:CGPointMake(x, y)];
    
    [overlayView setBounds:CGRectMake(0, 0, width, height)];
    [overlayView setCenter:CGPointMake(x, y)];
    
    [self positionItemsOnPlayerView];

    [self.mPlaybackView removeFromSuperview];
    [overlayView removeFromSuperview];
    
    [videoView addSubview:self.mPlaybackView];
    [videoView addSubview:overlayView];

    CGFloat animationDuration = 0.2f;
    if (!animate) animationDuration = 0.0f;
        
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         [self.mPlaybackView setTransform:CGAffineTransformMakeRotation(angle)];
                         [overlayView setTransform:CGAffineTransformMakeRotation(angle)];
                     }];
}

#pragma mark - allocating and configure positions of view items

- (void) allocVideoPlayer:(NSString *)videoURL
{
    NSURL *url;
    url = [NSURL URLWithString:videoURL];
    videoItem = [AVPlayerItem playerItemWithURL:url];
    
    overlayView = [[UIImageView alloc] init];
    overlayView.contentMode = UIViewContentModeScaleAspectFit;
    overlayView.backgroundColor = [UIColor clearColor];

    [self prepareOverlayImages];
    [self prepareOverlayTrack];

    mPlaybackView = [[AVPlayerPlaybackView alloc] init];
    self.mPlaybackView.backgroundColor = [UIColor blackColor];

    queuePlayer = [AVQueuePlayer queuePlayerWithItems:[NSArray arrayWithObject:videoItem]];
	[self.mPlaybackView setPlayer:queuePlayer];
    
    queuePlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
}

- (void) releaseVideoPlayer
{
    queuePlayer = nil;
    self.mPlaybackView = nil;
    overlayView = nil;
    videoItem = nil;;
}

- (void) releaseVideoOverlay
{
    [overlayItems.overlayImagesURL removeAllObjects];
    overlayItems.overlayImagesURL = nil;
    overlayItems.overlayTrack = nil;
    overlayItems = nil;
    [overlayTimer invalidate];
    overlayTimer = nil;
    [overlayImages removeAllObjects];
    overlayImages = nil;
}

- (void) allocActivityIndicator
{
    //Create and add the Activity Indicator to splashView
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.alpha = 1.0;
    activityIndicator.hidesWhenStopped = YES;
}

- (void) releaseActivityIndicator
{
    activityIndicator = nil;
}

- (void)positionItemsOnPlayerView
{
    // Set the stopButton location
    CGFloat x = self.mPlaybackView.frame.size.width - 40;
    CGFloat y = self.mPlaybackView.frame.size.height - 40;
    stopButton.frame = CGRectMake(x, y, 35.0, 35.0);
    stopButton.hidden = NO;
    
    // Set the playbackError location
    playbackErrorLabel.center = self.mPlaybackView.center;
    playbackErrorLabel.hidden = YES;
    
    // Set the activityIndicator location
    activityIndicator.center = self.mPlaybackView.center;
}

- (void)addItemsOnPlayerView
{
    [self.mPlaybackView addSubview: activityIndicator];
    if (!tapRecognizer) [self.mPlaybackView addSubview: stopButton];
    [self.mPlaybackView addSubview: playbackErrorLabel];
}

#pragma mark - Video Player (notifications)

- (void) registerPlayerCallbacks
{
    [videoItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    [videoItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:0 context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:videoItem];
}

- (void) deregisterPlayerCallbacks
{
    [videoItem  removeObserver:self forKeyPath:@"status"];
    [videoItem  removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                    object:videoItem];
    
}

#pragma mark - Video Player functions (open/close/play/stop)


#pragma mark - Video Player functions (PLAY)

-(void) playVideo:(NSString *)videoURL inView:(UIView *)videoView
{
    //[self setDemoOverlay: videoView];
    if (videoState != kVideoClosed)
    {
        NSLog(@"Video is already playing...stoping it...");
        [self movieFinishedOK];
        return;
    }
    
    if (activePlayer) {
        NSLog(@"Another video is already playing...stoping it...");
        if ([delegate respondsToSelector:@selector(videoShouldKeepActivePlayers:)]) {
            if (![delegate videoShouldKeepActivePlayers:delegateInfo]) {
                [activePlayer stopVideo: YES];
            }
        }
    }

    playView = videoView;

    activePlayer = self;
    
    videoState = kVideoOpening;
    NSLog(@"Video is opening");
    
    // Alloc various objects
    [self allocVideoPlayer:videoURL];
    [self allocActivityIndicator];
    [self addItemsOnPlayerView];
    [self registerPlayerCallbacks];
    
    // Configure view
    [self configurePlayerViewPortrait:videoView];
    
    // Play video
    [self openVideo];
}

- (void) playVideo
{
    [self playVideo:fileURL inView:playView];
}

- (void)openVideo
{
    [self.mPlaybackView setAlpha:1];
    [overlayView setAlpha:1];
    [activityIndicator startAnimating];
    [self registerToDeviceOrientationNotification];
    [queuePlayer play];
}

#pragma mark - Video Player functions (PREPARE)

- (void) prepareVideo:(NSString *)videoURL inView:(UIView *)videoView
{
    [self setPrepareAndWaitMode];
    [self playVideo:videoURL inView:videoView];
}

- (void) prepareVideo
{
    [self prepareVideo:fileURL inView:playView];
}

#pragma mark - Video Player functions (PLAY WHEN PREPARED)

- (void) playWhenPrepared: (UIView *)videoView
{
    getReadyOnly = NO;
    
    NSLog(@"VIDEO & AUDIO: GO");
 
    [self.activityIndicator stopAnimating];
    [videoView addSubview:self.view];
    
    switch (requestedOrientation) {
        case UIDeviceOrientationLandscapeLeft:
            [self configurePlayerViewLandscape:(M_PI / 2) withAnimation:NO];
            break;
        case UIDeviceOrientationLandscapeRight:
            [self configurePlayerViewLandscape:(3 * M_PI / 2) withAnimation:NO];
            break;
        default:
            break;
    }
    
    if (videoItem.status == AVPlayerItemStatusReadyToPlay)
    {
        [queuePlayer play];
        [self startOverlayAnimation];
    }
    
    if (overlayAudioStreamer && overlayAudioStreamer.status == AVPlayerItemStatusReadyToPlay)
    {
        [self playOverlayTrack];
    }
}

- (void) playWhenPrepared
{
    [self playWhenPrepared:playView];
}

- (void) setPrepareAndWaitMode
{
    getReadyOnly = YES;
}

#pragma mark - Video Player functions (PAUSE)

- (void) pauseVideo: (BOOL) pasue
{
    if (pasue) {
        [queuePlayer pause];
        [overlayAudioStreamer pause];
    } else {
        [queuePlayer play];
        [overlayAudioStreamer play];
    }
}

#pragma mark - Video Player functions (STOP)

-(void) stopVideo:(BOOL) animated
{
    if (animated)
    {
        if (videoState == kVideoOpened || videoState == kVideoOpening) {
            
            NSLog(@"Video is closing");
            [self movieFinishedOK];
        }
    } else
    {
        [self closeVideo];
    }
    
}

- (void) closeVideo
{
    if (videoState == kVideoClosed) return;
    
    NSLog(@"closeVideo...");
    [self deregisterPlayerCallbacks];
    [self.playbackErrorLabel removeFromSuperview];
    [self.stopButton removeFromSuperview];
    [self.activityIndicator removeFromSuperview];
    [self.mPlaybackView removeFromSuperview];
    [self.mPlaybackView setPlayer:nil];
    
    [self stopOverlayTrack];
    [self stopOverlayAnimation:YES];
    
    [overlayView removeFromSuperview];
    overlayView.image = nil;
    
    [self.view removeFromSuperview];
    [self releaseVideoPlayer];
    [self releaseActivityIndicator];
    [self deregisterToDeviceOrientationNotification];
    [self releaseVideoOverlay];

    stopButton.hidden = YES;
    videoState = kVideoClosed;
    
    if ([delegate respondsToSelector:@selector(videoDidClose:)]) {
        [delegate videoDidClose:delegateInfo];
    }
    
    if (activePlayer == self) activePlayer = nil;
    NSLog(@"Video is closed");
}

#pragma mark - Video Player functions (REPEAT)

- (void) repeatVideo: (BOOL) repeat
{
    isRepeat = repeat;
}

#pragma mark - Video Player functions (MUTE)

- (void) muteVideo: (BOOL) mute {
    isMute = mute;
    
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSArray * myTracks = videoItem.tracks;
        for(int i = 0; i < [myTracks count]; i++)
        {
            if([[[myTracks objectAtIndex:i] assetTrack].mediaType
                isEqualToString:AVMediaTypeAudio] == YES)
            {
                ((AVPlayerItemTrack *)[myTracks
                                       objectAtIndex:i]).enabled = !mute;
            }
        }
    });
    
    return;
}

#pragma mark - Video Player (callbacks)

- (void)playerItemDidReachEnd:(NSNotification *)notification {

    if (notification.object == videoItem) {
        
        if (isRepeat) {
            
            AVPlayerItem *playerItem = [queuePlayer currentItem];
            [playerItem seekToTime: kCMTimeZero];
            queuePlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            [queuePlayer play];
            
            AVPlayerItem *audioItem = [overlayAudioStreamer currentItem];
            [audioItem seekToTime: kCMTimeZero];
            overlayAudioStreamer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            [overlayAudioStreamer play];
            
            [self startOverlayAnimation];
            
        } else {
            // Do stuff here
            [self stopOverlayAnimation:YES];
            [self stopOverlayTrack];
            
            NSLog(@"playbackFinished. Reason: OK");
            [self movieFinishedOK];
        }
        
    }
}


- (void) handleVideoCallbacks
{
    switch(videoItem.status)
    {
        case AVPlayerItemStatusFailed:
            NSLog(@"playbackFinished. Reason: Playback Error");
            [self movieFinishedError];
            break;
        case AVPlayerItemStatusReadyToPlay:
            NSLog(@"player item status is ready to play");
            if (videoState == kVideoOpening)  {
                videoState = kVideoOpened;
                [self muteVideo:isMute];
                NSLog(@"Video is opened");
                if (overlayAudioStreamer &&
                    overlayAudioStreamer.status != AVPlayerItemStatusReadyToPlay) {
                    NSLog(@"Waiting for audio to be ready");
                    [queuePlayer pause];
                } else {
                    NSLog(@"VIDEO: Video & Audio are ready");
                    if (!getReadyOnly) {
                        [self playWhenPrepared];
                    } else {
                        NSLog(@"VIDEO & AUDIO waiting from GO");
                        [queuePlayer pause];
                    }
                    
                    if ([delegate respondsToSelector:@selector(videoIsReady:)]) {
                        [delegate videoIsReady:delegateInfo];
                    }
                    
                }
            }
            break;
        case AVPlayerItemStatusUnknown:
            NSLog(@"player item status is unknown");
            break;
    }
}

- (void) handleAudioCallbacks
{
    switch(overlayAudioItem.status)
    {
        case AVPlayerItemStatusFailed:
            NSLog(@" Audio playbackFinished. Reason: Playback Error");
            break;
        case AVPlayerItemStatusReadyToPlay:
            NSLog(@"Audio player item status is ready to play");
            if (videoItem.status != AVPlayerItemStatusReadyToPlay) {
                NSLog(@"Waiting for video to be ready");
                [overlayAudioStreamer pause];
            } else {
                NSLog(@"AUDIO: Video & Audio are ready");
                [self.activityIndicator stopAnimating];
                if (!getReadyOnly) {
                    [self playWhenPrepared];
                } else {
                    NSLog(@"VIDEO & AUDIO waiting from GO");
                    [overlayAudioStreamer pause];
                }
                if ([delegate respondsToSelector:@selector(videoIsReady:)]) {
                    [delegate videoIsReady:delegateInfo];
                }
            }
            break;
        case AVPlayerItemStatusUnknown:
            NSLog(@"Audio player item status is unknown");
            break;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[AVPlayerItem class]])
    {
        AVPlayerItem *item = (AVPlayerItem *)object;
        //playerItem status value changed?
        if ([keyPath isEqualToString:@"status"])
        {
            if (item == videoItem) {
                [self handleVideoCallbacks];
            } else {
                [self handleAudioCallbacks];
            }
            
        }
        else if ([keyPath isEqualToString:@"playbackBufferEmpty"])
        {
            if (item.playbackBufferEmpty)
            {
                NSLog(@"player item playback buffer is empty");
                [queuePlayer play];
            }
        }
    }
}

- (void)movieFinishedError
{
    videoState = kVideoClosing;
    NSLog(@"Video is closing");
    
    playbackErrorLabel.hidden = NO;
    [activityIndicator stopAnimating];
    
    [self.mPlaybackView setAlpha:1];
    [overlayView setAlpha:1];
    
    [UIView animateWithDuration:3.0f
                     animations:^{
                         [self.mPlaybackView setAlpha:0];
                         [overlayView setAlpha:0];
                     }
                     completion:^(BOOL finished) {
                         if (finished)
                         {
                             [self closeVideo];
                         }
                     }];
}

- (void)movieFinishedOK
{
    if (videoState == kVideoOpened) {
        
        videoState = kVideoClosing;
        NSLog(@"Video is closing");
        [self.mPlaybackView setAlpha:1];
        [overlayView setAlpha:1];
        
        NSLog(@"movieFinishedOK: close with fadingDuration %f", fadingDuration);

        [UIView animateWithDuration:fadingDuration
                         animations:^{
                             [self.mPlaybackView setAlpha:0];
                             [overlayView setAlpha:0];
                         }
                         completion:^(BOOL finished) {
                             if (finished)
                             {
                                 [self closeVideo];
                             }
                         }];
        
    } else {
        NSLog(@"movieFinishedOK: close now");
        [self closeVideo];
    }
}

#pragma mark - Video Player user interactions

- (void)stopButtonClicked:(UIButton*)button
{
    if (videoState == kVideoOpened || videoState == kVideoOpening) {
        
        NSLog(@"Video is closing");
        videoState = kVideoClosing;
        
        [self.mPlaybackView setAlpha:1];
        [overlayView setAlpha:1];
        
        [UIView animateWithDuration:1.0f
                         animations:^{
                             [self.mPlaybackView setAlpha:0];
                             [overlayView setAlpha:0];
                         }
                         completion:^(BOOL finished) {
                             if (finished)
                             {
                                 [self movieFinishedOK];
                             }
                         }];
    }
}


#pragma mark - Video Effects

- (void) setVideoOverlay: (VideoOverlay *) videoOverlay
{
    overlayItems = videoOverlay;
}

- (void) prepareOverlayImages
{
    if (!overlayItems) return;
    
    overlayImages = [[NSMutableArray alloc] init];
    
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        
        NSArray *imagesURL = [overlayItems.overlayImagesURL copy];
        
        for (id dataElement in imagesURL) {
            NSString *imageURL = (NSString *)dataElement;
            NSURL *url = [NSURL URLWithString:imageURL];
            NSData * data = [[NSData alloc] initWithContentsOfURL: url];
            if ( data == nil )
                return;
            
            UIImage *image = [UIImage imageWithData: data];
            [overlayImages addObject:image];
        }
    });
}

- (void) startOverlayAnimation
{
    if (!overlayItems) return;
    
    if (!overlayItems.overlayImagesURL) return;
    
    if (overlayTimer) {
        [self stopOverlayAnimation:NO];
    }
    
    overlayView.hidden = NO;
    
    NSLog(@"OVERLAY: start animating");

    overlayCurrentImage = 0;
    
    overlayTimer = [NSTimer scheduledTimerWithTimeInterval:overlayItems.overlayPeriod target:self selector:@selector(aPresentOverlay:) userInfo:nil repeats:YES];
}

- (void) stopOverlayAnimation: (BOOL) hide
{
    if (!overlayItems) return;
    
    if (hide) {
        overlayView.hidden = YES;
        overlayView.image = nil;
    }
    
    NSLog(@"OVERLAY: stop animating");
    
    if (overlayTimer) {
        [overlayTimer invalidate];
        overlayTimer = nil;
    }
}

-(void)aPresentOverlay: (NSTimer *)timer
{
    if (!overlayItems) return;
    
    if (overlayCurrentImage == [overlayItems.overlayImagesURL count]) {
        [self stopOverlayAnimation: NO];
        NSLog(@"OVERLAY: stop animation");
        return;
    }
    
    if (overlayCurrentImage < [overlayImages count]) {
        UIImage *image = [overlayImages objectAtIndex:overlayCurrentImage];
        overlayView.image = image;
        overlayCurrentImage++;
    }
}


-(void)aDemoTimer: (NSTimer *)timer
{
    UIView * view = timer.userInfo;
    [self playWhenPrepared:view];
}

- (void) setDemoOverlay:(UIView *) view
{
    //[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(aDemoTimer:) userInfo:view repeats:NO];

    VideoOverlay *overlay = [[VideoOverlay alloc] init];
    overlay.overlayImagesURL = [[NSMutableArray alloc] init];
    
    NSString * baseURL = @"http://d167cgw0so9a1a.cloudfront.net/C1/Feed/Fish.";
    for (int i = 0; i < 7; i++) {
        NSString *url = [NSString stringWithFormat:@"%@%d.png", baseURL, i];
        [overlay.overlayImagesURL addObject:url];
    }
    
    overlay.overlayPeriod = 0.5f;
    overlay.overlayTrack = @"https://s3.amazonaws.com/outder/C5/alone/sound.m4a";
    
    [self setVideoOverlay:overlay];
}

#pragma mark - Video overlay track

- (void) registerAudioCallbacks
{
    [overlayAudioItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    [overlayAudioItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:0 context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:overlayAudioItem];
}

- (void) deregisterAudioCallbacks
{
    [overlayAudioItem  removeObserver:self forKeyPath:@"status"];
    [videoItem  removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:videoItem];
    
}


- (void)playOverlayTrack
{
    if (!overlayItems) return;
    
    if (overlayAudioStreamer) {
        [overlayAudioStreamer play];
    }
}

- (void)prepareOverlayTrack
{
    if (!overlayItems) return;
    
    if (!overlayItems.overlayTrack) return;
    
    if (overlayAudioStreamer) {
        [self stopOverlayTrack];
    }
    
    overlayAudioItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:overlayItems.overlayTrack]];
    overlayAudioStreamer = [[AVPlayer alloc] initWithPlayerItem:overlayAudioItem];
    [self registerAudioCallbacks];
}

- (void)stopOverlayTrack
{
    if (!overlayItems) return;
    
    if (overlayAudioStreamer) {
        [overlayAudioStreamer pause];
        [self registerAudioCallbacks];
        overlayAudioStreamer = nil;
        overlayAudioItem = nil;
    }
}

#pragma mark - Tap recognizer

- (void)setTapGesture: (BOOL) enable
{
    if (enable) {
        playView.userInteractionEnabled = YES;
        tapRecognizer = [[UITapGestureRecognizer alloc]
                         initWithTarget:self action:@selector(videoImageTap:)];
        [playView addGestureRecognizer:tapRecognizer];
        [stopButton removeFromSuperview];
        
    } else {
        UIView *videoView = playView;
        [videoView removeGestureRecognizer:tapRecognizer];
        tapRecognizer = nil;
        [self.mPlaybackView addSubview: stopButton];
    }
}

- (void)videoImageTap:(UIGestureRecognizer *)sender
{
    NSLog(@"videoImageTap");
    
    BOOL shouldAct = NO;
    
    switch (videoState) {
        case kVideoClosed:
            if ([delegate respondsToSelector:@selector(videoShouldPlay:)]) {
                shouldAct = [delegate videoShouldPlay:delegateInfo];
            }
            if (shouldAct) {
                [self playVideo:fileURL inView:playView];
            }
            break;
        case kVideoOpened:
        case kVideoOpening:
            if ([delegate respondsToSelector:@selector(videoShouldClose:)]) {
                shouldAct = [delegate videoShouldClose:delegateInfo];
            }
            if (shouldAct) {
                [self stopVideo:YES];
            }
            break;
        default:
            break;
    }
}


@end
