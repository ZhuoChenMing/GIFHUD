//
//  GCDTimerManager.m
//  GIFHUD
//
//  Created by 酌晨茗 on 1/12/16.
//  Copyright (c) 2016 酌晨茗. All rights reserved.
//

#import "GCDTimerManager.h"

@interface GCDTimerManager()

@property (nonatomic, strong) NSMutableDictionary *timerDictionary;

@property (nonatomic, assign) NSInteger timeOut;

@end

@implementation GCDTimerManager

#pragma mark - 懒加载
- (NSMutableDictionary *)timerDictionary {
    if (!_timerDictionary) {
        _timerDictionary = [[NSMutableDictionary alloc] init];
    }
    return _timerDictionary;
}

#pragma mark - 初始化
+ (GCDTimerManager *)sharedInstance {
    static GCDTimerManager *_gcdTimerManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        _gcdTimerManager = [[GCDTimerManager alloc] init];
    });
    
    return _gcdTimerManager;
}

#pragma mark - 类方法
+ (void)scheduledDispatchTimerWithName:(NSString *)timerName
                          timeInterval:(CGFloat)interval
                                 queue:(dispatch_queue_t)queue
                               repeats:(BOOL)repeats
                                action:(dispatch_block_t)action {
    [[self sharedInstance] scheduledDispatchTimerWithName:timerName timeInterval:interval queue:queue repeats:repeats action:action];
}

+ (void)timerWithName:(NSString *)timerName
              timeOut:(CGFloat)timeOut
               action:(void(^)(NSInteger timeLeft))action {
    [[self sharedInstance] timerWithName:timerName timeOut:timeOut action:action];
}

+ (void)cancelTimerWithName:(NSString *)timerName {
    [[self sharedInstance] cancelTimerWithName:timerName];
}

+ (void)cancelAllTimer {
    [[self sharedInstance] cancelAllTimer];
}

#pragma mark - 实例方法
- (void)scheduledDispatchTimerWithName:(NSString *)timerName
                          timeInterval:(CGFloat)interval
                                 queue:(dispatch_queue_t)queue
                               repeats:(BOOL)repeats
                                action:(dispatch_block_t)action {
    if (timerName == nil) {
        return;
    }
    
    if (queue == nil) {
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    
    dispatch_source_t timer = [self.timerDictionary objectForKey:timerName];
    if (!timer) {
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_resume(timer);
        [self.timerDictionary setObject:timer forKey:timerName];
    }
    
    /* timer精度为0.1秒 */
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    
    __weak typeof(self) weakSelf = self;
    
    //[weakSelf removeActionBlockForTimerName:timerName];
    dispatch_source_set_event_handler(timer, ^{
        if ([[NSThread currentThread] isMainThread]) {
            action();
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                action();
            });
        }
        if (!repeats) {
            [weakSelf cancelTimerWithName:timerName];
        }
    });
}

- (void)timerWithName:(NSString *)timerName
              timeOut:(CGFloat)timeOut
               action:(void(^)(NSInteger timeLeft))action {
    if (timerName == nil) {
        return;
    }
    
    if (_timeOut <= 0) {
       self.timeOut = timeOut;
    }
    
    dispatch_source_t timer = [self.timerDictionary objectForKey:timerName];
    if (!timer) {
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
        dispatch_resume(timer);
        [self.timerDictionary setObject:timer forKey:timerName];
    }
    
    __block GCDTimerManager *weakSelf = self;
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        if (weakSelf.timeOut == 0) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                action(0);
            });
            [weakSelf cancelTimerWithName:timerName];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                action(weakSelf.timeOut + 1);
            });
        }
        weakSelf.timeOut--;
    });
}

- (void)cancelTimerWithName:(NSString *)timerName {
    dispatch_source_t timer = [self.timerDictionary objectForKey:timerName];
    
    if (!timer) {
        return;
    }
    
    [self.timerDictionary removeObjectForKey:timerName];
    dispatch_source_cancel(timer);
}

- (void)cancelAllTimer {
    // Fast Enumeration
    [self.timerDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *timerName, dispatch_source_t timer, BOOL *stop) {
        [self.timerDictionary removeObjectForKey:timerName];
        dispatch_source_cancel(timer);
    }];
}

@end
