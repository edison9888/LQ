//
//  QYXAppDelegate.h
//  qiyouxi
//
//  Created by 谢哲 on 12-7-30.
//  Copyright (c) 2012年 科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LQLaunchViewController;


@interface QYXAppDelegate : UIResponder <UIApplicationDelegate>{
    UINavigationController *navigationController;
    UIWindow *window;
    LQLaunchViewController *launchViewController;

}

@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (strong, nonatomic) IBOutlet UINavigationController *navigationController;
@property (strong, nonatomic) IBOutlet LQLaunchViewController *launchViewController;

@end
