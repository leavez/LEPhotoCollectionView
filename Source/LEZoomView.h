//
//  ZoomView.h
//  ScrollZoomViewTest
//
//  Created by Leave on 12/26/14.
//  Copyright (c) 2014 Leave. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LEZoomViewDelegate <NSObject>
- (void)didSingleTapZoomView:(UITapGestureRecognizer*)tap;
@optional
- (void)didDoubleTapPhotoInZoomView:(UITapGestureRecognizer*)tap;
@end


/**
 *  A ScrollView that contain an imageView.
 *  It manages the zoom things.
 */
@interface LEZoomView : UIScrollView

/// just set `image`, no need to set `imageView.image`
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, strong, readonly) UIImageView* imageView;
@property (nonatomic, weak) id<LEZoomViewDelegate> zoomViewDelegate;
/// default is YES
@property (nonatomic, assign) BOOL enableDoubleTapToZoom;
/// default is 3
@property (nonatomic, assign) CGFloat maxZoomScale;
/// valid when image is smaller than the view.
/// NO means scale image to fit the view, and YES means just show the original size
@property (nonatomic, assign) BOOL noInitailZoomIn;
/// ABS(image_ratio - container_ratio) / container_ratio.
/// if the value is less than this threshold, the image is considered nearly fullscreen.
@property (nonatomic, assign) CGFloat nearlyFullThreshold;



- (void)zoomToPoint:(CGPoint)point ;
- (BOOL)isNearlyFullWhenScaleFit;

// for subclass
- (void)didDoubleTapSelf:(UITapGestureRecognizer*)tap;
- (void)didSingleTapSelf:(UITapGestureRecognizer*)tap;

@end
