//
//  AppDelegate.m
//  rfj
//
//  Created by Nuno Silva on 20/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <MagicalRecord/MagicalRecord.h>
#import <AFSoundManager/AFSoundManager.h>
#import <AWSCognito/AWSCognito.h>
#import <NSObject+Singleton.h>
#import "AppDelegate.h"
#import "AWSCore.h"
#import "AWSCognito.h"
#import "AWSSNS.h"
#import "DataManager.h"
#import "MainViewController.h"
#import "Validation.h"

@interface AppDelegate ()
@property (strong, nonatomic) AFSoundPlayback *player;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"DataModel"];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL appInitialized = [userDefaults boolForKey:@"appInitialized"];
    if (!appInitialized) {
        [userDefaults setBool:YES forKey:@"appInitialized"];
        [userDefaults setBool:YES forKey:@"playJingleAtStartup"];
        [userDefaults synchronize];
    }
    
    if ([userDefaults boolForKey:@"playJingleAtStartup"]) {
        AFSoundItem *item = [[AFSoundItem alloc] initWithLocalResource:@"jingle.mp3" atPath:nil];
        self.player = [[AFSoundPlayback alloc] initWithItem:item];
        [self.player play];
    }
    
    // Aamazon SNS
    // Register for Push notifications
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType: AWSRegionEUWest1 identityPoolId:[[DataManager singleton].awsSnsConfig objectForKey:@"identityPoolId"] unauthRoleArn:[[DataManager singleton].awsSnsConfig objectForKey:@"unauthRoleArn"] authRoleArn:[[DataManager singleton].awsSnsConfig objectForKey:@"authRoleArn"] identityProviderManager:nil];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionEUWest1 credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    application.applicationIconBadgeNumber = 0;
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [application registerForRemoteNotifications];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    
    if(VALID(navController, UINavigationController)) {
        for (UIViewController *controller in navController.viewControllers) {
            if(VALID(controller, MainViewController)) {
                MainViewController *mainController = (MainViewController *)controller;
                
                mainController.needsToLoadInterstitial = YES;
                
                if(mainController == navController.topViewController) {
                    [mainController loadInterstitial];
                }
            }
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [MagicalRecord cleanUp];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    NSLog(@"deviceToken: %@", deviceToken);
    
    const char* data = [deviceToken bytes];
    NSMutableString* token = [NSMutableString string];
    
    for (int i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    
    AWSSNSCreatePlatformEndpointInput *endPointInput = [[AWSSNSCreatePlatformEndpointInput alloc] init];
    endPointInput.platformApplicationArn = [[DataManager singleton].awsSnsConfig objectForKey:@"platformApplicationArn"];
    endPointInput.token = token;
    
    AWSSNS *sns = [AWSSNS defaultSNS];
    [[sns createPlatformEndpoint:endPointInput] continueWithBlock:^id _Nullable(AWSTask<AWSSNSCreateEndpointResponse *> * _Nonnull task) {
        if(task.error != nil) {
            NSLog(@"%@", task.error);
        } else {
            NSLog(@"success created SNS Endpoint token!");
        }
        return nil;
    }];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
    NSLog(@"Failed to register with error : %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    application.applicationIconBadgeNumber = 0;
    NSString *msg = [NSString stringWithFormat:@"%@", userInfo];
    NSLog(@"%@",msg);
}

@end
