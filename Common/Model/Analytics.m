//
//  Analytics.m
//  rfj
//
//  Created by Nuno Silva on 03/04/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import "Analytics.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "DataManager.h"
#import "NSObject+Singleton.h"
#import <AFNetworking/AFNetworking.h>


@implementation Analytics

- (id)init {
    if (self = [super init]) {
        // Optional: set Logger to VERBOSE for debug information.
        //[[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
        
        // Initialize tracker. Replace with your tracking ID.
        [[GAI sharedInstance] trackerWithTrackingId:[[DataManager singleton].adsAndStatisticConfig objectForKey:@"GoogleAnalyticsApiKey"]];
    }
    return self;
}

- (void)trackScreenName:(NSString *)stringName {
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"iOS-%@", stringName]];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [self sendNetMetrixView];
}

- (void)sendNetMetrixView {
    NSString *urlString = [[DataManager singleton].adsAndStatisticConfig objectForKey:@"NetMetrixURL"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"Success netmetrix ");
    } failure:^(NSURLSessionTask *task, NSError *error) {
        NSLog(@"*** NETWORK ERROR ***: %@", [error localizedDescription]);
    }];
}

@end
