//
//  AppDelegate.m
//  rfj
//
//  Created by Nuno Silva on 20/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <MagicalRecord/MagicalRecord.h>
#import <AFSoundManager/AFSoundManager.h>
#import <NSObject+Singleton.h>
#import "AppDelegate.h"
#import "DataManager.h"
#import "MainViewController.h"
#import "Validation.h"
#import "AppOwiz.h"

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
        // [userDefaults setBool:YES forKey:@"playJingleAtStartup"];
        [userDefaults synchronize];
    }
    
    if ([userDefaults boolForKey:@"playJingleAtStartup"]) {
        AFSoundItem *item = [[AFSoundItem alloc] initWithLocalResource:@"jingle.mp3" atPath:nil];
        self.player = [[AFSoundPlayback alloc] initWithItem:item];
        [self.player play];
    }
    
    //Azure Push Notifications
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound |
                                            UIUserNotificationTypeAlert | UIUserNotificationTypeBadge categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    application.applicationIconBadgeNumber = 0;
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [application registerForRemoteNotifications];
    
    [self.window makeKeyAndVisible];
    
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


//- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
//    NSLog(@"Failed to register with error : %@", error);
//}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *) deviceToken {
    SBNotificationHub* hub = [[SBNotificationHub alloc] initWithConnectionString:HUBLISTENACCESS
                                                             notificationHubPath:HUBNAME];
    [hub registerNativeWithDeviceToken:deviceToken tags:[NSSet setWithObject:@"All"] completion:^(NSError* error) {
        if (error != nil) {
            NSLog(@"Error registering for notifications: %@", error);
        }
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification: (NSDictionary *)userInfo {
    [self MessageBox:@"Notification" message:[[userInfo objectForKey:@"aps"] valueForKey:@"alert"]];
}

-(void)MessageBox:(NSString *)title message:(NSString *)messageText
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:messageText delegate:self
                                          cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

@end
