//
//  ValueModel.h
//  MongolianReadProject
//
//  Created by 张祎 on 2017/6/2.
//  Copyright © 2017年 张祎. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, TouchMovedType) {
    TouchMovedTypeUnknow,
    TouchMovedTypeProgress,
    TouchMovedTypeBrightness,
    TouchMovedTypeVolume,
};

@interface ValueModel : NSObject
@property (nonatomic, assign) CGPoint touchBeginPoint;
@property (nonatomic, assign) float touchBeginProgress;
@property (nonatomic, assign) float touchBeginBrightness;
@property (nonatomic, assign) float touchBeginVolume;
@end
