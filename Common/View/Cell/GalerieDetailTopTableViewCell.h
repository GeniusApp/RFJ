//
//  GalerieDetailTopTableViewCell.h
//  rfj
//
//  Created by Gonçalo Girão on 08/06/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GalerieDetail+CoreDataProperties.h"

@class GalerieDetailTopTableViewCell;

@protocol GalerieDetailTopTableViewCellDelegate<NSObject>
-(void)GalerieDetailDidTap:(GalerieDetailTopTableViewCell *)item;
@end

@interface GalerieDetailTopTableViewCell : UITableViewCell
@property (assign, nonatomic) id<GalerieDetailTopTableViewCellDelegate> delegate;
@property (strong, nonatomic) GalerieDetail *item;
-(void)setTitle:(NSString *) title andAuthor:(NSString *) author andLink:(NSString *) link;

@end


//#import "GalerieItem+CoreDataProperties.h"
//
//@class GalerieItemTableViewCell;
//
//@protocol GalerieItemTableViewCellDelegate<NSObject>
//-(void)GalerieItemDidTap:(GalerieItemTableViewCell *)item;
//@end
//
//@interface GalerieItemTableViewCell : UITableViewCell
//@property (assign, nonatomic) id<GalerieItemTableViewCellDelegate> delegate;
//@property (strong, nonatomic) GalerieItem *item;
//
//@end
