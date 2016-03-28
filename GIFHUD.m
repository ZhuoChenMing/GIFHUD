
//
//  GIFHUD.m
//  GIFHUD
//
//  Created by 酌晨茗 on 16/3/3.
//  Copyright © 2016年 酌晨茗. All rights reserved.
//

#import "GIFHUD.h"
#import "GCDTimerManager.h"

@interface GIFHUD ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIView *overLayView;

@property (nonatomic, assign) bool flag;

@end

@implementation GIFHUD

+ (instancetype)shareGIFHUD {
    static GIFHUD *gif = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gif = [[self alloc] init];
    });
    return gif;
}

#pragma mark - 展示
+ (void)showHUD {
    [[self shareGIFHUD] showHUD];
}

+ (void)showHUDDissmissAfterTime:(CGFloat)time {
    [[self shareGIFHUD] showHUDDissmissAfterTime:time];
}

#pragma mark - 隐藏
+ (void)dissmissHUD {
    [[self shareGIFHUD] dissmissHUD];
}

#pragma mark - 实例方法
- (void)showHUD {
    
    if (self.subviews.count != 0) {
        return;
    }
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat imgWidth = 100;
    
    CGFloat left = (width - imgWidth) / 2.0;
    CGFloat top = (height - imgWidth) / 2.0;
    
    self.frame = CGRectMake(left, top, imgWidth, imgWidth);
    self.alpha = 0;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
    self.layer.cornerRadius = 5.0;
    
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, imgWidth - 20, imgWidth - 20)];
    _imageView.image = [UIImage imageNamed:@"dengdai"];
    
    [self addSubview:_imageView];
    
    
    __block GIFHUD *weakSelf = self;
    [GCDTimerManager scheduledDispatchTimerWithName:@"Timer" timeInterval:1 queue:dispatch_get_main_queue() repeats:YES action:^{
        [weakSelf animation];
    }];
    
    self.overLayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.overLayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
        [[UIApplication sharedApplication].keyWindow addSubview:self.overLayView];
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }];
}

- (void)animation {
    if (!_flag) {
        [UIView animateWithDuration:1 animations:^{
            self.imageView.transform = CGAffineTransformMakeRotation(-M_PI / 3.0);
        }];
    } else {
        [UIView animateWithDuration:1 animations:^{
            self.imageView.transform = CGAffineTransformMakeRotation(M_PI / 3.0);
        }];
    }
    self.flag = !_flag;
}

- (void)showHUDDissmissAfterTime:(CGFloat)time {
    [self showHUD];
    [self performSelector:@selector(dissmissHUD) withObject:nil afterDelay:time];
}

- (void)dissmissHUD {
    if (_imageView) {
        [UIView animateWithDuration:0.5 animations:^{
            self.imageView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.imageView removeFromSuperview];
            self.imageView = nil;
            [self.overLayView removeFromSuperview];
            self.overLayView = nil;
            [self removeFromSuperview];
            [GCDTimerManager cancelAllTimer];
        }];
    }
}

@end
