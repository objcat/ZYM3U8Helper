//
//  UIColor+AddColor.h
//  FlatUI
//
//  Created by lzhr on 5/3/13.
//  Copyright (c) 2013 lzhr. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RGBA(r,g,b,a) [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a]


@interface UIColor (AddColor)

// 通过16进制字符串创建颜色, 例如: #F173AC 是粉色
/*
 用法: 
 
view.backgroundColor = [UIColor colorFromHexCode:@"#F173AC"];
 
 */
+ (UIColor *)colorFromHexCode:(NSString *)hexString;

+ (UIColor *)deepBlueColor;


@end
