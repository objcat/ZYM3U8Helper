//
//  ZYM3U8Helper.m
//  iOS下载播放M3U8终极解决方案
//
//  Created by 张祎 on 2017/7/19.
//  Copyright © 2017年 张祎. All rights reserved.
//

#import "ZYM3U8Helper.h"
#import "M3U8Model.h"
#import "AFNetworking.h"
#import "stdlib.h"

@interface ZYM3U8Helper ()
@property (nonatomic, strong) NSMutableArray *tsArray;
@property (nonatomic, strong) NSProgress *progress;
@property (nonatomic, copy) NSString *path;
@end

@implementation ZYM3U8Helper

- (void)download_m3u8_WithURL:(NSString *)URL toPath:(NSString *)path {
    
    _path = path;
    
    //检测URL是否合法
    if ([self URLisError:URL]) {
        return ;
    }
    
    // initWithContentsOfURL 可能会阻塞主线程 故在子线程中解析
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSError *error = nil;
        
        //m3u8其实是一个字符串, 里面包含若干个ts文件的下载地址
        __block NSString *m3u8 = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:URL] encoding:NSUTF8StringEncoding error:&error];
        
        if (error) {
            NSLog(@"获取m3u8列表失败");
        }
        
        else{
            // 回到主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //检测M3U8文件中是否包含TS文件
                if (![self haveTSFile:m3u8]) { return; }
                
                //解析m3u8文件 采集ts的地址
                [self analysis_m3u8Str:m3u8];
                
                //采集地址完毕 根据传入的路径创建下载路径
                [self createDownloadPath:path];
                
                //解析完毕下载所需ts文件
                [self downLoadTsTile];
            });
        }
    });
}

- (void)analysis_m3u8Str:(NSString *)m3u8Str {
    NSRange tsRange = [m3u8Str rangeOfString:@"#EXTINF:"];
    self.tsArray = [NSMutableArray array];
    //解析m3u8文件
    while (tsRange.location != NSNotFound) {
        //声明一个model存储TS文件链接和时长
        M3U8Model *model = [[M3U8Model alloc] init];
        //截取TS片段时长 即#EXTINF: 与 , 中间的数值
        NSRange commaRange = [m3u8Str rangeOfString:@","];
        NSString *value = [m3u8Str substringWithRange:NSMakeRange(tsRange.location + [@"#EXTINF:" length], commaRange.location - (tsRange.location + [@"#EXTINF:" length]))];
        model.duration = [value integerValue];
        m3u8Str = [m3u8Str substringFromIndex:commaRange.location];
        //获取TS下载链接,这需要根据具体的M3U8获取链接，可以更具自己公司的需求
        NSRange linkRangeBegin = [m3u8Str rangeOfString:@","];
        NSRange linkRangeEnd = [m3u8Str rangeOfString:@".ts"];
        NSString *TSURL = [m3u8Str substringWithRange:NSMakeRange(linkRangeBegin.location + 2, (linkRangeEnd.location + 3) - (linkRangeBegin.location + 2))];
        TSURL = [TSURL stringByReplacingOccurrencesOfString:@"///" withString:@"/"];
        TSURL = [TSURL stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
        model.TSURL = TSURL;
        [self.tsArray addObject:model];
        m3u8Str = [m3u8Str substringFromIndex:(linkRangeEnd.location + 3)];
        tsRange = [m3u8Str rangeOfString:@"#EXTINF:"];
    }
}

- (void)createDownloadPath:(NSString *)path {
    
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *tempPath = [path stringByReplacingOccurrencesOfString:[doc stringByAppendingString:@"/"] withString:@""];
    NSArray *directoryArray = [tempPath componentsSeparatedByString:@"/"];
    NSString *currentPath = @"";
    
    for (NSInteger i = 0; i < directoryArray.count; i++) {
        if (i == 0) {
            currentPath = [NSString stringWithFormat:@"%@/%@", doc, directoryArray[i]];
        }else {
            currentPath = [NSString stringWithFormat:@"%@/%@", currentPath, directoryArray[i]];
        }
        
        [self createDirectoryWithPath:currentPath];
    }
}

- (void)createDirectoryWithPath:(NSString *)path {
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path]) {
        return;
    }else{
        [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)downLoadTsTile {
    
    /*
     m3u8文件的下载十分特殊
     下载列表中包含若干的.ts文件
     下载完成后需要在文件夹中加入.m3u8文件做文件播放导引
     这里采用了并发下载 并监控了所有ts文件下载的总进度条
     */
    
    self.progress = [NSProgress progressWithTotalUnitCount:self.tsArray.count * 100];
    
    [self.progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    for (NSInteger i = 0; i < self.tsArray.count; i++) {
        
        [self.progress becomeCurrentWithPendingUnitCount:100];
        NSProgress *subProgress = [NSProgress progressWithTotalUnitCount:100];
        [self.progress resignCurrent];
        
        M3U8Model *model = self.tsArray[i];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:model.TSURL]];
        NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            subProgress.completedUnitCount = 100 * downloadProgress.fractionCompleted;
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            //下载路径

            NSString *path = [_path stringByAppendingPathComponent:[NSString stringWithFormat:@"movie%ld.ts", i]];
            NSURL *fileURL = [NSURL fileURLWithPath:path];
            
            return fileURL;
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            NSLog(@"filepath: %@", filePath);
            NSLog(@"error: %@", error);
        }];
        
        [task resume];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(NSProgress *)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.progress) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(progressDidUpdate:)]) {
            [self.delegate progressDidUpdate:object];
        }
        
        if (object.fractionCompleted == 1) {
            //下载完毕 创建.m3u8文件
            [self createLocalM3U8file];
            
            
        }
    }
}

#pragma mark - 创建M3U8文件
- (void)createLocalM3U8file {
    
    //创建M3U8的链接地址
    NSString *path = [_path stringByAppendingPathComponent:@"movie.m3u8"];
    
    //拼接M3U8链接的头部内容
    NSString *m3u8_header = [NSString stringWithFormat:@"#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-MEDIA-SEQUENCE:0\n#EXT-X-TARGETDURATION:30\n"];
    
    //填充M3U8数据
    __block NSString *m3u8_body = [[NSString alloc] init];
    
    [self.tsArray enumerateObjectsUsingBlock:^(M3U8Model *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //文件名
        NSString *fileName = [NSString stringWithFormat:@"movie%ld.ts", idx];
        //文件时长
        NSString* length = [NSString stringWithFormat:@"#EXTINF:%ld,\n",obj.duration];
        //拼接M3U8
        m3u8_body = [m3u8_body stringByAppendingString:[NSString stringWithFormat:@"%@%@\n", length, fileName]];
    }];

    //M3U8头部和中间拼接,到此我们完成的新的M3U8链接的拼接
    NSString *result = [NSString stringWithFormat:@"%@%@", m3u8_header, m3u8_body];
    result = [result stringByAppendingString:@"#EXT-X-ENDLIST"];
    
    BOOL bSucc = [result writeToURL:[NSURL fileURLWithPath:path] atomically:YES encoding:NSUTF8StringEncoding error:nil];

    if (bSucc) {
        //成功
        NSLog(@"M3U8数据保存成功");
    } else {
        //失败
        NSLog(@"M3U8数据保存失败");
    }
}

- (BOOL)URLisError:(NSString *)URL {
    if (!([URL hasPrefix:@"http://"] || [URL hasPrefix:@"https://"])) {
        return YES;
    }else{
        NSLog(@"地址非http和https");
        return NO;
    }
}

- (BOOL)haveTSFile:(NSString *)M3U8Str {
    NSRange tsRange = [M3U8Str rangeOfString:@"#EXTINF:"];
    if (tsRange.location == NSNotFound) {
        NSLog(@"M3U8里没有TS文件");
        return NO;
    }else{
        return YES;
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"fractionCompleted"];
}

@end
