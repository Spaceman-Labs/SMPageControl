//
//  SMViewController.h
//  SMPageControl
//
//  Created by Jerry Jones on 10/13/12.
//  Copyright (c) 2012 Spaceman Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMPageControl.h"

@interface SMViewController : UIViewController

@property (nonatomic, readonly) IBOutlet UIScrollView *scrollview;
@property (nonatomic, readonly) IBOutlet UIPageControl *pageControl;
@property (nonatomic, readonly) IBOutlet SMPageControl *spacePageControl1;
@property (nonatomic, readonly) IBOutlet SMPageControl *spacePageControl2;
@property (nonatomic, readonly) IBOutlet SMPageControl *spacePageControl3;
@property (nonatomic, readonly) IBOutlet SMPageControl *spacePageControl4;
@property (nonatomic, readonly) IBOutlet SMPageControl *spacePageControl5;
@property (nonatomic, readonly) IBOutlet SMPageControl *spacePageControl6;
@property (nonatomic, readonly) IBOutlet SMPageControl *spacePageControl7;
@property (nonatomic, readonly) IBOutlet SMPageControl *spacePageControl8;

@end
