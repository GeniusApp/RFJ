//
//  MenuItemTableViewCell.m
//  rfj
//
//  Created by Nuno Silva on 21/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import "MenuItemTableViewCell.h"
#import "Constants.h"

@interface MenuItemTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UIView *topView;

@end

@implementation MenuItemTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = kMenuColorNormal;
    self.selectedBackgroundView = [[UIView alloc] init];
    self.selectedBackgroundView.backgroundColor = kMenuColorSelected;
    
    // Initialization code
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    gestureRecognizer.numberOfTapsRequired = 1;
    
    [self addGestureRecognizer:gestureRecognizer];
    
    gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleIconTap:)];
    gestureRecognizer.numberOfTapsRequired = 1;
    
    [self.icon setUserInteractionEnabled:YES];
    [self.icon addGestureRecognizer:gestureRecognizer];
}

-(void)setName:(NSString *)name {
    self.nameLabel.text = name;
}

-(void)setImage:(UIImage *)image {
    self.icon.image = image;
}

-(void)handleTap:(UIGestureRecognizer *)sender
{
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(menuItemDidTap:)]) {
        [self.delegate menuItemDidTap:self];
    }
}

-(void)handleIconTap:(UIGestureRecognizer *)sender
{
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(menuItemDidTapIcon:)]) {
        [self.delegate menuItemDidTapIcon:self];
    }
}

@end
