//
//  MainViewController.h
//  rfj
//
//  Created by Nuno Silva on 20/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface MainViewController : BaseViewController
@property (assign, nonatomic) BOOL needsToLoadInterstitial;


-(void)loadInterstitial;

@end
