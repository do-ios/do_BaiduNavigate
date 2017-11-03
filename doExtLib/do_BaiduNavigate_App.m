//
//  do_BaiduNavigate_App.m
//  DoExt_SM
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_BaiduNavigate_App.h"
#import "BNCoreServices.h"
#import "doServiceContainer.h"
#import "doIModuleExtManage.h"

static do_BaiduNavigate_App* instance;
@implementation do_BaiduNavigate_App
@synthesize OpenURLScheme;
+(id) Instance
{
    if(instance==nil)
        instance = [[do_BaiduNavigate_App alloc]init];
    return instance;
}
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //初始化导航SDK
    NSString *naviKey = [[doServiceContainer Instance].ModuleExtManage GetThirdAppKey:@"baiduNavigate.plist" :@"baiduNavigateKey" ];
    [BNCoreServices_Instance initServices: naviKey];
    [BNCoreServices_Instance startServicesAsyn:nil fail:nil];
    return YES;
}
@end
