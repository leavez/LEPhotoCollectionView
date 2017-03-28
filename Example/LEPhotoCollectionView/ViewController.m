//
//  ViewController.m
//  LEPhotoCollectionViewDemo
//
//  Created by Gao on 7/20/16.
//  Copyright © 2016 leave. All rights reserved.
//
#ifdef LEPhotoCollectionView_GIF_SUPPORT
#define SUPPORT_GIF 1
#endif

#import "ViewController.h"
#ifdef SUPPORT_GIF
#import <LEPhotoCollectionView_GIF/LEPhotoCollectionView.h>
#else
#import <LEPhotoCollectionView/LEPhotoCollectionView.h>
#endif


@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic) LEGapPagingCollectionView *photoView;
@property (nonatomic) NSArray<UIImage *> *data;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.photoView = [[LEGapPagingCollectionView alloc] initWithFrame:self.view.bounds];
    self.photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.photoView];
    self.photoView.delegate = self;
    self.photoView.datasource = self;
    [self.photoView.innerCollectionView registerClass:LEDraggablePhotoCell.class forCellWithReuseIdentifier:@"cell"];

    NSMutableArray *images = [NSMutableArray array];
    for (NSString *name in @[@"1.jpg",@"2.jpg",@"3.jpg"]) {
        [images addObject:[UIImage imageNamed:name]];
    }
#ifdef SUPPORT_GIF
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"slow" ofType:@"gif"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        FLAnimatedImage *image = [[FLAnimatedImage alloc] initWithAnimatedGIFData:data];
        [images addObject:image];
    }
#endif
    self.data = [images copy];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.data.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    LEDraggablePhotoCell *c = (LEDraggablePhotoCell *)cell;
    UIImage *image = self.data[indexPath.row];
#ifdef SUPPORT_GIF
    if ([image isKindOfClass:[FLAnimatedImage class]]) {
        c.innerScrollView.imageView.animatedImage = (FLAnimatedImage *)image;
    } else {
#endif
    c.innerScrollView.image = image;

#ifdef SUPPORT_GIF
    }
#endif

    c.collectionView = collectionView;
    return c;
}


@end
