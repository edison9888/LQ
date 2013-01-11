//
//  LQFirstPageViewController.m
//  qiyouxi
//
//  Created by Xie Zhe on 12-12-30.
//  Copyright (c) 2012年 LQ有限公司. All rights reserved.
//

#import "LQFirstPageViewController.h"
#import "LQHistoryTableViewCell.h"
#import "LQHistoryTableSectionHeader.h"
#import "LQGameDetailViewController.h"
#import "LQGameInfoListViewController.h"
#import "LQGameMoreItemTableViewCell.h"
#import "LQCategorySectionHeader.h"
#import "LQRecommendSectionHeader.h"
#import "LQAdTableViewCell.h"
#import "AudioListViewController.h"
#import "LQTopicCell.h"
#import "LQTablesController.h"

@interface LQFirstPageViewController ()
@property (nonatomic, strong) NSDictionary* announcement;
@property (nonatomic, strong) NSArray* advertisements;
@property (nonatomic, strong) NSMutableArray* histories;

//推荐应用
@property (nonatomic, strong) NSArray* recommendApps;
//推荐专题
@property (nonatomic, strong) NSArray* recommendTopics;
- (void)loadData;
@end

@implementation LQFirstPageViewController
@synthesize announcement;
@synthesize advertisements;
@synthesize recommendApps,recommendTopics;

@synthesize scrollView;
//@synthesize advView;
@synthesize histories;
@synthesize historyView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        // self.title = NSLocalizedString(@"First", @"First");
        // self.tabBarItem.image = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    selectedRow = -1;
    selectedSection = -1;
    currentRecommendIndex = 0;
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdateDownloadStatus:) name:kQYXDownloadStatusUpdateNotification object:nil];
    
    [self.historyView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kQYXDownloadStatusUpdateNotification object:nil];
}

- (void)onUpdateDownloadStatus:(NSNotification*)notification{
    [self performSelectorOnMainThread:@selector(updateDownloadStatus) withObject:nil waitUntilDone:NO];
}

- (void)updateDownloadStatus{
    [self.historyView reloadData];
}


#pragma mark - View Init
- (void)loadViews{
    [super loadViews];
    
    //self.advView.delegate = self;
    
    
}

#pragma mark - Data Init
- (void)loadRecommends{
    [self startLoading];
    //[self.client loadTodayRecommendation:[NSDate date]];
    [self.client loadRecommendation];

}

- (void)loadData{
    [super loadData];
    

 //   [self.client loadTodayAdvs];
    
    [self loadRecommends];
    
    self.histories = [NSMutableArray array];
    
    [self startLoading];
    //NSDate* today = [[NSDate date] dateByAddingTimeInterval:-3600*24];
    
//    [self.client loadHistory:today days:7];
    
}

//- (void)loadTodayGames:(NSArray*)games{
//    int index = 0;
//    for (NSDictionary * game in games){
//        LQRecommendButton* button = [sortedButtons objectAtIndex:index];
//        [button setTitle:[game objectForKey:@"name"] forState:UIControlStateNormal];
//        NSDictionary* images = [game objectForKey:@"pic"];
//        NSString* largeImage = [images objectForKey:@"big"];
//        NSString* smallImage = [images objectForKey:@"small"];
//        if (button == self.gameButton1 ||
//            button == self.gameButton5){
//            [button loadImageUrl:largeImage defaultImage:nil];
//        }else{
//            [button loadImageUrl:smallImage defaultImage:nil];
//        }
//        button.tag = [[game objectForKey:@"id"] intValue];
//        index++;
//    }
//}

- (void)loadTodayAdvs:(NSArray*)advs{
    self.advertisements = advs;
    
//    NSMutableArray* imageUrls = [NSMutableArray arrayWithCapacity:advs.count];
//    for (NSDictionary* adv in advs){
//        [imageUrls addObject:[adv objectForKey:@"adv_icon"]];
//    }
    
    //self.advView.imageUrls = imageUrls;
    //[self.historyView reloadData];

}

- (void)loadApps:(NSArray*) apps{
    NSMutableArray* items = [NSMutableArray array];

    for (NSDictionary* game in apps){
        [items addObject:[[LQGameInfo alloc] initWithAPIResult:game]];
    }
    self.recommendApps = items;
   // [self.historyView reloadData];

}

- (void) loadTopics:(NSArray*) topics{
    NSMutableArray* items = [NSMutableArray array];
    
    for (NSDictionary* game in topics){
        [items addObject:[[LQGameInfo alloc] initWithAPIResult:game]];
    }

    self.recommendTopics = items;
    //[self.historyView reloadData];

}

- (void)loadHistoryGames:(NSDictionary*)result{
    self.historyView.hidden = NO;
    
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyyMMdd"];
    
    NSMutableArray* items = nil;
    int currentDate = 0;
    
    for (NSDictionary* game in [result objectForKey:@"items"]){
        //int date = [[game objectForKey:@"idate"] intValue];
        int date = 20121231;
        if (date != currentDate){
            if (items != nil){
                [self.histories addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [format dateFromString:[NSString stringWithFormat:@"%.8d", currentDate]], @"date",
                                           items, @"items",
                                           nil]];
            }
            
            currentDate = date;
            items = [NSMutableArray array];
        }
        
        [items addObject:[[LQGameInfo alloc] initWithAPIResult:game]];
    }
    
    if (items != nil){
        [self.histories addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                   [format dateFromString:[NSString stringWithFormat:@"%.8d", currentDate]], @"date",
                                   items, @"items",
                                   nil]];
    }
    
    
    [self.historyView reloadData];
}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0)
        return 1;
    else{
        return currentRecommendIndex==0?recommendApps.count:recommendTopics.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    

    if(indexPath.section==0 && indexPath.row ==0){
        LQAdTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ad"];
        if(cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"LQAdTableViewCell" owner:self options:nil]objectAtIndex:0];
        }
        [cell setDelegate:self];
        
        if(advertisements.count>0){
            NSMutableArray* imageUrls = [NSMutableArray arrayWithCapacity:self.advertisements.count];
            for (NSDictionary* adv in self.advertisements){
                [imageUrls addObject:[adv objectForKey:@"image_url"]];
            }
            cell.advView.imageUrls = imageUrls;
        }
        return cell;
        
    }
    else if(currentRecommendIndex==0){
        LQHistoryTableViewCell* cell;
        if(indexPath.section == selectedSection &&
           indexPath.row == selectedRow){
            cell = [tableView dequeueReusableCellWithIdentifier:@"moreitem"];
            if (cell == nil){
                cell = [[[NSBundle mainBundle] loadNibNamed:@"LQGameMoreItemTableViewCell"  owner:self options:nil] objectAtIndex:0];
            }
        }
        else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"history"];
            if (cell == nil){
                cell = [[[NSBundle mainBundle] loadNibNamed:@"HistoryTableViewCell" owner:self options:nil] objectAtIndex:0];
            }
        }  
        cell.gameInfo = currentRecommendIndex==0?[recommendApps objectAtIndex:indexPath.row]:
        [recommendTopics objectAtIndex:indexPath.row];
       
        [cell addInfoButtonsTarget:self action:@selector(onGameDetail:) tag:0];
        return cell;
    }
    else{
        LQTopicCell* cell = [tableView dequeueReusableCellWithIdentifier:@"topic"];
        if (cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"LQTopicCell" owner:self options:nil] objectAtIndex:0];
        }
        cell.gameInfo = [recommendTopics objectAtIndex:indexPath.row];
        return cell;
    }
    
    
    
}

#pragma mark - TableView Data Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 44.0;
    }
    else if(section ==1) {
        return 34.0;
    }
    else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 0)
    {
        LQCategorySectionHeader *header = [[[NSBundle mainBundle] loadNibNamed:@"LQCategorySectionHeader" owner:self options:nil]objectAtIndex:0];
        
        [header addInfoButtonsTarget:self action:@selector(onLoadSoft:) tag:0];
        [header addInfoButtonsTarget:self action:@selector(onLoadGame:) tag:1];
        [header addInfoButtonsTarget:self action:@selector(onLoadRing:) tag:2];
        [header addInfoButtonsTarget:self action:@selector(onLoadWallpaper:) tag:3];
        
        return header;
        

    }
    else if(section == 1)
    {
        LQRecommendSectionHeader *header = [[[NSBundle mainBundle] loadNibNamed:@"LQRecommendSectionHeader" owner:self options:nil]objectAtIndex:0];
        [header addInfoButtonsTarget:self action:@selector(onSwitchRecommendSection:) tag:0];
        [header addInfoButtonsTarget:self action:@selector(onSwitchRecommendSection:) tag:1];
        [header setImageNames:@"home_tabbar_soft.png" leftSelected:@"home_tabbar_soft_down.png" rightNormal:@"home_tabbar_special.png" rightSelected:@"home_tabbar_special_down.png"];
        [header setButtonStatus:currentRecommendIndex];
        return header;
        
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(selectedRow!= indexPath.row
       && selectedSection!=indexPath.section){
        selectedRow = indexPath.row;
        selectedSection = indexPath.section;    
    }
    else {
        selectedRow = -1;
        selectedSection = -1;  
    }
    [self.historyView reloadData];

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}


#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
}
#pragma mark - Network Callback
- (void)client:(LQClientBase*)client didGetCommandResult:(id)result forCommand:(int)command format:(int)format tagObject:(id)tagObject{
    [super handleNetworkOK];
    switch (command) {
        case C_COMMAND_GETRECOMMENDATION:
            [self endLoading];
            if ([result isKindOfClass:[NSDictionary class]]){
               // [self loadTodayGames:result];
                [self loadTodayAdvs:[result objectForKey:@"nominates"]];
                [self loadApps:[result objectForKey:@"apps"]];
                [self loadTopics:[result objectForKey:@"zhuantis"]];
                [self.historyView reloadData];
            }
            break;
    
        case C_COMMAND_GETTODAYADVS:
            if ([result isKindOfClass:[NSArray class]]){
                [self loadTodayAdvs:result];
            }
            break;
        case C_COMMAND_GETHISTORY:
            [self endLoading];
            if ([result isKindOfClass:[NSDictionary class]]){
                [self loadHistoryGames:result];
            }
            break;
        default:
            break;
    }
}

- (void)handleNetworkError:(LQClientError*)error{
//    switch (error.command) {
//        case C_COMMAND_GETRECOMMENDATION:
//            [self endLoading];
//            if (self.advertisements.count > 0){
//                [super handleNetworkErrorHint];
//            }else{
//                [super handleNetworkError:error];
//            }
//            break;
//        case C_COMMAND_GETTODAYADVS:
//        case C_COMMAND_GETANNOUNCEMENT:
//        default:
//            break;
//    }
    [self endLoading];
    if (self.histories.count > 0){
        [super handleNetworkErrorHint];
    }else{
        [super handleNetworkError:error];
    }
}

#pragma mark - Actions

- (void)onLoadSoft:(id)sender{
    LQTablesController* controller  = [[LQTablesController alloc] initWithNibName:@"LQTablesController" bundle:nil  ];
    controller.nodeId = @"rj";
    controller.categoryId = @"show_software_cat";
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)onLoadGame:(id)sender{
    LQTablesController * controller  = [[LQTablesController alloc] initWithNibName:@"LQTablesController" bundle:nil ];
    controller.nodeId = @"yx";
    controller.categoryId = @"show_game_cat";

    [self.navigationController pushViewController:controller animated:YES];
}

- (void)onLoadRing:(id)sender{
    AudioListViewController * controller  = [[AudioListViewController alloc] init ];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)onLoadWallpaper:(id)sender{
//    LQGameInfoListViewController* controller  = [[LQGameInfoListViewController alloc] init ];
//    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)onReload:(id)sender{
    LQGameInfoListViewController* controller  = [[LQGameInfoListViewController alloc] init ];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) onGameDetail:(id)sender{
    UIButton *button = sender;
    int tag = button.tag;
    LQGameDetailViewController *controller = [[LQGameDetailViewController alloc] init];
    controller.gameId = tag;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)onSwitchRecommendSection:(id)sender{
    UIButton* button = sender;
    int tag = button.tag;
    if(tag == currentRecommendIndex)
        return;
    else {
        currentRecommendIndex = tag;
        [self.historyView reloadData];
    }
    
}
@end
