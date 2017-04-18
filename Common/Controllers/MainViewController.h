//
//  MainViewController.h
//  rfj
//
//  Created by Nuno Silva on 20/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController
@property (assign, nonatomic) BOOL needsToLoadInterstitial;


-(void)loadInterstitial;

@end
