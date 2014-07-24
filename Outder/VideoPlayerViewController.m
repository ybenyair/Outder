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

@interface  VideoOverlayHandler : NSObject

@property (nonatomic) NSUInteger currentOverlayIndex;
@property (nonatomic,strong) NSMutableArray *overlayImages;
@property (nonatomic,strong) VideoOverlay *videoOverlay;
@property (nonatomic,strong) AVPlayer *audioStreamer;
@property (nonatomic,strong) NSTimer *overlayTimer;

@end

@implementation VideoOverlayHandler

@end

@interface VideoPlayerViewController ()

@end

@implementation VideoPlayerViewController
{
    NSMutableArray *videoItems;
    NSMutableArray *videoOverlayHandlerArray;
    AVQueuePlayer *queuePlayer;
    UIImageView *overlayView;
    NSUInteger currentPlayingVideo;
}

static VideoPlayerViewController *activePlayer = nil;

@synthesize activityIndicator;
@synthesize stopButton;
//@synthesize videoPlayer;
@synthesize videoState;
@synthesize playbackErrorLabel, enableAutoRotation, mPlaybackView;

#pragma mark - controller initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"VideoPlayerViewController" bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
        // Do any additional setup after loading the view from its nib.
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.view.contentMode = UIViewContentModeScaleAspectFit;
        self.videoState = kVideoClosed;
        self.enableAutoRotation = YES;
        
        [self initStopButton];
        [self initPlaybackErrorLabel];
    }
    
    return self;
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
            [self configurePlayerViewLandscape:(M_PI / 2)];
            break;
        
        case UIDeviceOrientationLandscapeRight:
            /* start special animation */
            NSLog(@"Landscape right");
            [self configurePlayerViewLandscape:(3 * M_PI / 2)];
            break;
            
        case UIDeviceOrientationPortrait:
            [self configurePlayerViewBackToPortrait:(0)];
            NSLog(@"Portrait");
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            /* start special animation */
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
    self.mPlaybackView.frame = videoView.bounds;
    overlayView.frame = videoView.bounds;

    self.view.frame = videoView.bounds;

    [self positionItemsOnPlayerView];
    [self.view addSubview: self.mPlaybackView];
    [self.view addSubview:overlayView];
    [videoView addSubview:self.view];
}

- (void)configurePlayerViewLandscape:(CGFloat)angle
{
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

    [UIView animateWithDuration:0.2f
                     animations:^{
                         [self.mPlaybackView setTransform:CGAffineTransformMakeRotation(angle)];
                         [overlayView setTransform:CGAffineTransformMakeRotation(angle)];
                     }];
}

#pragma mark - allocating and configure positions of view items

- (void) allocVideoPlayer:(NSArray *)videoURLs
{
    videoItems = [[NSMutableArray alloc] init];

    for (id dataElement in videoURLs) {
        NSURL *url;
        NSString *videoURL = (NSString *)dataElement;
        url = [NSURL URLWithString:videoURL];
        AVPlayerItem *videoItem = [AVPlayerItem playerItemWithURL:url];
        
        [videoItems addObject:videoItem];
    }
    
    overlayView = [[UIImageView alloc] init];
    overlayView.contentMode = UIViewContentModeScaleAspectFit;
    overlayView.backgroundColor = [UIColor clearColor];

    currentPlayingVideo = 0;
    
    NSUInteger index = 0;
    for (index = 0; index < [videoOverlayHandlerArray count]; index++) {
        [self prepareOverlayImages:index];
        [self prepareBackgroundTrack:index];
    }
    
    mPlaybackView = [[AVPlayerPlaybackView alloc] init];
    self.mPlaybackView.backgroundColor = [UIColor blackColor];

    queuePlayer = [AVQueuePlayer queuePlayerWithItems:videoItems];
	[self.mPlaybackView setPlayer:queuePlayer];
}

- (void) releaseVideoPlayer
{
    queuePlayer = nil;
    self.mPlaybackView = nil;
    overlayView = nil;
    [videoItems removeAllObjects];
    videoItems = nil;
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
    [self.mPlaybackView  addSubview: activityIndicator];
    [self.mPlaybackView addSubview: stopButton];
    [self.mPlaybackView addSubview: playbackErrorLabel];
}

#pragma mark - Video Player (notifications)

- (void) registerPlayerCallbacks
{
     for (id dataElement in videoItems) {
         
         [dataElement addObserver:self forKeyPath:@"status" options:0 context:nil];
         [dataElement addObserver:self forKeyPath:@"playbackBufferEmpty" options:0 context:nil];
         
         [[NSNotificationCenter defaultCenter] addObserver:self
                                                  selector:@selector(playerItemDidReachEnd:)
                                                      name:AVPlayerItemDidPlayToEndTimeNotification
                                                    object:dataElement];
     }
    
}

- (void) deregisterPlayerCallbacks
{
    for (id dataElement in videoItems) {
        
        [dataElement  removeObserver:self forKeyPath:@"status"];
        [dataElement  removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:dataElement];
    }
    
}

#pragma mark - Video Player functions (open/close/play/stop)

- (void)openVideo: (UIView *)videoView
{
    [self.mPlaybackView setAlpha:1];
    [overlayView setAlpha:1];
    [activityIndicator startAnimating];
    [self registerToDeviceOrientationNotification];
    [queuePlayer play];
}

- (void) closeVideo
{
    [self deregisterPlayerCallbacks];
    [self.playbackErrorLabel removeFromSuperview];
    [self.stopButton removeFromSuperview];
    [self.mPlaybackView removeFromSuperview];
    [self.mPlaybackView setPlayer:nil];
    
    [overlayView removeFromSuperview];
    overlayView.image = nil;
    
    [self.view removeFromSuperview];
    [self releaseVideoPlayer];
    [self releaseActivityIndicator];
    [self deregisterToDeviceOrientationNotification];
    
    [self releaseVideoOverlayHandler:currentPlayingVideo];

    stopButton.hidden = YES;
    videoState = kVideoClosed;
    [self.delegate videoClosed];
    if (activePlayer == self) activePlayer = nil;
    NSLog(@"Video is closed");
}

-(void) playVideo:(NSString *)videoURL inView:(UIView *)videoView
{
    if (!videoURL) return;
    
    NSArray *videoURLs = [NSArray arrayWithObject:videoURL];
    [self playVideoList:videoURLs inView:videoView];
}

-(void) playVideoList:(NSArray *)videoURLs inView:(UIView *)videoView
{
    [self setDemoOverlay];

    if (videoState != kVideoClosed)
    {
        NSLog(@"Video is already playing...stoping it...");
        [self movieFinishedOK];
        return;
    }
    
    if (activePlayer) {
        NSLog(@"Another video is already playing...stoping it...");
        [activePlayer stopVideo];
    }

    activePlayer = self;

    videoState = kVideoOpening;
    NSLog(@"Video is opening");
    
    // Alloc various objects
    [self allocVideoPlayer:videoURLs];
    [self allocActivityIndicator];
    [self addItemsOnPlayerView];
    [self registerPlayerCallbacks];
    
    // Configure view
    [self configurePlayerViewPortrait:videoView];
    
    // Play video (add subviews)
    [self openVideo: videoView];
}

-(void) stopVideo
{
    if (videoState == kVideoOpened || videoState == kVideoOpening) {
        
        NSLog(@"Video is closing");
        [self movieFinishedOK];
    }
}

#pragma mark - Video Player (callbacks)

- (NSUInteger) getVideoIndex: (id) item
{
    NSUInteger index = 0;
    for (id dataElement in videoItems) {
        if (item == dataElement) {
            break;
        }
        index++;
    }
    return index;
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    // Do stuff here
    NSUInteger index = [self getVideoIndex:notification.object];
    [self stopOverlayAnimation: index andHide:YES];
    [self stopBackgroundTrack: index];
    [self releaseVideoOverlayHandler:index];
    
    currentPlayingVideo++;
    if (currentPlayingVideo < [videoOverlayHandlerArray count]) {
        [self startOverlayAnimation: currentPlayingVideo];
        [self playBackgroundTrack: currentPlayingVideo];
    }
    
    if (notification.object == [videoItems lastObject]) {
        NSLog(@"playbackFinished. Reason: OK");
        [self movieFinishedOK];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[AVPlayerItem class]])
    {
        AVPlayerItem *item = (AVPlayerItem *)object;
        //playerItem status value changed?
        if ([keyPath isEqualToString:@"status"])
        {   //yes->check it...
            
            switch(item.status)
            {
                case AVPlayerItemStatusFailed:
                    NSLog(@"playbackFinished. Reason: Playback Error");
                    [self movieFinishedError];
                    break;
                case AVPlayerItemStatusReadyToPlay:
                    NSLog(@"player item status is ready to play");
                    if (videoState == kVideoOpening)  {
                        videoState = kVideoOpened;
                        [self.activityIndicator stopAnimating];
                        NSLog(@"Video is opened");
                    
                        NSUInteger index = [self getVideoIndex:item];
                        [self startOverlayAnimation:index];
                        [self playBackgroundTrack:index];
                        currentPlayingVideo = index;
                    }
                    break;
                case AVPlayerItemStatusUnknown:
                    NSLog(@"player item status is unknown");
                    break;
            }
        }
        else if ([keyPath isEqualToString:@"playbackBufferEmpty"])
        {
            if (item.playbackBufferEmpty)
            {
                NSLog(@"player item playback buffer is empty");
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

        [UIView animateWithDuration:1.0f
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

- (void) releaseVideoOverlayHandler: (NSUInteger) index
{
    VideoOverlayHandler *hndl = [self getVideoOverlayHandler:index];
    if (!hndl) return;
    
    [hndl.videoOverlay.overlayImagesURL removeAllObjects];
    hndl.videoOverlay.overlayImagesURL = nil;
    hndl.videoOverlay = nil;
    
    [hndl.overlayImages removeAllObjects];
    hndl.overlayImages = nil;
    
    hndl.overlayTimer = nil;
    hndl.audioStreamer = nil;
    
    if (hndl == [videoOverlayHandlerArray lastObject]) {
        [videoOverlayHandlerArray removeAllObjects];
        videoOverlayHandlerArray = nil;
    }
        
    hndl = nil;
}

- (VideoOverlayHandler *) getVideoOverlayHandler: (NSUInteger) index
{
    if (!videoOverlayHandlerArray) return nil;
    
    if (index >= [videoOverlayHandlerArray count]) return nil;
    
    return [videoOverlayHandlerArray objectAtIndex:index];
}

- (void) setVideoEffects: (NSArray *) videoOverlaysArray
{
    videoOverlayHandlerArray = [[NSMutableArray alloc] init];
    
    for (id dataElement in videoOverlaysArray) {
        VideoOverlay *videoOverlay = (VideoOverlay *)dataElement;
        VideoOverlayHandler *obj = [[VideoOverlayHandler alloc] init];
        obj.videoOverlay = videoOverlay;
        [videoOverlayHandlerArray addObject:obj];
    }
}

- (void) prepareOverlayImages: (NSUInteger) index
{
    VideoOverlayHandler *hndl = [self getVideoOverlayHandler:index];
    
    if (!hndl) return;
    
    hndl.overlayImages = [[NSMutableArray alloc] init];

    dispatch_async(dispatch_get_global_queue(0,0), ^{
    
        for (id dataElement in hndl.videoOverlay.overlayImagesURL) {
            NSString *imageURL = (NSString *)dataElement;
            NSURL *url = [NSURL URLWithString:imageURL];
            NSData * data = [[NSData alloc] initWithContentsOfURL: url];
            if ( data == nil )
                return;
            
            UIImage *image = [UIImage imageWithData: data];
            [hndl.overlayImages addObject:image];
        }
    });
}

- (void) startOverlayAnimation: (NSUInteger) index
{
    VideoOverlayHandler *hndl = [self getVideoOverlayHandler:index];
    if (!hndl) return;
    
    if (!hndl.videoOverlay.overlayImagesURL) return;
    
    if (hndl.overlayTimer) {
        [self stopOverlayAnimation: index andHide:NO];
    }
    
    overlayView.hidden = NO;
    
    NSLog(@"OVERLAY: start animating index %lu", (unsigned long)index);

    hndl.currentOverlayIndex = 0;
    NSNumber *num = [NSNumber numberWithUnsignedInteger:index];
    hndl.overlayTimer = [NSTimer scheduledTimerWithTimeInterval:hndl.videoOverlay.overlayPeriod target:self selector:@selector(aPresentOverlay:) userInfo:num repeats:YES];
}

- (void) stopOverlayAnimation: (NSUInteger) index andHide:(BOOL) hide
{
    VideoOverlayHandler *hndl = [self getVideoOverlayHandler:index];
    if (!hndl) return;
    
    if (hide) overlayView.hidden = YES;
    
    overlayView.image = nil;
    
    NSLog(@"OVERLAY: stop animating index %lu", (unsigned long)index);
    
    if (hndl.overlayTimer) {
        [hndl.overlayTimer invalidate];
        hndl.overlayTimer = nil;
    }
}

-(void)aPresentOverlay: (NSTimer *)timer
{
    NSNumber *num = (NSNumber *)[timer userInfo];
    NSUInteger index = [num unsignedIntValue];
    VideoOverlayHandler *hndl = [self getVideoOverlayHandler:index];
    if (!hndl) return;
    
    if (hndl.currentOverlayIndex == [hndl.videoOverlay.overlayImagesURL count]) {
        [self stopOverlayAnimation: index andHide:NO];
        NSLog(@"OVERLAY: stop animation");
        return;
    }
    
    if (hndl.currentOverlayIndex < [hndl.overlayImages count]) {
        UIImage *image = [hndl.overlayImages objectAtIndex:hndl.currentOverlayIndex];
        overlayView.image = image;
        hndl.currentOverlayIndex++;
    }
}

- (void) setDemoOverlay
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    VideoOverlay *overlay = [[VideoOverlay alloc] init];
    overlay.overlayImagesURL = [[NSMutableArray alloc] init];
    
    NSString * baseURL = @"http://d167cgw0so9a1a.cloudfront.net/C1/Feed/Fish.";
    for (int i = 0; i < 7; i++) {
        NSString *url = [NSString stringWithFormat:@"%@%d.png", baseURL, i];
        [overlay.overlayImagesURL addObject:url];
    }
    
    overlay.overlayPeriod = 0.5f;
    overlay.backgroundTrack = @"https://s3.amazonaws.com/outder/C5/alone/sound.m4a";
    [array addObject:overlay];

    overlay = [[VideoOverlay alloc] init];
    [array addObject:overlay];
    
    overlay = [[VideoOverlay alloc] init];
    overlay.overlayImagesURL = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 7; i++) {
        NSString *url = [NSString stringWithFormat:@"%@%d.png", baseURL, i];
        [overlay.overlayImagesURL addObject:url];
    }
    
    overlay.overlayPeriod = 0.5f;
    overlay.backgroundTrack = @"https://s3.amazonaws.com/outder/C5/alone/sound.m4a";
    [array addObject:overlay];

    [self setVideoEffects:array];
}


- (void)playBackgroundTrack: (NSUInteger) index
{
    VideoOverlayHandler *hndl = [self getVideoOverlayHandler:index];
    if (!hndl) return;
    
    if (hndl.audioStreamer) {
        [hndl.audioStreamer play];
    }
}

- (void)prepareBackgroundTrack: (NSUInteger) index
{
    VideoOverlayHandler *hndl = [self getVideoOverlayHandler:index];
    if (!hndl) return;
    
    if (!hndl.videoOverlay.backgroundTrack) return;
    
    if (hndl.audioStreamer) {
        [self stopBackgroundTrack: index];
    }
    
    AVPlayerItem *aPlayerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:hndl.videoOverlay.backgroundTrack]];
    hndl.audioStreamer = [[AVPlayer alloc] initWithPlayerItem:aPlayerItem];
    [hndl.audioStreamer pause];
}

- (void)stopBackgroundTrack: (NSUInteger) index
{
    VideoOverlayHandler *hndl = [self getVideoOverlayHandler:index];
    if (!hndl) return;
    
    if (hndl.audioStreamer) {
        [hndl.audioStreamer pause];
        hndl.audioStreamer = nil;
    }
}
    
@end
