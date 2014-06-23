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

@synthesize activityIndicator;
@synthesize stopButton;
@synthesize videoPlayer;
@synthesize videoState;
@synthesize playbackErrorLabel;

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
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void) deregisterToDeviceOrientationNotification
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
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
            [self stopButtonClicked:nil];
            NSLog(@"Portrait");
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            /* start special animation */
            break;
            
        default:
            break;
    };
}

- (void)configurePlayerViewPortrait:(UIView *)videoView
{
    // Set the whole view frame
    self.view.frame = videoView.bounds;
    // Set the video player frame
    videoPlayer.view.frame = videoView.bounds;
    
    [self positionItemsOnPlayerView];
    
    [self.view addSubview: videoPlayer.view];
    [videoView addSubview:self.view];
}

- (void)configurePlayerViewLandscape:(CGFloat)angle
{
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
    UIView *videoView = [UIApplication sharedApplication].windows.firstObject;
    CGFloat width = videoView.frame.size.height;
    CGFloat height = videoView.frame.size.width;
    
    CGFloat x = videoView.center.x;
    CGFloat y = videoView.center.y;
    
    [videoPlayer.view setBounds:CGRectMake(0, 0, width, height)];
    [videoPlayer.view setCenter:CGPointMake(x, y)];
    [self positionItemsOnPlayerView];

    [videoPlayer.view removeFromSuperview];
    [videoView addSubview:videoPlayer.view];
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         [videoPlayer.view setTransform:CGAffineTransformMakeRotation(angle)];
                     }];
}

#pragma mark - allocating and configure positions of view items

- (void) allocVideoPlayer:(NSString *)videoURL
{
    NSURL *url;
    url = [NSURL URLWithString:videoURL];
    
    videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    [videoPlayer setScalingMode:MPMovieScalingModeAspectFill];
    [videoPlayer prepareToPlay];
    [videoPlayer setFullscreen:YES animated:YES];
    [videoPlayer setControlStyle:MPMovieControlStyleNone];
}

- (void) releaseVideoPlayer
{
    videoPlayer = nil;
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
    CGFloat x = videoPlayer.view.frame.size.width - 40;
    CGFloat y = videoPlayer.view.frame.size.height - 40;
    stopButton.frame = CGRectMake(x, y, 35.0, 35.0);
    stopButton.hidden = NO;
    
    // Set the playbackError location
    playbackErrorLabel.center = videoPlayer.view.center;
    playbackErrorLabel.hidden = YES;
    
    // Set the activityIndicator location
    activityIndicator.center = videoPlayer.view.center;
}

- (void)addItemsOnPlayerView
{
    [videoPlayer.view addSubview: activityIndicator];
    [videoPlayer.view addSubview: stopButton];
    [videoPlayer.view addSubview: playbackErrorLabel];
}

#pragma mark - Video Player (notifications)

- (void) registerPlayerCallbacks
{
    // Register this class as an observer instead
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:videoPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieStateCallback:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:videoPlayer];
}

- (void) deregisterPlayerCallbacks
{
    // Remove this class from the observers
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:videoPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerLoadStateDidChangeNotification
                                                  object:videoPlayer];
}

#pragma mark - Video Player functions (open/close/play/stop)

- (void)openVideo: (UIView *)videoView
{
    [activityIndicator startAnimating];
    [self registerToDeviceOrientationNotification];
    [videoPlayer play];
}

- (void) closeVideo
{
    [self.playbackErrorLabel removeFromSuperview];
    [self.stopButton removeFromSuperview];
    [videoPlayer.view removeFromSuperview];
    [self.view removeFromSuperview];
    [self releaseVideoPlayer];
    [self releaseActivityIndicator];
    [self deregisterToDeviceOrientationNotification];
    stopButton.hidden = YES;
    videoState = kVideoClosed;
    NSLog(@"Video is closed");
}

-(void) playVideo:(NSString *)videoURL inView:(UIView *)videoView
{
    if (videoState != kVideoClosed)
    {
        NSLog(@"Video is already playing...");
        return;
    }
        
    videoState = kVideoOpening;
    NSLog(@"Video is opening");
    
    // Alloc various objects
    [self allocVideoPlayer:videoURL];
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
        videoState = kVideoClosing;
        [videoPlayer stop];
    }
}

#pragma mark - Video Player (callbacks)

- (void)movieStateCallback:(NSNotification *)notification
{
    NSLog(@"Player state = %d", videoPlayer.loadState);
    
    if ((videoState == kVideoOpening) &&
        (videoPlayer.loadState & MPMovieLoadStatePlayable) == MPMovieLoadStatePlayable) {
        videoState = kVideoOpened;
        [self.activityIndicator stopAnimating];
        NSLog(@"Video is opened");
    }
}

- (void)movieFinishedError
{
    videoState = kVideoClosing;
    NSLog(@"Video is closing");
    
    playbackErrorLabel.hidden = NO;
    [activityIndicator stopAnimating];
    
    [self.videoPlayer.view setAlpha:1];
    
    [UIView animateWithDuration:3.0f
                     animations:^{
                         [self.videoPlayer.view setAlpha:0];
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
        [self.videoPlayer.view setAlpha:1];
        
        [UIView animateWithDuration:1.0f
                         animations:^{
                             [self.videoPlayer.view setAlpha:0];
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

- (void)movieFinishedCallback:(NSNotification*)aNotification
{
    NSNumber* reason = [[aNotification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    [self deregisterPlayerCallbacks];
    
    if ([reason intValue] == MPMovieFinishReasonPlaybackError) {
        NSLog(@"playbackFinished. Reason: Playback Error");
        [self movieFinishedError];
    } else {
        NSLog(@"playbackFinished. Reason: OK");
        [self movieFinishedOK];
    }
    
}

#pragma mark - Video Player user interactions

- (void)stopButtonClicked:(UIButton*)button
{
    if (videoState == kVideoOpened || videoState == kVideoOpening) {
        
        NSLog(@"Video is closing");
        videoState = kVideoClosing;
        
        [self.videoPlayer.view setAlpha:1];
        
        [UIView animateWithDuration:1.0f
                         animations:^{
                             [self.videoPlayer.view setAlpha:0];
                         }
                         completion:^(BOOL finished) {
                             if (finished)
                             {
                                 [videoPlayer stop];
                             }
                         }];
    }
}

@end
