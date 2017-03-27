//
//  PhotoCell.m
//  ScrollZoomViewTest
//
//  Created by Leave on 12/26/14.
//  Copyright (c) 2014 Leave. All rights reserved.
//

#import "LEPhotoCell.h"
#import "LEZoomView_Inner.h"

@interface LEPhotoCell()
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@end

@implementation LEPhotoCell


-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commomInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commomInit];
    }
    return self;
}

-(void)commomInit{
    self.innerScrollView = [[LEZoomView alloc] initWithFrame:self.bounds];
    self.innerScrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.innerScrollView];

    [self setUpMenuGesture];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.innerScrollView.frame = self.bounds;
}


// ------------------------------------------------------------------------------------------

#pragma mark - MENU

- (void)setUpMenuGesture {
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressed:)];
    [self addGestureRecognizer:_longPressGesture];
    [self.innerScrollView.tapGuestureSingle addTarget:self action:@selector(didSingleTapSelf:)];
    [self.innerScrollView.tapGuestureDouble addTarget:self action:@selector(didDoubleTapSelf:)];
    self.menuEnabled = NO;
}

- (void)setMenuEnabled:(BOOL)menuEnabled {
    _menuEnabled = menuEnabled;
    self.longPressGesture.enabled = menuEnabled;
}

- (void)didLongPressed:(UILongPressGestureRecognizer*)longPressGuesture
{
    if (longPressGuesture.state != UIGestureRecognizerStateBegan) {
        return;
    }

    CGPoint location = [longPressGuesture locationInView:self];
    if (CGRectContainsPoint(self.innerScrollView.imageView.frame, location)) {
        // check if in the image
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [self becomeFirstResponder];
        menu.menuItems = @[
                           [[UIMenuItem alloc] initWithTitle:self.saveButtonTitle ?: @"保存" action:@selector(saveImage)],
                           [[UIMenuItem alloc] initWithTitle:self.imageCopyButtonTitle ?: @"复制" action:@selector(copyImage)],
                           [[UIMenuItem alloc] initWithTitle:self.linkCopyButtonTitle ?: @"复制链接" action:@selector(copyLink)],
                           [[UIMenuItem alloc] initWithTitle:self.shareButtonTitle ?: @"分享" action:@selector(shareImage)]
                           ];
        CGPoint point = [longPressGuesture locationInView:self];
        CGRect rect = CGRectMake(point.x, point.y-5, 1, 1);
        [menu setTargetRect:rect  inView:self];
        [menu setMenuVisible:YES animated:YES];
    }
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}

- (void)copyImage{
    if ([self.menuDelegate respondsToSelector:@selector(photoCellMenuDidTapCopy:)]) {
        [self.menuDelegate photoCellMenuDidTapCopy:self];
    }
    [self hiddenMenu];
}

- (void)copyLink{
    if ([self.menuDelegate respondsToSelector:@selector(photoCellMenuDidCopyLink:)]) {
        [self.menuDelegate photoCellMenuDidCopyLink:self];
    }
    [self hiddenMenu];
}

-(void)saveImage{
    if ([self.menuDelegate respondsToSelector:@selector(photoCellMenuDidTapSave:)]) {
        [self.menuDelegate photoCellMenuDidTapSave:self];
    }
    [self hiddenMenu];
}

- (void)shareImage{
    if ([self.menuDelegate respondsToSelector:@selector(photoCellMenuDidTapShare:)]) {
        [self.menuDelegate photoCellMenuDidTapShare:self];
    }
    [self hiddenMenu];
}

- (void)hiddenMenu {
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
}

- (void)didSingleTapSelf:(UITapGestureRecognizer *)tap{
    [self hiddenMenu];
}
- (void)didDoubleTapSelf:(UITapGestureRecognizer *)tap{
    [self hiddenMenu];
}

@end
