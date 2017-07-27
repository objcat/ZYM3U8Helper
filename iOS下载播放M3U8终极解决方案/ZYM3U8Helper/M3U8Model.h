//
//  M3U8Model.h
//  iOS下载播放M3U8终极解决方案
//
//  Created by 张祎 on 2017/7/19.
//  Copyright © 2017年 张祎. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface M3U8Model : NSObject
@property (assign, nonatomic) NSInteger duration;
@property (copy, nonatomic) NSString *TSURL;
@property (assign, nonatomic) NSInteger index;
@end
