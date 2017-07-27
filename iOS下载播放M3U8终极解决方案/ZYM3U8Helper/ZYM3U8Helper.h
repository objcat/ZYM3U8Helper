//
//  ZYM3U8Helper.h
//  iOS下载播放M3U8终极解决方案
//
//  Created by 张祎 on 2017/7/19.
//  Copyright © 2017年 张祎. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZYM3U8HelperProtocol <NSObject>
- (void)progressDidUpdate:(NSProgress *)progress;
@end

@interface ZYM3U8Helper : NSObject
/**
 下载m3u8视频(流媒体)
 @param URL URL地址
 @param path 保存的文件夹路径(如果路径中有未创建的文件夹则本工具会自动帮助创建)
 */
- (void)download_m3u8_WithURL:(NSString *)URL toPath:(NSString *)path;
@property (nonatomic, assign) id <ZYM3U8HelperProtocol> delegate;
@end
