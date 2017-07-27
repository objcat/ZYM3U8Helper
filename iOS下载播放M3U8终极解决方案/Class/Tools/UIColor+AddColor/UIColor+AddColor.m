//
//  UIColor+AddColor.m
//  FlatUI
//
//  Created by lzhr on 5/3/13.
//  Copyright (c) 2013 lzhr. All rights reserved.
//

#import "UIColor+AddColor.h"

@implementation UIColor (AddColor)

// Thanks to http://stackoverflow.com/questions/3805177/how-to-convert-hex-rgb-color-codes-to-uicolor
+ (UIColor *) colorFromHexCode:(NSString *)hexString {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}


+ (UIColor *) ngaBackColor
{
    return [UIColor colorWithRed:253.0f/255.0f green:243.0f/255.0f blue:216.0f/255.0f alpha:1];
}

+ (UIColor *) ngaDarkColor
{
    return [UIColor colorWithRed:249.0f/255.0f green:238.0f/255.0f blue:167.0f/255.0f alpha:1];
}

+ (UIColor *) blendedColorWithForegroundColor:(UIColor *)foregroundColor
                              backgroundColor:(UIColor *)backgroundColor
                                 percentBlend:(CGFloat) percentBlend {
    CGFloat onRed, offRed, newRed, onGreen, offGreen, newGreen, onBlue, offBlue, newBlue, onWhite, offWhite;
    if ([foregroundColor getWhite:&onWhite alpha:nil]) {
        onRed = onWhite;
        onBlue = onWhite;
        onGreen = onWhite;
    }
    else {
        [foregroundColor getRed:&onRed green:&onGreen blue:&onBlue alpha:nil];
    }
    if ([backgroundColor getWhite:&offWhite alpha:nil]) {
        offRed = offWhite;
        offBlue = offWhite;
        offGreen = offWhite;
    }
    else {
        [backgroundColor getRed:&offRed green:&offGreen blue:&offBlue alpha:nil];
    }
    newRed = onRed * percentBlend + offRed * (1-percentBlend);
    newGreen = onGreen * percentBlend + offGreen * (1-percentBlend);
    newBlue = onBlue * percentBlend + offBlue * (1-percentBlend);
    return [UIColor colorWithRed:newRed green:newGreen blue:newBlue alpha:1.0];
}

+ (UIColor *)deepBlueColor {
    return RGBA(38, 130, 203, 1);
}

@end
