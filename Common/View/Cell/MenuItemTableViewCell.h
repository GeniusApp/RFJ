//
//  MenuItemTableViewCell.h
//  rfj
//
//  Created by Nuno Silva on 21/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MenuItemTableViewCell;

@protocol MenuItemTableViewCellDelegate<NSObject>
-(void)menuItemDidTap:(MenuItemTableViewCell *)item;
-(void)menuItemDidTapIcon:(MenuItemTableViewCell *)item;
@end

@interface MenuItemTableViewCell : UITableViewCell
@property (assign, nonatomic) id<MenuItemTableViewCellDelegate> delegate;

-(void)setName:(NSString *)name;
-(void)setImage:(UIImage *)image;

@end
