//
//  SMViewController.m
//  SMPageControl
//
//  Created by Jerry Jones on 10/13/12.
//  Copyright (c) 2012 Spaceman Labs. All rights reserved.
//

#import "SMViewController.h"

@interface SMViewController ()

@end

@implementation SMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
		
	[self.spacePageControl setPageIndicatorImage:[UIImage imageNamed:@"pageDot"]];
	[self.spacePageControl setCurrentPageIndicatorImage:[UIImage imageNamed:@"currentPageDot"]];
	self.spacePageControl.backgroundColor = [UIColor clearColor];
	
	[self.pageControl addTarget:self action:@selector(pageControl:) forControlEvents:UIControlEventValueChanged];
	[self.spacePageControl addTarget:self action:@selector(spacePageControl:) forControlEvents:UIControlEventValueChanged];
}

- (void)pageControl:(id)sender
{
	NSLog(@"Current Page (UIPageControl) : %i", self.pageControl.currentPage);
}

- (void)spacePageControl:(id)sender
{
	NSLog(@"Current Page (SMPageControl): %i", self.spacePageControl.currentPage);
}

@end
