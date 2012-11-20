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
#define MIN_HEIGHT 36.0f

typedef NS_ENUM(NSUInteger, SMPageControlImageType) {
	SMPageControlImageTypeNormal = 1,
	SMPageControlImageTypeCurrent,
	SMPageControlImageTypeMask
};

@interface SMPageControl ()
@property (nonatomic, readonly) NSMutableDictionary *pageImages;
@property (nonatomic, readonly) NSMutableDictionary *currentPageImages;
@property (nonatomic, readonly) NSMutableDictionary *pageImageMasks;
@property (nonatomic, readonly) NSMutableDictionary *cgImageMasks;
@end

@implementation SMPageControl
{
@private
    NSInteger			_displayedPage;
	CGFloat				_measuredIndicatorWidth;
	CGFloat				_measuredIndicatorHeight;
	CGImageRef			_pageImageMask;
}

@synthesize pageImages = _pageImages;
@synthesize currentPageImages = _currentPageImages;
@synthesize pageImageMasks = _pageImageMasks;
@synthesize cgImageMasks = _cgImageMasks;

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

- (void)dealloc
{
	if (_pageImageMask) {
		CGImageRelease(_pageImageMask);
	}	
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
		
	CGFloat xOffset = left;
	CGFloat yOffset = 0.0f;
	UIColor *fillColor = nil;
	UIImage *image = nil;
	CGImageRef maskingImage = nil;
	CGSize maskSize = CGSizeZero;
	
	for (NSUInteger i = 0; i < _numberOfPages; i++) {
		NSNumber *indexNumber = @(i);
		
		if (i == _displayedPage) {
			fillColor = _currentPageIndicatorTintColor ? _currentPageIndicatorTintColor : [UIColor whiteColor];
			image = _currentPageImages[indexNumber];
			if (nil == image) {
				image = _currentPageIndicatorImage;
			}
		} else {
			fillColor = _pageIndicatorTintColor ? _pageIndicatorTintColor : [[UIColor whiteColor] colorWithAlphaComponent:0.3f];
			image = _pageImages[indexNumber];
			if (nil == image) {
				image = _pageIndicatorImage;
			}
		}
		
		// If no finished images have been set, try a masking image
		if (nil == image) {
			maskingImage = (__bridge CGImageRef)_cgImageMasks[indexNumber];
			UIImage *originalImage = _pageImageMasks[indexNumber];
			maskSize = originalImage.size;

			// If no per page mask is set, try for a global page mask!
			if (nil == maskingImage) {
				maskingImage = _pageImageMask;
				maskSize = _pageIndicatorMaskImage.size;
			}
		}
				
		[fillColor set];
		
		if (image) {
			yOffset = [self _topOffsetForHeight:image.size.height rect:rect];
			CGFloat centeredXOffset = xOffset + floorf((_measuredIndicatorWidth - image.size.width) / 2.0f);
			[image drawAtPoint:CGPointMake(centeredXOffset, yOffset)];
		} else if (maskingImage) {
			yOffset = [self _topOffsetForHeight:maskSize.height rect:rect];
			CGFloat centeredXOffset = xOffset + floorf((_measuredIndicatorWidth - maskSize.width) / 2.0f);
			CGRect imageRect = CGRectMake(centeredXOffset, yOffset, maskSize.width, maskSize.height);
			CGContextDrawImage(context, imageRect, maskingImage);
		} else {
			yOffset = [self _topOffsetForHeight:_indicatorDiameter rect:rect];
			CGFloat centeredXOffset = xOffset + floorf((_measuredIndicatorWidth - _indicatorDiameter) / 2.0f);
			CGContextFillEllipseInRect(context, CGRectMake(centeredXOffset, yOffset, _indicatorDiameter, _indicatorDiameter));
		}
		
		maskingImage = NULL;
		xOffset += _measuredIndicatorWidth + _indicatorMargin;
	}
	
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

- (CGFloat)_topOffsetForHeight:(CGFloat)height rect:(CGRect)rect
{
	CGFloat top = 0.0f;
	switch (_verticalAlignment) {
		case SMPageControlVerticalAlignmentMiddle:
			top = CGRectGetMidY(rect) - (height / 2.0f);
			break;
		case SMPageControlVerticalAlignmentBottom:
			top = CGRectGetMaxY(rect) - height;
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
	CGSize size = CGSizeMake(marginSpace + indicatorSpace, _measuredIndicatorHeight);
	return size;
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

- (void)_setImage:(UIImage *)image forPage:(NSInteger)pageIndex type:(SMPageControlImageType)type
{
	if (pageIndex < 0 || pageIndex >= _numberOfPages) {
		return;
	}
	
	NSMutableDictionary *dictionary = nil;
	switch (type) {
		case SMPageControlImageTypeCurrent:
			dictionary = self.currentPageImages;
			break;
		case SMPageControlImageTypeNormal:
			dictionary = self.pageImages;
			break;
		case SMPageControlImageTypeMask:
			dictionary = self.pageImageMasks;
			break;
		default:
			break;
	}
    
    if (image) {
        dictionary[@(pageIndex)] = image;
    } else {
        [dictionary removeObjectForKey:@(pageIndex)];
    }
}

- (void)setImage:(UIImage *)image forPage:(NSInteger)pageIndex;
{
    [self _setImage:image forPage:pageIndex type:SMPageControlImageTypeNormal];
	[self _updateMeasuredIndicatorSizes];
}

- (void)setCurrentImage:(UIImage *)image forPage:(NSInteger)pageIndex
{
	[self _setImage:image forPage:pageIndex type:SMPageControlImageTypeCurrent];;
	[self _updateMeasuredIndicatorSizes];
}

- (void)setImageMask:(UIImage *)image forPage:(NSInteger)pageIndex
{
	[self _setImage:image forPage:pageIndex type:SMPageControlImageTypeMask];
	
	if (nil == image) {
		[self.cgImageMasks removeObjectForKey:@(pageIndex)];
		return;
	}
	
	CGImageRef maskImage = [self createMaskForImage:image];

	if (maskImage) {
		self.cgImageMasks[@(pageIndex)] = (__bridge id)maskImage;
		CGImageRelease(maskImage);
		[self _updateMeasuredIndicatorSizeWithSize:image.size];
		[self setNeedsDisplay];
	}
}

- (id)_imageForPage:(NSInteger)pageIndex type:(SMPageControlImageType)type
{
	if (pageIndex < 0 || pageIndex >= _numberOfPages) {
		return nil;
	}
	
	NSDictionary *dictionary = nil;
	switch (type) {
		case SMPageControlImageTypeCurrent:
			dictionary = _currentPageImages;
			break;
		case SMPageControlImageTypeNormal:
			dictionary = _pageImages;
			break;
		case SMPageControlImageTypeMask:
			dictionary = _pageImageMasks;
			break;
		default:
			break;
	}
	
	return dictionary[@(pageIndex)];
}

- (UIImage *)imageForPage:(NSInteger)pageIndex
{
	return [self _imageForPage:pageIndex type:SMPageControlImageTypeNormal];
}

- (UIImage *)currentImageForPage:(NSInteger)pageIndex
{
	return [self _imageForPage:pageIndex type:SMPageControlImageTypeCurrent];
}

- (UIImage *)imageMaskForPage:(NSInteger)pageIndex
{
	return [self _imageForPage:pageIndex type:SMPageControlImageTypeMask];
}

- (void)sizeToFit
{
	CGRect frame = self.frame;
	CGSize size = [self sizeForNumberOfPages:self.numberOfPages];
	size.height = MAX(size.height, MIN_HEIGHT);
	frame.size = size;
	self.frame = frame;
}

- (void)updatePageNumberForScrollView:(UIScrollView *)scrollView
{
	NSInteger page = (int)floorf(scrollView.contentOffset.x / scrollView.bounds.size.width);
	self.currentPage = page;
}

- (void)setScrollViewContentOffsetForCurrentPage:(UIScrollView *)scrollView animated:(BOOL)animated
{
	CGPoint offset = scrollView.contentOffset;
	offset.x = scrollView.bounds.size.width * self.currentPage;
	[scrollView setContentOffset:offset animated:animated];
}

#pragma mark -

- (CGImageRef)createMaskForImage:(UIImage *)image CF_RETURNS_RETAINED
{
	size_t pixelsWide = image.size.width * image.scale;
	size_t pixelsHigh = image.size.height * image.scale;
	int bitmapBytesPerRow = (pixelsWide * 1);
	CGContextRef context = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh, CGImageGetBitsPerComponent(image.CGImage), bitmapBytesPerRow, NULL, kCGImageAlphaOnly);
	CGContextTranslateCTM(context, 0.f, pixelsHigh);
	CGContextScaleCTM(context, 1.0f, -1.0f);
	
	CGContextDrawImage(context, CGRectMake(0, 0, pixelsWide, pixelsHigh), image.CGImage);
	CGImageRef maskImage = CGBitmapContextCreateImage(context);
	CGContextRelease(context);

	return maskImage;
}

- (void)_updateMeasuredIndicatorSizeWithSize:(CGSize)size
{
	_measuredIndicatorWidth = MAX(_measuredIndicatorWidth, size.width);
	_measuredIndicatorHeight = MAX(_measuredIndicatorHeight, size.height);
}

- (void)_updateMeasuredIndicatorSizes
{
	_measuredIndicatorWidth = _indicatorDiameter;
	_measuredIndicatorHeight = _indicatorDiameter;
	
	// If we're only using images, ignore the _indicatorDiameter
	if ( (self.pageIndicatorImage || self.pageIndicatorMaskImage) && self.currentPageIndicatorImage )
	{
		_measuredIndicatorWidth = 0;
		_measuredIndicatorHeight = 0;
	}
	
	if (self.pageIndicatorImage) {
		[self _updateMeasuredIndicatorSizeWithSize:self.pageIndicatorImage.size];
	}
	
	if (self.currentPageIndicatorImage) {
		[self _updateMeasuredIndicatorSizeWithSize:self.currentPageIndicatorImage.size];
	}
	
	if (self.pageIndicatorMaskImage) {
		[self _updateMeasuredIndicatorSizeWithSize:self.pageIndicatorMaskImage.size];
	}
}


#pragma mark - Tap Gesture

// We're using touchesEnded: because we want to mimick UIPageControl as close as possible
// As of iOS 6, UIPageControl still (as far as we know) does not use a tap gesture recognizer. This means that actions like
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

- (void)setPageIndicatorMaskImage:(UIImage *)pageIndicatorMaskImage
{
	if ([pageIndicatorMaskImage isEqual:_pageIndicatorMaskImage]) {
		return;
	}
	
	_pageIndicatorMaskImage = pageIndicatorMaskImage;
	
	if (_pageImageMask) {
		CGImageRelease(_pageImageMask);
	}
	
	_pageImageMask = [self createMaskForImage:_pageIndicatorMaskImage];
	
	[self _updateMeasuredIndicatorSizes];
	[self setNeedsDisplay];
}

- (NSMutableDictionary *)pageImages
{
	if (nil != _pageImages) {
		return _pageImages;
	}
	
	_pageImages = [[NSMutableDictionary alloc] init];
	return _pageImages;
}

- (NSMutableDictionary *)currentPageImages
{
	if (nil != _currentPageImages) {
		return _currentPageImages;
	}
	
	_currentPageImages = [[NSMutableDictionary alloc] init];
	return _currentPageImages;
}

- (NSMutableDictionary *)pageImageMasks
{
	if (nil != _pageImageMasks) {
		return _pageImageMasks;
	}
	
	_pageImageMasks = [[NSMutableDictionary alloc] init];
	return _pageImageMasks;
}

- (NSMutableDictionary *)cgImageMasks
{
	if (nil != _cgImageMasks) {
		return _cgImageMasks;
	}
	
	_cgImageMasks = [[NSMutableDictionary alloc] init];
	return _cgImageMasks;
}

@end
