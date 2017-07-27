//
//  MRSlider.m
//  MongolianReadProject
//
//  Created by 张祎 on 2017/5/27.
//  Copyright © 2017年 张祎. All rights reserved.
//

#import "MRSlider.h"

@implementation MRSlider

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[touches allObjects] lastObject];
    CGPoint location = [touch locationInView:self];
    CGFloat value = (self.maximumValue - self.minimumValue) * location.x / self.frame.size.width;
    self.value = value;
    self.touchEndBlock ? self.touchEndBlock() : nil;
}

/*
 
 使用过程发现  响应开始触控后 就不能响应滑动了 这很伤.
 super一下就好了  问题解决.
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.touchBeginBlock ? self.touchBeginBlock() : nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
