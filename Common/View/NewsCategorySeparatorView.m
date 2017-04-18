//
//  NewsCategorySeparatorView.m
//  rfj
//
//  Created by Nuno Silva on 21/03/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import "NewsCategorySeparatorView.h"

@interface NewsCategorySeparatorView()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation NewsCategorySeparatorView

-(void)setName:(NSString *)name {
    self.nameLabel.text = name;
}

@end
