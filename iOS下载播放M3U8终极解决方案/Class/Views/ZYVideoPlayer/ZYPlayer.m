//
//  ZYPlayer.m
//  MongolianReadProject
//
//  Created by 张祎 on 2017/5/26.
//  Copyright © 2017年 张祎. All rights reserved.
//

#import "ZYPlayer.h"

@interface ZYPlayer ()
@property (nonatomic, weak) id playTimeObserver;
@end

@implementation ZYPlayer

+ (instancetype)playerWithURL:(NSString *)URL {
    
    NSURL *url = [NSURL URLWithString:URL];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
    ZYPlayer *player = [[ZYPlayer alloc] initWithPlayerItem:item];
    
    return player;
}

+ (instancetype)playerWithFileURL:(NSString *)fileURL {
    NSURL *url = [NSURL fileURLWithPath:fileURL];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
    ZYPlayer *player = [[ZYPlayer alloc] initWithPlayerItem:item];
    
    return player;
}

- (instancetype)initWithPlayerItem:(AVPlayerItem *)item {
    self = [super initWithPlayerItem:item];
    if (self) {
        [self KVO];
        [self addNotifaction];
    }
    return self;
}

#pragma mark - KVO 监听进度 缓冲进度

- (void)KVO {
    
    [self.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    __weak typeof(self) weakSelf = self;
    
    self.playTimeObserver = [self addPeriodicTimeObserverForInterval:CMTimeMake(1, 2) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        Float64 currentPlayTime = self.currentItem.currentTime.value / self.currentItem.currentTime.timescale;
        Float64 progress = CMTimeGetSeconds(self.currentItem.currentTime) / CMTimeGetSeconds(self.currentItem.duration);
        NSString *currentTimeString = [weakSelf timeToString:currentPlayTime];
        //回调当前播放进度
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(playerDidUpdateProgress:currentTime:)]) {
            [weakSelf.delegate playerDidUpdateProgress:progress currentTime:currentTimeString];
        }
    }];
}

#pragma mark - Notification

- (void)addNotifaction {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(AVPlayerItemDidPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [center addObserver:self selector:@selector(AVPlayerItemTimeJumpedNotification:) name:AVPlayerItemTimeJumpedNotification object:nil];
    [center addObserver:self selector:@selector(AVPlayerItemFailedToPlayToEndTimeErrorKey:) name:AVPlayerItemFailedToPlayToEndTimeErrorKey object:nil];
}

- (BOOL)loop {
    return YES;
}

//播放结束
- (void)AVPlayerItemDidPlayToEndTimeNotification:(NSNotification *)noti {
    
    self.playerType = ZYPlayerTypeEnd;
    
    if (self.loop) {
        [self seekToTime:0];
        [self play];
    }
    
    else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidEndPlay)]) {
            [self.delegate playerDidEndPlay];
        }
        [self removeObserves];
    }
}

//跳转进度
- (void)AVPlayerItemTimeJumpedNotification:(NSNotification *)noti {
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidJump)]) {
        [self.delegate playerDidJump];
    }
}

//播放失败
- (void)AVPlayerItemFailedToPlayToEndTimeErrorKey:(NSNotification *)noti {
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidError:)]) {
        [self.delegate playerDidError:noti.object];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if (![object isKindOfClass:[AVPlayerItem class]]) {
        return;
    }

    if ([keyPath isEqualToString:@"status"]) {
        //监听状态
        
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue]; // 获取
        if (status == AVPlayerStatusReadyToPlay) {
            [self play];
        } else if (status == AVPlayerStatusFailed) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidError:)]) {
                [self.delegate playerDidError:nil];
            }
        } else {
            NSLog(@"AVPlayerStatusUnknown");
        }
        
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        //缓冲进度
        NSTimeInterval timeInterval = [self availableDuration];
        CMTime duration             = self.currentItem.duration;
        CGFloat totalDuration       = CMTimeGetSeconds(duration);
        float timeRange = timeInterval / totalDuration;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidUpdateTimeRanges:)]) {
            [self.delegate playerDidUpdateTimeRanges:timeRange];
        }

    }
}

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [self.currentItem loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (NSString *)timeToString:(Float64)time {
    
    NSInteger integerTime = time;
    NSString *timeStr;
    
    if (integerTime < 60) {
        timeStr = [NSString stringWithFormat:@"00:%02ld", integerTime];
    }
    
    else if (integerTime < 3600) {
        timeStr = [NSString stringWithFormat:@"%02ld:%02ld", integerTime / 60, integerTime % 60];
    }
    else{
        timeStr = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", integerTime / 3600, integerTime % 3600 / 60, integerTime % 60];
    }
    
    return timeStr;
}

//播放
- (void)play {
    
    [super play];
    
    _playerType = ZYPlayerTypePlaying;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidPlay:)]) {
        [self.delegate playerDidPlay:[self timeToString:CMTimeGetSeconds(self.currentItem.duration)]];
    }
    
    _duration = [self timeToString:CMTimeGetSeconds(self.currentItem.duration)];
}

//暂停
- (void)pause {
    
    [super pause];
    
    _playerType = ZYPlayerTypePause;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidPause)]) {
        [self.delegate playerDidPause];
    }
}

- (void)dealloc {
    //移除所有监听
    [self removeObserves];
}

//移除进度条监听如果不移除会出内存不释放问题 与 timer同理
- (void)removeTimeOvserver {
    [self removeTimeObserver:_playTimeObserver];
}

- (void)removeObserves {
    
    [self.currentItem removeObserver:self forKeyPath:@"status"];
    [self.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [center removeObserver:self name:AVPlayerItemTimeJumpedNotification object:nil];
    [center removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeErrorKey object:nil];
}

- (void)seekToTime:(Float32)value {
    CMTimeScale scale = self.currentItem.asset.duration.timescale;
    Float64 time = CMTimeGetSeconds(self.currentItem.duration) * value;
    [self seekToTime:CMTimeMakeWithSeconds(time, scale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}
@end
