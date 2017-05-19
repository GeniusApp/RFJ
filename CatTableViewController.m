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

@interface CatTableViewController ()<NewsItemTableViewCellDelegate>

@property (strong, nonatomic) NSArray<NewsItem *> *newsItems;
@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSArray<NewsItem *> *> *sortedNewsItems;
@property (strong, nonatomic) NSMutableArray<NSDictionary<NSArray<NSNumber *>*, NSArray<NewsItem *> *> *>*sortedNewsItems2;
@property (weak, nonatomic) IBOutlet UIView *loadingView;

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
    [self sortNewsItems2];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"NewsItemTableViewCell" bundle:nil] forCellReuseIdentifier:@"newsItemCell"];
    self.currentPage = 0;
    self.isLoading = NO;
    [self loadNextPage];
    
    
    
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

}

- (void)refreshTable {
    //TODO: refresh your data
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
    
}

-(NSArray<NewsItem *> *)combinedNewsItems
{
    NSMutableArray<NewsItem *> *items = [[NSMutableArray<NewsItem *> alloc] init];
    
    for(NSDictionary<NSArray<NSNumber *> *, NSArray<NewsItem *> *> *content in self.sortedNewsItems2) {
        [items addObjectsFromArray:[content objectForKey:[[content allKeys] objectAtIndex:0]]];
    }
    
    /*
     for(NSNumber *navigationID in [self.sortedNewsItems allKeys]) {
     [items addObjectsFromArray:[self.sortedNewsItems objectForKey:navigationID]];
     }
     */
    
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

-(void)sortNewsItems2 {
    self.sortedNewsItems2 = [[NSMutableArray<NSDictionary<NSArray<NSNumber *>*, NSArray<NewsItem *> *> *> alloc] init];
    NSArray<NSArray<NSNumber *> *> *searchNumbers =
    @[
      @[@(9611), @(9618)],
      @[@(9612)],
      @[@(9613)],
      @[@(9614)],
      @[@(9615)],
      ];
    
    for(NSArray<NSNumber *> *searchItem in searchNumbers)
    {
        NSMutableArray<NewsItem *> *items = [[NSMutableArray<NewsItem *> alloc] init];
        
        for(NewsItem *item in self.newsItems) {
            BOOL valid = NO;
            
            for(NSNumber *navigationId in searchItem)
            {
                if([navigationId intValue] == item.navigationId)
                {
                    valid = YES;
                    
                    break;
                }
            }
            
            if(!valid)
            {
                continue;
            }
            
            [items addObject:item];
        }
        
        [self.sortedNewsItems2 addObject:
         @{
           searchItem: items
           }];
    }
    //NSLog(@"QUALWUER COISA: %@", self.sortedNewsItems2);
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

-(void)showLoading {
    [self.loadingView setHidden:NO];
}

-(void)hideLoading {
    [self.loadingView setHidden:YES];
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
        
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self hideLoading];
        
        //NSLog(@"Error: %@", error);
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return [self.sortedNewsItems2 count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return [[self.sortedNewsItems objectForKey:navigationID] count];
    if (section == 0) {
        return 3;
    } else {
        return section == 1 ? 7 : 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int rowNumber = indexPath;
    BOOL isMultipleOfSeven = !(rowNumber % 7);
    if (isMultipleOfSeven == TRUE) {
        
    }
    
    if (rowNumber % 7 == 0 && rowNumber != 0) {
        static NSString *CellIdentifier = @"Cell";
        // Reuse and create cell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.text = @"Test Data";
        return cell;
    } else {
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
            actualCell.delegate = self;
            if(indexPath.section == 0) {
                //TODO
                return actualCell;
            }
            else {
                NSDictionary<NSArray<NSNumber *> *, NSArray<NewsItem *> *> *content = [self.sortedNewsItems2 objectAtIndex:indexPath.section - 1];
                NSArray<NewsItem *> *items = [content objectForKey:[[content allKeys] objectAtIndex:0]];
                
                if(VALID_NOTEMPTY(items, NSArray<NewsItem *>)) {
                    //NSLog(@"ITEMS: %@", self.sortedNewsItems);
                    if(indexPath.row >= 0 && indexPath.row < [items count]) {
                        NewsItem *item = [items objectAtIndex:indexPath.row];
                        //NSLog(@"INDEXPATH: %@", items);
                        actualCell.item = item;
                    }
                }
            }
        }
        
        return cell;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return ceilf([UIScreen mainScreen].bounds.size.width * 0.6372340425531915);
    
    return 44.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section > 0) {
        return kContentCategorySeparatorHeight;
    }
    return 0;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //NSNumber *navigationID = [[self.sortedNewsItems allKeys] objectAtIndex:section];
    
    if(section == 0) {
        return nil;
    }
    
    NewsCategorySeparatorView *headerView = nil;
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"NewsCategorySeparatorView" owner:self options:nil];
    
    if(VALID_NOTEMPTY(views, NSArray))
    {
        headerView = [views objectAtIndex:0];
    }
    
    if(VALID(headerView, NewsCategorySeparatorView)) {
        /*
         NSInteger categoryIndex = [self.allMenuItems indexOfObjectPassingTest:^BOOL(MenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         return obj.id == [navigationID intValue];
         }];
         
         if(categoryIndex != NSNotFound) {
         [headerView setName:[self.allMenuItems objectAtIndex:categoryIndex].name];
         }
         */
        
        NSDictionary<NSArray<NSNumber *> *, NSArray<NewsItem *> *> *content = [self.sortedNewsItems2 objectAtIndex:section - 1];
        NSArray<NSNumber *> *navigationIds = [[content allKeys] objectAtIndex:0];
        
        if(VALID_NOTEMPTY(navigationIds, NSArray<NSNumber *>)) {
            NSString *nameString = @"";
            
            NSInteger categoryIndex = [self.allMenuItems indexOfObjectPassingTest:^BOOL(MenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return obj.id == [[navigationIds objectAtIndex:0] intValue];
            }];
            
            if(categoryIndex != NSNotFound) {
                nameString = [self.allMenuItems objectAtIndex:categoryIndex].name;
            }
            
            for(NSInteger i = 1; i < [navigationIds count]; i++) {
                categoryIndex = [self.allMenuItems indexOfObjectPassingTest:^BOOL(MenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    return obj.id == [[navigationIds objectAtIndex:i] intValue];
                }];
                
                if(categoryIndex != NSNotFound) {
                    nameString = [NSString stringWithFormat:@"%@ & %@", nameString, [self.allMenuItems objectAtIndex:categoryIndex].name];
                }
            }
            
            [headerView setName:nameString];
        }
    }
    
    return headerView;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    UITableViewCell *cell = nil;
//    NewsItemTableViewCell *actualCell = (NewsItemTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"newsItemCell"];
//    cell = actualCell;
//    
//    NSNumber *navigationID = [[self.sortedNewsItems allKeys] objectAtIndex:indexPath.section];
//    NSArray<NewsItem *> *items = [self.sortedNewsItems objectForKey:navigationID];
//    
//    if(indexPath.row >= 0 && indexPath.row < [items count]) {
//        NewsItem *item = [items objectAtIndex:indexPath.row];
//        actualCell.item = item;
//        
//        NewsGroupViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"newsGroup"];
//        if(VALID(controller, NewsGroupViewController)) {
//            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
//                NewsItem *localItem = [item MR_inContext:localContext];
//                
//                if(VALID(localItem, NewsItem)) {
//                    localItem.read = YES;
//                }
//            }];
//            
//            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//            
//            controller.newsToDisplay = [self combinedNewsItems];
//            controller.startingIndex = @([controller.newsToDisplay indexOfObjectPassingTest:^BOOL(NewsItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                return obj == item;
//            }]);
//            
//            [self.navigationController pushViewController:controller animated:YES];
//        }
//    }
//}

#pragma mark - UIScrollView Delegate

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(scrollView == self.tableView) {
        if(scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height && !self.isLoading) {
            //We probably don't want this
            //[self loadNextPage];
        }
    }
}

-(void)NewsItemDidTap:(NewsItemTableViewCell *)item {
    NSLog(@"DID SELECT ROW AT INDEXPATH: %ld", (long)item);
    NSIndexPath *index = [self.tableView indexPathForCell:item];

    if(index.row >= 0 && index.row < [self.newsItems count]) {
        NewsGroupViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"newsGroup"];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:index.row forKey:@"RecordIndex"];
        [defaults synchronize];
        if(VALID(controller, NewsGroupViewController)) {
            [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext * _Nonnull localContext) {
                NewsItem *localItem = [item.item MR_inContext:localContext];
                
                if(VALID(localItem, NewsItem)) {
                    localItem.read = YES;
                }
            }];
            
            [self.tableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
            
            controller.newsToDisplay = [self combinedNewsItems];
            controller.startingIndex = @([controller.newsToDisplay indexOfObjectPassingTest:^BOOL(NewsItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                return obj == item.item;
            }]);
            
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}
@end
