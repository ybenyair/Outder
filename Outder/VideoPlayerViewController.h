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

typedef enum {
    kVideoOpening,
    kVideoOpened,
    kVideoClosing,
    kVideoClosed
} eVideoPlayerState;

@protocol VideoPlayerViewControllerDelegate
- (void)videoClosed;
@end

@interface VideoPlayerViewController : UIViewController {
    eVideoPlayerState videoState;
    BOOL enableAutoRotation;
}

-(void) playVideo:(NSString *)videoURL inView:(UIView *)videoView;
-(void) stopVideo;
- (void)stopButtonClicked:(UIButton*)button;

@property (nonatomic, weak) id <VideoPlayerViewControllerDelegate> delegate;
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic,strong) UIButton *stopButton;
@property (nonatomic,strong) UILabel *playbackErrorLabel;

@property  eVideoPlayerState videoState;
@property  BOOL enableAutoRotation;

@property (strong, nonatomic) AVPlayerPlaybackView *mPlaybackView;

@end
