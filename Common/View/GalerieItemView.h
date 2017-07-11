//
//  NewsItemTableViewCell.h
//  rfj
//
//  Created by Nuno Silva on 21/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalerieItem+CoreDataProperties.h"

@class GalerieItemView;

@protocol GalerieItemViewDelegate<NSObject>
-(void)GalerieItemDidTap:(GalerieItemView *)item;
@end

@interface GalerieItemView : UIView
@property (assign, nonatomic) id<GalerieItemViewDelegate> delegate;
@property (strong, nonatomic) GalerieItem *item;

@end
