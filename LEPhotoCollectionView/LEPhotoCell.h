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
@property (nonatomic,strong) LEZoomView *innerScrollView;


// -------- menu -----------
/**
 *  long press this view will show a system menu (UIMenuController)
 *  enable defalut is NO.
 */
@property (nonatomic, assign) BOOL menuEnabled;
@property (nonatomic, weak) id<LEPhotoCellMenuDelegate> menuDelegate;
@property (nonatomic, copy) NSString *saveButtonTitle;
@property (nonatomic, copy) NSString *imageCopyButtonTitle;
@property (nonatomic, copy) NSString *linkCopyButtonTitle;
@property (nonatomic, copy) NSString *shareButtonTitle;

@end


@protocol LEPhotoCellMenuDelegate <NSObject>
@optional
- (void)photoCellMenuDidTapCopy:(LEPhotoCell*)photoCell;
- (void)photoCellMenuDidTapSave:(LEPhotoCell*)photoCell;
- (void)photoCellMenuDidTapShare:(LEPhotoCell*)photoCell;
- (void)photoCellMenuDidCopyLink:(LEPhotoCell*)photoCell;
@end