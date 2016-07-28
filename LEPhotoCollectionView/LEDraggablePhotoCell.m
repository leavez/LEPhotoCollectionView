//
//  LEDraggablePhotoCell.m
//  LEPhotoCollectionView
//
//  Created by Gao on 7/21/16.
//  Copyright © 2016 leave. All rights reserved.
//

#import "LEDraggablePhotoCell.h"

@interface LEDraggablePhotoCell ()<UIGestureRecognizerDelegate>
@property (nonatomic) CGAffineTransform originalTransform;
@end



@implementation LEDraggablePhotoCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
        [self addGestureRecognizer:_panGesture];
        _panGesture.delegate = self;
        self.userInteractionEnabled = YES;
        //
        UIView *imageView = self.innerScrollView.imageView;
        imageView.layer.shadowColor = [[UIColor blackColor] CGColor];
        imageView.layer.shadowRadius = 10;
        imageView.layer.shadowOpacity = 0;
        imageView.layer.shadowPath = nil;
        _useShadowForImage = YES;
    }
    return self;
}


#pragma mark -

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGesture) {
        CGPoint velocity = [self.panGesture velocityInView:self];
        return !( ABS(velocity.x) > 1 * ABS(velocity.y) ) ;
    } else {
        return [super gestureRecognizerShouldBegin:gestureRecognizer];
    }
}

- (void)didPan:(UIPanGestureRecognizer *) pan {
    if (!self.collectionView) {
        return;
    }

    UIView *view = self.collectionView;
    CGPoint translation = [pan translationInView:view];

    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            self.originalTransform = self.transform;
            if ([self.dragDelegate respondsToSelector:@selector(draggableCellWillBeginDragging:)]) {
                [self.dragDelegate draggableCellWillBeginDragging:self];
            }
            [self showImageShadow:YES];
        } break;

        case UIGestureRecognizerStateChanged: {
            // move cell
            // 制造一点不跟手的效果
            [self animateView:^{
                self.transform = CGAffineTransformTranslate(self.originalTransform, 0, translation.y);
            }];

            // change background
            CGFloat percentage = [self transformMoveToPercentage:translation];
            CGFloat alpha = 1 - percentage;
            UIView *backgroundView = self.containerBackgroundView;
            backgroundView.alpha = alpha;

            if ([self.dragDelegate respondsToSelector:@selector(draggableCellIsDragging:translation:percentage:)]) {
                [self.dragDelegate draggableCellIsDragging:self translation:translation percentage:percentage];
            }
        } break;

        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            CGPoint velocity = [pan velocityInView:view];
            if ([self shouldExit:translation velocity:velocity]) {
                // go away
                if ([self.dragDelegate respondsToSelector:@selector(draggableCellWillMoveAway:)]) {
                    return [self.dragDelegate draggableCellWillMoveAway:self];
                }
                [self moveAwayAnimatedWithPresentTranslation:translation Velocity:velocity Completion:^{
                    if ([self.dragDelegate respondsToSelector:@selector(draggableCellDidMoveAway:)]) {
                        return [self.dragDelegate draggableCellDidMoveAway:self];
                    }
                    [self showImageShadow:NO];
                }];

            } else {
                // move back
                [self showImageShadow:NO];
                if ([self.dragDelegate respondsToSelector:@selector(draggableCellWillMoveBack:)]) {
                    return [self.dragDelegate draggableCellWillMoveBack:self];
                }
                [self moveBackAnimatedWithPresentTranslation:translation Velocity:velocity Completion:^{
                    if ([self.dragDelegate respondsToSelector:@selector(draggableCellDidMoveBack:)]) {
                        return [self.dragDelegate draggableCellDidMoveBack:self];
                    }
                }];
            }
        } break;

        default: break;
    }
}



#pragma mark - inner

- (BOOL)shouldExit:(CGPoint)translation velocity:(CGPoint)velocity {
    if ([self.dragDelegate respondsToSelector:@selector(draggableCellShouldMoveAway:velocity:translation:)]) {
        return [self.dragDelegate draggableCellShouldMoveAway:self velocity:velocity translation:translation];
    } else {
        // default setting
        return !(ABS(velocity.y) < 500 && ABS(translation.y) < 130);
    }
}

- (void)moveAwayAnimatedWithPresentTranslation:(CGPoint)translation
                                      Velocity:(CGPoint)velocity
                                    Completion:(void(^)())completion {

    NSTimeInterval duration = 0.27;
    if (ABS(velocity.y) < 200 ){
        duration += 0.1;
    }
    CGFloat adjustAlpha = 1;
    CGFloat shadowDuration = 0.35;
    UIView *backgroundView = self.containerBackgroundView;

    // cell
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGFloat heightDelta = (translation.y > 0 ? 1 : -1 ) * self.containerViewHeight;
        CGAffineTransform transform = self.transform;
        transform = CGAffineTransformTranslate(transform, 0, heightDelta);
        self.transform = transform;
        self.alpha = adjustAlpha;
    } completion:nil];

    // background
    [UIView animateWithDuration:shadowDuration animations:^{
        backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        self.alpha = 1;
        if (completion) {
            completion();
        }
    }];
}

- (void)moveBackAnimatedWithPresentTranslation:(CGPoint)translation
                                      Velocity:(CGPoint)velocity
                                    Completion:(void(^)())completion {

    [UIView animateWithDuration:0.2 animations:^{
        self.transform = CGAffineTransformIdentity;
        UIView *backgroundView = self.containerBackgroundView;
        backgroundView.alpha = 1;
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (CGFloat)containerViewHeight {
    if (self.collectionView) {
        return self.collectionView.bounds.size.height;
    } else {
        return [UIApplication sharedApplication].keyWindow.bounds.size.height;
    }
}

- (void)animateView:(void(^)())block {
    NSTimeInterval duration = 0.1115;
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:block completion:nil];
}

- (void)showImageShadow:(BOOL)shown {
    if (!self.useShadowForImage) {
        return;
    }

    // refresh path
    UIView *imageView = self.innerScrollView.imageView;
    imageView.layer.shadowPath = [UIBezierPath bezierPathWithRect:imageView.bounds].CGPath;

    //
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    CGFloat maxAlpha = 0.3;
    CGFloat toValue = shown ? maxAlpha : 0;
    anim.fromValue = @(imageView.layer.shadowOpacity);
    anim.toValue = @(toValue);
    anim.duration = 0.3;
    [imageView.layer addAnimation:anim forKey:@"shadowOpacity"];
    imageView.layer.shadowOpacity = toValue;
}

- (CGFloat)transformMoveToPercentage:(CGPoint)translation {
    CGFloat y = translation.y;
    return ABS(y) / [self containerViewHeight];
}

- (UIView *)containerBackgroundView {
    if ([self.dragDelegate respondsToSelector:@selector(draggableCellWantContainerBackgroundView:)]) {
        return [self.dragDelegate draggableCellWantContainerBackgroundView:self];
    }
    return nil;
}

@end
