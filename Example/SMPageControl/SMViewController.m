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
	
	CGSize size = self.view.bounds.size;
	size.width *= 10;
	self.scrollview.contentSize = size;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
