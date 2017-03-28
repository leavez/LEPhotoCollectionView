//
//  ZoomView.m
//  ScrollZoomViewTest
//
//  Created by Leave on 12/26/14.
//  Copyright (c) 2014 Leave. All rights reserved.
//

#import "LEZoomView.h"
#import "LEZoomView_Inner.h"

#define kDoubleToZoomPrecentageToMaxZoom 0.4
static NSString *observeContext = @"observeContext";



@interface LEZoomView()<UIScrollViewDelegate>
@property (nonatomic,assign) CGFloat fillScreenZoomScale;
@property (nonatomic,assign) CGFloat fitScreenZoomScale;
// flags
@property (nonatomic,assign) CGSize lastSize;
@end


@implementation LEZoomView
@synthesize image = _image;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
#ifdef LEPhotoCollectionView_GIF_SUPPORT
        _imageView = [[FLAnimatedImageView alloc] initWithFrame:CGRectZero];
#else
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
#endif
        [self addSubview:_imageView];
        _imageView.contentMode = UIViewContentModeCenter;
        
        self.delegate = self;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.maxZoomScale = 3;
        self.nearlyFullThreshold = 0.15;
        self.noInitailZoomIn = YES;
        
        // tap guesture
        self.enableDoubleTapToZoom = YES;
        self.tapGuestureSingle = [[UITapGestureRecognizer alloc ]initWithTarget:self action:@selector(didSingleTapSelf:)];
        self.tapGuestureSingle.numberOfTapsRequired = 1;
        [self addGestureRecognizer:self.tapGuestureSingle];
        [self.tapGuestureSingle requireGestureRecognizerToFail:self.tapGuestureDouble];
        
        [self addObserver:self forKeyPath:@"imageView.image" options:0 context:&observeContext];
#ifdef LEPhotoCollectionView_GIF_SUPPORT
        [self addObserver:self forKeyPath:@"imageView.animatedImage" options:0 context:&observeContext];
#endif
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if (context == &observeContext) {
        if ([keyPath isEqualToString:@"imageView.image"]) {
            [UIView setAnimationsEnabled:NO];
            [self setImageRelatedViewProperties:self.imageView.image.size];
            [UIView setAnimationsEnabled:YES];
        }
#ifdef LEPhotoCollectionView_GIF_SUPPORT
        else if ([keyPath isEqualToString:@"imageView.animatedImage"]) {
            [UIView setAnimationsEnabled:NO];
            [self setImageRelatedViewProperties:self.imageView.animatedImage.size];
            [UIView setAnimationsEnabled:YES];
        }
#endif
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"imageView.image" context:&observeContext];
#ifdef LEPhotoCollectionView_GIF_SUPPORT
    [self removeObserver:self forKeyPath:@"imageView.animatedImage" context:&observeContext];
#endif
}

-(void)setImage:(UIImage *)image{
    _image = image;
    self.imageView.image = image;
}
-(UIImage*)image {
    if (_image) {
        return _image;
    } else {
        return self.imageView.image;
    }
}



/// set the imageView frame and scrollview contentSize and zoomScale
/// call this method when imageView's image is changed
- (void)setImageRelatedViewProperties:(CGSize)imageSize{

    // Reset
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    self.contentSize = CGSizeMake(0, 0);


    // Setup photo frame and scrollView content size
    // 让 imageView 以 image 实际尺寸充满 contentsize
    CGRect frame;
    frame.origin = CGPointZero;
    frame.size = imageSize;
    self.imageView.frame = frame;
    self.contentSize = frame.size;

    // set max min zoom scales for image size and current view bounds
    CGSize containerSize = self.bounds.size;
    [self setMaxMinZoomScalesWithContainerSize:containerSize imageSize:imageSize];
}



- (void)setMaxMinZoomScalesWithContainerSize:(CGSize)boundsSize imageSize:(CGSize)imageSize {

    if (CGSizeEqualToSize(imageSize, CGSizeZero)) {
        return;
    }

    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    // use minimum of these to allow the image to become fully visible
    CGFloat minScale = MIN(xScale, yScale);
    minScale *= 0.9999; // 否则会有bug
    self.fitScreenZoomScale = minScale;
    self.fillScreenZoomScale = MAX(xScale, yScale) * 0.999;
    
    // Image is smaller than screen so no zooming!
    if (!self.noInitailZoomIn && xScale >= 1 && yScale >= 1) {
        minScale = 1.0;
    }
    
    // Set min/max zoom
    self.minimumZoomScale = minScale;
    self.maximumZoomScale = self.maxZoomScale;
    
    // Initial zoom，以显示全图
    self.zoomScale = minScale;
    
}





- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}



// Center the image as it becomes smaller than the size of the screen
- (void)layoutSubviews {
    // 只要在动的时候，这个方法都会被调用
    [super layoutSubviews];
    
    // center the image view
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    if (!CGRectEqualToRect(self.imageView.frame, frameToCenter)){
        self.imageView.frame = frameToCenter;
    }
    
    // refresh zoom scalse if needed
    if (!CGSizeEqualToSize(self.lastSize, self.bounds.size)) {
        self.lastSize = self.bounds.size;
        [self setImageRelatedViewProperties:self.imageView.image.size];
    }
}


// 我不知道为什么加了这两句话，缩小后 就是从中心慢慢放大，而不是从左上角闪烁。
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - setter and getter

- (void)setEnableDoubleTapToZoom:(BOOL)enableDoubleTapToZoom
{
    _enableDoubleTapToZoom = enableDoubleTapToZoom;
    
    if (enableDoubleTapToZoom) {
        if (!self.tapGuestureDouble) {
            self.tapGuestureDouble = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTapSelf:)];
            self.tapGuestureDouble.numberOfTapsRequired = 2;
            [self addGestureRecognizer: self.tapGuestureDouble];
        }
    }
    self.tapGuestureDouble.enabled = enableDoubleTapToZoom;
}


#pragma mark - delegate

-(void)didSingleTapSelf:(UITapGestureRecognizer*)tap{
    if ([self.zoomViewDelegate respondsToSelector:@selector(didSingleTapZoomView:)]) {
        [self.zoomViewDelegate didSingleTapZoomView:tap];
    }
}

- (void)didDoubleTapSelf:(UITapGestureRecognizer*)tap{
    
    
    // check if tap on the photo
    CGPoint location = [tap locationInView:self];
    if (CGRectContainsPoint(self.imageView.frame, location)) {
        // if tap the imageview
        // Zoom
        if (self.zoomScale != self.minimumZoomScale) {
            // Zoom out
            [self setZoomScale:self.minimumZoomScale animated:YES];
        } else {
            // Zoom in
            [self zoomToPoint:[tap locationInView:self.imageView]];
        }
        
        if ([self.zoomViewDelegate respondsToSelector:@selector(didDoubleTapPhotoInZoomView:)]) {
            [self.zoomViewDelegate didDoubleTapPhotoInZoomView:tap];
        }
    }
    
}


- (void)zoomToPoint:(CGPoint)point {
    CGFloat newZoomScale = [self isNearlyFullWhenScaleFit] ? 1.8 * self.minimumZoomScale : self.fillScreenZoomScale;
    CGFloat xsize = self.bounds.size.width / newZoomScale;
    CGFloat ysize = self.bounds.size.height / newZoomScale;
    [self zoomToRect:CGRectMake(point.x - xsize/2, point.y - ysize/2, xsize, ysize) animated:YES];
    
}

- (BOOL)isNearlyFullWhenScaleFit {
    CGSize size = self.image.size;
    CGFloat imageRatio = size.height / size.width;
    CGFloat containerRatio = self.bounds.size.height / self.bounds.size.width;
    return ABS(imageRatio - containerRatio) / containerRatio < self.nearlyFullThreshold;
}

@end
