//
//  GIFHUD.h
//  GIFHUD
//
//  Created by 酌晨茗 on 16/3/3.
//  Copyright © 2016年 酌晨茗. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GIFHUD : UIView

+ (void)showHUD;

+ (void)showHUDDissmissAfterTime:(CGFloat)time;

+ (void)dissmissHUD;

@end
