//
//  MP3Player.h
//  BeginCenter
//
//  Created by Alex Benedek on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>

@interface MP3Player : NSObject <AVAudioPlayerDelegate>
{
    dispatch_block_t _soundCompletionHandler;

}

@property (nonatomic, retain) AVAudioPlayer *player;

-(void)playMP3FileNamed:(NSString*)name completion:(dispatch_block_t)handler;
-(void) stopPlaying;

@end
