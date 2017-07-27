//
//  ZYVideoPlayer.m
//  MongolianReadProject
//
//  Created by 张祎 on 2017/6/1.
//  Copyright © 2017年 张祎. All rights reserved.
//

#import "ZYVideoPlayer.h"
#import "Masonry.h"
#import "MRSlider.h"
#import "ValueModel.h"
#import <MediaPlayer/MediaPlayer.h>


@interface ZYVideoPlayer () <ZYPlayerDelegate>

@property (strong, nonatomic) IBOutlet UIView *topBar;//顶部工具栏
@property (strong, nonatomic) IBOutlet UIView *bottomBar;//底部工具栏
@property (strong, nonatomic) IBOutlet UIButton *playButton;//播放按钮
@property (strong, nonatomic) IBOutlet MRSlider *slider;//进度条
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;//显示时间
@property (strong, nonatomic) IBOutlet UIButton *fullScreenButton;//全屏button
@property (strong, nonatomic) IBOutlet UIProgressView *timeRangeProgressView;//缓冲条
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topBarTopConstraint;
@property (nonatomic, assign) BOOL isSliding; //是否在滑动
@property (nonatomic, assign) BOOL playFlag;  //是否在播放
@property (nonatomic, assign) BOOL isFullScreen; //是否全屏
@property (nonatomic, strong) UIButton *pauseBackgroundButton;
@property (nonatomic, strong) ValueModel *valueModel;
@property (nonatomic, strong) MPVolumeView *volumeView;
@property (nonatomic, strong) UISlider *volumeSlider;

@end

@implementation ZYVideoPlayer

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint tempPoint = [touch locationInView:self];
    if (!CGPointEqualToPoint(tempPoint, _valueModel.touchBeginPoint)) {
        return;
    }
    
    //如果point相等  就是唤出toolBar
    if (self.playFlag) {
        self.bottomBar.hidden = self.topBar.hidden = NO;
    }else{
        self.bottomBar.hidden = self.topBar.hidden = YES;
    }
    
    self.playFlag = !self.playFlag;
}




- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    //开始触控点
    _valueModel.touchBeginPoint = [touches.anyObject locationInView:self];
    
    //开始触控亮度
    _valueModel.touchBeginBrightness = [UIScreen mainScreen].brightness;
    
    //开始触控进度
    _valueModel.touchBeginProgress = self.slider.value;
    
    //开始触摸声音
    _valueModel.touchBeginVolume = _volumeSlider.value;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    
    if (touches.count > 1 || [touch tapCount] > 1 || event.allTouches.count > 1) {
        //如果是多点触控 不响应
        return;
    }
    
    if (![[touches.anyObject view] isEqual:self]) {
        //如果触摸的不是自己 不响应
        return;
    }
    
    CGPoint tempPoint = [touch locationInView:self];
    
    //如果滑动距离过小  不响应
    if (fabs(tempPoint.x - _valueModel.touchBeginPoint.x) < 15 && fabs(tempPoint.y - _valueModel.touchBeginPoint.y) < 15) {
        return;
    }
    
    float tan = fabs(tempPoint.y - _valueModel.touchBeginPoint.y) / fabs(tempPoint.x - _valueModel.touchBeginPoint.x);
    
    TouchMovedType type;
    
    if (tan < 1 / sqrt(3)) {
        //当滑动角度小于30度 进行手势
        type = TouchMovedTypeProgress;
    }else if (tan > sqrt(3)) {
        //当滑动角大于60度 控制声音的音量
        if (_valueModel.touchBeginPoint.x < self.bounds.size.width / 2) {
            //屏幕左半面控制亮度
            type = TouchMovedTypeBrightness;
        }else {
            //屏幕右办面控制音量
            type = TouchMovedTypeVolume;
        }
        
    }else {
        type = TouchMovedTypeUnknow;
        //什么都不做
        return;
    }
    
    
    switch (type) {
        case TouchMovedTypeBrightness: {
            
            //判断是否为全屏状态
            if (self.isFullScreen) {
                
                float tempLight = _valueModel.touchBeginBrightness - ((tempPoint.y - _valueModel.touchBeginPoint.y) / self.bounds.size.height);
                
                if (tempLight > 1) {
                    tempLight = 1;
                }else if (tempLight < 0) {
                    tempLight = 0;
                }
                
                [UIScreen mainScreen].brightness = tempLight;
            }
            
            break;
        }
            
        case TouchMovedTypeProgress: {
            
            
            
            break;
        }
            
        case TouchMovedTypeVolume: {
            
            if (self.isFullScreen) {
                float tempVolume = _valueModel.touchBeginVolume - ((tempPoint.y - _valueModel.touchBeginPoint.y) / self.bounds.size.height);
                
                if (tempVolume > 1) {
                    tempVolume = 1;
                }else if (tempVolume < 0) {
                    tempVolume = 0;
                }
                
                _volumeSlider.value = tempVolume;
            }
            
            break;
        }
            
        default:
            break;
    }
}
- (IBAction)backButtonAction:(id)sender {
    if (self.self.isFullScreen) {
        [self fullScreen:self];
    }else{
        self.popBLock ? self.popBLock() : nil;
    }
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self makeUI];
    [self configVolume];
}

- (void)configVolume {
    
    //初始化model  用于保存点击时的数据
    _valueModel = [[ValueModel alloc] init];
    _volumeView = [[MPVolumeView alloc] init];
    for (UIView *view in [_volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            self.volumeSlider = (UISlider *)view;
            break;
        }
    }
    self.backButton.showsTouchWhenHighlighted = YES;
    self.shareButton.showsTouchWhenHighlighted = YES;
}

- (void)makeUI {
    
    [self configSlider];
    
    [self createBlockView];
}

- (void)createBlockView {
    
    //创建加载视图
    UIView *blockView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, VIDEOHEIGHT)];
    [self addSubview:blockView];
    blockView.tag = 10086;
    blockView.backgroundColor = [UIColor blackColor];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] init];
    indicatorView.center = blockView.center;
    [indicatorView startAnimating];
    [blockView addSubview:indicatorView];
    [self sendSubviewToBack:blockView];
    
    [blockView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    //播放背景按钮
    self.pauseBackgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.pauseBackgroundButton setImage:[UIImage imageNamed:@"iconPlayCentralM4-2"] forState:UIControlStateNormal];
    self.pauseBackgroundButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.pauseBackgroundButton.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, VIDEOHEIGHT);
    [self addSubview:self.pauseBackgroundButton];
    [self.pauseBackgroundButton addTarget:self action:@selector(pauseBackgroundButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.pauseBackgroundButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(44);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self).offset(-33);
    }];
    
    self.pauseBackgroundButton.hidden = YES;
}

- (void)configSlider {
    
    //设置进度条和缓存条样式
    [self.slider setThumbImage:[UIImage imageNamed:@"OvalM4-2a"] forState:UIControlStateNormal];
    self.slider.value = 0;
    
    self.slider.maximumTrackTintColor = [UIColor clearColor];
    self.slider.minimumTrackTintColor = RGBA(219, 161, 52, 1);
    
    self.timeRangeProgressView.progressTintColor = [UIColor grayColor];
    self.timeRangeProgressView.trackTintColor = [UIColor lightGrayColor];
    self.timeRangeProgressView.progress = 0;
    
    __weak typeof(self) weakSelf = self;
    [self.slider setTouchEndBlock:^{
        [weakSelf seekToTime];
    }];
    
    [self.slider setTouchBeginBlock:^{
        weakSelf.isSliding = YES;
    }];
}

- (IBAction)Sliderchanged:(id)sender {
    self.isSliding = YES;
}

- (IBAction)SliderInClick:(id)sender {
    [self seekToTime];
}

- (IBAction)sliderOutClick:(id)sender {
    [self seekToTime];
}

- (void)seekToTime {
    [self.player seekToTime:self.slider.value];
    self.isSliding = NO;
    [self.player play];
    self.pauseBackgroundButton.hidden = YES;
    [self.playButton setImage:[UIImage imageNamed:@"iconPauseCornerM4-2"] forState:UIControlStateNormal];
}

- (void)pauseBackgroundButtonAction {
    
    [self changeImageWithState:self.player.playerType];
    
    if (self.player.playerType == ZYPlayerTypePlaying) {
        [self.player pause];
    }
    
    else{
        if (self.player.status == ZYPlayerTypeEnd) {
            
        }else{
            [self.player play];
        }
    }
}


- (void)changeImageWithState:(ZYPlayerType)type {
    
    switch (self.player.playerType) {
        case ZYPlayerTypePlaying:
            [self.playButton setImage:[UIImage imageNamed:@"iconPlayCornerM4-2"] forState:UIControlStateNormal];
            self.pauseBackgroundButton.hidden = NO;
            
            break;
        case ZYPlayerTypePause:
        case ZYPlayerTypeEnd:
            [self.playButton setImage:[UIImage imageNamed:@"iconPauseCornerM4-2"] forState:UIControlStateNormal];
            self.pauseBackgroundButton.hidden = YES;
            break;
            
        default:
            break;
    }
}

- (void)playerDidPlay:(NSString *)durationTime {
    
    [self.playButton setImage:[UIImage imageNamed:@"iconPauseCornerM4-2"] forState:UIControlStateNormal];
    
    UIView *view = [self viewWithTag:10086];
    [view removeFromSuperview];
}



- (IBAction)fullScreen:(id)sender {
    
    UIView *superView = self.superview;
    
    AppDelegate *delegate = [AppDelegate delegate];
    
    if (self.isFullScreen) {
        
        self.isFullScreen = NO;
        delegate.canRevolve = NO;
        NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        self.topBarTopConstraint.constant = 0;
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(superView).offset(20);
            make.centerX.equalTo(superView);
            make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
            make.height.mas_equalTo(VIDEOHEIGHT);
        }];
    }
    
    else {
        
        self.isFullScreen = YES;
        delegate.canRevolve = YES;
        NSNumber *value = [NSNumber numberWithInt:UIDeviceOrientationLandscapeRight];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
        self.topBarTopConstraint.constant = 20;
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(superView);
            make.centerX.equalTo(superView);
            make.width.mas_equalTo(superView);
            make.bottom.equalTo(superView);
        }];
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

- (IBAction)play:(id)sender {
    
    [self changeImageWithState:self.player.playerType];
    
    if (self.player.playerType == ZYPlayerTypePlaying) {
        [self.player pause];
    }
    
    else{
        if (self.player.status == ZYPlayerTypeEnd) {
            [self.player play];
        }else{
            [self.player play];
        }
    }
    
    
}

+ (instancetype)playerWithFrame:(CGRect)frame URL:(NSString *)URL {
    
    ZYVideoPlayer *videoPlayer = [[[NSBundle mainBundle] loadNibNamed:@"ZYVideoPlayer" owner:nil options:nil] objectAtIndex:0];
    
    videoPlayer.player = [ZYPlayer playerWithURL:URL];
    videoPlayer.player.delegate = videoPlayer;
    videoPlayer.frame = frame;
    videoPlayer.playerLayer.videoGravity = AVLayerVideoGravityResize;
    
    return videoPlayer;
}

+ (instancetype)playerWithFrame:(CGRect)frame fileURL:(NSString *)fileURL {
    ZYVideoPlayer *videoPlayer = [[[NSBundle mainBundle] loadNibNamed:@"ZYVideoPlayer" owner:nil options:nil] objectAtIndex:0];
    
    videoPlayer.player = [ZYPlayer playerWithFileURL:fileURL];
    videoPlayer.player.delegate = videoPlayer;
    videoPlayer.frame = frame;
    videoPlayer.playerLayer.videoGravity = AVLayerVideoGravityResize;
    
    return videoPlayer;
}

- (void)createPlayerWithURL:(NSString *)URL {
    [self clearVideoData];
    [self.player removeTimeOvserver];
    self.player = [ZYPlayer playerWithURL:URL];
    self.player.delegate = self;
    self.frame = self.frame;
    self.playerLayer.videoGravity = AVLayerVideoGravityResize;
}

- (void)playerDidUpdateProgress:(float)progress currentTime:(NSString *)currentTime {
    
    if (self.isSliding) {
        return;
    }
    
    self.slider.value = progress;
    self.timeLabel.text = [NSString stringWithFormat:@"%@/%@", currentTime?:@"00:00", self.player.duration?:@"00:00"];
}


- (void)clearVideoData {
    self.timeLabel.text = [NSString stringWithFormat:@"%@/%@", @"00:00", @"00:00"];
    self.slider.value = 0;
    self.timeRangeProgressView.progress = 0;
}

- (void)playerDidUpdateTimeRanges:(float)timeRanges {
    self.timeRangeProgressView.progress = timeRanges;
}

- (void)changeVideoWithURL:(NSString *)URL {
    [self createPlayerWithURL:URL];
}

+ (Class)layerClass{
    return [AVPlayerLayer class];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (AVPlayerLayer *)playerLayer{
    return (AVPlayerLayer *)self.layer;
}

- (void)dealloc {
    [self.player removeTimeOvserver];
    NSLog(@"视频播放释放");
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
