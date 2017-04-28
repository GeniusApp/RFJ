//
//  CatTableViewController.m
//  rfj
//
//  Created by Gonçalo Girão on 27/04/2017.
//  Copyright © 2017 Genius App Sarl. All rights reserved.
//

#import "CatTableViewController.h"
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

@interface CatTableViewController ()

@property (strong, nonatomic) NSArray<NewsItem *> *newsItems;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSArray<NewsItem *> *> *sortedNewsItems;
@property (strong, nonatomic) NSArray<MenuItem *> *allMenuItems;


@property (assign, nonatomic) NSInteger currentPage;
@property (assign, nonatomic) BOOL isLoading;

@property (strong, nonatomic) DFPInterstitial *interstitial;
@property (strong, nonatomic) DFPBannerView  *bannerView;
@property (strong, nonatomic)  UIView *coverView;

@end

@implementation CatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshTable)
                  forControlEvents:UIControlEventValueChanged];
    
    self.allMenuItems = [MenuItem sortedMenuItems];
    self.newsItems = [NewsItem MR_findAll];
    
    [[ResourcesManager singleton] fetchResourcesWithSuccessBlock:nil andFailureBlock:nil];
    
    [self sortNewsItems];

    
    [self.tableView registerNib:[UINib nibWithNibName:@"NewsItemTableViewCell" bundle:nil] forCellReuseIdentifier:@"newsItemCell"];

    
    [self loadNextPage];
    [self loadInterstitial];
    
    
//    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(NewsItemDidTap:)];
//    gestureRecognizer.numberOfTapsRequired = 1;
//    [gestureRecognizer setCancelsTouchesInView:NO];
//
//    [self.tableView setUserInteractionEnabled:YES];
//    [self.tableView addGestureRecognizer:gestureRecognizer];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
        [self loadInterstitial];

}

- (void)refreshTable {
    //TODO: refresh your data
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
    
}

-(NSArray<NewsItem *> *)combinedNewsItems
{
    NSMutableArray<NewsItem *> *items = [[NSMutableArray<NewsItem *> alloc] init];
    
    for(NSNumber *navigationID in [self.sortedNewsItems allKeys]) {
        [items addObjectsFromArray:[self.sortedNewsItems objectForKey:navigationID]];
    }
    
    return items;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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



-(void)loadInterstitial {
    //self.needsToLoadInterstitial = NO;
    
    NSDictionary *BackendURLs = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BackendURLs" ofType:@"plist"]];
    self.interstitial = [[DFPInterstitial alloc] initWithAdUnitID:[BackendURLs objectForKey:@"DFPInterstitialLoadingLink"]];
   // self.interstitial.delegate = self;
    
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
    
    
    
    self.currentPage++;
    
    [self loadPageItemsForPage:self.currentPage count:kItemsPerPage success:^(NSArray<NewsItem *> *items) {
        
        for(NewsItem *item in items) {
            NSInteger itemIndex = [self.newsItems indexOfObjectPassingTest:^BOOL(NewsItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return item.id == obj.id;
            }];
            
            if(itemIndex == NSNotFound) {
                self.newsItems = [self.newsItems arrayByAddingObject:item];
            }
        }
        
        [self sortNewsItems];
        
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        //[self hideLoading];
        

    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return [self.sortedNewsItems count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    NSNumber *navigationID = [[self.sortedNewsItems allKeys] objectAtIndex:section];
    return [[self.sortedNewsItems objectForKey:navigationID] count];
    //return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    NewsItemTableViewCell *actualCell = (NewsItemTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"newsItemCell"];
    
    if(!VALID(actualCell, NewsItemTableViewCell)) {
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"NewsItemTableViewCell" owner:self options:nil];
        
        if(VALID_NOTEMPTY(views, NSArray)) {
            actualCell = [views objectAtIndex:0];
        }
    }
    
    if(VALID(actualCell, NewsItemTableViewCell)) {
        cell = actualCell;
        //actualCell.delegate = self;
        
        NSNumber *navigationID = [[self.sortedNewsItems allKeys] objectAtIndex:indexPath.section];
        NSArray<NewsItem *> *items = [self.sortedNewsItems objectForKey:navigationID];
        
        if(indexPath.row >= 0 && indexPath.row < [items count]) {
            NewsItem *item = [items objectAtIndex:indexPath.row];
            actualCell.item = item;
            
        }
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return ceilf([UIScreen mainScreen].bounds.size.width * 0.6372340425531915);
    
    return 44.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(tableView == self.tableView) {
        return kContentCategorySeparatorHeight;
    }
    return 0;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"DID SELECT ROW AT INDEXPATH: %ld", (long)indexPath.row);
    
    NewsGroupViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"newsGroup"];
    
    //    NSIndexPath *index = [self.tableView indexPathForCell:item];
    //
    //    if(index.row >= 0 && index.row < [self.newsItems count]) {
    //        NewsGroupViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"newsGroup"];
    //
    //        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //        [defaults setInteger:index.row forKey:@"RecordIndex"];
    //        [defaults synchronize];
    //        if(VALID(controller, NewsGroupViewController)) {
    //            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
    //                NewsItem *localItem = [item.item MR_inContext:localContext];
    //
    //                if(VALID(localItem, NewsItem)) {
    //                    localItem.read = YES;
    //                }
    //            }];
    //
    //            [self.tableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
    //
    //            controller.newsToDisplay = [self combinedNewsItems];
    //            controller.startingIndex = @([controller.newsToDisplay indexOfObjectPassingTest:^BOOL(NewsItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    //                return obj == item.item;
    //            }]);
    //
    //            [self.navigationController pushViewController:controller animated:YES];
    //        }
    //    }
}

//-(void)NewsItemDidTap:(NewsItemTableViewCell *)item {
//    NSLog(@"News ITEM TAPPED");
//    NSIndexPath *index = [self.tableView indexPathForCell:item];
//
//    if(index.row >= 0 && index.row < [self.newsItems count]) {
//        NewsGroupViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"newsGroup"];
//        
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        [defaults setInteger:index.row forKey:@"RecordIndex"];
//        [defaults synchronize];
//        if(VALID(controller, NewsGroupViewController)) {
//            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
//                NewsItem *localItem = [item.item MR_inContext:localContext];
//                
//                if(VALID(localItem, NewsItem)) {
//                    localItem.read = YES;
//                }
//            }];
//            
//            [self.tableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
//            
//            controller.newsToDisplay = [self combinedNewsItems];
//            controller.startingIndex = @([controller.newsToDisplay indexOfObjectPassingTest:^BOOL(NewsItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                return obj == item.item;
//            }]);
//            
//            [self.navigationController pushViewController:controller animated:YES];
//        }
//    }
//}
@end
