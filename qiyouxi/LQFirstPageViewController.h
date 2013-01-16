//
//  LQFirstPageViewController.h
//  qiyouxi
//
//  Created by Xie Zhe on 12-12-30.
//  Copyright (c) 2012年 LQ有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LQViewController.h"
#import "LQRecommendButton.h"
#import "LQAdvertiseView.h"

@interface LQFirstPageViewController : LQViewController<UITableViewDelegate, UITableViewDataSource>{
    NSInteger selectedRow;
    NSInteger selectedSection;
    int currentRecommendIndex; // 0 apps 1 topics
}
//@property (unsafe_unretained) IBOutlet UIScrollView* scrollView;

//@property (unsafe_unretained) IBOutlet LQAdvertiseView* advView;

@property (unsafe_unretained) IBOutlet UITableView* historyView;

- (IBAction)onReload:(id)sender;
- (void)onLoadSoft:(id)sender;
- (void)onLoadGame:(id)sender;
- (void)onLoadRing:(id)sender;
- (void)onLoadWallpaper:(id)sender;
- (void)onGameDetail:(id)sender;
- (void)onSwitchRecommendSection:(id)sender;
- (void)onTopicList:(id)sender;
@end
