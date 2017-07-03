//
//  NewsItemSwipeTableViewCell.h
//  rfj
//
//  Created by Gonçalo Girão on 31/05/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalerieItem+CoreDataProperties.h"

@class GalerieItemSwipeTableViewCell;

@protocol GalerieItemSwipeTableViewCellDelegate<NSObject>
-(void)GalerieItemSwipeDidTap:(GalerieItemSwipeTableViewCell *)item withGalerieItem:(GalerieItem *)GalerieItem;
@end

@interface GalerieItemSwipeTableViewCell : UITableViewCell
@property (assign, nonatomic) id<GalerieItemSwipeTableViewCellDelegate> delegate;
@property (strong, nonatomic) NSArray <GalerieItem *> *GalerieItems;
- (void) moveLeft;
- (void) moveRight;
- (void) display;
@end
