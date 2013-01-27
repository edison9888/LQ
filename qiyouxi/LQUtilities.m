//
//  LQUtilities.m
//  liqu
//
//  Created by Xie Zhe on 13-1-23.
//  Copyright (c) 2013年 科技有限公司. All rights reserved.
//

#import "LQUtilities.h"
#import "LQConfig.h"

@implementation LQUtilities
+(BOOL) copyFile:(NSString*) srcPath destPath:(NSString*) destPath{
    NSError* error=nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
        NSLog(@"文件存在");
        [[NSFileManager defaultManager] removeItemAtPath:destPath error:&error];//删除不了哦
        if (error!=nil) {
            NSLog(@"error=%@",error);
            return NO;
        }
    }
    
    [[NSFileManager defaultManager]copyItemAtPath:srcPath toPath:destPath error:&error ];
    if (error!=nil) {
        return NO;
        NSLog(@"%@", error);
        NSLog(@"%@", [error userInfo]);
    }
    return YES;

}

+(BOOL) removeFile:(NSString*) destPath {
     NSError* error=nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
        NSLog(@"文件存在");
        [[NSFileManager defaultManager] removeItemAtPath:destPath error:&error];//删除不了哦
        if (error!=nil) {
            NSLog(@"error=%@",error);
            return NO;
        }
    }
    return YES;
}

+ (void)AlertWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

@end

static AppUpdateReader* _intance = nil;

static NSString* const installedAppListPath = @"/private/var/mobile/Library/Caches/com.apple.mobile.installation.plist";

@implementation AppUpdateReader

@synthesize appsList/*,delegate*/,client;
#pragma mark - Init

+ (AppUpdateReader*)sharedInstance{
    if (_intance == nil){
        _intance = [[AppUpdateReader alloc] init];
    }
    
    return _intance;
}
    
- (id)init{
    self = [super init];
    if (self != nil){
        if (client == nil){
            client = [[LQClient alloc] initWithDelegate:self];
        }
        if(updateListeners == nil){
            updateListeners = [NSMutableArray array];
        }
            
    }
    return self;
}


-(NSMutableArray *)desktopAppsFromDictionary:(NSDictionary *)dictionary
{
    NSMutableArray *desktopApps = [NSMutableArray array];
    
    for (NSString *appKey in dictionary)
    {
        NSRange range = [appKey rangeOfString:@"com.apple."];
        if(range.location == 0 && range.length>0)
            continue;
        
        NSDictionary* appDict = [dictionary objectForKey:appKey];
        NSString* appVersion = [appDict objectForKey:@"CFBundleVersion"];
        NSString* appValue = [NSString stringWithFormat:@"%@,%@",appKey,appVersion];
        [desktopApps addObject:appValue];
        
        
    }
    return desktopApps;
}

-(NSArray *)installedApp
{    
    BOOL isDir = NO;
    if([[NSFileManager defaultManager] fileExistsAtPath: installedAppListPath isDirectory: &isDir] && !isDir) 
    {
        NSDictionary *cacheDict = [NSDictionary dictionaryWithContentsOfFile: installedAppListPath];
        NSDictionary *system = [cacheDict objectForKey: @"System"];
        NSMutableArray *installedApp = [NSMutableArray arrayWithArray:[self desktopAppsFromDictionary:system]];
        
        NSDictionary *user = [cacheDict objectForKey: @"User"]; 
        [installedApp addObjectsFromArray:[self desktopAppsFromDictionary:user]];
        
        return installedApp;
    }
    
    return nil;
}

- (void)loadApps:(NSArray*) apps{
    NSMutableArray* items = [NSMutableArray array];
    for (NSDictionary* game in apps){
        [items addObject:[[LQGameInfo alloc] initWithAPIResult:game]];
    }
    
    appsList = items;
}

- (void)loadNeedUpdateApps{
    //已经有了 不需要重新加载
    if(self.appsList!=nil){        
        for (id listener in updateListeners) {
            if([listener respondsToSelector:@selector(didAppUpdateListSuccess:)]){
                [listener didAppUpdateListSuccess:self.appsList];
            } 
        }
//        
//        if([self.delegate respondsToSelector:@selector(didAppUpdateListSuccess:)]) {
//            [self.delegate didAppUpdateListSuccess:self.appsList];
//        } 
        return;
    }

    //读取已经安装的apps 提交后台判断
    NSArray * array = [self installedApp];
    NSString* appsString = [array componentsJoinedByString:@","];
//    if(appsString == nil)
//        appsString = [LQConfig restoreAppList];
//    else 
//        [LQConfig saveAppList:appsString];
//
    
    if(appsString !=nil && appsString.length>0)
        [self.client loadAppUpdate:appsString];

    
}
- (void)reloadNeedUpdateApps{
    appsList = nil;
    [self loadNeedUpdateApps];
}

#pragma mark - Network Callback
- (void)client:(LQClientBase*)client didGetCommandResult:(id)result forCommand:(int)command format:(int)format tagObject:(id)tagObject{
    switch (command) {
        case C_COMMAND_GETAPPUPDATE:
            if ([result isKindOfClass:[NSDictionary class]]){
                [self loadApps:[result objectForKey:@"apps"]];
                for (id listener in updateListeners) {
                    if([listener respondsToSelector:@selector(didAppUpdateListSuccess:)]){
                        [listener didAppUpdateListSuccess:self.appsList];
                    } 
                }


            }
            break;
        default:
            break;
    }
}

// when command fails
- (void)client:(LQClientBase*)client didFailExecution:(LQClientError*)error{
//    if([self.delegate respondsToSelector:@selector(didAppUpdateListFailed:)]) {
//    [self.delegate didAppUpdateListFailed:error];
//}
    
    for (id listener in updateListeners) {
        if([listener respondsToSelector:@selector(didAppUpdateListFailed:)]){
            [listener didAppUpdateListFailed:error];
        } 
    }
}

- (void)addListener:(id) listener{
    if([updateListeners containsObject:listener] == NO)
        [updateListeners addObject:listener];
}
- (void)removeListener:(id) listener{
    [updateListeners removeObject: listener];
}
@end
