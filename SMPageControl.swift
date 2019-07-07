//
//  SMPageControl.h
//  SMPageControl
//
//  Created by Jerry Jones on 10/13/12.
//  Updated to Swift by Noor ul Ain Ali on 7/1/19.
//
//  Copyright (c) 2012 Spaceman Labs. All rights reserved.
//

import UIKit

@objc enum SMPageControlHorizontalAlignment: Int {
    case left = 0
    case center
    case right
}

@objc enum SMPageControlVerticalAlignment: Int {
    case top = 1
    case middle
    case bottom
}

@objc enum SMPageControlTap: Int {
    case tapBehaviorStep = 1
    case tapBehaviorJump
}

enum SMPageControlImageType: Int {
    case typeNormal = 1
    case typeCurrent
    case typeMask
}

enum SMPageControlStyle: Int {
    case defaultStyleClassic = 0
    case defaultStyleModern
}

@objc class SMPageControl : UIControl {
    
    @objc var numberOfPages: NSInteger = 0 {
        didSet {
            self.accessibilityPageControl.numberOfPages = numberOfPages
            if numberOfPages != 0 {
                self.currentPage = 0
            }
            if self.responds(to: #selector(UIView.invalidateIntrinsicContentSize)) {
                self.invalidateIntrinsicContentSize()
            }
            self.updateAccessibilityValue()
            self.setNeedsDisplay()
        }
    }
    @objc var currentPage: NSInteger = -1 {
        willSet(newValue) {
            self.currentPage = min(max(0, newValue), numberOfPages - 1)
        }
        didSet {
            self.setCurrentPage(currentPage, sendEvent: false, canDefer: false)
        }
    }
    
    @objc var indicatorMargin: CGFloat = 10.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @objc var indicatorDiameter: CGFloat = 6.0 {
        willSet(newValue) {
            // Absolute minimum height of the control is the indicator diameter
            if minHeight < indicatorDiameter {
                self.minHeight = indicatorDiameter
            }
            
            self.updateMeasuredIndicatorSizes()
            self.setNeedsDisplay()
        }
    }
    
    @objc var minHeight: CGFloat = 36.0 {
        willSet(newValue) {
            if minHeight < indicatorDiameter {
                minHeight = indicatorDiameter
            } else {
                minHeight = newValue
            }
            if self.responds(to: #selector(UIView.invalidateIntrinsicContentSize)) {
                self.invalidateIntrinsicContentSize()
            }
            self.setNeedsLayout()
        }
    }
    @objc var alignment: SMPageControlHorizontalAlignment = .center
    @objc var verticalAlignment: SMPageControlVerticalAlignment = .middle
    @objc var pageIndicatorImage: UIImage? = nil {
        didSet {
            self.updateMeasuredIndicatorSizes()
            self.setNeedsDisplay()
        }
    }
    @objc var pageIndicatorMaskImage: UIImage? = nil {
        didSet {
            if let image = pageIndicatorMaskImage {
                pageImageMask = self.createMaskForImage(image)
            }
            self.updateMeasuredIndicatorSizes()
            self.setNeedsDisplay()
        }
    }
    @objc var pageIndicatorTintColor: UIColor? = nil
    @objc var currentPageIndicatorImage: UIImage? = nil {
        didSet {
            self.updateMeasuredIndicatorSizes()
            self.setNeedsDisplay()
        }
    }
    @objc var currentPageIndicatorTintColor: UIColor? = nil
    @objc var hidesForSinglePage: Bool = false
    @objc var tapBehavior: SMPageControlTap = .tapBehaviorStep
    var pageNames = NSMutableDictionary()
    var pageImages : [Int: UIImage] = [:]
    var currentPageImages : [Int: UIImage] = [:]
    var pageImageMasks : [Int: UIImage] = [:]
    var cgImageMasks : [Int: CGImage] = [:]
    var pageRects = NSMutableArray()
    // Page Control used for stealing page number localizations for accessibility labels
    var accessibilityPageControl: UIPageControl!
    private var displayedPage: NSInteger?
    private var measuredIndicatorWidth: CGFloat = 0.0
    private var measuredIndicatorHeight: CGFloat = 0.0
    private var pageImageMask: CGImage?
    
    private let DEFAULTINDICATORWIDTH: CGFloat = 6.0
    private let DEFAULTINDICATORMARGIN: CGFloat = 10.0
    private let DEFAULTMINHEIGHT: CGFloat = 36.0
    private let DEFAULTINDICATORWIDTHLARGE: CGFloat = 7.0
    private let DEFAULTINDICATORMARGINLARGE: CGFloat = 9.0
    private let DEFAULTMINHEIGHTLARGE: CGFloat = 36.0
    
    @objc func rectForPageIndicator( pageIndex: NSInteger) -> CGRect {
        if pageIndex < 0 || pageIndex >= numberOfPages {
            return CGRect.zero
        }
        
        let left: CGFloat = self.leftOffset()
        let size: CGSize = self.sizeForNumberOfPages(pageIndex + 1)
        let rect: CGRect = CGRect(x: left + size.width - measuredIndicatorWidth, y: 0.0, width: measuredIndicatorWidth, height: measuredIndicatorWidth)
        return rect
    }
    
    @objc func sizeForNumberOfPages(_ pageCount: NSInteger) -> CGSize {
        let marginSpace: CGFloat = CGFloat(max(0, pageCount - 1)) * indicatorMargin
        let indicatorSpace: CGFloat = CGFloat(pageCount) * measuredIndicatorWidth
        let size: CGSize = CGSize(width: marginSpace + indicatorSpace, height: measuredIndicatorHeight)
        
        return size
    }
    
    @objc func setImage(_ image: UIImage, forPage pageIndex: NSInteger) {
        self.setImage(image, forPage:pageIndex, type: SMPageControlImageType.typeNormal)
        self.updateMeasuredIndicatorSizes()
    }
    
    @objc func setCurrentImage(_ image: UIImage?, forPage pageIndex: NSInteger) {
        self.setImage(image, forPage:pageIndex, type: SMPageControlImageType.typeCurrent)
        self.updateMeasuredIndicatorSizes()
    }
    
    @objc func setImageMask(_ image: UIImage?, forPage pageIndex: NSInteger) {
        self.setImage(image, forPage:pageIndex, type:SMPageControlImageType.typeMask)
        if image == nil {
            self.cgImageMasks[pageIndex] = nil
            return
        }
        if let mImage = image, let maskImage: CGImage = self.createMaskForImage(mImage) {
            self.cgImageMasks[pageIndex] = maskImage
            self.updateMeasuredIndicatorSizeWithSize(mImage.size)
            self.setNeedsDisplay()
        }
    }
    
    @objc func imageForPage(_ pageIndex: NSInteger) -> UIImage? {
        return self.imageForPage(pageIndex, type: SMPageControlImageType.typeNormal)
    }
    
    @objc func currentImageForPage(_ pageIndex: NSInteger) -> UIImage? {
        return self.imageForPage(pageIndex, type: SMPageControlImageType.typeCurrent)
    }
    
    @objc func imageMaskForPage(_ pageIndex: NSInteger) -> UIImage? {
        return self.imageForPage(pageIndex, type: SMPageControlImageType.typeMask)
    }
    
    @objc func updatePageNumberForScrollView(_ scrollView: UIScrollView) {
        let page: Int = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        self.currentPage = page
    }
    
    @objc func setScrollViewContentOffsetForCurrentPage(_ scrollView: UIScrollView, animated: Bool) {
        var offset: CGPoint = scrollView.contentOffset
        offset.x = scrollView.bounds.size.width * CGFloat(self.currentPage)
        scrollView.setContentOffset(offset, animated:animated)
    }
    
    // MARK: - UIAccessibility
    
    // SMPageControl mirrors UIPageControl's standard accessibility functionality by default.
    // Basically, the accessibility label is set to "[current page index + 1] of [page count]".
    
    // SMPageControl extends UIPageControl's functionality by allowing you to name specific pages. This is especially useful when using
    // the per-page indicator images, and allows you to provide more context to the user.
    
    @objc func setName(_ name: String, forPage pageIndex: NSInteger) {
        if pageIndex < 0 || pageIndex >= numberOfPages {
            return
        }
        self.pageNames[pageIndex] = name
    }
    
    @objc func nameForPage(_ pageIndex: NSInteger) -> String? {
        if pageIndex < 0 || pageIndex >= numberOfPages {
            return nil
        }
        return self.pageNames.object(forKey: pageIndex) as? String
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            self.renderPages(context, rect: rect)
        }
    }
    
    // MARK: - Private
    
    private func initialize() {
        tapBehavior = SMPageControlTap.tapBehaviorStep
        self.backgroundColor = UIColor.clear
        self.setStyleWithDefaults(defaultStyle: SMPageControlStyle.defaultStyleClassic)
        alignment = SMPageControlHorizontalAlignment.center
        verticalAlignment = SMPageControlVerticalAlignment.middle
        self.isAccessibilityElement = true
        self.accessibilityTraits = UIAccessibilityTraits.updatesFrequently
        self.accessibilityPageControl = UIPageControl()
        self.contentMode = UIView.ContentMode.redraw
        numberOfPages = 0
    }
    
    private func renderPages(_ context: CGContext, rect: CGRect) {
        let pageRects: NSMutableArray = NSMutableArray(capacity: self.numberOfPages)
        
        if numberOfPages < 2 && hidesForSinglePage {
            return
        }
        
        let left: CGFloat = self.leftOffset()
        
        var xOffset: CGFloat = left
        var yOffset: CGFloat = 0.0
        var fillColor: UIColor! = nil
        var image: UIImage! = nil
        var maskingImage: CGImage? = nil
        var maskSize: CGSize = CGSize.zero
        
        for indexNumber in 0..<numberOfPages {
            if indexNumber == displayedPage {
                fillColor = currentPageIndicatorTintColor ?? UIColor.white
                image = currentPageImages[indexNumber]
                if image == nil {
                    image = currentPageIndicatorImage
                }
            } else {
                fillColor = pageIndicatorTintColor ?? UIColor.white.withAlphaComponent(0.3)
                image = pageImages[indexNumber]
                if image == nil {
                    image = pageIndicatorImage
                }
            }
            
            // If no finished images have been set, try a masking image
            if image == nil, let cgImage = cgImageMasks[indexNumber] {
                maskingImage = cgImage
                let originalImage:UIImage! = pageImageMasks[indexNumber]
                maskSize = originalImage.size
                
                // If no per page mask is set, try for a global page mask!
                if nil == maskingImage {
                    maskingImage = pageImageMask
                    maskSize = pageIndicatorMaskImage?.size ?? CGSize.zero
                }
            }
            
            fillColor.set()
            var indicatorRect: CGRect = .zero
            if (image != nil) {
                yOffset = self.topOffsetForHeight(height: image.size.height, rect:rect)
                let centeredXOffset: CGFloat = xOffset + ((measuredIndicatorWidth - image.size.width)/2)
                image.draw(at: CGPoint(x: centeredXOffset, y: yOffset))
                indicatorRect = CGRect(x: centeredXOffset, y: yOffset, width: image.size.width, height: image.size.height)
            } else if (maskingImage != nil) {
                yOffset = self.topOffsetForHeight(height: maskSize.height, rect:rect)
                let centeredXOffset:CGFloat = xOffset + CGFloat(floorf(Float((measuredIndicatorWidth - maskSize.width) / 2.0)))
                indicatorRect = CGRect(x: centeredXOffset, y: yOffset, width: maskSize.width, height: maskSize.height)
                if let maskImage = maskingImage {
                    context.draw(maskImage, in: indicatorRect)
                }
            } else {
                yOffset = self.topOffsetForHeight(height: indicatorDiameter, rect:rect)
                let centeredXOffset: CGFloat = xOffset + CGFloat(floorf(Float((measuredIndicatorWidth - indicatorDiameter) / 2.0)))
                indicatorRect = CGRect(x: centeredXOffset, y: yOffset, width: indicatorDiameter, height: indicatorDiameter)
                context.fillEllipse(in: indicatorRect)
            }
            
            pageRects.add(NSValue(cgRect: indicatorRect))
            maskingImage = nil
            xOffset += measuredIndicatorWidth + indicatorMargin
        }
        
        self.pageRects = pageRects
        
    }
    
    private func leftOffset() -> CGFloat {
        let rect: CGRect = self.bounds
        let size: CGSize = self.sizeForNumberOfPages(self.numberOfPages)
        var left: CGFloat = 0.0
        switch alignment {
        case .center:
            left = CGFloat(ceilf(Float(rect.midX - (size.width / 2.0))))
        case .right:
            left = rect.maxX - size.width
        default:
            ()
        }
        return left
    }
    
    private func topOffsetForHeight(height:CGFloat, rect:CGRect) -> CGFloat {
        var top:CGFloat = 0.0
        switch verticalAlignment {
        case .middle:
            top = rect.midY - (height / 2.0)
        case .bottom:
            top = rect.maxY - height
        default:
            ()
        }
        return top
    }
    
    func setImage(_ image: UIImage!, forPage pageIndex: Int, type: SMPageControlImageType) {
        if pageIndex < 0 || pageIndex >= numberOfPages {
            return
        }
        switch type {
        case SMPageControlImageType.typeCurrent:
            if let dictImage = image {
                self.currentPageImages[pageIndex] = dictImage
            } else {
                self.currentPageImages[pageIndex] = nil
            }
        case SMPageControlImageType.typeNormal:
            if let dictImage = image {
                self.pageImages[pageIndex] = dictImage
            } else {
                self.pageImages[pageIndex] = nil
            }
        case SMPageControlImageType.typeMask:
            if let dictImage = image {
                self.pageImageMasks[pageIndex] = dictImage
            } else {
                self.pageImageMasks[pageIndex] = nil
            }
        }
    }
    
    func imageForPage(_ pageIndex:Int, type:SMPageControlImageType) -> UIImage? {
        if pageIndex < 0 || pageIndex >= numberOfPages {
            return nil
        }
        var dictionary: [Int: UIImage] = [:]
        switch (type) {
        case SMPageControlImageType.typeCurrent:
            dictionary = currentPageImages
        case SMPageControlImageType.typeNormal:
            dictionary = pageImages
        case SMPageControlImageType.typeMask:
            dictionary = pageImageMasks
        }
        return dictionary[pageIndex]
    }
    
    override func sizeThatFits(_ size:CGSize) -> CGSize {
        var sizeThatFits:CGSize = self.sizeForNumberOfPages(self.numberOfPages)
        sizeThatFits.height = max(sizeThatFits.height, minHeight)
        return sizeThatFits
    }
    
    func intrinsicContentSize() -> CGSize {
        if numberOfPages < 1 || (numberOfPages < 2 && hidesForSinglePage) {
            return CGSize(width: UIView.noIntrinsicMetric, height: 0.0)
        }
        let intrinsicContentSize:CGSize = CGSize(width: UIView.noIntrinsicMetric, height:  max(measuredIndicatorHeight, minHeight))
        return intrinsicContentSize
    }
    
    func setStyleWithDefaults(defaultStyle:SMPageControlStyle) {
        switch (defaultStyle) {
        case .defaultStyleModern:
            self.indicatorDiameter = DEFAULTINDICATORWIDTHLARGE
            self.indicatorMargin = DEFAULTINDICATORMARGINLARGE
            self.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.2)
            self.minHeight = DEFAULTMINHEIGHTLARGE
        default:
            self.indicatorDiameter = DEFAULTINDICATORWIDTH
            self.indicatorMargin = DEFAULTINDICATORMARGIN
            self.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
            self.minHeight = DEFAULTMINHEIGHT
        }
    }
    
    // MARK: -
    
    func createMaskForImage(_ image: UIImage) -> CGImage? {
        let pixelsWide: size_t = size_t(image.size.width * image.scale)
        let pixelsHigh: size_t = size_t(image.size.height * image.scale)
        let bitmapBytesPerRow: size_t = (pixelsWide * 1)
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        
        if let cgImage = image.cgImage, let context = CGContext(data: nil,
                                                                width: pixelsWide,
                                                                height: pixelsHigh,
                                                                bitsPerComponent: cgImage.bitsPerComponent,
                                                                bytesPerRow: bitmapBytesPerRow,
                                                                space: colorSpace,
                                                                bitmapInfo: CGImageAlphaInfo.alphaOnly.rawValue)
        {
            context.translateBy(x: 0.0, y: CGFloat(pixelsHigh))
            context.scaleBy(x: 1.0, y: -1.0)
            context.draw(cgImage, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(pixelsWide), height: CGFloat(pixelsHigh)))
            return context.makeImage()
        }
        return nil
    }
    
    func updateMeasuredIndicatorSizeWithSize(_ size:CGSize) {
        measuredIndicatorWidth = max(measuredIndicatorWidth, size.width)
        measuredIndicatorHeight = max(measuredIndicatorHeight, size.height)
    }
    
    func updateMeasuredIndicatorSizes() {
        measuredIndicatorWidth = indicatorDiameter
        measuredIndicatorHeight = indicatorDiameter
        
        // If we're only using images, ignore the indicatorDiameter
        if  (self.pageIndicatorImage != nil || self.pageIndicatorMaskImage != nil && self.currentPageIndicatorImage != nil)
        {
            measuredIndicatorWidth = 0
            measuredIndicatorHeight = 0
        }
        
        if (self.pageIndicatorImage != nil) {
            self.updateMeasuredIndicatorSizeWithSize(self.pageIndicatorImage?.size ?? CGSize.zero)
        }
        
        if (self.currentPageIndicatorImage != nil) {
            self.updateMeasuredIndicatorSizeWithSize(self.currentPageIndicatorImage?.size ?? CGSize.zero)
        }
        
        if (self.pageIndicatorMaskImage != nil) {
            self.updateMeasuredIndicatorSizeWithSize(self.pageIndicatorMaskImage?.size ?? CGSize.zero)
        }
        
        if self.responds(to: #selector(UIView.invalidateIntrinsicContentSize)) {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    
    // MARK: - Tap Gesture
    
    // We're using touchesEnded: because we want to mimick UIPageControl as close as possible
    // As of iOS 6, UIPageControl still (as far as we know) does not use a tap gesture recognizer. This means that actions like
    // touching down, sliding around, and releasing, still results in the page incrementing or decrementing.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let touch: UITouch = touches.first {
            let point: CGPoint = touch.location(in: self)
            
            if SMPageControlTap.tapBehaviorJump == self.tapBehavior {
                
                var tappedIndicatorIndex:Int = NSNotFound
                self.pageRects.enumerateObjects { (value, index, stop) in
                    if let rectValue = value as? NSValue {
                        let indicatorRect = rectValue.cgRectValue
                        if indicatorRect.contains(point) {
                            tappedIndicatorIndex = index
                            stop.pointee = true
                        }
                    }
                }
                if NSNotFound != tappedIndicatorIndex {
                    self.setCurrentPage(tappedIndicatorIndex, sendEvent: true, canDefer: true)
                    return
                }
            }
            
            let size: CGSize = self.sizeForNumberOfPages(self.numberOfPages)
            let left: CGFloat = self.leftOffset()
            let middle: CGFloat = left + (size.width / 2.0)
            if point.x < middle {
                self.currentPage = self.currentPage - 1
                self.setCurrentPage(self.currentPage, sendEvent: true, canDefer: true)
            } else {
                self.currentPage = self.currentPage + 1
                self.setCurrentPage(self.currentPage, sendEvent: true, canDefer: true)
            }
        }
    }
    
    
    // MARK: - Accessors
    
    func setFrame(frame:CGRect) {
        super.frame = frame
        self.setNeedsDisplay()
    }
    
    func setCurrentPage(_ currentPage: Int, sendEvent: Bool, canDefer: Bool) {
        self.accessibilityPageControl.currentPage = self.currentPage
        self.updateAccessibilityValue()
        if !canDefer {
            displayedPage = self.currentPage
            self.setNeedsDisplay()
        }
        if sendEvent {
            self.sendActions(for: UIControl.Event.valueChanged)
        }
    }
    
    func updateAccessibilityValue() {
        if let pageName = self.nameForPage(self.currentPage), let accessibilityValue = self.accessibilityPageControl.accessibilityValue {
            self.accessibilityValue = String(format:"%@ - %@", pageName, accessibilityValue)
        } else {
            self.accessibilityValue = accessibilityValue
        }
    }
    
}
