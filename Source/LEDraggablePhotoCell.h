//
//  LEDraggablePhotoCell.h
//  LEPhotoCollectionView
//
//  Created by Gao on 7/21/16.
//  Copyright © 2016 leave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEPhotoCell.h"

@class LEDraggablePhotoCell;
@protocol LEDraggablePhotoCellDelegate <NSObject>

- (nullable UIView *)draggableCellWantContainerBackgroundView:(nonnull LEDraggablePhotoCell *)cell;

@optional
- (void)draggableCellWillBeginDragging:(nonnull LEDraggablePhotoCell *)cell;
- (void)draggableCellIsDragging:(nonnull LEDraggablePhotoCell *)cell translation:(CGPoint)translation percentage:(CGFloat)percentage;
- (void)draggableCellWillMoveAway:(nonnull LEDraggablePhotoCell *)cell;
- (void)draggableCellWillMoveBack:(nonnull LEDraggablePhotoCell *)cell;
- (void)draggableCellDidMoveAway:(nonnull LEDraggablePhotoCell *)cell;
- (void)draggableCellDidMoveBack:(nonnull LEDraggablePhotoCell *)cell;

- (BOOL)draggableCellShouldMoveAway:(nonnull LEDraggablePhotoCell *)cell velocity:(CGPoint)velocity translation:(CGPoint)translation;
@end


/**
 *  A cell that can drag to dismiss
 *  `collectionView` is required to be set before dragging. You could set it in `dequeueReusabeCellForIndexPath`
 */
@interface LEDraggablePhotoCell : LEPhotoCell

@property (nonatomic, weak, nullable) id<LEDraggablePhotoCellDelegate> dragDelegate;
@property (nonatomic, nonnull) UIPanGestureRecognizer *panGesture;

/// `collectionView` is required to be set before dragging.
/// You could set it in `dequeueReusabeCellForIndexPath`
@property (nonatomic, weak, nullable) UIView *collectionView;

/// show shadow for image when drag began. defalut is YES
@property (nonatomic, assign) BOOL useShadowForImage;

- (nonnull instancetype)initWithCoder:(nullable NSCoder *)aDecoder NS_UNAVAILABLE;

@end
