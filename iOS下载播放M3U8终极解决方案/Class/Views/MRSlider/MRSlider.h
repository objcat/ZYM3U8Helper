//
//  MRSlider.h
//  MongolianReadProject
//
//  Created by 张祎 on 2017/5/27.
//  Copyright © 2017年 张祎. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRSlider : UISlider
@property (nonatomic, copy) void (^touchEndBlock) (void);
@property (nonatomic, copy) void (^touchBeginBlock) (void);
@end
