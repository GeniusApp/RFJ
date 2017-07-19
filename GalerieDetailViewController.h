//
//  GalerieDetailViewController.h
//  rfj
//
//  Created by Gonçalo Girão on 18/05/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface GalerieDetailViewController : BaseViewController
@property (strong, nonatomic) NSNumber *newsID;
@property (strong, nonatomic) NSNumber *currentGalerie;

-(void)loadGalerie:(NSNumber *)newsID;

@end
