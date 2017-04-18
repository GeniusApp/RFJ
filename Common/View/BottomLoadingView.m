//
//  BottomLoadingView.m
//  rfj
//
//  Created by Nuno Silva on 27/03/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import "BottomLoadingView.h"
#import "Validation.h"
#define kImageCount 16

@interface BottomLoadingView()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSMutableArray<UIImage *> *images;
@end

@implementation BottomLoadingView

-(void)awakeFromNib {
    [super awakeFromNib];
    
    if(self.imageView == nil) {
        NSArray *contents = [[NSBundle mainBundle] loadNibNamed:@"BottomLoadingView" owner:self options:nil];
        UIView *view = nil;
        
        if(VALID_NOTEMPTY(contents, NSArray)) {
            view = [contents objectAtIndex:0];
        }
        
        if(VALID(view, UIView)) {
            [self addSubview:view];
            
            NSLayoutConstraint *centerHorizontalConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
            
            NSLayoutConstraint *centerVerticalConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
            
            view.translatesAutoresizingMaskIntoConstraints = NO;
            self.translatesAutoresizingMaskIntoConstraints = NO;
            
            [self addConstraints:@[centerHorizontalConstraint, centerVerticalConstraint]];
        }
    }
    else {
        self.images = [[NSMutableArray alloc] init];
        
        for(NSInteger i = 0; i < kImageCount; i++) {
            NSString *fileName = [NSString stringWithFormat:@"loading%ld", (long)i];
            
            UIImage *image = [UIImage imageNamed:fileName];
            
            if(image != nil) {
                [self.images addObject:image];
            }
        }
        
        self.imageView.animationImages = self.images;
        self.imageView.animationDuration = 1.0f;
        self.imageView.animationRepeatCount = 0;
        
        [self.imageView startAnimating];
    }
}

@end
