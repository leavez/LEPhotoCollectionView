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


@protocol DelageteImageViewDelegate <NSObject>
- (void)delegateImageViewdidSetImage:(UIImage *)image;
@end

@interface DelegateImageView : UIImageView
@property (nonatomic,weak) id<DelageteImageViewDelegate> delegate;
@end

@implementation DelegateImageView
// override
- (void)setImage:(UIImage *)image {
    [super setImage:image];
    if ([self.delegate respondsToSelector:@selector(delegateImageViewdidSetImage:)]) {
        [self.delegate delegateImageViewdidSetImage:image];
    }
}
@end




@interface LEZoomView()<UIScrollViewDelegate,DelageteImageViewDelegate>
@property (nonatomic,assign) CGFloat fillScreenZoomScale;
@end


@implementation LEZoomView
@synthesize image = _image;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        DelegateImageView *imageView = [[DelegateImageView alloc] initWithFrame:CGRectZero];
        imageView.delegate = self;
        _imageView = imageView;
        [self addSubview:_imageView];
        _imageView.contentMode = UIViewContentModeCenter;
        
        self.delegate = self;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.maxZoomScale = 3;
        self.noInitailZoomIn = YES;
        
        // tap guesture
        self.enableDoubleTapToZoom = YES;
        self.tapGuestureSingle = [[UITapGestureRecognizer alloc ]initWithTarget:self action:@selector(didSingleTapSelf:)];
        self.tapGuestureSingle.numberOfTapsRequired = 1;
        [self addGestureRecognizer:self.tapGuestureSingle];
        [self.tapGuestureSingle requireGestureRecognizerToFail:self.tapGuestureDouble];
    }
    return self;
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

- (void)delegateImageViewdidSetImage:(UIImage *)image
{
    [UIView setAnimationsEnabled:NO];
    [self setImageFrameAndContentSize:image];
    [UIView setAnimationsEnabled:YES];
}



// called when imageView's image is changed
- (void)setImageFrameAndContentSize:(UIImage*)image{
    
    // Reset
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    self.contentSize = CGSizeMake(0, 0);
    
    // Setup photo frame
    // 让image以原始大小充满contentsize
    CGRect frame;
    frame.origin = CGPointZero;
    frame.size = image.size;
    self.imageView.frame = frame;
    self.contentSize = frame.size;
    
    [self setMaxMinZoomScalesForCurrentBounds];
}


- (void)setMaxMinZoomScalesForCurrentBounds {
    
    // Reset
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    
    // Bail if no image
    if (!self.image && !self.imageView.image){
        return;
    }
    
    // Reset position
    self.imageView.frame = CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height);
    
    // Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = self.imageView.image.size;
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    // use minimum of these to allow the image to become fully visible
    CGFloat minScale = MIN(xScale, yScale);
    minScale *= 0.9999; // 否则会有bug
    self.fillScreenZoomScale = MAX(xScale, yScale) * 0.999;
    
    // Image is smaller than screen so no zooming!
    if (!self.noInitailZoomIn && xScale >= 1 && yScale >= 1) {
        minScale = 1.0;
    }
    
    // give Max
    CGFloat maxScale = self.maxZoomScale;
    
    // Set min/max zoom
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    
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
    
    // Center
    if (!CGRectEqualToRect(self.imageView.frame, frameToCenter)){
        self.imageView.frame = frameToCenter;
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
    //            CGFloat newZoomScale = self.maximumZoomScale + (self.minimumZoomScale - self.maximumZoomScale) *kDoubleToZoomPrecentageToMaxZoom;
    CGFloat newZoomScale = self.fillScreenZoomScale;
    CGFloat xsize = self.bounds.size.width / newZoomScale;
    CGFloat ysize = self.bounds.size.height / newZoomScale;
    [self zoomToRect:CGRectMake(point.x - xsize/2, point.y - ysize/2, xsize, ysize) animated:YES];

}
@end
