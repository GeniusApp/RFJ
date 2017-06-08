//
//  NewsItemTableViewCell.m
//  rfj
//
//  Created by Nuno Silva on 21/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <MagicalRecord/MagicalRecord.h>
#import "GalerieDetailTableViewCell.h"
#import "Validation.h"
#import "Constants.h"
#import "UIImageView+WebCache.h"
#import "MenuItem+CoreDataProperties.h"

@interface GalerieDetailTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UIView *coverView;


@end

@implementation GalerieDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Uncomment following lines to revert handleTap - by ggirao
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    gestureRecognizer.numberOfTapsRequired = 1;
    
    [self.coverView setUserInteractionEnabled:YES];
    [self.coverView addGestureRecognizer:gestureRecognizer];
}

-(void)setItem:(GalerieDetail *)item {
    if(VALID(item, GalerieDetail)) {
        _item = item;

            [self.coverImage sd_setImageWithURL:[NSURL URLWithString:item.retina1] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if(VALID(image, UIImage)) {
                    [self.coverImage setImage:image];
                }
            }];

        
        
        
    }
}

-(void)handleTap:(UIGestureRecognizer *)gestureRecognizer {
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(GalerieDetailDidTap:)]) {
        [self.delegate GalerieDetailDidTap:self];
    }
}

@end
