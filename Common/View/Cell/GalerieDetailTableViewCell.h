//
//  NewsItemTableViewCell.h
//  rfj
//
//  Created by Nuno Silva on 21/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalerieDetail+CoreDataProperties.h"

@class GalerieDetailTableViewCell;

@protocol GalerieDetailTableViewCellDelegate<NSObject>
-(void)GalerieDetailDidTap:(GalerieDetailTableViewCell *)item;
@end

@interface GalerieDetailTableViewCell : UITableViewCell
@property (assign, nonatomic) id<GalerieDetailTableViewCellDelegate> delegate;

-(void) setItem:(GalerieDetail *)item atIndex:(NSInteger) itemIndex;
@end
