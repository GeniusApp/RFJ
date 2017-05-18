//
//  ImportantTableViewCell.m
//  rfj
//
//  Created by Gonçalo Girão on 17/05/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import "ImportantTableViewCell.h"
#import <MagicalRecord/MagicalRecord.h>
#import "NewsItemTableViewCell.h"
#import "Validation.h"
#import "Constants.h"
#import "UIImageView+WebCache.h"
#import "MenuItem+CoreDataProperties.h"
@interface ImportantTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *coverView;

@end
@implementation ImportantTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

-(void)setItem:(NewsItem *)item {
    if(VALID(item, NewsItem)) {
        item = item;
        self.titleLabel.text = item.title;
        
            [self.coverImage sd_setImageWithURL:[NSURL URLWithString:item.retina1] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if(VALID(image, UIImage)) {
                    [self.coverImage setImage:image];
                }
            }];

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

@end

