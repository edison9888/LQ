//
//  LQGameDetailViewController.h
//  qiyouxi
//
//  Created by Xie Zhe on 12-12-30.
//  Copyright (c) 2012年 LQ有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LQViewController.h"
#import "LQImageButton.h"
#import "LQAdvertiseView.h"
#import "QYXData.h"
#import "LQCommentTableViewCell.h"
@interface LQGameDetailViewController : LQViewController<UITableViewDataSource, UITableViewDelegate>{
}
@property (assign) int gameId;
@property (strong) LQGameInfo* gameInfo;

@property (unsafe_unretained) IBOutlet UIView* contentView;

@property (strong) IBOutlet UIView* gameInfoPanel;


@property (unsafe_unretained) IBOutlet UIScrollView* mainScrollView;

@property (unsafe_unretained) IBOutlet UIView* gameBaseInfoPanel;
@property (unsafe_unretained) IBOutlet LQImageButton* gameIconView;
@property (unsafe_unretained) IBOutlet UILabel* gameTitleLabel;
//@property (unsafe_unretained) IBOutlet UILabel* gameDetailLabel;
@property (unsafe_unretained) IBOutlet UILabel* gameSize;
@property (unsafe_unretained) IBOutlet UILabel* gameDownloadCount;
@property (unsafe_unretained) IBOutlet UILabel* gameType;
@property (unsafe_unretained) IBOutlet UILabel* gameVender;
@property (unsafe_unretained) IBOutlet UILabel* gameVersion;
@property (unsafe_unretained) IBOutlet UILabel* gameScore;
@property (unsafe_unretained) IBOutlet UIButton* downloadNowButton;
@property (unsafe_unretained) IBOutlet UIButton* installNowButton;
@property (unsafe_unretained) IBOutlet UILabel* commentLabel;

@property (unsafe_unretained) IBOutlet UIView* gamePhotoInfoPanel;
@property (unsafe_unretained) IBOutlet LQAdvertiseView* screenShotsView;
@property (unsafe_unretained) IBOutlet UIButton* weiboShareButton;
@property (unsafe_unretained) IBOutlet UIButton* qqShareButton;
@property (unsafe_unretained) IBOutlet UILabel* gameScore2;
@property (unsafe_unretained) IBOutlet UITableView *gameInfoCommentTableView;

//
//@property (unsafe_unretained) IBOutlet LQImageButton* commentGirlView;
//@property (unsafe_unretained) IBOutlet UILabel* commentGirlNameLabel;


@property (strong) IBOutlet UIView* commentsPanel;
@property (unsafe_unretained) IBOutlet UITableView* userCommentsView;

@property (unsafe_unretained) IBOutlet UIButton* detailButton;
@property (unsafe_unretained) IBOutlet UIButton* commentsButton;
@property (unsafe_unretained) IBOutlet UIView* buttonUnderline;

@property (strong) LQCommentTableViewCell* dummyCell;

- (IBAction)onShowDetail:(id)sender;
- (IBAction)onShowComments:(id)sender;@end
