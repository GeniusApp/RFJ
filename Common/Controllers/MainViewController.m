//
//  MainViewController.m
//  rfj
//
//  Created by Nuno Silva on 20/02/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import <MagicalRecord/MagicalRecord.h>
#import <GoogleMobileAds/DFPInterstitial.h>
#import "Constants.h"
#import "DataManager.h"
#import "CategoryViewController.h"
#import "Validation.h"
#import "MainViewController.h"
#import "MenuItem+CoreDataProperties.h"
#import "MenuItemTableViewCell.h"
#import "MenuManager.h"
#import "NewsCategorySeparatorView.h"
#import "NewsGroupViewController.h"
#import "NewsItem+CoreDataProperties.h"
#import "NewsItemTableViewCell.h"
#import "NewsDetailViewController.h"
#import "NewsManager.h"
#import "RadioManager.h"
#import "ResourcesManager.h"
#import "WebViewController.h"
#import "AppOwiz.h"

@import GoogleMobileAds;

@interface MainViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, GADInterstitialDelegate,
    NewsItemTableViewCellDelegate, MenuItemTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *loadingView;


@property (strong, nonatomic) NSMutableArray<MenuItem *> *menuItems;
@property (strong, nonatomic) NSArray<NewsItem *> *newsItems;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSArray<NewsItem *> *> *sortedNewsItems;
@property (strong, nonatomic) NSMutableArray<NSNumber *> *expandedMenuItems;
@property (strong, nonatomic) NSArray<MenuItem *> *allMenuItems;

@property (assign, nonatomic) NSInteger currentPage;
@property (assign, nonatomic) BOOL isLoading;

@property (strong, nonatomic) DFPInterstitial *interstitial;
@property (strong, nonatomic) DFPBannerView  *bannerView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //ggirao stuff for container tableViewController

    //self.contentTableView.hidden = YES;
    
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    self.allMenuItems = [MenuItem sortedMenuItems];
    self.newsItems = [NewsItem MR_findAll];
    
    [[ResourcesManager singleton] fetchResourcesWithSuccessBlock:nil andFailureBlock:nil];
    
    [self refreshMenuItems];
    [self sortNewsItems];
    
    if([[DataManager singleton] isRFJ]) {
        self.menuTableView.backgroundColor = kBackgroundColorRFJ;
    }

    if([[DataManager singleton] isRJB]) {
        self.menuTableView.backgroundColor = kBackgroundColorRJB;
    }

    if([[DataManager singleton] isRTN]) {
        self.menuTableView.backgroundColor = kBackgroundColorRTN;
    }
    
    if(![MenuManager singleton].performedInitialFetch) {
        [[MenuManager singleton] fetchMenuItemsFromServerWithSuccessBlock:^(NSArray<MenuItem *> *items) {
            self.allMenuItems = items;
            [self refreshMenuItems];
        } andFailureBlock:^(NSError *error, NSArray<MenuItem *> *oldItems) {
            self.allMenuItems = oldItems;
            [self refreshMenuItems];
        }];
    }
    
    self.expandedMenuItems = [[NSMutableArray<NSNumber *> alloc] init];
    
    self.currentPage = 0;
    
    self.menuHeightConstraint.constant = 0;
    self.isLoading = NO;
    
    [self loadNextPage];
    [self loadInterstitial];

    NSLog(@"SHOW ME VALUES: %@", self.sortedNewsItems);
    [[AppOwiz sharedInstance] startWithAppToken:@"58f732549e6a8" withCrashReporting:YES withFeedback:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(self.needsToLoadInterstitial) {
        [self loadInterstitial];
    }
}

-(NSArray<NewsItem *> *)combinedNewsItems
{
    NSMutableArray<NewsItem *> *items = [[NSMutableArray<NewsItem *> alloc] init];
    
    for(NSNumber *navigationID in [self.sortedNewsItems allKeys]) {
        [items addObjectsFromArray:[self.sortedNewsItems objectForKey:navigationID]];
    }
    
    return items;
}
- (IBAction)toggleSound:(UIButton *)sender {
    if ([sender isSelected]) {
        [sender setImage:[UIImage imageNamed:@"couper_son_.png"] forState:UIControlStateNormal];
        [sender setSelected:NO];
    } else {
        [sender setImage:[UIImage imageNamed:@"ecouter"] forState:UIControlStateSelected];
        [sender setSelected:YES];
    }
}

- (IBAction)openInfoReport:(id)sender {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"infoReportViewController"];
    
    if(VALID(controller, UIViewController)) {
        [self.navigationController pushViewController:controller animated:YES];
    }
}

-(void)sortNewsItems {
    self.sortedNewsItems = [[NSMutableDictionary<NSNumber *, NSArray<NewsItem *> *> alloc] init];

    for(NewsItem *item in self.newsItems) {
        NSArray *sortedItems = nil;
        
        if([self.sortedNewsItems objectForKey:@(item.navigationId)] == nil) {
            sortedItems = [NSArray arrayWithObject:item];
        }
        else {
            sortedItems = [[self.sortedNewsItems objectForKey:@(item.navigationId)] arrayByAddingObject:item];
        }
        
        [self.sortedNewsItems setObject:sortedItems forKey:@(item.navigationId)];
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

-(IBAction)playRadio:(id)sender {
    if([[RadioManager singleton] isPlaying]) {
        [[RadioManager singleton] stop];
    }
    else {
        [[RadioManager singleton] play];
    }
}

-(void)loadInterstitial {
    self.needsToLoadInterstitial = NO;
    
    NSDictionary *BackendURLs = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BackendURLs" ofType:@"plist"]];
    self.interstitial = [[DFPInterstitial alloc] initWithAdUnitID:[BackendURLs objectForKey:@"DFPInterstitialLoadingLink"]];
    self.interstitial.delegate = self;
    
    DFPRequest *request = [DFPRequest request];
    request.testDevices = @[kGADSimulatorID, @"40238db35009b7d4b7bf9ac26d418d9e"];

    [self.interstitial loadRequest:request];
}

-(void)loadPageItemsForPage:(NSInteger)page count:(NSInteger)count
                    success:(void(^)(NSArray<NewsItem *> *items))successBlock
                    failure:(void(^)(NSError *error))failureBlock {
    self.isLoading = YES;
    
    [[NewsManager singleton] fetchNewsAtPage:page objectType:0 categoryId:-1 withSuccessBlock:^(NSArray<NewsItem *> *items) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isLoading = NO;
            
            if(successBlock) {
                successBlock(items);
            }
        });
    } andFailureBlock:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isLoading = NO;
            
            if(failureBlock) {
                failureBlock(error);
            }
        });
    }];
}

-(void)loadNextPage {
    if(self.isLoading) {
        return;
    }
    
    [self showLoading];
    
    self.currentPage++;
    
    [self loadPageItemsForPage:self.currentPage count:kItemsPerPage success:^(NSArray<NewsItem *> *items) {
        [self hideLoading];
        
        for(NewsItem *item in items) {
            NSInteger itemIndex = [self.newsItems indexOfObjectPassingTest:^BOOL(NewsItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return item.id == obj.id;
            }];
            
            if(itemIndex == NSNotFound) {
                self.newsItems = [self.newsItems arrayByAddingObject:item];
            }
        }

        [self sortNewsItems];
        
        [self.contentTableView reloadData];
    } failure:^(NSError *error) {
        [self hideLoading];
        
        //NSLog(@"Error: %@", error);
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

#pragma mark - UITableView Delegates
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == self.menuTableView) {
        return [self.menuItems count];
    }
    else if(tableView == self.contentTableView) {
        NSNumber *navigationID = [[self.sortedNewsItems allKeys] objectAtIndex:section];
        return [[self.sortedNewsItems objectForKey:navigationID] count];
    }
    
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(tableView == self.menuTableView) {
        return 1;
    }
    
    return [self.sortedNewsItems count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSNumber *navigationID = [[self.sortedNewsItems allKeys] objectAtIndex:section];
    
    NewsCategorySeparatorView *headerView = nil;

    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"NewsCategorySeparatorView" owner:self options:nil];
    
    if(VALID_NOTEMPTY(views, NSArray))
    {
        headerView = [views objectAtIndex:0];
    }
    
    if(VALID(headerView, NewsCategorySeparatorView)) {
        NSInteger categoryIndex = [self.allMenuItems indexOfObjectPassingTest:^BOOL(MenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return obj.id == [navigationID intValue];
        }];
        
        if(categoryIndex != NSNotFound) {
            [headerView setName:[self.allMenuItems objectAtIndex:categoryIndex].name];
        }
    }
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(tableView == self.contentTableView) {
        return kContentCategorySeparatorHeight;
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
            
            if(indexPath.row >= 0 && indexPath.row < [self.menuItems count]) {
                MenuItem *item = [self.menuItems objectAtIndex:indexPath.row];
                actualCell.delegate = self;
                
                [actualCell setName:item.name];

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
    else if(tableView == self.contentTableView) {
        NewsItemTableViewCell *actualCell = (NewsItemTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"newsItemCell"];
        
        if(!VALID(actualCell, NewsItemTableViewCell)) {
            NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"NewsItemTableViewCell" owner:self options:nil];
            
            if(VALID_NOTEMPTY(views, NSArray)) {
                actualCell = [views objectAtIndex:0];
            }
        }
        
        if(VALID(actualCell, NewsItemTableViewCell)) {
            cell = actualCell;
            actualCell.delegate = self;

            NSNumber *navigationID = [[self.sortedNewsItems allKeys] objectAtIndex:indexPath.section];
            NSArray<NewsItem *> *items = [self.sortedNewsItems objectForKey:navigationID];
            //NSLog(@"ITEMS: %@", items);
            if(indexPath.row >= 0 && indexPath.row < [items count]) {
                NewsItem *item = [items objectAtIndex:indexPath.row];
                //NSLog(@"INDEXPATH: %@", items);
                actualCell.item = item;
                
            }
        }
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.menuTableView) {
        return 44.0f;
    }
    else if(tableView == self.contentTableView) {
        return ceilf([UIScreen mainScreen].bounds.size.width * 0.6372340425531915);
    }
    
    return 44.0f;
}

#pragma mark - UIScrollView Delegate

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(scrollView == self.contentTableView) {
        if(scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height && !self.isLoading) {
            //We probably don't want this
            //[self loadNextPage];
        }
    }
}

#pragma mark - Interstitial Delegate

- (void)interstitialDidReceiveAd:(DFPInterstitial *)ad {
    [self.interstitial presentFromRootViewController:self];
}

#pragma mark - MenuItemTableViewCell Delegate

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
            else
            {
                BOOL shouldExpand = [self.allMenuItems indexOfObjectPassingTest:^BOOL(MenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    return obj.parentId == menuItem.id;
                }] != NSNotFound;
                
                if(shouldExpand && menuItem.id != 0) {
                    [self.expandedMenuItems addObject:@(menuItem.id)];
                    
                    NSInteger startIndex = index.row + 1;
                    NSInteger currentIndex = 0;
                    NSMutableArray<NSIndexPath *> *insertedRows = [[NSMutableArray<NSIndexPath *> alloc] init];
                    
                    for(MenuItem *subItem in self.allMenuItems) {
                        if(subItem.parentId == menuItem.id) {
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

#pragma mark - NewsItemTableViewCell Delegate

-(void)NewsItemDidTap:(NewsItemTableViewCell *)item {
    NSIndexPath *index = [self.contentTableView indexPathForCell:item];

    if(index.row >= 0 && index.row < [self.newsItems count]) {
        NewsGroupViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"newsGroup"];
        //NSLog(@"ITEM COUNT: %ld", (long)index.row);
        //NSLog(@"SECTION COUNT: %ld", (long)index.section);


        if(VALID(controller, NewsGroupViewController)) {
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
                NewsItem *localItem = [item.item MR_inContext:localContext];
                
                if(VALID(localItem, NewsItem)) {
                    localItem.read = YES;
                }
            }];
            
            [self.contentTableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
            
            controller.newsToDisplay = [self combinedNewsItems];
            controller.startingIndex = @([controller.newsToDisplay indexOfObjectPassingTest:^BOOL(NewsItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return obj == item.item;
            }]);
            
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

@end
