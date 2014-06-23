//
//  VideoPlayerViewController.h
//  Outder
//
//  Created by Yossi on 6/21/14.
//  Copyright (c) 2014 Outder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

typedef enum {
    kVideoOpening,
    kVideoOpened,
    kVideoClosing,
    kVideoClosed
} eVideoPlayerState;

@interface VideoPlayerViewController : UIViewController {
    eVideoPlayerState videoState;
}

-(void) playVideo:(NSString *)videoURL inView:(UIView *)videoView;
-(void) stopVideo;

@property (nonatomic,strong) MPMoviePlayerController *videoPlayer;
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic,strong) UIButton *stopButton;
@property  eVideoPlayerState videoState;


@end
