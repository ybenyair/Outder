//
//  VideoPlayerViewController.m
//  Outder
//
//  Created by Yossi on 6/21/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import "VideoPlayerViewController.h"

@interface VideoPlayerViewController ()

@end

@implementation VideoPlayerViewController
{
    NSMutableArray *videoItems;
    AVQueuePlayer *queuePlayer;
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
                     }];
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    CGFloat x = self.view.center.x;
    CGFloat y = self.view.center.y;
    
    [self.mPlaybackView setBounds:CGRectMake(0, 0, width, height)];
    [self.mPlaybackView setCenter:CGPointMake(x, y)];
    
    [self.mPlaybackView removeFromSuperview];
    [self.view addSubview:self.mPlaybackView];
    [self positionItemsOnPlayerView];
}

- (void)configurePlayerViewPortrait:(UIView *)videoView
{
    // Set the whole view frame
    // Set the video player frame
    self.mPlaybackView.frame = videoView.bounds;
    self.view.frame = videoView.bounds;
    
    [self positionItemsOnPlayerView];
    [self.view addSubview: self.mPlaybackView];
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
    [self positionItemsOnPlayerView];

    [self.mPlaybackView removeFromSuperview];
    [videoView addSubview:self.mPlaybackView];
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         [self.mPlaybackView setTransform:CGAffineTransformMakeRotation(angle)];
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
    
    mPlaybackView = [[AVPlayerPlaybackView alloc] init];
    self.mPlaybackView.backgroundColor = [UIColor blackColor];

    queuePlayer = [AVQueuePlayer queuePlayerWithItems:videoItems];
	[self.mPlaybackView setPlayer:queuePlayer];
}

- (void) releaseVideoPlayer
{
    queuePlayer = nil;
    self.mPlaybackView = nil;
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
    [[videoItems lastObject] addObserver:self forKeyPath:@"status" options:0 context:nil];
    [[videoItems lastObject] addObserver:self forKeyPath:@"playbackBufferEmpty" options:0 context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[videoItems lastObject]];
    
}

- (void) deregisterPlayerCallbacks
{    
    [[videoItems lastObject]  removeObserver:self forKeyPath:@"status"];
    [[videoItems lastObject]  removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[videoItems lastObject]];
    
}

#pragma mark - Video Player functions (open/close/play/stop)

- (void)openVideo: (UIView *)videoView
{
    [self.mPlaybackView setAlpha:1];
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
    [self.view removeFromSuperview];
    [self releaseVideoPlayer];
    [self releaseActivityIndicator];
    [self deregisterToDeviceOrientationNotification];
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

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    // Do stuff here
    NSLog(@"playbackFinished. Reason: OK");
    [self movieFinishedOK];
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
    
    [UIView animateWithDuration:3.0f
                     animations:^{
                         [self.self.mPlaybackView setAlpha:0];
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
        
        [UIView animateWithDuration:1.0f
                         animations:^{
                             [self.mPlaybackView setAlpha:0];
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
        
        [UIView animateWithDuration:1.0f
                         animations:^{
                             [self.mPlaybackView setAlpha:0];
                         }
                         completion:^(BOOL finished) {
                             if (finished)
                             {
                                 [self movieFinishedOK];
                             }
                         }];
    }
}

@end
