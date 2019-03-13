//
//  SuspensionView.m
//  hopper
//
//  Created by mgfjx on 2017/2/3.
//  Copyright © 2017年 XXL. All rights reserved.
//

#import "SuspensionView.h"

@interface SuspensionView (){
    
    CGFloat contentOffsetX;
    CGFloat contentOffsetY;
    
}

@end

@implementation SuspensionView

- (instancetype)init{
    self = [super init];
    if (self) {
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
//        [self addGestureRecognizer:tap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
        [self addGestureRecognizer:pan];
        
    }
    return self;
}

- (void)panHandler:(UIPanGestureRecognizer *)pan{
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        CGPoint origin = [pan locationInView:pan.view];
        
        contentOffsetX = origin.x;
        contentOffsetY = origin.y;
    }
    
    if (pan.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [pan locationInView:self.superview];
        CGRect frame = pan.view.frame;
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        CGFloat x = point.x - contentOffsetX;
        CGFloat y = point.y - contentOffsetY;
        CGFloat offset = self.bounds.size.width + 10;
        if (x + self.frame.size.width <= offset) {
            x = offset - self.frame.size.width;
        }
        if (x >= width - offset) {
            x = width - offset;
        }
        if (y + self.frame.size.height <= 64 + offset) {
            y = 64 + offset - self.frame.size.height;
        }
        if (y >= height - offset) {
            y = height - offset;
        }
        frame.origin = CGPointMake(x, y);
        pan.view.frame = frame;
    }
    
}

@end
