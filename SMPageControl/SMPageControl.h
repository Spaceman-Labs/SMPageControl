//
//  SMPageControl.h
//  SMPageControl
//
//  Created by Jerry Jones on 10/13/12.
//  Copyright (c) 2012 Spaceman Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SMPageControlAlignment) {
	SMPageControlAlignmentLeft = 1,
	SMPageControlAlignmentCenter,
	SMPageControlAlignmentRight
};

typedef NS_ENUM(NSUInteger, SMPageControlVerticalAlignment) {
	SMPageControlVerticalAlignmentTop = 1,
	SMPageControlVerticalAlignmentMiddle,
	SMPageControlVerticalAlignmentBottom
};

NS_CLASS_AVAILABLE_IOS(5_0) @interface SMPageControl : UIView

@property (nonatomic, assign, readwrite) NSInteger numberOfPages;							// default is 0
@property (nonatomic, assign, readwrite) NSInteger currentPage;								// default is 0. value pinned to 0..numberOfPages-1
@property (nonatomic, assign, readwrite) CGFloat indicatorMargin;							// deafult is 10
@property (nonatomic, assign, readwrite) CGFloat indicatorWidth;							// deafult is 6
@property (nonatomic, assign, readwrite) SMPageControlAlignment alignment;					// deafult is Center
@property (nonatomic, assign, readwrite) SMPageControlVerticalAlignment verticalAlignment;	// deafult is Middle

@property (nonatomic) BOOL hidesForSinglePage;          // hide the the indicator if there is only one page. default is NO

@property (nonatomic) BOOL defersCurrentPageDisplay;    // if set, clicking to a new page won't update the currently displayed page until -updateCurrentPageDisplay is called. default is NO
- (void)updateCurrentPageDisplay;                      // update page display to match the currentPage. ignored if defersCurrentPageDisplay is NO. setting the page value directly will update immediately
- (CGRect)rectForPage:(NSInteger)pageIndex;
- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount;   // returns minimum size required to display dots for given page count. can be used to size control if page count could change

@property (nonatomic, retain) UIColor *pageIndicatorTintColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, retain) UIColor *currentPageIndicatorTintColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, retain) UIImage *pageIndicatorImage NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, retain) UIImage *currentPageIndicatorImage NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;

@end
