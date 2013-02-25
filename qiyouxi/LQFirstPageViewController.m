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
#import "LQGameInfoListViewController.h"
#import "LQGameMoreItemTableViewCell.h"
#import "LQCategorySectionHeader.h"
#import "LQRecommendSectionHeader.h"
#import "LQAdTableViewCell.h"
#import "AudioListViewController.h"
#import "LQTopicCell.h"
#import "LQTablesController.h"
#import "LQDownloadManager.h"
#import "LQTopicListViewController.h"
#import "SVPullToRefresh.h" 
#import "LQRingTablesController.h"
#import "LQDetailTablesController.h"
@interface LQFirstPageViewController ()
@property (nonatomic, strong) NSDictionary* announcement;
@property (nonatomic, strong) NSArray* advertisements;
@property (nonatomic, strong) NSMutableArray* histories;

//推荐应用
@property (nonatomic, strong) NSArray* recommendApps;
//推荐专题
@property (nonatomic, strong) NSMutableArray* recommendTopics;

@property (nonatomic,strong) NSString* moreUrl;
- (void)loadData;
- (void)loadMoreData;
@end

@implementation LQFirstPageViewController
@synthesize announcement;
@synthesize advertisements;
@synthesize recommendApps,recommendTopics;

//@synthesize scrollView;
//@synthesize advView;
@synthesize histories;
@synthesize historyView;
@synthesize moreUrl;

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
    currentRecommendIndex = 1;
    
    
    __unsafe_unretained LQFirstPageViewController* weakSelf = self;
    // setup pull-to-refresh
    [self.historyView addPullToRefreshWithActionHandler:^{
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [weakSelf loadData];
        });
    }];
    
    [self.historyView addInfiniteScrollingWithActionHandler:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [weakSelf loadMoreData];
        });
    }];

    if(recommendTopics==nil)
        recommendTopics = [NSMutableArray array];
    
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
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdateDownloadStatus:) name:kQYXDownloadStatusUpdateNotification object:nil];
    
    [self.historyView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kQYXDownloadStatusUpdateNotification object:nil];
}

//- (void)onUpdateDownloadStatus:(NSNotification*)notification{
//    [self performSelectorOnMainThread:@selector(updateDownloadStatus) withObject:nil waitUntilDone:NO];
//}
//
//- (void)updateDownloadStatus{
//    [self.historyView reloadData];
//}


#pragma mark - View Init
- (void)loadViews{
    [super loadViews];
    
}

#pragma mark - Data Init
- (void)loadRecommends{
    [self startLoading];
    [self.client loadRecommendation];

}

- (void)loadData{
    [super loadData];
        
    [self loadRecommends];
    
    self.histories = [NSMutableArray array];
    
    [self startLoading];
    
}

- (void)loadMoreData{
    if(self.moreUrl != nil){
        [self.client loadAppMoreListCommon:self.moreUrl];
    }
    else {
        [self.historyView.infiniteScrollingView stopAnimating];
        return;
    }
    
    
}
- (void)loadTodayAdvs:(NSArray*)advs{
    self.advertisements = advs;
}

- (void)loadApps:(NSArray*) apps{
    NSMutableArray* items = [NSMutableArray array];

    for (NSDictionary* game in apps){
        [items addObject:[[LQGameInfo alloc] initWithAPIResult:game]];
    }
    self.recommendApps = items;

}

- (void) loadTopics:(NSArray*) topics{
    NSMutableArray* items = [NSMutableArray array];
    
    for (NSDictionary* game in topics){
        [items addObject:[[LQGameInfo alloc] initWithAPIResult:game]];
    }
    [self.recommendTopics removeAllObjects];
    [self.recommendTopics addObjectsFromArray:items];
    
    [self.historyView.pullToRefreshView stopAnimating];

}

- (void) loadMoreTopics:(NSArray*) topics{
    NSMutableArray* items = [NSMutableArray array];
    
    for (NSDictionary* game in topics){
        [items addObject:[[LQGameInfo alloc] initWithAPIResult:game]];
    }
    
    int oldAppsCount = recommendTopics.count;
    int addAppsCount = topics.count;
    [self.recommendTopics addObjectsFromArray:items];
   
    __unsafe_unretained LQFirstPageViewController* weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        NSMutableArray *indexPaths = [NSMutableArray array];
        for(int i=oldAppsCount;i<(oldAppsCount+addAppsCount);i++)
        {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:1]];
        }
        if(indexPaths.count>0){
            //[weakSelf.historyView beginUpdates];
            
            [weakSelf.historyView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
            //[weakSelf.historyView endUpdates];
        }
        [weakSelf.historyView.infiniteScrollingView stopAnimating];
    });
    
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
            [cell setDelegate:self];
            
            if(advertisements.count>0){
                NSMutableArray* imageUrls = [NSMutableArray arrayWithCapacity:self.advertisements.count];
                for (NSDictionary* adv in self.advertisements){
                    [imageUrls addObject:[adv objectForKey:@"image_url"]];
                }
                cell.advView.imageUrls = imageUrls;
            }
        }
        
        return cell;
        
    }
    else if(currentRecommendIndex==0){
        if(indexPath.section == selectedSection &&
           indexPath.row == selectedRow){
            LQGameMoreItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"moreitem"];
            if (cell == nil){
                cell = [[[NSBundle mainBundle] loadNibNamed:@"LQGameMoreItemTableViewCell"  owner:self options:nil] objectAtIndex:0];
            }
            cell.gameInfo = [recommendApps objectAtIndex:indexPath.row];
            [cell addInfoButtonsTarget:self action:@selector(onGameDetail:) tag:indexPath.row];
            [cell addLeftButtonTarget:self action:@selector(onGameDownload:) tag:indexPath.row];
            [cell addMiddleButtonTarget:self action:@selector(onGameDownload:) tag:indexPath.row];
            [cell addRightButtonTarget:self action:@selector(onGameDetail:) tag:indexPath.row];
            return cell;
        }
        else{
            LQHistoryTableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:@"history"];
            if (cell == nil){
                cell = [[[NSBundle mainBundle] loadNibNamed:@"HistoryTableViewCell" owner:self options:nil] objectAtIndex:0];
            }
            cell.gameInfo = [recommendApps objectAtIndex:indexPath.row];
            [cell addInfoButtonsTarget:self action:@selector(onGameDetail:) tag:indexPath.row];
            return cell;
        }  
    }
    else{
        LQTopicCell* cell = [tableView dequeueReusableCellWithIdentifier:@"topic"];
        if (cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"LQTopicCell" owner:self options:nil] objectAtIndex:0];
        }
        cell.gameInfo = [recommendTopics objectAtIndex:indexPath.row];
        [cell addInfoButtonsTarget:self action:@selector(onTopicList:) tag:indexPath.row];
        return cell;
    }
  
}

#pragma mark - TableView Data Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 0;
    }
    else if(section ==1) {
        return 50.0;
    }
    else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section == 1)
    {
        LQCategorySectionHeader *header = [[[NSBundle mainBundle] loadNibNamed:@"LQCategorySectionHeader" owner:self options:nil]objectAtIndex:0];
        
        [header addInfoButtonsTarget:self action:@selector(onLoadSoft:) tag:0];
        [header addInfoButtonsTarget:self action:@selector(onLoadGame:) tag:1];
        [header addInfoButtonsTarget:self action:@selector(onLoadRing:) tag:2];
        [header addInfoButtonsTarget:self action:@selector(onLoadWallpaper:) tag:3];
        
        return header;
        

    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section!=1) {
        return;
    }
     if(currentRecommendIndex==0) {
         if(selectedRow!= indexPath.row){
             selectedRow = indexPath.row;
             selectedSection = indexPath.section;    
         }
         else {
             selectedRow = -1;
             selectedSection = -1;  
         }
         [self.historyView reloadData];
    }
     else {
         int tag = indexPath.row;
         if(tag < recommendTopics.count){
             LQGameInfo* info = [recommendTopics objectAtIndex:tag];
             LQTopicListViewController * controller  = [[LQTopicListViewController alloc] initWithNibName:@"LQTablesController" bundle:nil ];
             controller.requestUrl = info.requestUrl;
             controller.iconUrl = info.icon;
             [self.navigationController pushViewController:controller animated:YES];
             
             
         }

     }
    

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}


#pragma mark - Network Callback
- (void)client:(LQClientBase*)client didGetCommandResult:(id)result forCommand:(int)command format:(int)format tagObject:(id)tagObject{
    [super handleNetworkOK];
    switch (command) {
        case C_COMMAND_GETRECOMMENDATION:
            [self endLoading];
            if ([result isKindOfClass:[NSDictionary class]]){
               // [self loadTodayGames:result];
                self.moreUrl = [result objectForKey:@"more_url"];
                [self loadTodayAdvs:[result objectForKey:@"nominates"]];
                [self loadApps:[result objectForKey:@"apps"]];
                [self loadTopics:[result objectForKey:@"zhuantis"]];
                [self.historyView reloadData];
            }
            break;
        case C_COMMAND_GETAPPLISTSOFTGAME_MORE:
            if ([result isKindOfClass:[NSDictionary class]]){
                self.moreUrl = [result objectForKey:@"more_url"];
                [self loadMoreTopics:[result objectForKey:@"zhuantis"]];
            }

            break;
        default:
            break;
    }
}

- (void)handleNetworkError:(LQClientError*)error{
    [self endLoading];
    if (self.histories.count > 0){
        [super handleNetworkErrorHint];
    }else{
        [super handleNetworkError:error];
    }
    
    [self.historyView.pullToRefreshView stopAnimating];
    [self.historyView.infiniteScrollingView stopAnimating];
}

#pragma mark - Actions

- (void)onLoadSoft:(id)sender{
    LQTablesController* controller  = [[LQTablesController alloc] initWithNibName:@"LQTablesController" bundle:nil  ];
    controller.listOperator=@"app_list";
    controller.nodeId = @"rj";
    controller.categoryId = @"show_software_cat";
    controller.titleString= @"软件";
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)onLoadGame:(id)sender{
    LQTablesController * controller  = [[LQTablesController alloc] initWithNibName:@"LQTablesController" bundle:nil ];
    controller.listOperator=@"app_list";
    controller.nodeId = @"yx";
    controller.categoryId = @"show_game_cat";
    controller.titleString= @"游戏";
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)onLoadRing:(id)sender{
//    AudioListViewController * controller  = [[AudioListViewController alloc] init ];
//    [self.navigationController pushViewController:controller animated:YES];
    
    LQRingTablesController * controller  = [[LQRingTablesController alloc] initWithNibName:@"LQTablesController" bundle:nil ];
    controller.listOperator=@"ls_list";
    controller.nodeId = @"ls";
    controller.categoryId = @"show_ls_cat";
    controller.titleString= @"铃声";
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)onLoadWallpaper:(id)sender{
    LQTablesController * controller  = [[LQTablesController alloc] initWithNibName:@"LQTablesController" bundle:nil ];
    controller.listOperator=@"wallpaper_list";
    controller.nodeId = @"bz";
    controller.categoryId = @"show_wallpaper_cat";
    controller.titleString= @"壁纸";
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)onReload:(id)sender{
    LQGameInfoListViewController* controller  = [[LQGameInfoListViewController alloc] init ];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) onGameDetail:(id)sender{
    UIButton *button = sender;
    int row = button.tag;
    LQGameInfo* gameInfo = [recommendApps objectAtIndex:row];
    LQDetailTablesController *controller = [[LQDetailTablesController alloc] initWithNibName:@"LQTablesController" bundle:nil];
    controller.gameId = gameInfo.gameId;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) onGameDownload:(id)sender{
    UIButton* button = (UIButton*)sender;
    int row = button.tag;
    LQGameInfo* gameInfo = [recommendApps objectAtIndex:row];
    [[LQDownloadManager sharedInstance] commonAction:gameInfo installAfterDownloaded:NO];
//    int gameId = info.gameId;
//    QYXDownloadStatus status = [[LQDownloadManager sharedInstance] getStatusById:gameId];
//    
//    switch (status) {
//        case kQYXDSFailed:
//            [[LQDownloadManager sharedInstance] resumeDownloadById:gameId];
//            break;
////        case kQYXDSCompleted:
////        case kQYXDSInstalling:
////            [[LQDownloadManager sharedInstance] installGameBy:self.gameInfo.gameId];
////            break;
////        case kQYXDSPaused:
////            [[LQDownloadManager sharedInstance] resumeDownloadById:self.gameInfo.gameId];
////            break;
////        case kQYXDSRunning:
////            [[LQDownloadManager sharedInstance] pauseDownloadById:self.gameInfo.gameId];
////            break;
//        case kQYXDSNotFound:
//            if(info!=nil)
//            [[LQDownloadManager sharedInstance] addToDownloadQueue:info installAfterDownloaded:NO];
//            
//            break;
////        case kQYXDSInstalled:
////            [[LQDownloadManager sharedInstance] startGame:self.gameInfo.package];
////            break;
//        default:
//            break;
//    }

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

- (void)onTopicList:(id)sender{
    UIButton* button = sender;
    int tag = button.tag;
    if(tag < recommendTopics.count){
        LQGameInfo* info = [recommendTopics objectAtIndex:tag];
        LQTopicListViewController * controller  = [[LQTopicListViewController alloc] initWithNibName:@"LQTablesController" bundle:nil ];
        controller.requestUrl = info.requestUrl;
        controller.iconUrl = info.icon;
        [self.navigationController pushViewController:controller animated:YES];
        
        
    }
}
- (void)QYXAdvertiseView:(LQAdvertiseView*)advertiseView selectPage:(int)page{
    
    if(advertisements.count>page){
        NSDictionary* adv = [advertisements objectAtIndex:page];
        int gameId = [[adv objectForKey:@"id"] intValue];
        LQDetailTablesController *controller = [[LQDetailTablesController alloc] initWithNibName:@"LQTablesController" bundle:nil];
        controller.gameId = gameId;
        [self.navigationController pushViewController:controller animated:YES];

           
    }
    
        
}
@end
