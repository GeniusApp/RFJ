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
#import "NewsGroupViewController.h"
#import "NewsDetailViewController.h"
#import "GalerieViewController.h"
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

@interface NewsGroupViewController ()<UITableViewDelegate, UITableViewDataSource, MenuItemTableViewCellDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *buttonTapped;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@property (nonatomic, assign) double theFakeMenuHeightConstraintConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIWebView *bottomBanner;
@property (weak, nonatomic) IBOutlet UIButton *infoReportButton;
@property (strong, nonatomic) NSMutableArray<MenuItem *> *menuItems;
@property (strong, nonatomic) NSMutableArray<NSNumber *> *expandedMenuItems;
@property (strong, nonatomic) NSArray<MenuItem *> *allMenuItems;
@property (assign, nonatomic) BOOL isLoading;
@property (assign, nonatomic) NSInteger remainingLoadingElements;
@property (strong, nonatomic) NSArray<NewsDetailViewController *> *pages;
@property (strong, nonatomic) UIPageViewController *pageController;

@end

@implementation NewsGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // tableView
    [self.menuTableView registerNib:[UINib nibWithNibName:@"MenuItemTableViewCell" bundle:nil] forCellReuseIdentifier:@"MenuItemTableViewCell"];
    
    self.expandedMenuItems = [[NSMutableArray<NSNumber *> alloc] init];
    
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
    self.expandedMenuItems = [[NSMutableArray<NSNumber *> alloc] init];
    self.menuHeightConstraint.constant = 0;
    self.isLoading = YES;
    self.remainingLoadingElements = 1;
    
    self.pages = [NSArray array];
    
    for(NSInteger i = 0; i < 3; i++) {
        NewsDetailViewController *page = [self.storyboard instantiateViewControllerWithIdentifier:@"newsDetail"];
            
        if(VALID(page, NewsDetailViewController)) {
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
    [self.pages objectAtIndex:0].newsIndex = @([self.startingIndex integerValue]);
    [[self.pages objectAtIndex:0] loadNews:@([self.newsToDisplay objectAtIndex:[self.startingIndex integerValue]].id)];
    [self.view bringSubviewToFront:self.infoReportButton];
    [self.view bringSubviewToFront:self.bottomBanner];
    [self.view bringSubviewToFront:self.loadingView];
    [self.menuTableView.superview bringSubviewToFront:self.menuTableView];
#ifdef SHOW_ADS
    NSString *banner = @"<link rel=\"stylesheet\" href=\"http://geniusapp.com/webview.css\" type=\"text/css\" media=\"all\" />";
    banner = [banner stringByAppendingString:@"<div class=\"pub\"><img src='https://ww2.lapublicite.ch/pubserver/www/delivery/avw.php?zoneid=20049&amp;cb=101&amp;n=a77eccf9' border='0' alt='' /></div>"];
    NSString *bannerURL = @"https://ww2.lapublicite.ch/webservices/WSBanner.php?type=RFJAPPBAN";
    [self getJsonResponse:bannerURL success:^(NSDictionary *responseDict) {
        NSString *str = responseDict[@"banner"];
        NSString *fixBanner = @"<link rel=\"stylesheet\" href=\"https://www.rfj.ch/Htdocs/Styles/webview.css\" type=\"text/css\" media=\"all\" />";
        str = [fixBanner stringByAppendingString:str];
        [self.bottomBanner loadHTMLString:str baseURL:nil];
    } failure:^(NSError *error) {
        // error handling here ...
    }];
#endif
    [self hideLoading];
}
-(void)getJsonResponse:(NSString *)urlStr success:(void (^)(NSDictionary *responseDict))success failure:(void(^)(NSError* error))failure
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    // Asynchronously API is hit here
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                //                                                NSLog(@"%@",data);
                                                if (error)
                                                    failure(error);
                                                else {
                                                    NSDictionary *json  = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                    //                                                    NSLog(@"%@",json);
                                                    success(json);
                                                }
                                            }];
    [dataTask resume];    // Executed First
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
    [self adjustMenuHeightConstant];
    
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
    if(tableView == self.menuTableView) {
        static NSString * cellId = @"MenuItemTableViewCell";
        MenuItemTableViewCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        MenuItem *item = [self.menuItems objectAtIndex:indexPath.row];
        cell.delegate = self;
        cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0099ff"];
        cell.contentView.layer.borderWidth = 1;
        cell.contentView.layer.borderColor = [[UIColor colorWithHexString:@"#2182c3"] CGColor];
        // TODO AN Refactor. Create .json or .plist instead. DO NOT use isEqual. Use id comparision
        if(
           [item.name  isEqual: @"Région"]              ||
           [item.name  isEqual: @"Suisse"]              ||
           [item.name  isEqual: @"Monde"]               ||
           [item.name  isEqual: @"Économie"]            ||
           [item.name  isEqual: @"Culture"]             ||
           [item.name  isEqual: @"Football"]            ||
           [item.name  isEqual: @"Hockey"]              ||
           [item.name  isEqual: @"Basketball"]          ||
           [item.name  isEqual: @"Volleyball"]          ||
           [item.name  isEqual: @"Cyclisme"]            ||
           [item.name  isEqual: @"Ski"]                 ||
           [item.name  isEqual: @"Hippisme"]            ||
           [item.name  isEqual: @"Tennis"]              ||
           [item.name  isEqual: @"Autres sports"]       ||
           [item.name  isEqual: @"Sports motorisés"]    ||
           [item.name  isEqual: @"Inline hockey"] ) {
            cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#0073c0"];
            cell.contentView.layer.borderColor = [[UIColor colorWithHexString:@"#146195"] CGColor];
        }
        cell.theNameString = item.name;
        BOOL shouldExpand = [self.allMenuItems indexOfObjectPassingTest:^BOOL(MenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return obj.parentId == item.id;
        }] != NSNotFound;
        
        if(shouldExpand && item.id != 0) {
            cell.theImage = [UIImage imageNamed:@"hamburger_menu"];
            cell.theBoolIconInteractionEnabled = YES;
        } else if(VALID_NOTEMPTY(item.link, NSString)) {
            cell.theImage = [UIImage imageNamed:@"link"];
            cell.theBoolIconInteractionEnabled = NO;
        } else {
            cell.theImage = nil;
            cell.theBoolIconInteractionEnabled = NO;
        }
        return cell;
    }
    return nil;
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
                
                self.menuHeightConstraint.constant = self.theFakeMenuHeightConstraintConstant - [removedRows count] * kMenuRowHeight;
                [self adjustMenuHeightConstant];
                
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
                    
                    self.menuHeightConstraint.constant = self.theFakeMenuHeightConstraintConstant + [insertedRows count] * kMenuRowHeight;
                    [self adjustMenuHeightConstant];
                    
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
                [BaseViewController gaiTrackEventMenu:menuItem.name];
                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:menuItem.link]];
            } else if ([@(menuItem.id) isEqualToNumber:[NSNumber numberWithInt:9622]]) {
                
                GalerieViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"GalerieViewController"];
                
                if(VALID(controller, GalerieViewController)) {
                    //controller.navigationId = @(menuItem.id);
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
    NewsDetailViewController *outController = nil;

    if(VALID_NOTEMPTY(self.pages, NSArray)) {
        NewsDetailViewController *currentController = (NewsDetailViewController *)viewController;
        NSInteger index = [self.pages indexOfObject:currentController];
        
        if(index == NSNotFound) {
            return outController;
        }
        
        if([currentController.newsIndex integerValue] + 1 < [self.newsToDisplay count]) {
            if(index == [self.pages count] - 1) {
                outController =  [self.pages objectAtIndex:0];
            }
            else {
                outController = [self.pages objectAtIndex:index + 1];
            }
        }
        
        if(VALID(outController, NewsDetailViewController)) {
            NSNumber *currentNewsID = @([self.newsToDisplay objectAtIndex:[currentController.newsIndex integerValue] + 1].id);

            if(!VALID(outController.currentNews, NSNumber) || [outController.currentNews integerValue] != [currentNewsID integerValue]) {
                outController.newsIndex = @([currentController.newsIndex integerValue] + 1);
                [outController loadNews:currentNewsID];
            }
        }
    }
    
    return outController;
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NewsDetailViewController *outController = nil;

    if(VALID_NOTEMPTY(self.pages, NSArray)) {
        NewsDetailViewController *currentController = (NewsDetailViewController *)viewController;
        NSInteger index = [self.pages indexOfObject:currentController];
        
        if(index == NSNotFound) {
            return outController;
        }
        
        if([currentController.newsIndex integerValue] - 1 >= 0) {
            if(index == 0) {
                outController = [self.pages objectAtIndex:[self.pages count] - 1];
            }
            else {
                outController = [self.pages objectAtIndex:index - 1];
            }
        }
        
        if(VALID(outController, NewsDetailViewController)) {
            NSNumber *currentNewsID = @([self.newsToDisplay objectAtIndex:[currentController.newsIndex integerValue] - 1].id);
            
            if(!VALID(outController.currentNews, NSNumber) || [outController.currentNews integerValue] != [currentNewsID integerValue]) {
                outController.newsIndex = @([currentController.newsIndex integerValue] - 1);
                [outController loadNews:currentNewsID];
            }
        }
    }
    
    return outController;
}

- (void)adjustMenuHeightConstant
{
    self.theFakeMenuHeightConstraintConstant = self.menuHeightConstraint.constant;
    double theProperHeightCount = 0;
    {
        theProperHeightCount += self.menuTableView.superview.frame.size.height;
        theProperHeightCount -= self.bottomBanner.frame.size.height;
        theProperHeightCount -= self.menuTableView.frame.origin.y;
    }
    if (self.menuHeightConstraint.constant > theProperHeightCount)
    {
        self.menuHeightConstraint.constant = theProperHeightCount;
    }
}

@end
