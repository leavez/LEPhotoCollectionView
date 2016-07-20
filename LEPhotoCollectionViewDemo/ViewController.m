//
//  ViewController.m
//  LEPhotoCollectionViewDemo
//
//  Created by Gao on 7/20/16.
//  Copyright © 2016 leave. All rights reserved.
//

#import "ViewController.h"
#import "LEPhotoCollectionView.h"

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
    [self.photoView.innerCollectionView registerClass:LEPhotoCell.class forCellWithReuseIdentifier:@"cell"];

    NSMutableArray *images = [NSMutableArray array];
    for (NSString *name in @[@"1.jpg",@"2.jpg",@"3.jpg"]) {
        [images addObject:[UIImage imageNamed:name]];
    }
    self.data = [images copy];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.data.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    LEPhotoCell *c = (LEPhotoCell *)cell;
    c.innerScrollView.image = self.data[indexPath.row];
    return c;
}


@end
