//
//  LEGapPagingCollectionView.h
//  ScrollZoomViewTest
//
//  Created by Leave on 12/26/14.
//  Copyright (c) 2014 Leave. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  A view that contain a collectionView with flowlayout, 
 *  providing gaps between cells, which scroll like the Photo App.
 */
@interface LEGapPagingCollectionView : UIView

@property (nonatomic, strong, nonnull) UICollectionView *innerCollectionView;
@property (nonatomic, weak, nullable) id<UICollectionViewDelegate> delegate;
@property (nonatomic, weak, nullable) id<UICollectionViewDataSource> datasource;

/// the gap between pages, default is 40.
@property (nonatomic, assign) CGFloat itemsGap;
@property (nonatomic, readonly) NSInteger currentPage;


/**
 *  shortcut for `[self.innerCollectionView reloadData]`
 */
- (void)reloadData;

/**
 *  Scroll to page at index
 *  @return if pageIndex is invalid, return NO.
 */
- (BOOL)scrollToPage:(NSInteger)pageIndex animated:(BOOL)animated;


/**
 *  The deviation of cell's center from collectionView's center (in CollectionView's superView coodinated).
 *  `width/2` return 100%.  x < 0 means the cell is on the right side.
 *
 *  cell 中心距离理想中心的偏离程度，偏离 width/2 为 100%. 值为负代表 cell 在页面中心的右边.
 *
 *  -----------------------------------
 *     [         x         ]
 *      [ collection view ]
 *             [ cell    x        ]
 *
 *               |-------|             (this length is what we want)
 *  -----------------------------------
 *
 *  @return value between  -1, 1
 */
- (CGFloat)currentPageDeviationRatio;



@end


