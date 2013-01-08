//
//  LQSearchViewController.m
//  qiyouxi
//
//  Created by Xie Zhe on 12-12-30.
//  Copyright (c) 2012年 LQ有限公司. All rights reserved.
//

#import "LQSearchViewController.h"
#import "LQSearchSectionHeader.h"
#import "SearchHistoryItem.h"
#import "LQSearchHistoryCell.h"
@interface LQSearchViewController ()

@end

@implementation LQSearchViewController

@synthesize searchBar;
@synthesize searchTable;
@synthesize searchBarController;
@synthesize scrollView;
@synthesize searchHistoryView;
@synthesize searchHistoryTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        currentRecommendIndex = 0;
        searchHistoryItems = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // a page is the width of the scroll view
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 2, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = YES;
    
    CGRect frame = scrollView.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    searchTable.frame = frame;
    [scrollView addSubview:searchHistoryView];

    frame = scrollView.frame;
    frame.origin.x = frame.size.width;
    frame.origin.y = 0;
    searchTable.frame = frame;
    [scrollView addSubview:searchTable];

    

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - searchBar delegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchbar;
{
	//键盘消失
	[searchbar resignFirstResponder];
    NSString* searchText = [searchbar text];
    if(searchText.length==0)
        return;
    
    SearchHistoryItem* item = 
    [SearchHistoryItem searchHistoryItemWithType:@"soft"
                                            name:[searchbar text]];
    [searchHistoryItems addObject:item];
    
    [searchHistoryTable reloadData];
    
}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //if(section == 0)
    if(tableView == searchHistoryTable)
        return searchHistoryItems.count;
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView==searchHistoryTable){
        
        LQSearchHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"search"];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"LQSearchHistoryCell" owner:self options:nil]objectAtIndex:0];
        }
        
        SearchHistoryItem* item = [searchHistoryItems objectAtIndex:indexPath.row];
        [cell.type setText:item.type];
        [cell.name setText:item.name];
        [cell addInfoButtonsTarget:self action:@selector(onDeleteSearchItem:) tag:indexPath.row];
        return cell;
    }
    return nil;
}
#pragma mark - TableView Data Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(tableView==searchHistoryTable && section == 0){
        return 45.0;
    }
    else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
     if(tableView==searchHistoryTable && section == 0)
    {
        LQSearchSectionHeader *header = [[[NSBundle mainBundle] loadNibNamed:@"LQSearchSectionHeader" owner:self options:nil]objectAtIndex:0];
        [header addInfoButtonsTarget:self action:@selector(onSwitchRecommendSection:) tag:0];
        [header addInfoButtonsTarget:self action:@selector(onSwitchRecommendSection:) tag:1];
        [header setImageNames:nil
                 leftSelected:@"search_history_bt.png"
                  rightNormal:nil 
                rightSelected:@"search_hotword_bt.png"];
        [header setButtonStatus:currentRecommendIndex];
        return header;
        
    }
    return nil;
}

#pragma recommendSetion callback
- (void)onSwitchRecommendSection:(id)sender{
    UIButton* button = sender;
    int tag = button.tag;
    if(tag == currentRecommendIndex)
        return;
    else {
        currentRecommendIndex = tag;
        [self.searchHistoryTable reloadData];
    }

}

- (void)onDeleteSearchItem:(id)sender{
    UIButton* button = sender;
    int tag = button.tag;
    if(tag>=0 && tag< searchHistoryItems.count){
        [searchHistoryItems removeObjectAtIndex:tag];
        [self.searchHistoryTable reloadData];
    }

}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
//    [self filterContentForSearchText:searchString scope:
//     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
//    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
//    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
//     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOptions]];
//    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

@end
