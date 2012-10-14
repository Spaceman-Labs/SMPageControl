//
//  SMPageControl.m
//  SMPageControl
//
//  Created by Jerry Jones on 10/13/12.
//  Copyright (c) 2012 Spaceman Labs. All rights reserved.
//

#import "SMPageControl.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif


#define DEFAULT_INDICATOR_WIDTH 6.0f
#define DEFAULT_INDICATOR_MARGIN 10.0f

@interface SMPageControl ()
@end

@implementation SMPageControl
{
@private
    NSInteger			_displayedPage;
	CGFloat				_measuredIndicatorWidth;
	CGFloat				_measuredIndicatorHeight;
	NSMutableDictionary	*_pageImages;
	NSMutableDictionary	*_currentPageImages;
}

- (void)_initialize
{
	_numberOfPages = 0;
	
	self.backgroundColor = [UIColor clearColor];
	_measuredIndicatorWidth = DEFAULT_INDICATOR_WIDTH;
	_measuredIndicatorHeight = DEFAULT_INDICATOR_WIDTH;
	_indicatorDiameter = DEFAULT_INDICATOR_WIDTH;
	_indicatorMargin = DEFAULT_INDICATOR_MARGIN;
	_alignment = SMPageControlAlignmentCenter;
	_verticalAlignment = SMPageControlVerticalAlignmentMiddle;
	
	_pageImages = [NSMutableDictionary dictionary];
	_currentPageImages = [NSMutableDictionary dictionary];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (nil == self) {
		return nil;
    }
	
	[self _initialize];
    return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self _initialize];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	[self _renderPages:context rect:rect];
}

- (void)_renderPages:(CGContextRef)context rect:(CGRect)rect
{
	if (_numberOfPages < 2 && _hidesForSinglePage) {
		return;
	}
	
	CGFloat left = [self _leftOffset];
//	CGSize size = [self sizeForNumberOfPages:self.numberOfPages];
//	CGContextFillRect(context, CGRectMake(left, 0, size.width, size.height));
		
	CGFloat xOffset = left;
	CGFloat yOffset = [self _topOffset];
	UIColor *fillColor = nil;
	UIImage *image = nil;
	
	for (NSUInteger i = 0; i < _numberOfPages; i++) {
		
		if (i == _displayedPage) {
			fillColor = _currentPageIndicatorTintColor ? _currentPageIndicatorTintColor : [UIColor whiteColor];
			image = _currentPageImages[@(i)];
			if (nil == image) {
				image = _currentPageIndicatorImage;
			}
		} else {
			fillColor = _pageIndicatorTintColor ? _pageIndicatorTintColor : [[UIColor whiteColor] colorWithAlphaComponent:0.3f];
			image = _pageImages[@(i)];
			if (nil == image) {
				image = _pageIndicatorImage;
			}
		}
		[fillColor set];

		if (image) {
			[image drawAtPoint:CGPointMake(xOffset, yOffset)];
		} else {
			CGContextFillEllipseInRect(context, CGRectMake(xOffset, yOffset, _measuredIndicatorWidth, _measuredIndicatorHeight));
		}

		xOffset += _measuredIndicatorWidth + _indicatorMargin;
	}
	
//	[[UIColor greenColor] set];
//	CGContextFillRect(context, CGRectMake(left, 0.0f, [self sizeForNumberOfPages:_numberOfPages].width, 10.0f));
}

- (CGFloat)_leftOffset
{
	CGRect rect = self.bounds;
	CGSize size = [self sizeForNumberOfPages:self.numberOfPages];
	CGFloat left = 0.0f;
	switch (_alignment) {
		case SMPageControlAlignmentCenter:
			left = CGRectGetMidX(rect) - (size.width / 2.0f);
			break;
		case SMPageControlAlignmentRight:
			left = CGRectGetMaxX(rect) - size.width;
			break;
		default:
			break;
	}
	
	return left;
}

- (CGFloat)_topOffset
{
	CGRect rect = self.bounds;
	CGSize size = [self sizeForNumberOfPages:self.numberOfPages];
	CGFloat top = 0.0f;
	switch (_verticalAlignment) {
		case SMPageControlVerticalAlignmentMiddle:
			top = CGRectGetMidY(rect) - (_measuredIndicatorHeight / 2.0f);
			break;
		case SMPageControlVerticalAlignmentBottom:
			top = CGRectGetMaxY(rect) - size.height;
			break;
		default:
			break;
	}

	return top;
}

- (void)updateCurrentPageDisplay
{
	_displayedPage = _currentPage;
	[self setNeedsDisplay];
}

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount
{
	CGFloat marginSpace = MAX(0, pageCount - 1) * _indicatorMargin;
	CGFloat indicatorSpace = pageCount * _measuredIndicatorWidth;
	return CGSizeMake(marginSpace + indicatorSpace, _measuredIndicatorHeight);
}

- (CGRect)rectForPageIndicator:(NSInteger)pageIndex
{
	if (pageIndex < 0 || pageIndex >= _numberOfPages) {
		return CGRectZero;
	}
	
	CGFloat left = [self _leftOffset];
	CGSize size = [self sizeForNumberOfPages:pageIndex + 1];
	CGRect rect = CGRectMake(left + size.width - _measuredIndicatorWidth, 0, _measuredIndicatorWidth, _measuredIndicatorWidth);
	return rect;
}

- (void)_setImage:(UIImage *)image forPage:(NSInteger)pageIndex current:(BOOL)current
{
	if (pageIndex < 0 || pageIndex >= _numberOfPages) {
		return;
	}
	
	NSMutableDictionary *dictionary = current ? _currentPageImages : _pageImages;
	dictionary[@(pageIndex)] = image;
}

- (void)setImage:(UIImage *)image forPage:(NSInteger)pageIndex;
{
	[self _setImage:image forPage:pageIndex current:NO];
}

- (void)setCurrentImage:(UIImage *)image forPage:(NSInteger)pageIndex
{
	[self _setImage:image forPage:pageIndex current:YES];
}

- (UIImage *)_imageForPage:(NSInteger)pageIndex current:(BOOL)current
{
	if (pageIndex < 0 || pageIndex >= _numberOfPages) {
		return nil;
	}
	
	NSDictionary *dictionary = current ? _currentPageImages : _pageImages;
	return dictionary[@(pageIndex)];
}

- (UIImage *)imageForPage:(NSInteger)pageIndex
{
	return [self _imageForPage:pageIndex current:NO];
}

- (UIImage *)currentImageForPage:(NSInteger)pageIndex
{
	return [self _imageForPage:pageIndex current:YES];
}

- (void)sizeToFit
{
	CGRect frame = self.frame;
	CGSize size = [self sizeForNumberOfPages:self.numberOfPages];
	size.height = MAX(size.height, 36.0f);
	frame.size = size;
	self.frame = frame;
}

- (void)updatePageNumberForScrollView:(UIScrollView *)scrollView
{
	NSInteger page = (int)floorf(scrollView.contentOffset.x / scrollView.frame.size.width);
	self.currentPage = page;
}

#pragma mark -

- (void)_updateMeasuredIndicatorSizes
{
	_measuredIndicatorWidth = _indicatorDiameter;
	_measuredIndicatorHeight = _indicatorDiameter;
	
	// If we're only using images, ignore the _indicatorDiameter
	if (self.pageIndicatorImage && self.currentPageIndicatorImage) {
		_measuredIndicatorWidth = 0;
		_measuredIndicatorHeight = 0;
	}
	
	if (self.pageIndicatorImage) {
		CGSize imageSize = self.pageIndicatorImage.size;
		_measuredIndicatorWidth = MAX(_indicatorDiameter, imageSize.width);
		_measuredIndicatorHeight = MAX(_indicatorDiameter, imageSize.height);
	}
	
	if (self.currentPageIndicatorImage) {
		CGSize imageSize = self.currentPageIndicatorImage.size;
		_measuredIndicatorWidth = MAX(_indicatorDiameter, imageSize.width);
		_measuredIndicatorHeight = MAX(_indicatorDiameter, imageSize.height);
	}	
}


#pragma mark - Tap Gesture

// We're using touchesEnded: because we want to mimick UIPageControl as close as possible
// As of iOS 6, UIPageControl still does not use a tap gesture recognizer. This means that actions like
// touching down, sliding around, and releasing, still results in the page incrementing or decrementing.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	CGSize size = [self sizeForNumberOfPages:self.numberOfPages];
	CGFloat left = [self _leftOffset];
	CGFloat middle = left + (size.width / 2.0f);
	if (point.x < middle) {
		[self setCurrentPage:self.currentPage - 1 sendEvent:YES canDefer:YES];
	} else {
		[self setCurrentPage:self.currentPage + 1 sendEvent:YES canDefer:YES];
	}
}

#pragma mark - Accessors

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	[self setNeedsDisplay];
}

- (void)setIndicatorDiameter:(CGFloat)indicatorDiameter
{
	if (indicatorDiameter == _indicatorDiameter) {
		return;
	}
	
	_indicatorDiameter = indicatorDiameter;
	[self _updateMeasuredIndicatorSizes];
	[self setNeedsDisplay];
}

- (void)setIndicatorMargin:(CGFloat)indicatorMargin
{
	if (indicatorMargin == _indicatorMargin) {
		return;
	}
	
	_indicatorMargin = indicatorMargin;
	[self setNeedsDisplay];
}

- (void)setNumberOfPages:(NSInteger)numberOfPages
{
	if (numberOfPages == _numberOfPages) {
		return;
	}
	
	_numberOfPages = MAX(0, numberOfPages);
	[self setNeedsDisplay];
}

- (void)setCurrentPage:(NSInteger)currentPage
{
	[self setCurrentPage:currentPage sendEvent:NO canDefer:NO];
}

- (void)setCurrentPage:(NSInteger)currentPage sendEvent:(BOOL)sendEvent canDefer:(BOOL)defer
{
	if (currentPage < 0 || currentPage >= _numberOfPages) {
		return;
	}
	
	_currentPage = currentPage;
	if (NO == self.defersCurrentPageDisplay || NO == defer) {
		_displayedPage = _currentPage;
		[self setNeedsDisplay];
	}
	
	if (sendEvent) {
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}
}

- (void)setCurrentPageIndicatorImage:(UIImage *)currentPageIndicatorImage
{
	if ([currentPageIndicatorImage isEqual:_currentPageIndicatorImage]) {
		return;
	}
	
	_currentPageIndicatorImage = currentPageIndicatorImage;
	[self _updateMeasuredIndicatorSizes];
	[self setNeedsDisplay];
}

- (void)setPageIndicatorImage:(UIImage *)pageIndicatorImage
{
	if ([pageIndicatorImage isEqual:_pageIndicatorImage]) {
		return;
	}
	
	_pageIndicatorImage = pageIndicatorImage;
	[self _updateMeasuredIndicatorSizes];
	[self setNeedsDisplay];
}

@end
