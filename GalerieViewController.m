//
//  GalerieViewController.m
//  rfj
//
//  Created by Gonçalo Girão on 18/05/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import "GalerieViewController.h"
#import <MagicalRecord/MagicalRecord.h>
#import <GoogleMobileAds/DFPInterstitial.h>
#import "Constants.h"
#import "DataManager.h"
#import "CategoryViewController.h"
#import "Validation.h"
#import "GalerieItem+CoreDataProperties.h"
#import "GalerieDetail+CoreDataProperties.h"
#import "MenuItem+CoreDataProperties.h"
#import "MenuItemTableViewCell.h"
#import "MenuManager.h"
#import "NewsCategorySeparatorView.h"
#import "GalerieDetailViewController.h"
#import "GalerieGroupViewController.h"
#import "GalerieItem+CoreDataProperties.h"
#import "GalerieItemTableViewCell.h"
#import "NewsDetailViewController.h"
#import "NewsManager.h"
#import "NewsSeparatorViewWithBackButton.h"
#import "RadioManager.h"
#import "ResourcesManager.h"
#import "WebViewController.h"


@interface GalerieViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, GADInterstitialDelegate,
GalerieItemTableViewCellDelegate, MenuItemTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@property (nonatomic, assign) double theFakeMenuHeightConstraintConstant;
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIWebView *bottomBanner;
@property (weak, nonatomic) IBOutlet NewsSeparatorViewWithBackButton *separatorView;
@property (strong, nonatomic) NSMutableArray<MenuItem *> *menuItems;
@property (strong, nonatomic) NSArray<GalerieItem *> *galerieItems;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSArray<GalerieItem *> *> *sortedGalerieItems;
@property (strong, nonatomic) NSMutableArray<NSNumber *> *expandedMenuItems;
@property (strong, nonatomic) NSArray<MenuItem *> *allMenuItems;

@property (assign, nonatomic) NSInteger currentPage;
@property (assign, nonatomic) BOOL isLoading;
@property (strong, nonatomic) NSNumber *activeCategoryId;

@end

@implementation GalerieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // tableView
    [self.menuTableView registerNib:[UINib nibWithNibName:@"MenuItemTableViewCell" bundle:nil] forCellReuseIdentifier:@"MenuItemTableViewCell"];
    [self.contentTableView registerNib:[UINib nibWithNibName:@"GalerieItemTableViewCell" bundle:nil] forCellReuseIdentifier:@"GalerieItemTableViewCell"];
    
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor whiteColor];
    refreshControl.tintColor = [UIColor blackColor];
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.contentTableView;
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = refreshControl;
    
    self.allMenuItems = [MenuItem sortedMenuItems];
    self.galerieItems = [GalerieItem MR_findAllSortedBy:@"createDate"
                                        ascending:NO];

    
    
    [[ResourcesManager singleton] fetchResourcesWithSuccessBlock:nil andFailureBlock:nil];
    
    [self refreshMenuItems];
    [self sortGalerieItems];
    
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
    self.activeCategoryId = [NSNumber numberWithInt:9622];
    [self refreshCategory:[self.activeCategoryId intValue]];
    self.currentPage = 0;
    
    self.menuHeightConstraint.constant = 0;
    self.isLoading = NO;
    [self loadNextPage];
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    [self.navigationController popViewControllerAnimated:YES];
}

// Metdodo Som

// Metodo infoReporter

- (void)refreshTable:(id)sender {
    //TODO: refresh your data
    
    //[self.contentTableView reloadData];
    [self loadNextPage];
    [self.contentTableView.refreshControl endRefreshing];
    
    
}

-(void)refreshCategory:(NSInteger)categoryId
{
    NSInteger menuIndex = [self.allMenuItems indexOfObjectPassingTest:^BOOL(MenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return obj.id == categoryId;
    }];
    
    if(menuIndex == NSNotFound) {
        return;
    }
    
    self.activeCategoryId = @(categoryId);
    self.currentPage = 1;
    self.galerieItems = @[];
    self.galerieItems = [GalerieItem MR_findAllSortedBy:@"createDate"
                                        ascending:NO];
    [self.separatorView setCategoryName:[self.allMenuItems objectAtIndex:menuIndex].name];
    
    [self showLoading];
    
    [[NewsManager singleton] fetchImagesAtPage:self.currentPage objectType:1 categoryId:categoryId withSuccessBlock:^(NSArray<GalerieItem *> *items) {
        self.galerieItems = [self.galerieItems arrayByAddingObjectsFromArray:items];
        
        [self.contentTableView reloadData];
        [self hideLoading];
    } andFailureBlock:^(NSError *error) {
        //NSLog(@"Failure getting news items: %@", error);
        
        [self.contentTableView reloadData];
        [self hideLoading];
    }];
}

-(NSArray<GalerieItem *> *)combinedGalerieItems
{
    NSMutableArray<GalerieItem *> *items = [[NSMutableArray<GalerieItem *> alloc] init];
    
    for(NSNumber *navigationID in [self.sortedGalerieItems allKeys]) {
        [items addObjectsFromArray:[self.sortedGalerieItems objectForKey:navigationID]];
    }
    
    return items;
}

-(void)sortGalerieItems {
    self.sortedGalerieItems = [[NSMutableDictionary<NSNumber *, NSArray<GalerieItem *> *> alloc] init];
    
    for(GalerieItem *item in self.galerieItems) {
        NSArray *sortedItems = nil;
        
        if([self.sortedGalerieItems objectForKey:@(item.navigationId)] == nil) {
            sortedItems = [NSArray arrayWithObject:item];
        }
        else {
            sortedItems = [[self.sortedGalerieItems objectForKey:@(item.navigationId)] arrayByAddingObject:item];
        }
        
        [self.sortedGalerieItems setObject:sortedItems forKey:@(item.navigationId)];
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

-(void)loadPageItemsForPage:(NSInteger)page count:(NSInteger)count
                    success:(void(^)(NSArray<GalerieItem *> *items))successBlock
                    failure:(void(^)(NSError *error))failureBlock {
    self.isLoading = YES;
    
    [[NewsManager singleton] fetchImagesAtPage:page objectType:1 categoryId:-1 withSuccessBlock:^(NSArray<GalerieItem *> *items) {
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
    
    [self loadPageItemsForPage:self.currentPage count:kItemsPerPage success:^(NSArray<GalerieItem *> *items) {
        [self hideLoading];
        
        for(GalerieItem *item in items) {
            NSInteger itemIndex = [self.galerieItems indexOfObjectPassingTest:^BOOL(GalerieItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return item.id == obj.id;
            }];
            
            if(itemIndex == NSNotFound) {
                self.galerieItems = [self.galerieItems arrayByAddingObject:item];
            }
        }

        
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
        return [self.galerieItems count];
    }
    
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(tableView == self.menuTableView) {
        return 1;
    } else {
        return 1;
    }
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
    } else if(tableView == self.contentTableView) {
        static NSString * cellId = @"GalerieItemTableViewCell";
        GalerieItemTableViewCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        cell.delegate = self;
        cell.item = self.galerieItems[indexPath.row];
        return cell;
    }
    return nil;
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
                
                self.menuHeightConstraint.constant = self.theFakeMenuHeightConstraintConstant - [removedRows count] * kMenuRowHeight;
                [self adjustMenuHeightConstant];
                
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
                WebViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewController"];
                
                if(VALID(controller, WebViewController)) {
                    controller.url = menuItem.link;
                    [self.navigationController pushViewController:controller animated:YES];
                }
            }
            else {
                if ([@(menuItem.id) isEqualToNumber:[NSNumber numberWithInt:9622]]) {
                    
                    GalerieViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"GalerieViewController"];
                    
                    if(VALID(controller, GalerieViewController)) {
                        //controller.navigationId = @(menuItem.id);
                        [self.navigationController pushViewController:controller animated:YES];
                    }
                } else {
                    CategoryViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"categoryViewController"];
                    
                    if(VALID(controller, CategoryViewController)) {
                        controller.navigationId = @(menuItem.id);
                        [self.navigationController pushViewController:controller animated:YES];
                    }
                }
            }
        }
    }
}





#pragma mark - NewsItemTableViewCell Delegate

-(void)GalerieItemDidTap:(GalerieItemTableViewCell *)item {
//    NSIndexPath *index = [self.contentTableView indexPathForCell:item];
//    NSLog(@"GALERIE PHOTO TAPPED %ld", (long)index.row);
//    GalerieItem *photoItem = [self.galerieItems objectAtIndex:index.row];
//    NSLog(@"GALERIE PHOTO TAPPED %@", photoItem.retina1);
//    UIImage *image =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoItem.retina1]]];
//    [self addImageViewWithImage:image];
    NSIndexPath *index = [self.contentTableView indexPathForCell:item];
    if(index.row >= 0 && index.row < [self.galerieItems count]) {
        GalerieGroupViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"galerieGroup"];
        
        if(VALID(controller, GalerieGroupViewController)) {
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
                GalerieItem *localItem = [item.item MR_inContext:localContext];
                
                if(VALID(localItem, GalerieItem)) {
                    localItem.read = YES;
                }
            }];
            
            [self.contentTableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
           
            controller.galerieToDisplay = self.galerieItems;
            controller.startingIndex = @([controller.galerieToDisplay indexOfObjectPassingTest:^BOOL(GalerieItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return obj == item.item;
            }]);
            
            [self.navigationController pushViewController:controller animated:YES];
        }
    }

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
