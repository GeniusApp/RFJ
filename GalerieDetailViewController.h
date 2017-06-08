//
//  GalerieDetailViewController.h
//  rfj
//
//  Created by Gonçalo Girão on 18/05/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GalerieDetailViewController : UIViewController
@property (strong, nonatomic) NSNumber *newsID;

-(void)loadGalerie:(NSNumber *)newsID;

@end
