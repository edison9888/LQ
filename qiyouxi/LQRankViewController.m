//
//  LQRankViewController.m
//  qiyouxi
//
//  Created by Xie Zhe on 13-1-11.
//  Copyright (c) 2013年 科技有限公司. All rights reserved.
//

#import "LQRankViewController.h"
#import "LQRankSectionHeader.h"
#import "LQWallpaperCell.h"
#import "AudioCell.h"
#import "AudioPlayer.h"
#import "AudioMoreItemCell.h"
@interface LQRankViewController ()

@end

@implementation LQRankViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - View Init
- (void)loadViews{
    [super loadViews];
}

#pragma mark - Data Init

- (void)loadData{
    [super loadData];
    
    if(self.orderBy == nil || self.nodeId == nil){
        [self endLoading];
        return;
    }
    //[self startLoading];    
    [self.client loadAppListCommon:self.listOperator nodeid:self.nodeId orderby:self.orderBy];
}

#pragma mark - Network Callback
- (void)client:(LQClientBase*)client didGetCommandResult:(id)result forCommand:(int)command format:(int)format tagObject:(id)tagObject{
    [self handleNetworkOK];
    switch (command) {
        case C_COMMAND_GETAPPLISTSOFTGAME:
            [self endLoading];
            if ([result isKindOfClass:[NSDictionary class]]){
                // [self loadTodayGames:result];
                [self loadApps:[result objectForKey:@"apps"]];
            }
            break;
            
        default:
            break;
    }
}
#pragma mark - TableView Data Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    LQRankSectionHeader *header = [[[NSBundle mainBundle] loadNibNamed:@"LQRankSectionHeader" owner:self options:nil]objectAtIndex:0];
    
    [header addInfoButtonsTarget:self action:@selector(onChangeRank:) tag:0];
    [header addInfoButtonsTarget:self action:@selector(onChangeRank:) tag:1];
    [header addInfoButtonsTarget:self action:@selector(onChangeRank:) tag:2];
   
    int selectedIndex = 0;
    if(self.orderBy == ORDER_BY_WEEK)
        selectedIndex = 0;
    else if (self.orderBy == ORDER_BY_MONTH)
        selectedIndex = 1;
    else 
        selectedIndex = 2;
    
    [header setButtonStatus:selectedIndex];
    return header;
    
}
-(void) onChangeRank:(id)sender{
    UIButton* button = (UIButton*) sender;
    int tag = button.tag;
    
    if(tag == 0){
        self.orderBy = ORDER_BY_WEEK;
    }
    else if(tag == 1){
        self.orderBy = ORDER_BY_MONTH;
    }
    else {
        self.orderBy = ORDER_BY_TOTAL;
    }
    [self loadData];
}

@end

@implementation LQRingRankViewController
@synthesize curUrl;
- (void)playAudio:(AudioButton *)button
{    
    NSInteger index = button.tag;
    LQGameInfo *item = [self.appsList objectAtIndex:index];
    
    if (_audioPlayer == nil) {
        _audioPlayer = [[AudioPlayer alloc] init];
    }
    
    if ([_audioPlayer.button isEqual:button]) {
        [_audioPlayer play];
    } else {
        [_audioPlayer stop];
        
        self.curUrl = [NSString stringWithFormat:@"%@.%@",[item.downloadUrl stringByDeletingPathExtension],@"mp3"];
        
//        NSString* mp3path = @"http://y1.eoews.com/assets/ringtones/2012/5/18/34049/oiuxsvnbtxks7a0tg6xpdo66exdhi8h0bplp7twp.mp3";
        _audioPlayer.button = button; 
        _audioPlayer.url = [NSURL URLWithString:@"http://y1.eoews.com/assets/ringtones/2012/5/18/34045/hi4dwfmrxm2citwjcc5841z3tiqaeeoczhbtfoex.mp3"];
        
        [_audioPlayer play];
    }   
}

-(void) viewDidUnload{
    if (_audioPlayer != nil) {
        [_audioPlayer stop];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return 70.f;
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   // static NSString *CellIdentifier = @"AudioCell";
    
    AudioCell *cell;
    
    if(indexPath.row == self.selectedRow){
        AudioMoreItemCell* morecell = [tableView dequeueReusableCellWithIdentifier:@"AudioMoreItemCell"];
        if (morecell == nil){
            morecell = [[[NSBundle mainBundle] loadNibNamed:@"AudioMoreItemCell" owner:self options:nil] objectAtIndex:0];
            [morecell configurePlayerButton];
            
            [morecell setButtonsName:@"立刻安装" middle:@"下载" right:nil];
            
            [morecell addLeftButtonTarget:self action:@selector(onGameDownload:) tag:indexPath.row];
            [morecell addMiddleButtonTarget:self action:@selector(onGameDownload:) tag:indexPath.row];
        }
        cell = morecell;
        
    }
    else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"AudioCell"];
        if (cell == nil){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"AudioCell" owner:self options:nil] objectAtIndex:0];
            [cell configurePlayerButton];
        }
    }
    
    
    
    // Configure the cell..
    LQGameInfo *item = [self.appsList objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = item.name;
    cell.artistLabel.text = item.tags;
    cell.audioButton.tag = indexPath.row;
    [cell.audioButton addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];    
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.selectedRow!= indexPath.row
       ){
        self.selectedRow = indexPath.row;
    }
    else {
        self.selectedRow = -1;
    }
    [self.tableView reloadData];
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    LQRankSectionHeader *header = [[[NSBundle mainBundle] loadNibNamed:@"LQRankSectionHeader" owner:self options:nil]objectAtIndex:0];
    
    [header addInfoButtonsTarget:self action:@selector(onChangeRank:) tag:0];
    [header addInfoButtonsTarget:self action:@selector(onChangeRank:) tag:1];
    [header addInfoButtonsTarget:self action:@selector(onChangeRank:) tag:2];
    
    int selectedIndex = 0;
    if(self.orderBy == ORDER_BY_NEWEST)
        selectedIndex = 0;
    else if (self.orderBy == ORDER_BY_TUIJIAN)
        selectedIndex = 1;
    else 
        selectedIndex = 2;
    
    [header.leftButton setTitle:@"最新" forState:UIControlStateNormal];
    [header.middleButton setTitle:@"推荐" forState:UIControlStateNormal];
    [header.rightButton setTitle:@"排行" forState:UIControlStateNormal];

    [header setButtonStatus:selectedIndex];
    return header;
    
}

-(void) onChangeRank:(id)sender{
    UIButton* button = (UIButton*) sender;
    int tag = button.tag;
    
    if(tag == 0){
        self.orderBy = ORDER_BY_NEWEST;
    }
    else if(tag == 1){
        self.orderBy = ORDER_BY_TUIJIAN;
    }
    else {
        self.orderBy = ORDER_BY_TOTAL;
    }
    [self loadData];
}

@end

@implementation LQWallpaperRankViewController
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    LQWallpaperCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"wallpaper"];
    if (cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LQWallpaperCell" owner:self options:nil] objectAtIndex:0];
    }
    
    int startIndex = indexPath.row * 4;
    // Configure the cell..
    NSMutableArray *itemList = [NSMutableArray array];
    for(int i=startIndex;i<self.appsList.count&&i<(4+startIndex);i++){
        LQGameInfo *item = [self.appsList objectAtIndex:i];
        [itemList addObject:item];
    }
    [cell setButtonInfo:itemList];
    
    return cell;
}


@end
