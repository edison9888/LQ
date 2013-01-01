//
//  ViewController.h
//  AudioPlayerDemo
//
//  Created by Lin Zhang on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AudioPlayer;

@interface AudioListViewController : LQViewController <UITableViewDelegate, UITableViewDataSource>
{
    AudioPlayer *_audioPlayer;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
