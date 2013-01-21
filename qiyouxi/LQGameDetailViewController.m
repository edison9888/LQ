//
//  LQGameDetailViewController.m
//  qiyouxi
//
//  Created by Xie Zhe on 12-12-30.
//  Copyright (c) 2012年 LQ有限公司. All rights reserved.
//

#import "LQGameDetailViewController.h"
#import "LQCommentTableViewCell.h"
#import "LQImageBrowseViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"
#import "LQPostCommentViewController.h"
@interface LQGameDetailViewController (){
    NSString* moreUrl;
}
@property (strong) EGORefreshTableHeaderView* commentsHeaderView;
@property (assign) BOOL refreshing;
@property (assign) BOOL moreCommentsToLoad;
@property (strong) NSMutableArray* gameInfoUserComments; //在详情页显示评论
@property (strong) NSMutableArray* userComments;
@property (assign) CGFloat commentLabelMaxHeight;
@property (strong) NSString* moreUrl;


@end

@implementation LQGameDetailViewController

@synthesize gameId;
@synthesize gameInfo;
@synthesize userComments;
@synthesize gameInfoUserComments;
@synthesize commentLabelMaxHeight;
@synthesize mainScrollView;

@synthesize gameVender,gameVersion,gameType,gameScore,gameDownloadCount,gameBaseInfoPanel,gameSize;
@synthesize installNowButton,downloadNowButton;
@synthesize weiboShareButton,qqShareButton;
@synthesize gamePhotoInfoPanel;
@synthesize gameScore2;
@synthesize gameInfoCommentTableView;

@synthesize gameInfoPanel;
@synthesize gameIconView, gameTitleLabel;
@synthesize commentLabel;
@synthesize screenShotsView;

@synthesize contentView;
@synthesize commentsPanel;
@synthesize userCommentsView;

//@synthesize detailButton;
//@synthesize commentsButton;
//@synthesize buttonUnderline;

@synthesize dummyCell;

@synthesize commentsHeaderView;
@synthesize moreCommentsToLoad;
@synthesize refreshing;
@synthesize moreUrl;

#pragma mark - View Init
- (void)loadViews{
    self.commentLabelMaxHeight = self.commentLabel.bounds.size.height;
    
    CGRect frame = self.userCommentsView.frame;
    frame.origin.x = 0;
    frame.origin.y = frame.size.height;
    self.commentsHeaderView = [[EGORefreshTableFooterView alloc] initWithFrame:frame];
    [self.userCommentsView addSubview:self.commentsHeaderView];
    
    self.userComments = [[NSMutableArray alloc] init];
    self.commentsHeaderView.delegate = self;
    [self.commentsHeaderView refreshLastUpdatedDate];
    
    self.userCommentsView.hidden = YES;
    
    
    
    
}

- (void)viewDidLoad{
    // a page is the width of the scroll view
    mainScrollView.pagingEnabled = NO;
    //mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width, 1000);
    mainScrollView.showsHorizontalScrollIndicator = NO;
    mainScrollView.showsVerticalScrollIndicator = YES;
    mainScrollView.scrollsToTop = NO;
    
    [gameBaseInfoPanel removeFromSuperview];
    int height = 0;
    CGRect frame = gameBaseInfoPanel.frame;
    height+=frame.size.height;    
    [mainScrollView addSubview:gameBaseInfoPanel];
    
    [gamePhotoInfoPanel removeFromSuperview];
    frame = gamePhotoInfoPanel.frame;
    frame.origin.y= height+frame.origin.y;
    height+=frame.size.height;
    gamePhotoInfoPanel.frame = frame;
    [mainScrollView addSubview:gamePhotoInfoPanel];
    
    mainScrollView.contentSize = CGSizeMake(mainScrollView.frame.size.width, height);
    [mainScrollView layoutIfNeeded];
    
    self.gameInfoUserComments = [[NSMutableArray alloc]init];
    [self loadData];
}
-  (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    if ([self.commentsPanel superview] != nil){
        [self startLoading];
        [self loadMoreComments];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.userComments removeAllObjects];
    [self.userCommentsView reloadData];
}

#pragma mark - Data Init
- (void)loadData{
    [super loadData];
    [self startLoading];
    [self.client loadGameInfo:self.gameId];
}

- (void)loadGameBaseInfo{
    self.gameTitleLabel.text = self.gameInfo.name;
    
    int size= [self.gameInfo.size intValue];
    float sizeMB= (float)size/(1024*1024);
    self.gameSize.text =  [NSString stringWithFormat:@"大小:%.2fMB",sizeMB];
 
    self.gameVersion.text = [NSString stringWithFormat:@"版本:%@",gameInfo.versionCode];
    self.gameScore.text = [NSString stringWithFormat:@"%@分",gameInfo.rating];
    self.gameType.text = [NSString stringWithFormat:@"分类:%@", gameInfo.tags];
    self.gameVender.text = [NSString stringWithFormat:@"开发商:%@",@""];
    self.commentLabel.text = gameInfo.intro;
    //文字居中显示  
    commentLabel.textAlignment = UITextAlignmentLeft;  
    //自动折行设置  
    commentLabel.lineBreakMode = UILineBreakModeWordWrap;  
    commentLabel.numberOfLines = 0;  
    //[self.commentLabel autowrap:self.commentLabelMaxHeight];

}

- (void)loadGamePhotoInfo{
    self.screenShotsView.delegate = self;
    self.screenShotsView.needRotate = YES;
    self.screenShotsView.imageUrls = self.gameInfo.screenShotsSmall;
    self.gameScore2.text = [NSString stringWithFormat:@"%@分",gameInfo.rating];
    
}
- (void)loadGameInfo:(NSDictionary*)result{
    self.gameInfo = [[LQGameInfo alloc] initWithAPIResult:result];
    
    [self loadGameBaseInfo];
    [self loadGamePhotoInfo];   
    [self loadGameInfoComments:[result objectForKey:@"arr_comment"]];

}

- (void)loadGameInfoComments:(NSArray*) result{
    [self.gameInfoUserComments addObjectsFromArray: result];
    [self.gameInfoCommentTableView reloadData];
}

- (void)loadUserComments:(NSDictionary*)result{
//    NSArray* items = [[result objectForKey:@"context"] objectForKey:@"items"];
//    int total_count = [[[result objectForKey:@"context"] objectForKey:@"total_count"] intValue];
    
    NSArray* items = [result objectForKey:@"arr_comment"];
    moreUrl = [result objectForKey:@"more_url"];  

    
    [self.userComments addObjectsFromArray:items];
    [self.userCommentsView reloadData];    
    
    self.refreshing = NO;
    self.moreCommentsToLoad = (moreUrl!=nil);//total_count > self.userComments.count;    
    [self.commentsHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.userCommentsView];
    
    if (self.userComments.count > 0){
        self.userCommentsView.hidden = NO;
    }else{
        self.userCommentsView.hidden = YES;
    }
}

- (void)loadMoreComments{
    [self startLoading];
    [self.client loadUserMoreComments:moreUrl];

    //[self.client loadUserComments:self.gameId /*start:self.userComments.count count:50*/];
}

#pragma mark - Actions
//- (IBAction)onShowDetail:(id)sender{
//    [self.commentsPanel removeFromSuperview];
//    [self.contentView addSubview:self.gameInfoPanel];
//    
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.5];
//    CGPoint center = self.buttonUnderline.center;
//    center.x = self.detailButton.center.x;
//    self.buttonUnderline.center = center;
//    [UIView commitAnimations];
//}

//- (IBAction)onShowComments:(id)sender{
//    [self.gameInfoPanel removeFromSuperview];
//    [self.contentView addSubview:self.commentsPanel];
//    
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.5];
//    CGPoint center = self.buttonUnderline.center;
//    center.x = self.commentsButton.center.x;
//    self.buttonUnderline.center = center;
//    [UIView commitAnimations];
//    
//    if (self.userComments.count == 0){
//        [self startLoading];
//        [self.client loadUserComments:self.gameId];
//
//    }
//    LQPostCommentViewController* controller = [[LQPostCommentViewController alloc] initWithNibName:@"LQPostCommentViewController" bundle:nil];
//    controller.gameId = self.gameId;
//    controller.gameScore.text = self.gameScore.text;
//    [self.navigationController pushViewController:controller animated:YES];
//    
//    
//    
//}

#pragma mark - Network Callback
- (void)client:(LQClientBase*)client didGetCommandResult:(id)result forCommand:(int)command format:(int)format tagObject:(id)tagObject{
    switch (command) {
        case C_COMMAND_GETGAMEINFO:
            [self endLoading];
            [self loadGameInfo:[result objectForKey:@"appinfo"]];
            break;
        case C_COMMAND_GETUSERCOMMENTS:
            [self endLoading];
            if ([result isKindOfClass:[NSDictionary class]]){
                [self loadUserComments:result];
            }
        default:
            break;
    }
}

- (void)handleNetworkError:(LQClientError*)error{
    switch (error.command) {
        case C_COMMAND_GETGAMEINFO:
            [self endLoading];
            [super handleNetworkError:error];
            break;
        case C_COMMAND_GETUSERCOMMENTS:
            [self endLoading];
            [super handleNetworkErrorHint];
        default:
            break;
    }
}

#pragma mark - TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == self.gameInfoCommentTableView)
        return self.gameInfoUserComments.count;
    else
        return self.userComments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LQCommentTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"comment"];
    if (cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CommentTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    
    if(tableView == self.gameInfoCommentTableView)
    {
        NSDictionary* item = [self.gameInfoUserComments objectAtIndex:indexPath.row];
        cell.comment = item;
        
    }
    else{
        NSDictionary* item = [self.userComments objectAtIndex:indexPath.row];
        cell.comment = item;
    }
   
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
//    if (self.dummyCell == nil){
//        self.dummyCell = [[[NSBundle mainBundle] loadNibNamed:@"CommentTableViewCell" owner:self options:nil] objectAtIndex:0];
//        
//    }
//    
//    NSDictionary* item = [self.userComments objectAtIndex:indexPath.row];
//    self.dummyCell.comment = item;
//    
//    [self.dummyCell layoutSubviews];
//    
//    CGSize rowSize = [self.dummyCell sizeThatFits:CGSizeZero];
//    return rowSize.height;    
}

#pragma mark - EGORefreshTableView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
    if (self.moreCommentsToLoad){
        [self.commentsHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.moreCommentsToLoad){
        [self.commentsHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    //    [self loadCurrentCategory];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return self.refreshing; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate date]; // should return date data source was last changed
}

- (float)egoRefreshTableHeaderTableViewHeight:(EGORefreshTableHeaderView*)view{
    return self.userCommentsView.contentSize.height;
}

- (BOOL)egoRefreshTableHeaderDataSourceNeedLoading:(EGORefreshTableHeaderView*)view{
    return self.moreCommentsToLoad;
}


#pragma mark - 
- (void)QYXAdvertiseView:(LQAdvertiseView*)advertiseView selectPage:(int)page{
//    [self performSegueWithIdentifier:@"gotoBrowse" sender:[NSNumber numberWithInt:page]];
}

@end
