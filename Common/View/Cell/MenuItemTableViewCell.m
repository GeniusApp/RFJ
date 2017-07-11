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
@property (nonatomic, strong, nullable) IBOutlet UIButton *theIconButton;

@end

@implementation MenuItemTableViewCell

#pragma mark - Class Methods (Public)

#pragma mark - Class Adjust Methods (Public)

#pragma mark - Class Get Methods (Public)

#pragma mark - Class Methods (Private)

#pragma mark - Class Adjust Methods (Private)

#pragma mark - Class Get Methods (Private)

#pragma mark - Init & Dealloc

- (instancetype _Nonnull)init
{
    self = [super init];
    [self methodInitMenuItemTableViewCell];
    return self;
}

- (instancetype _Nonnull)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    
    [self methodInitMenuItemTableViewCell];
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    [self methodInitMenuItemTableViewCell];
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self createMenuItemTableViewCell];
}

- (void)methodInitMenuItemTableViewCell
{
    _theBoolIconInteractionEnabled = NO;
    [self adjustToBoolIconInteractionEnabled:_theBoolIconInteractionEnabled];
}

- (void)dealloc
{
    [self eraseMenuItemTableViewCell];
}

#pragma mark - Setters (Public)

- (void)setTheBoolIconInteractionEnabled:(BOOL)theBoolIconInteractionEnabled
{
    _theBoolIconInteractionEnabled = theBoolIconInteractionEnabled;
    [self adjustToBoolIconInteractionEnabled:theBoolIconInteractionEnabled];
}

- (void)setTheNameString:(NSString * _Nullable)theNameString
{
    _theNameString = theNameString;
    [self adjustToNameString:theNameString];
}

- (void)setTheImage:(UIImage * _Nullable)theImage
{
    _theImage = theImage;
    [self adjustToImage:theImage];
}

#pragma mark - Getters (Public)

#pragma mark - Setters (Private)

#pragma mark - Getters (Private)

#pragma mark - Lifecycle

#pragma mark - Create Views & Variables

- (void)createMenuItemTableViewCell
{
    self.backgroundColor = kMenuColorNormal;
    self.selectedBackgroundView = [[UIView alloc] init];
    self.selectedBackgroundView.backgroundColor = kMenuColorSelected;
    
    // Initialization code
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    gestureRecognizer.numberOfTapsRequired = 1;
    [self.contentView addGestureRecognizer:gestureRecognizer];
    
    UIButton *theIconButton = self.theIconButton;
    
    if (!theIconButton)
    {
        theIconButton = [UIButton new];
        self.theIconButton = theIconButton;
    }
    {
        [self.contentView insertSubview:theIconButton
                           belowSubview:self.icon];
        
        CGRect theFrame;
        {
            theFrame.size.height = theIconButton.superview.frame.size.height;
            theFrame.size.width = theFrame.size.height;
            theFrame.origin.y = 0;
            theFrame.origin.x = theIconButton.superview.frame.size.width - theFrame.size.width;
        }
        theIconButton.frame = theFrame;
        
        [theIconButton addTarget:self
                          action:@selector(actionIconButton:)
                forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)eraseMenuItemTableViewCell
{
    
}

#pragma mark - Actions

- (void)actionIconButton:(UIButton * _Nonnull)theButton
{
    if ([self.delegate respondsToSelector:@selector(menuItemDidTapIcon:)])
    {
        [self.delegate menuItemDidTapIcon:self];
    }
}

#pragma mark - Gestures

-(void)handleTap:(UIGestureRecognizer *)sender
{
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(menuItemDidTap:)]) {
        [self.delegate menuItemDidTap:self];
    }
}

#pragma mark - Notifications

#pragma mark - Delegates ()

#pragma mark - Methods (Public)

#pragma mark - Adjust Methods (Public)

#pragma mark - Get Methods (Public)

#pragma mark - Methods (Private)

#pragma mark - Adjust Methods (Private)

- (void)adjustToBoolIconInteractionEnabled:(BOOL)theBoolIconInteractionEnabled
{
    self.theIconButton.userInteractionEnabled = theBoolIconInteractionEnabled;
}

- (void)adjustToNameString:(NSString * _Nullable)theNameString
{
    self.nameLabel.text = theNameString;
}

- (void)adjustToImage:(UIImage * _Nullable)theImage
{
    self.icon.image = theImage;
}

#pragma mark - Get Methods (Private)

#pragma mark - Overriden Methods

@end






























