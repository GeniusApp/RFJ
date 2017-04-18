//
//  RadioManager.m
//  rfj
//
//  Created by Nuno Silva on 27/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <AFSoundManager/AFSoundManager.h>
#import "DataManager.h"
#import "RadioManager.h"
#import "Validation.h"

@interface RadioManager()
@property (strong, nonatomic) AFSoundPlayback *radioPlayer;
@end

@implementation RadioManager

-(void)play
{
    NSDictionary *backendURLs = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BackendURLs" ofType:@"plist"]];
    NSString *url = [backendURLs objectForKey:@"RadioURL"];
    self.radioPlayer = [[AFSoundPlayback alloc] initWithItem:[[AFSoundItem alloc] initWithStreamingURL:[NSURL URLWithString:url]]];
    [self.radioPlayer play];
}

-(void)stop
{
    if([self isPlaying])
    {
        [self.radioPlayer pause];
        
        self.radioPlayer = nil;
    }
}

-(BOOL)isPlaying
{
    return VALID(self.radioPlayer, AFSoundPlayback) && self.radioPlayer.status == AFSoundStatusPlaying;
}

@end
