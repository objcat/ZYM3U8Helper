//
//  ZYVideoPlayer.h
//  MongolianReadProject
//
//  Created by 张祎 on 2017/6/1.
//  Copyright © 2017年 张祎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ZYPlayer.h"

@interface ZYVideoPlayer : UIView
+ (instancetype)playerWithFrame:(CGRect)frame URL:(NSString *)URL;
+ (instancetype)playerWithFrame:(CGRect)frame fileURL:(NSString *)fileURL;
- (void)changeVideoWithURL:(NSString *)URL;
@property(nonatomic, strong) ZYPlayer *player;
@property(nonatomic, strong) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (nonatomic, copy) void (^popBLock) (void);
@end
