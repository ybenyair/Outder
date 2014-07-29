//
//  VideoPlayerViewController.h
//  Outder
//
//  Created by Yossi on 6/21/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "AVPlayerPlaybackView.h"

#pragma mark - VideoOverlays

@interface  VideoOverlay : NSObject

@property (nonatomic) CGFloat overlayPeriod;
@property (nonatomic,strong) NSMutableArray *overlayImagesURL;
@property (nonatomic,strong) NSString *overlayTrack;

@end


#pragma mark - VideoPlayerViewController

typedef enum {
    kVideoOpening,
    kVideoOpened,
    kVideoClosing,
    kVideoClosed
} eVideoPlayerState;

@protocol VideoPlayerViewControllerDelegate <NSObject>
// The user tapped on the Video view
- (BOOL)videoShouldPlay: (id)userInfo;
// The user tapped on the Video view
- (BOOL)videoShouldClose: (id)userInfo;
// The video is ready to be played
- (void)videoIsReady: (id)userInfo;
// The video was just closed
- (void)videoDidClose: (id)userInfo;
// Do we support in one than one video instance
- (BOOL)videoShouldKeepActivePlayers: (id)userInfo;
@end

@interface VideoPlayerViewController : UIViewController {
    eVideoPlayerState videoState;
    BOOL enableAutoRotation;
}

// Access to members
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic,strong) UIButton *stopButton;
@property (nonatomic,strong) UILabel *playbackErrorLabel;
@property  eVideoPlayerState videoState;
@property  BOOL enableAutoRotation;
@property (strong, nonatomic) AVPlayerPlaybackView *mPlaybackView;

// Configuration methods
- (void) setDelegate:(id)obj withInfo: (id) info;
- (void) setFadingDuration: (CGFloat) duration;
- (void) setVideoOverlay: (VideoOverlay *) videoOverlay;
- (void) setTapGesture: (BOOL)enable;
- (void) setVideoURL: (NSString *)videoURL;


// Player methods (when using regular init)
- (void) playVideo:(NSString *)videoURL inView:(UIView *)videoView;
- (void) prepareVideo:(NSString *)videoURL inView:(UIView *)videoView;
- (void) playWhenPrepared: (UIView *)videoView;
- (void) pauseVideo: (BOOL) pasue;
- (void) stopVideo:(BOOL) animated;
- (void) repeatVideo: (BOOL) repeat;
- (void) muteVideo: (BOOL) mute;

// Player methods (when using custom init)
- (id)initWithView:(UIView *)view andURL:(NSString *) url;
- (void) playVideo;
- (void) prepareVideo;
- (void) playWhenPrepared;

@end
