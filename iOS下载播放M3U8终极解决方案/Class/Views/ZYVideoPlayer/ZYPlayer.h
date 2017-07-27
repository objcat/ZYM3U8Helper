//
//  ZYPlayer.h
//  MongolianReadProject
//
//  Created by 张祎 on 2017/5/26.
//  Copyright © 2017年 张祎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


typedef NS_ENUM(NSUInteger, ZYPlayerType) {
    ZYPlayerTypePlaying,
    ZYPlayerTypePause,
    ZYPlayerTypeEnd,
};

@protocol ZYPlayerDelegate <NSObject>

@optional

/* 播放状态监控 */
- (void)playerDidEndPlay;
- (void)playerDidJump;
- (void)playerDidPlay:(NSString *)durationTime;
- (void)playerDidPause;
- (void)playerDidError:(NSError *)error;

/**
 进度条监控
 @param progress 播放进度
 */
- (void)playerDidUpdateProgress:(float)progress currentTime:(NSString *)currentTime;


/**
 缓冲进度监控

 @param timeRanges 缓冲进度
 */
- (void)playerDidUpdateTimeRanges:(float)timeRanges;


@end

@interface ZYPlayer : AVPlayer


+ (instancetype)playerWithURL:(NSString *)URL;
+ (instancetype)playerWithFileURL:(NSString *)fileURL;

/**
 跳转进度
 使用系统方法封装 直接传入0-1的数值即可
 @param value 进度
 */
- (void)seekToTime:(Float32)value;

/**
 代理人
 */
@property (nonatomic, weak) id <ZYPlayerDelegate> delegate;

/**
 是否循环播放
 */
@property (nonatomic, assign) BOOL loop;

/**
 当前播放状态
 */
@property (nonatomic, assign) ZYPlayerType playerType;

/**
 总进度
 */
@property (nonatomic, strong) NSString *duration;

/**
 移除进度条监听
 */
- (void)removeTimeOvserver;
@end
