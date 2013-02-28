//
//  LQDownloadedViewController.h
//  liqu
//
//  Created by Xie Zhe on 13-1-22.
//  Copyright (c) 2013年 科技有限公司. All rights reserved.
//

#import "LQViewController.h"

@interface LQDownloadedViewController : LQViewController<UITableViewDelegate, UITableViewDataSource>{
    NSMutableArray* completedList;
    NSMutableArray* installedList;
}
@property (unsafe_unretained) IBOutlet UITableView* applicaitonView;
@property (unsafe_unretained) IBOutlet UILabel* title;
@property (unsafe_unretained) IBOutlet UILabel* noItemLabel;
@property (nonatomic,strong) NSString* type;
@property (nonatomic,strong) NSString* titleString;
-(IBAction)onBack:(id)sender;
@end
