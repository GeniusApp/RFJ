//
//  NewsDetailViewController.m
//  rfj
//
//  Created by Nuno Silva on 27/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <MagicalRecord/MagicalRecord.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"
#import "GalerieGroupViewController.h"
#import "GalerieDetailViewController.h"
#import "MenuItem+CoreDataProperties.h"
#import "MenuItemTableViewCell.h"
#import "NewsManager.h"
#import "NewsSeparatorViewWithBackButton.h"
#import "RadioManager.h"
#import "Validation.h"
#import "MMMarkdown.h"
#import "DataManager.h"
#import "CategoryViewController.h"
#import "WebViewController.h"

@interface GalerieGroupViewController ()<UITableViewDelegate, UITableViewDataSource, MenuItemTableViewCellDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *buttonTapped;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIWebView *bottomBanner;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *infoReportButton;

@property (strong, nonatomic) NSMutableArray<MenuItem *> *menuItems;
@property (strong, nonatomic) NSMutableArray<NSNumber *> *expandedMenuItems;
@property (strong, nonatomic) NSArray<MenuItem *> *allMenuItems;
@property (assign, nonatomic) BOOL isLoading;
@property (assign, nonatomic) NSInteger remainingLoadingElements;
@property (strong, nonatomic) NSArray<GalerieDetailViewController *> *pages;
@property (strong, nonatomic) UIPageViewController *pageController;

@end

@implementation GalerieGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.allMenuItems = [MenuItem sortedMenuItems];
    [self refreshMenuItems];
    
    if([[DataManager singleton] isRFJ]) {
        self.menuTableView.backgroundColor = kBackgroundColorRFJ;
    }
    
    if([[DataManager singleton] isRJB]) {
        self.menuTableView.backgroundColor = kBackgroundColorRJB;
    }
    
    if([[DataManager singleton] isRTN]) {
        self.menuTableView.backgroundColor = kBackgroundColorRTN;
    }
    
    self.menuHeightConstraint.constant = 0;
    self.isLoading = YES;
    self.remainingLoadingElements = 1;
    
    self.pages = [NSArray array];
    
    for(NSInteger i = 0; i < 3; i++) {
        GalerieDetailViewController *page = [self.storyboard instantiateViewControllerWithIdentifier:@"galerieDetail"];
            
        if(VALID(page, GalerieDetailViewController)) {
            self.pages = [self.pages arrayByAddingObject:page];
        }
    }
    
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    [self.pageController setViewControllers:@[[self.pages objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.pageController.delegate = self;
    self.pageController.dataSource = self;
    
    [self.pageController willMoveToParentViewController:self];
    [self addChildViewController:self.pageController];
    [self.view addSubview:self.pageController.view];
    [self.pageController didMoveToParentViewController:self];
    [self.pageController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.pageController.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.pageController.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.pageController.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.pageController.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeRight multiplier:1 constant:0];
    
    [self.view addConstraints:@[topConstraint, bottomConstraint, leftConstraint, rightConstraint]];
    [self.pages objectAtIndex:0].newsID = @([self.startingIndex integerValue]);
    [[self.pages objectAtIndex:0] loadGalerie:@([self.galerieToDisplay objectAtIndex:[self.startingIndex integerValue]].id)];
    [self.view bringSubviewToFront:self.infoReportButton];
    [self.view bringSubviewToFront:self.bottomBanner];
    [self.view bringSubviewToFront:self.loadingView];
    NSString *banner = @"<link rel=\"stylesheet\" href=\"http://geniusapp.com/webview.css\" type=\"text/css\" media=\"all\" />";
    banner = [banner stringByAppendingString:@"<div class=\"pub\"><img src='https://ww2.lapublicite.ch/pubserver/www/delivery/avw.php?zoneid=20049&amp;cb=101&amp;n=a77eccf9' border='0' alt='' /></div>"];
    [self.bottomBanner loadHTMLString:banner baseURL:nil];
    [self hideLoading];
}
- (IBAction)homeButtonTapped:(UIButton *)sender {
    NSArray *array = [self.navigationController viewControllers];
    [self.navigationController popToViewController:[array objectAtIndex:0] animated:YES];
}

- (IBAction)openInfoReport:(id)sender {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"infoReportViewController"];
    
    if(VALID(controller, UIViewController)) {
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(void)refreshMenuItems
{
    NSMutableArray<MenuItem *> *menuItems = [[NSMutableArray<MenuItem *> alloc] init];
    
    for(MenuItem *item in self.allMenuItems)
    {
        if(item.parentId == 0)
        {
            [menuItems addObject:item];
            
            if([self.expandedMenuItems containsObject:@(item.id)])
            {
                for(MenuItem *childItem in self.allMenuItems)
                {
                    if(childItem.parentId == item.id)
                    {
                        [menuItems addObject:item];
                    }
                }
            }
        }
    }
    
    self.menuItems = menuItems;
    
    [self.menuTableView reloadData];
}

-(void)showLoading {
    [self.loadingView setHidden:NO];
}

-(void)hideLoading {
    [self.loadingView setHidden:YES];
}

-(void)showMenu {
    self.menuHeightConstraint.constant = self.menuTableView.contentSize.height;
    
    [UIView animateWithDuration:kMenuAnimationTime animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void)hideMenu {
    self.menuHeightConstraint.constant = 0;
    
    [UIView animateWithDuration:kMenuAnimationTime animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)toggleMenu:(id)sender {
    if(self.menuHeightConstraint.constant > 0) {
        [self hideMenu];
    }
    else {
        [self showMenu];
    }
}

-(IBAction)playRadio:(id)sender {
    if([[RadioManager singleton] isPlaying]) {
        [[RadioManager singleton] stop];
    }
    else {
        [[RadioManager singleton] play];
    }
}

#pragma mark - UITableView Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.menuTableView) {
        return [self.menuItems count];
    }
    
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if(tableView == self.menuTableView) {
        MenuItemTableViewCell *actualCell = (MenuItemTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"menuItemCell"];
        
        if(!VALID(actualCell, MenuItemTableViewCell)) {
            NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"MenuItemTableViewCell" owner:self options:nil];
            
            if(VALID_NOTEMPTY(views, NSArray)) {
                actualCell = [views objectAtIndex:0];
            }
        }
        
        if(VALID(actualCell, MenuItemTableViewCell)) {
            cell = actualCell;
            actualCell.tag = indexPath.row;
            
            if(indexPath.row >= 0 && indexPath.row < [self.menuItems count]) {
                MenuItem *item = [self.menuItems objectAtIndex:indexPath.row];
                
                actualCell.delegate = self;
                
                if ([item.name  isEqual: @"Région"]) {
                    //item.name = @"   Région";
                    [actualCell setName:item.name];
                    //actualCell.layer.backgroundColor = [[UIColor colorWithHexString:@"#0073bf"] CGColor];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                    // cell.layer.backgroundColor = [[UIColor colorWithHexString:@"#000000"] CGColor];
                } else if ([item.name  isEqual: @"Suisse"]) {
                    //item.name = @"   Suisse";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Monde"]) {
                    //item.name = @"   Monde";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Économie"]) {
                    //item.name = @"   Économie";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Culture"]) {
                    //item.name = @"   Culture";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Football"]) {
                    //item.name = @"   Football";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Hockey"]) {
                    //item.name = @"   Hockey";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Basketball"]) {
                    //item.name = @"   Basketball";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Volleyball"]) {
                    //item.name = @"   Volleyball";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Cyclisme"]) {
                    //item.name = @"   Cyclisme";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Ski"]) {
                    // item.name = @"   Ski";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Hippisme"]) {
                    // item.name = @"   Hippisme";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Tennis"]) {
                    // item.name = @"   Tennis";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Autres sports"]) {
                    //item.name = @"   Autres sports";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Sports motorisés"]) {
                    // item.name = @"   Sports motorisés";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else if ([item.name  isEqual: @"Inline hockey"]) {
                    // item.name = @"   Inline hockey";
                    [actualCell setName:item.name];
                    actualCell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073bf"];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
                } else {
                    [actualCell setName:item.name];
                    actualCell.layer.backgroundColor = [[UIColor colorWithHexString:@"#0099ff"] CGColor];
                    actualCell.layer.borderWidth = 1;
                    actualCell.layer.borderColor = [[UIColor colorWithHexString:@"#2182c3"] CGColor];
                }
                
                BOOL shouldExpand = [self.allMenuItems indexOfObjectPassingTest:^BOOL(MenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    return obj.parentId == item.id;
                }] != NSNotFound;
                
                UIImage *icon = nil;
                
                if(shouldExpand && item.id != 0) {
                    icon = [UIImage imageNamed:@"hamburger_menu"];
                }
                else if(VALID_NOTEMPTY(item.link, NSString)) {
                    icon = [UIImage imageNamed:@"link"];
                }
                
                if(VALID(icon, UIImage)) {
                    [actualCell setImage:icon];
                }
            }
        }
    }
    
    return cell;
}

#pragma mark - Menu Item Delegate

-(void)menuItemDidTapIcon:(MenuItemTableViewCell *)item {
    NSIndexPath *index = [self.menuTableView indexPathForCell:item];
    
    if(index.row >= 0 && index.row < [self.menuItems count]) {
        MenuItem *menuItem = [self.menuItems objectAtIndex:index.row];
        
        if(VALID(menuItem, MenuItem)) {
            if([self.expandedMenuItems containsObject:@(menuItem.id)]) {
                [self.expandedMenuItems removeObject:@(menuItem.id)];
                
                NSMutableArray<NSIndexPath *> *removedRows = [[NSMutableArray<NSIndexPath *> alloc] init];
                
                for(NSInteger i = [self.menuItems count] - 1; i >= 0; i--) {
                    MenuItem *subItem = [self.menuItems objectAtIndex:i];
                    
                    if(VALID(subItem, MenuItem) && subItem.parentId == menuItem.id) {
                        [removedRows addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                        
                        [self.menuItems removeObject:subItem];
                    }
                }
                
                [self.menuTableView deleteRowsAtIndexPaths:removedRows withRowAnimation:UITableViewRowAnimationTop];
                
                self.menuHeightConstraint.constant = self.menuHeightConstraint.constant - [removedRows count] * kMenuRowHeight;
                
                [UIView animateWithDuration:kMenuAnimationTime animations:^{
                    [self.menuTableView beginUpdates];
                    [self.menuTableView endUpdates];
                    [self.view layoutIfNeeded];
                }];
            }
            else {
                BOOL shouldExpand = [self.allMenuItems indexOfObjectPassingTest:^BOOL(MenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    return obj.parentId == menuItem.id;
                }] != NSNotFound;
                
                if(shouldExpand && menuItem.id != 0) {
                    [self.expandedMenuItems addObject:@(menuItem.id)];
                    
                    NSInteger startIndex = index.row + 1;
                    NSInteger currentIndex = 0;
                    NSMutableArray<NSIndexPath *> *insertedRows = [[NSMutableArray<NSIndexPath *> alloc] init];
                    
                    for(MenuItem *subItem in self.allMenuItems)
                    {
                        if(subItem.parentId == menuItem.id)
                        {
                            [self.menuItems insertObject:subItem atIndex:startIndex + currentIndex];
                            [insertedRows addObject:[NSIndexPath indexPathForRow:startIndex + currentIndex inSection:0]];
                            
                            currentIndex++;
                        }
                    }
                    
                    [self.menuTableView insertRowsAtIndexPaths:insertedRows withRowAnimation:UITableViewRowAnimationTop];
                    
                    self.menuHeightConstraint.constant = self.menuHeightConstraint.constant + [insertedRows count] * kMenuRowHeight;
                    
                    [UIView animateWithDuration:kMenuAnimationTime animations:^{
                        [self.menuTableView beginUpdates];
                        [self.menuTableView endUpdates];
                        [self.view layoutIfNeeded];
                    }];
                }
            }
        }
    }
}

-(void)menuItemDidTap:(MenuItemTableViewCell *)item {
    self.menuHeightConstraint.constant = 0;
    
    NSIndexPath *index = [self.menuTableView indexPathForCell:item];
    
    if(index.row >= 0 && index.row < [self.menuItems count]) {
        MenuItem *menuItem = [self.menuItems objectAtIndex:index.row];
        
        if(VALID(menuItem, MenuItem)) {
            [self.expandedMenuItems removeAllObjects];
            [self refreshMenuItems];
            
            if(VALID_NOTEMPTY(menuItem.link, NSString)) {
                WebViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewController"];
                
                if(VALID(controller, WebViewController)) {
                    controller.url = menuItem.link;
                    [self.navigationController pushViewController:controller animated:YES];
                }
            }
            else {
                CategoryViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"categoryViewController"];
                
                if(VALID(controller, CategoryViewController)) {
                    controller.navigationId = @(menuItem.id);
                    [self.navigationController pushViewController:controller animated:YES];
                }
            }
        }
    }
}

#pragma mark - UIPageViewController delegate

-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    for(UIViewController *controller in pendingViewControllers) {
        [controller.view setNeedsUpdateConstraints];
        [controller.view setNeedsLayout];
        [controller.view updateConstraintsIfNeeded];
        [controller.view layoutIfNeeded];
    }
}

-(void)pageViewController:(UIPageViewController *)pageViewController  didFinishAnimating:(BOOL)finished previousViewControllers:(nonnull NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    UIViewController *currentController = [pageViewController.viewControllers objectAtIndex:0];
    
    [currentController.view setNeedsUpdateConstraints];
    [currentController.view setNeedsLayout];
    [currentController.view updateConstraintsIfNeeded];
    [currentController.view layoutIfNeeded];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    GalerieDetailViewController *outController = nil;

    if(VALID_NOTEMPTY(self.pages, NSArray)) {
        GalerieDetailViewController *currentController = (GalerieDetailViewController *)viewController;
        NSInteger index = [self.pages indexOfObject:currentController];
        
        if(index == NSNotFound) {
            return outController;
        }
        
        if([currentController.newsID integerValue] + 1 < [self.galerieToDisplay count]) {
            if(index == [self.pages count] - 1) {
                outController =  [self.pages objectAtIndex:0];
            }
            else {
                outController = [self.pages objectAtIndex:index + 1];
            }
        }
        
        if(VALID(outController, GalerieDetailViewController)) {
            NSNumber *currentNewsID = @([self.galerieToDisplay objectAtIndex:[currentController.newsID integerValue] + 1].id);

            if(!VALID(outController.currentGalerie, NSNumber) || [outController.currentGalerie integerValue] != [currentNewsID integerValue]) {
                outController.newsID = @([currentController.newsID integerValue] + 1);
                [outController loadGalerie:currentNewsID];
            }
        }
    }
    
    return outController;
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    GalerieDetailViewController *outController = nil;

    if(VALID_NOTEMPTY(self.pages, NSArray)) {
        GalerieDetailViewController *currentController = (GalerieDetailViewController *)viewController;
        NSInteger index = [self.pages indexOfObject:currentController];
        
        if(index == NSNotFound) {
            return outController;
        }
        
        if([currentController.newsID integerValue] - 1 >= 0) {
            if(index == 0) {
                outController = [self.pages objectAtIndex:[self.pages count] - 1];
            }
            else {
                outController = [self.pages objectAtIndex:index - 1];
            }
        }
        
        if(VALID(outController, GalerieDetailViewController)) {
            NSNumber *currentNewsID = @([self.galerieToDisplay objectAtIndex:[currentController.newsID integerValue] - 1].id);
            
            if(!VALID(outController.currentGalerie, NSNumber) || [outController.currentGalerie integerValue] != [currentNewsID integerValue]) {
                outController.newsID = @([currentController.newsID integerValue] - 1);
                [outController loadGalerie:currentNewsID];
            }
        }
    }
    
    return outController;
}

@end
