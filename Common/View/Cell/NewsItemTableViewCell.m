//
//  NewsItemTableViewCell.m
//  rfj
//
//  Created by Nuno Silva on 21/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <MagicalRecord/MagicalRecord.h>
#import "NewsItemTableViewCell.h"
#import "Validation.h"
#import "Constants.h"
#import "UIImageView+WebCache.h"
#import "MenuItem+CoreDataProperties.h"

@interface NewsItemTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIImageView *imageType;

@end

@implementation NewsItemTableViewCell

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

-(void)setItem:(NewsItem *)item {
    if(VALID(item, NewsItem)) {
        _item = item;
        self.titleLabel.text = item.title;
        if (item.type == 1) {
            NSString *concat1 = self.titleLabel.text;
            NSString *concat2 = @"     ";
            self.titleLabel.text = [NSString stringWithFormat:@"%@ %@", concat2, concat1];
            [self.imageType setImage:[UIImage imageNamed:@"image"]];
        }
        if (item.type == 2) {
            NSString *concat1 = self.titleLabel.text;
            NSString *concat2 = @"     ";
            self.titleLabel.text = [NSString stringWithFormat:@"%@ %@", concat2, concat1];
            [self.imageType setImage:[UIImage imageNamed:@"sound"]];
        }
        if (item.type == 3) {
            NSString *concat1 = self.titleLabel.text;
            NSString *concat2 = @"     ";
            self.titleLabel.text = [NSString stringWithFormat:@"%@ %@", concat2, concat1];
            [self.imageType setImage:[UIImage imageNamed:@"play"]];
        }
        
        if ([item.retina1 rangeOfString:@"jpg"].location == NSNotFound && [item.retina1 rangeOfString:@"JPG"].location == NSNotFound) {
            [self.coverImage sd_setImageWithURL:[NSURL URLWithString:item.retina1] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if(VALID(image, UIImage)) {
                    UIImage *noImage = [UIImage imageNamed:@"no-image.png"];
                    [self.coverImage setImage:noImage];
                }
            }];
        } else {
            [self.coverImage sd_setImageWithURL:[NSURL URLWithString:item.retina1] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if(VALID(image, UIImage)) {
                    [self.coverImage setImage:image];
                }
            }];
        }
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"'Actualisé le' dd.MM.y - HH:mm"];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        
        self.dateLabel.text = [formatter stringFromDate:item.updateDate];
        
        NSArray<MenuItem *> *allItems = [MenuItem MR_findAll];
        
        NSInteger categoryIndex = [allItems indexOfObjectPassingTest:^BOOL(MenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return obj.id == item.navigationId;
        }];
        
        if(categoryIndex != NSNotFound) {
            self.categoryLabel.text = [allItems objectAtIndex:categoryIndex].name;
        }
        else {
            self.categoryLabel.text = @"";
        }
        
        if(item.read) {
            self.dateLabel.textColor = kNewsReadColor;
            self.titleLabel.textColor = kNewsReadColor;
            self.categoryLabel.textColor = kNewsReadColor;
        }
    }
}

-(void)handleTap:(UIGestureRecognizer *)gestureRecognizer {
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(NewsItemDidTap:)]) {
        [self.delegate NewsItemDidTap:self];
    }
}

@end
