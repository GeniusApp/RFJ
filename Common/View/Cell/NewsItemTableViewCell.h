//
//  NewsItemTableViewCell.h
//  rfj
//
//  Created by Nuno Silva on 21/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsItem+CoreDataProperties.h"

@class NewsItemTableViewCell;

@protocol NewsItemTableViewCellDelegate<NSObject>
-(void)NewsItemDidTap:(NewsItemTableViewCell *)item;
@end

@interface NewsItemTableViewCell : UITableViewCell
@property (assign, nonatomic) id<NewsItemTableViewCellDelegate> delegate;
@property (strong, nonatomic) NewsItem *item;

@end
