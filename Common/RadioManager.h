//
//  RadioManager.h
//  rfj
//
//  Created by Nuno Silva on 27/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSObject+Singleton.h"

@interface RadioManager : NSObject

-(void)play;
-(void)stop;
-(BOOL)isPlaying;

@end
