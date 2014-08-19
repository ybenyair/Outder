//
//  MP3Player.m
//  BeginCenter
//
//  Created by Alex Benedek on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MP3Player.h"

@implementation MP3Player

-(void)playMP3FileNamed:(NSString*)name completion:(dispatch_block_t)handler{
    
    _soundCompletionHandler = handler;
 
    NSString *soundFilePath =
    [[NSBundle mainBundle] pathForResource: name
                                    ofType: @"wav"];
    
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    
    AVAudioPlayer *newPlayer =
    [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL
                                           error: nil];
    self.player = newPlayer;
    self.player.delegate = self;
    
    if (self.player)
    {
        [_player prepareToPlay];
        
        [_player play];
    }
    else if (_soundCompletionHandler)
        _soundCompletionHandler();
    
    
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    self.player = nil;
    if (_soundCompletionHandler)
        _soundCompletionHandler();
}

-(void)stopPlaying{
    if (self.player.playing)
        [self.player stop];
}

@end
