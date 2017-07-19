//
//  BaseViewController.m
//  rfj
//
//  Created by Denis Pechernyi on 7/19/17.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import "BaseViewController.h"
#import <Google/Analytics.h>

@interface BaseViewController ()

@end

@implementation BaseViewController

@synthesize screenNameForce = _screenNameForce;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) setScreenName:(NSString *)screenName {
    screenName = [NSString stringWithFormat:@"iOS-%@",screenName];
    [super setScreenName:screenName];
}

- (void) setScreenNameForce:(NSString*)screenName {
    _screenNameForce = screenName;
    screenName = [NSString stringWithFormat:@"iOS-%@",screenName];
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:screenName];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (NSString*)screenNameForce {
    return _screenNameForce;
}

+ (void) gaiTrackEventMenu:(NSString *)title {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"iOS-Menu"
                                                          action:@"Open"
                                                           label:title
                                                           value:nil] build]];
}

+ (void) gaiTrackEventAd:(NSString *)title {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"iOS-Ad"
                                                          action:@"Open"
                                                           label:title
                                                           value:nil] build]];
}

@end
