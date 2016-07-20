//
//  LEGapPagingCollectionView.m
//  ScrollZoomViewTest
//
//  Created by Leave on 12/26/14.
//  Copyright (c) 2014 Leave. All rights reserved.
//


#import "LEGapPagingCollectionView.h"

@interface PhotoBrowserCollectionView : UICollectionView
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, assign) CGFloat itemsGap;
@end

@implementation PhotoBrowserCollectionView

-(instancetype)initWithFrame:(CGRect)frame itemsGap:(CGFloat)itemGap {
    
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    self = [super initWithFrame:frame collectionViewLayout: layout] ;
    if (self) {
        self.itemsGap = itemGap;

        self.flowLayout = layout;
        self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.flowLayout.sectionInset = UIEdgeInsetsMake(0, itemGap/2, 0, itemGap/2);
        self.flowLayout.minimumInteritemSpacing = itemGap;
        self.flowLayout.minimumLineSpacing = itemGap;

        self.pagingEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    return  self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.flowLayout.itemSize = CGSizeMake(frame.size.width - self.itemsGap, frame.size.height);
}
@end






@implementation LEGapPagingCollectionView

- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        self.itemsGap = 40;
        CGRect widerFrame = frame;
        widerFrame.size.width += self.itemsGap;
        widerFrame.origin.x -= self.itemsGap/2;
        self.innerCollectionView = [[PhotoBrowserCollectionView alloc] initWithFrame:widerFrame];
        [self addSubview:self.innerCollectionView];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setDelegate:(id<UICollectionViewDelegate>)delegate {
    _delegate = delegate;
    self.innerCollectionView.delegate = delegate;
}

- (void)setDatasource:(id<UICollectionViewDataSource>)datasource {
    _datasource = datasource;
    self.innerCollectionView.dataSource = datasource;
}

- (void)reloadData{
    [self.innerCollectionView reloadData];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect widerFrame = self.frame;
    widerFrame.size.width += self.itemsGap;
    widerFrame.origin.x = -self.itemsGap/2;
    widerFrame.origin.y = 0;
    [self.innerCollectionView setFrame:widerFrame];
}


- (NSInteger)currentPage {
    CGFloat offset = self.innerCollectionView.contentOffset.x;
    CGFloat width = self.innerCollectionView.bounds.size.width;
    int page = (int)( (offset + width/2 ) / width );
    return page;
}
- (CGFloat)currentPageDeviationRatio {
    CGFloat width = self.innerCollectionView.bounds.size.width;
    CGFloat pageCenter = width * (self.currentPage + 1.0/2.0); // page start from zero
    CGFloat currentPhotoCenter = self.innerCollectionView.contentOffset.x + width/2;
    CGFloat percentage = (currentPhotoCenter - pageCenter) / (width/2);
    return percentage;
}


@end


