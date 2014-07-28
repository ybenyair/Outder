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

@protocol VideoPlayerViewControllerDelegate
- (void)videoClosed: (id)userInfo;
- (void)videoReady: (id)userInfo;
- (BOOL)keepActivePlayers;
@end

@interface VideoPlayerViewController : UIViewController {
    eVideoPlayerState videoState;
    BOOL enableAutoRotation;
}

- (id)initWithView:(UIView *)view;

- (void) setDelegate:(id)obj withInfo: (id) info;
- (void) setFadingDuration: (CGFloat) duration;
- (void) setVideoOverlay: (VideoOverlay *) videoOverlay;
- (void) playVideo:(NSString *)videoURL inView:(UIView *)videoView;
- (void) prepareVideo:(NSString *)videoURL inView:(UIView *)videoView;
- (void) playWhenPrepared: (UIView *)videoView;
- (void) pauseVideo: (BOOL) pasue;
- (void) muteVideo: (BOOL) mute;
- (void) repeatVideo: (BOOL) repeat;
- (void) enableTapGesture: (UIView *)view;


-(void) stopVideo:(BOOL) animated;

- (void)stopButtonClicked:(UIButton*)button;

@property (nonatomic,strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic,strong) UIButton *stopButton;
@property (nonatomic,strong) UILabel *playbackErrorLabel;

@property  eVideoPlayerState videoState;
@property  BOOL enableAutoRotation;

@property (strong, nonatomic) AVPlayerPlaybackView *mPlaybackView;

@end
