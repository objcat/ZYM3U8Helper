//
//  ViewController.m
//  iOS下载播放M3U8终极解决方案
//
//  Created by 张祎 on 2017/7/19.
//  Copyright © 2017年 张祎. All rights reserved.
//

#import "ViewController.h"
#import "ZYVideoPlayer.h"
#import "ZYM3U8Helper.h"
#import <CommonCrypto/CommonDigest.h>

//#define VIDEOURL @"https://devstreaming-cdn.apple.com/videos/wwdc/2017/602pxa6f2vw71ze/602/hls_vod_mvp.m3u8"

#define VIDEOURL @"http://flv.bn.netease.com/videolib3/1706/01/VOAMY7359/SD/movie_index.m3u8"

@interface ViewController () <ZYM3U8HelperProtocol>
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) ZYVideoPlayer *videoPlayer;
@property (nonatomic, strong) ZYM3U8Helper *helper;
@end

@implementation ViewController
- (IBAction)play:(id)sender {
    
    [self.progressView removeFromSuperview];
    self.progressView = nil;
    
    //拼接m3u8本地服务器路径 如果没下载视频是无法播放的
    NSString *serverPath = @"http://127.0.0.1:12345";
    NSString *m3u8Path = [serverPath stringByAppendingPathComponent:@"aaa"];
    m3u8Path = [m3u8Path stringByAppendingPathComponent:[self MD5WithString:VIDEOURL]];
    m3u8Path = [m3u8Path stringByAppendingPathComponent:@"movie.m3u8"];
    [self createPlayerWithURL:m3u8Path];
    
    //网络地址播放
//    [self createPlayerWithURL:VIDEOURL];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.helper = [[ZYM3U8Helper alloc] init];
    self.helper.delegate = self;
}

- (void)progressDidUpdate:(NSProgress *)progress {
    NSLog(@"qqqqqqqQ: %lf", progress.fractionCompleted);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = progress.fractionCompleted;
    });
}

- (NSString *)MD5WithString:(NSString *)string {
    const char *cstr = [string UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (CC_LONG)strlen(cstr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (IBAction)downLoad:(id)sender {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"aaa/%@", [self MD5WithString:VIDEOURL]]];
    [self.helper download_m3u8_WithURL:VIDEOURL toPath:path];
}

- (void)createPlayerWithURL:(NSString *)URL {
    
    [self.videoPlayer removeFromSuperview];
    self.videoPlayer = nil;
    
    self.videoPlayer = [ZYVideoPlayer playerWithFrame:CGRectZero URL:URL];
    [self.view addSubview:self.videoPlayer];
    
    [self.videoPlayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(VIDEOHEIGHT);
    }];
    
    __weak typeof(self) weakSelf = self;
    [self.videoPlayer setPopBLock:^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
