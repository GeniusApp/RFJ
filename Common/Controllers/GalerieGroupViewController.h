//
//  GalerieGroupViewController.h
//  rfj
//
//  Created by Nuno Silva on 31/03/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalerieItem+CoreDataProperties.h"

@interface GalerieGroupViewController : UIViewController
@property (strong, nonatomic) NSArray<GalerieItem *> *galerieToDisplay;
@property (strong, nonatomic) NSNumber *startingIndex;
@property int iRecordIndex;

@end
