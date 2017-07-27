//
//  AppDelegate.m
//  iOS下载播放M3U8终极解决方案
//
//  Created by 张祎 on 2017/7/19.
//  Copyright © 2017年 张祎. All rights reserved.
//

#import "AppDelegate.h"
#import "HTTPServer.h"
#import "DDTTYLogger.h"

@interface AppDelegate ()
@property (nonatomic, strong) HTTPServer *httpServer;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //创建本地http服务器
    /*
     由于m3u8文件的特殊性，所以必须搭建本地服务器才可以进行播放
     该服务器的作用是构造本地服务器路径来播放.m3u8文件
     例如 @"http://127.0.0.1:12345/movie1/movie.m3u8"
     */
    [self openServer];
    
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSLog(@"沙盒路径：%@", path);

    return YES;
}

- (void)openServer {
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    //初始化服务器对象
    self.httpServer = [[HTTPServer alloc]init];
    
    //设置服务器类型
    [self.httpServer setType:@"_http._tcp."];
    
    //设置服务器端口
    [self.httpServer setPort:12345];
    
    //设置服务器路径
    NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
//    NSString *webPath = [pathPrefix stringByAppendingPathComponent:@"Downloads"];
    [self.httpServer setDocumentRoot:pathPrefix];
    NSLog(@"服务器路径：%@", pathPrefix);
    NSError *error;

    //开启HTTP服务器
    if ([self.httpServer start:&error]) {
        NSLog(@"开启HTTP服务器 端口:%hu",[self.httpServer listeningPort]);
    }
    else{
        NSLog(@"服务器启动失败错误为:%@",error);
    }
}

+ (void)changeStatebarColor:(UIColor *)color {
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)])
    {
        statusBar.backgroundColor = color;
    }
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window{
    if (_canRevolve) {
        return UIInterfaceOrientationMaskLandscapeRight;
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
}

+ (AppDelegate *)delegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
