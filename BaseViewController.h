//
//  BaseViewController.h
//  rfj
//
//  Created by Denis Pechernyi on 7/19/17.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import "GAITrackedViewController.h"

@interface BaseViewController : GAITrackedViewController

@property (nonatomic,copy) NSString * screenNameForce;

+ (void) gaiTrackEventMenu:(NSString*)title;
+ (void) gaiTrackEventAd:(NSString *)title;

@end
