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

- (void)initStopButton
{
    stopButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *buttonImage = [UIImage imageNamed:@"mediaStopBtn"];
    [stopButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [stopButton addTarget:self action:@selector(stopButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [stopButton setShowsTouchWhenHighlighted:YES];
    stopButton.hidden = YES;
}

- (void)setStopButtonFrame: (UIView *)videoView
{
    CGFloat x = videoView.frame.size.width - 40;
    CGFloat y = videoView.frame.size.height - 40;
    stopButton.frame = CGRectMake(x, y, 35.0, 35.0);
    stopButton.hidden = NO;
}

- (void) allocVideoPlayer:(NSString *)videoURL
{
    NSURL *url;
    url = [NSURL URLWithString:videoURL];
    
    videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    [videoPlayer setContentURL:[NSURL URLWithString:videoURL]];
    [videoPlayer.view setFrame: self.view.bounds];
    [videoPlayer setScalingMode:MPMovieScalingModeAspectFill];
    [videoPlayer prepareToPlay];
    [videoPlayer setFullscreen:NO animated:NO];
    [videoPlayer setControlStyle:MPMovieControlStyleNone];
}

- (void)configurePlayerView:(UIView *)videoView
{
    self.view.frame = videoView.bounds;
    [self.view setAlpha:1];
    [self setStopButtonFrame:videoView];
}

- (void) allocActivityIndicator
{
    //Create and add the Activity Indicator to splashView
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.alpha = 1.0;
    activityIndicator.center = self.view.center;
    activityIndicator.hidesWhenStopped = YES;
}

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

- (void)openVideo: (UIView *)videoView
{
    [self.view addSubview: videoPlayer.view];
    [videoPlayer.view addSubview: activityIndicator];
    [videoPlayer.view addSubview: stopButton];
    [activityIndicator startAnimating];
    
    [videoPlayer play];
    [videoView addSubview:self.view];
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

    [self configurePlayerView:videoView];
    [self allocVideoPlayer:videoURL];
    [self allocActivityIndicator];
    [self registerPlayerCallbacks];
    [self openVideo: videoView];
}

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

- (void)movieFinishedCallback:(NSNotification*)aNotification
{

    [self deregisterPlayerCallbacks];
    
    if (videoState == kVideoOpened) {
        
        videoState = kVideoClosing;
        NSLog(@"Video is closing");
        [self.view setAlpha:1];
        
        [UIView animateWithDuration:1.0f
                         animations:^{
                             [self.view setAlpha:0];
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

- (void) releaseVideoPlayer
{
    videoPlayer = nil;
}

- (void) releaseActivityIndicator
{
    activityIndicator = nil;
}

- (void) closeVideo
{
    [self.stopButton removeFromSuperview];
    [videoPlayer.view removeFromSuperview];
    [self.view removeFromSuperview];
    [self releaseVideoPlayer];
    [self releaseActivityIndicator];
    stopButton.hidden = YES;
    videoState = kVideoClosed;
    NSLog(@"Video is closed");
}

-(void) stopVideo
{
    if (videoState == kVideoOpened || videoState == kVideoOpening) {
        
        NSLog(@"Video is closing");
        videoState = kVideoClosing;
        [videoPlayer stop];
    }
}


- (void)stopButtonClicked:(UIButton*)button
{
    if (videoState == kVideoOpened || videoState == kVideoOpening) {
        
        NSLog(@"Video is closing");
        videoState = kVideoClosing;
        
        [self.view setAlpha:1];
        
        [UIView animateWithDuration:1.0f
                         animations:^{
                             [self.view setAlpha:0];
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
