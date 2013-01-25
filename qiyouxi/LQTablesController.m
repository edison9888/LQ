//
//  LQTablesController.m
//  qiyouxi
//
//  Created by Xie Zhe on 13-1-9.
//  Copyright (c) 2013年 科技有限公司. All rights reserved.
//

#import "LQTablesController.h"
#import "LQGameInfoListViewController.h"
#import "LQCommonTableViewController.h"
#import "LQRankViewController.h"
#import "LQCategoryListViewController.h"
#import "LQGameDetailViewController.h"
#define kNumberOfPages 4
@interface LQTablesController ()

-(void) onPageUpDown:(id)sender;
@end

@implementation LQTablesController
@synthesize scrollView, viewControllers,pageView,titleLabel,titleString;
@synthesize nodeId,categoryId,listOperator,pageController;

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
    // Do any additional setup after loading the view from its nib.
    [self initTables];
    [self initPageController];
    self.titleLabel.text = titleString;
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

- (void)initTables
{
	// load our data from a plist file inside our app bundle
    /*NSString *path = [[NSBundle mainBundle] pathForResource:@"content_iPhone" ofType:@"plist"];
     self.contentList = [NSArray arrayWithContentsOfFile:path];
     */
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < kNumberOfPages; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    // a page is the width of the scroll view
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    
    //pageControl.numberOfPages = kNumberOfPages;
    //pageControl.currentPage = 0;
    
    // pages are created on demand
    // load the visible page
    // load the page on either side to avoid flashes when the user starts scrolling
    //
    [self loadScrollViewWithPage:0];
    //[self loadScrollViewWithPage:1];
}

- (void)initPageController{
    NSArray* names = [[NSArray alloc] initWithObjects:@"最新",@"推荐",@"排行",@"分类", nil];
    
    //int width = names.count*(PAGE_NAME_SPAN+PAGE_NAME_WIDTH);
    
    CGRect frame = CGRectMake(0, 0, pageView.frame.size.width, pageView.frame.size.height);
    
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
    if (page >= kNumberOfPages)
        return;
    
    // replace the placeholder if necessary
    LQCommonTableViewController *controller = [viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        NSString* orderBy;
        if(page == 0){
            orderBy = ORDER_BY_NEWEST;
            if (nodeId == @"rj" || nodeId == @"yx") {
                controller = [[LQGameInfoListViewController alloc] initWithNibName:@"LQCommonTableViewController" bundle:nil listOperator:listOperator nodeId:nodeId orderBy:orderBy];
                
            }
            else if(nodeId == @"ls"){
                controller = [[LQRingListViewController alloc] initWithNibName:@"LQCommonTableViewController" bundle:nil listOperator:listOperator nodeId:nodeId orderBy:orderBy];
            }
            else {
                controller = [[LQWallpaperListViewController alloc] initWithNibName:@"LQCommonTableViewController" bundle:nil listOperator:listOperator nodeId:nodeId orderBy:orderBy];
            }
            
        }
        else if(page == 1){
            orderBy = ORDER_BY_TUIJIAN;
            if (nodeId == @"rj" || nodeId == @"yx") {
                controller = [[LQGameInfoListViewController alloc] initWithNibName:@"LQCommonTableViewController" bundle:nil listOperator:listOperator nodeId:nodeId orderBy:orderBy];
            }
            else if(nodeId == @"ls"){
                controller = [[LQRingListViewController alloc] initWithNibName:@"LQCommonTableViewController" bundle:nil listOperator:listOperator nodeId:nodeId orderBy:orderBy];
            }
            else {
                controller = [[LQWallpaperListViewController alloc] initWithNibName:@"LQCommonTableViewController" bundle:nil listOperator:listOperator nodeId:nodeId orderBy:orderBy];
            }
            
            
            
        }
        else if(page == 2) {
            orderBy = ORDER_BY_WEEK;
            if (nodeId == @"rj" || nodeId == @"yx") {

            controller = [[LQRankViewController alloc] initWithNibName:@"LQCommonTableViewController" bundle:nil listOperator:listOperator nodeId:nodeId orderBy:orderBy];
            }
            else if(nodeId == @"ls"){
                controller = [[LQRingRankViewController alloc] initWithNibName:@"LQCommonTableViewController" bundle:nil listOperator:listOperator nodeId:nodeId orderBy:orderBy];
            }
            else {
                    controller = [[LQWallpaperRankViewController alloc] initWithNibName:@"LQCommonTableViewController" bundle:nil listOperator:listOperator nodeId:nodeId orderBy:orderBy];
                }
            
        }
        else {
            //orderBy = ORDER_BY_TUIJIAN;
            controller = [[LQCategoryListViewController alloc] initWithNibName:@"LQCommonTableViewController" bundle:nil category:categoryId];
            
        }
        [viewControllers replaceObjectAtIndex:page withObject:controller];
        
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
        controller.parent = self;
        /* NSDictionary *numberItem = [self.contentList objectAtIndex:page];
         controller.numberImage.image = [UIImage imageNamed:[numberItem valueForKey:ImageKey]];
         controller.numberTitle.text = [numberItem valueForKey:NameKey];*/
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageController.currentPage = page;
    
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    //[self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    //[self loadScrollViewWithPage:page + 1];
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

- (void) switchToPage:(int)page{
    [self loadScrollViewWithPage:page];
    
    // update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    
    // Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
    pageController.currentPage = page;

}
- (IBAction)changePage:(id)sender
{
    UIButton* button = sender;
    [self switchToPage:button.tag];
}


- (IBAction)onBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


//- (void) setTitleString:(NSString *)aTitleString{
//    titleString = aTitleString;
//    self.titleLabel.text = aTitleString;
//}

-(void) onPageUpDown:(id)sender{
    UIButton* button = sender;
    int tag = button.tag;
    int newPage = pageController.currentPage+tag;
    if(newPage<0 || newPage>viewControllers.count)
        return;
    //pageController.currentPage = newPage;
    [self switchToPage:newPage];
}
@end
