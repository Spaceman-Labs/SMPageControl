# SMPageControl

UIPageControl’s Fancy One-Upping Cousin.

Designers _love_ to make beautifully custom page controls that fit in with all the wood, gradients, and inner shadows they've worked so hard perfecting. 

Who can blame them?! SMPageControl makes it dead simple to give them what they want. Even better, SMPageControl is a _drop in_ replacement for UIPageControl. It mirrors all the functions of UIPageControl, with literally no changes beyond the class name.

## Moar Customization!

SMPageControl has a variety of simple (yet powerful) areas of customization, and most all of them support the UIAppearance Proxy available to iOS 5.0 and newer.

* Indicator size
* Indicator spacing
* Indicator Alignment
* Images as indicators
* Per indicator customization
* Extensive support for UIAppearance

![Screenshot](http://spacemanlabs.com/github/SMPageControl-1.png)

## Example Usage

``` objective-c
SMPageControl *pageControl = [[SMPageControl alloc] init];
pageControl.numberOfPages = 10;
pageControl.pageIndicatorImage = [UIImage imageNamed:@"pageDot"];
pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"currentPageDot"];
[pageControl sizeToFit];
[self.view addSubview:pageControl];

```

## More Info

The original blog post for this project can be found here.


LICENSE
-------

Copyright (C) 2012 by Spaceman Labs

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.