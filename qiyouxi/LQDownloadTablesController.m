//
//  LQDownloadTablesController.m
//  liqu
//
//  Created by Xie Zhe on 13-1-22.
//  Copyright (c) 2013年 科技有限公司. All rights reserved.
//

#import "LQDownloadTablesController.h"
#import "LQDownloadingViewController.h"
#import "LQDownloadedCategoryController.h"
#define kDownloadTables 2
@interface LQDownloadTablesController ()

@end

@implementation LQDownloadTablesController

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
    self.titleLabel.text = @"下载详情";
    self.backButton.hidden = YES;
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

- (void)initTables
{
	// load our data from a plist file inside our app bundle
    /*NSString *path = [[NSBundle mainBundle] pathForResource:@"content_iPhone" ofType:@"plist"];
     self.contentList = [NSArray arrayWithContentsOfFile:path];
     */
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < kDownloadTables; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    // a page is the width of the scroll view
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kDownloadTables, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    
    [self loadScrollViewWithPage:0];
}

- (void)initPageController{
    NSArray* names = [[NSArray alloc] initWithObjects:@"已下载",@"下载中", nil];
    
    //int width = names.count*(PAGE_NAME_SPAN+PAGE_NAME_WIDTH);
    
    CGRect frame = CGRectMake(0, 0, self.pageView.frame.size.width, self.pageView.frame.size.height);
    
    pageController = [[LQPageController alloc] initWithFrame:frame];
    [pageController setPageNames:names];
    pageController.currentPage = 0;
    
    [pageController addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventTouchUpInside];
    [pageController addLeftRightTarget:self action:@selector(onPageUpDown:) tag:0];
    [self.pageView addSubview:pageController];
}
- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= kDownloadTables)
        return;
    
    // replace the placeholder if necessary
    UIViewController *controller = [viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        if(page == 0) {
            LQDownloadedCategoryController *  detailController = [[LQDownloadedCategoryController alloc] initWithNibName:@"LQDownloadedCategoryController" bundle:nil];
            detailController.parent = self;
            [viewControllers replaceObjectAtIndex:page withObject:detailController];
            controller = detailController;     
        }
        else{
            LQDownloadingViewController*  postController = [[LQDownloadingViewController alloc] initWithNibName:@"LQDownloadingViewController" bundle:nil];
            [viewControllers replaceObjectAtIndex:page withObject:postController];
            controller = postController;
        }
        
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
        //controller.parent = self;
    }
}
@end
