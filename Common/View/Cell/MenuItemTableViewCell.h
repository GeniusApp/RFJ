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
-(void)menuItemDidTap:(MenuItemTableViewCell * _Nonnull)item;
-(void)menuItemDidTapIcon:(MenuItemTableViewCell * _Nonnull)item;
@end

@interface MenuItemTableViewCell : UITableViewCell
@property (nonatomic, weak, nullable) id<MenuItemTableViewCellDelegate> delegate;
@property (nonatomic, assign) BOOL theBoolIconInteractionEnabled;
@property (nonatomic, strong, nullable) NSString *theNameString;
@property (nonatomic, strong, nullable) UIImage *theImage;

//-(void)setName:(NSString *)name;
//-(void)setImage:(UIImage *)image;

@end
