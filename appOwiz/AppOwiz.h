//
//  AppOwiz.h
//  AppOwiz
//
//  Created by AppOwiz Team.
//  Copyright (c) 2016 AppOwiz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppOwiz : NSObject

+(AppOwiz *)sharedInstance;
-(void)startWithAppToken:(NSString *)AppToken withCrashReporting:(BOOL )isCrashReportingEnabled withFeedback:(BOOL) isFeedbackEnabled;
@end
