//
//  NewsItemTableViewCell.h
//  rfj
//
//  Created by Nuno Silva on 21/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsItem+CoreDataProperties.h"

@class NewsItemView;

@protocol NewsItemViewDelegate<NSObject>
-(void)NewsItemDidTap:(NewsItemView *)item;
@end

@interface NewsItemView : UIView
@property (assign, nonatomic) id<NewsItemViewDelegate> delegate;
@property (strong, nonatomic) NewsItem *item;

@end
