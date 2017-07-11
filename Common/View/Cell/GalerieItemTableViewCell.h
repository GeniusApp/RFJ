//
//  NewsItemTableViewCell.h
//  rfj
//
//  Created by Nuno Silva on 21/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalerieItem+CoreDataProperties.h"

@class GalerieItemTableViewCell;

@protocol GalerieItemTableViewCellDelegate<NSObject>
-(void)GalerieItemDidTap:(GalerieItemTableViewCell *)item;
@end

@interface GalerieItemTableViewCell : UITableViewCell
@property (assign, nonatomic) id<GalerieItemTableViewCellDelegate> delegate;
@property (strong, nonatomic) GalerieItem *item;

@end
