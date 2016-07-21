//
//  PhotoCell.h
//  ScrollZoomViewTest
//
//  Created by Leave on 12/26/14.
//  Copyright (c) 2014 Leave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEZoomView.h"
@protocol LEPhotoCellMenuDelegate;


/**
 *  Base cell for display image.
 *
 *  Image displyed in innerScrollView, which manage zoom.
 */
@interface LEPhotoCell : UICollectionViewCell
@property (nonatomic, strong, nonnull) LEZoomView *innerScrollView;


// -------- menu -----------
// -------- menu is depracated -----------
/**
 *  long press this view will show a system menu (UIMenuController)
 *  enable defalut is NO.
 */
@property (nonatomic, assign) BOOL menuEnabled;
@property (nonatomic, weak, nullable) id<LEPhotoCellMenuDelegate> menuDelegate;
@property (nonatomic, strong, nullable) NSString *saveButtonTitle;
@property (nonatomic, strong, nullable) NSString *imageCopyButtonTitle;
@property (nonatomic, strong, nullable) NSString *linkCopyButtonTitle;
@property (nonatomic, strong, nullable) NSString *shareButtonTitle;

@end


@protocol LEPhotoCellMenuDelegate <NSObject>
@optional
- (void)photoCellMenuDidTapCopy:(nonnull LEPhotoCell*)photoCell;
- (void)photoCellMenuDidTapSave:(nonnull LEPhotoCell*)photoCell;
- (void)photoCellMenuDidTapShare:(nonnull LEPhotoCell*)photoCell;
- (void)photoCellMenuDidCopyLink:(nonnull LEPhotoCell*)photoCell;
@end