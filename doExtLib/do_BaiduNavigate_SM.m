//
//  do_BaiduNavigate_SM.m
//  DoExt_API
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_BaiduNavigate_SM.h"

#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"
#import "doInvokeResult.h"
#import "BNCoreServices.h"
#import "doJsonHelper.h"

@interface do_BaiduNavigate_SM()<BNNaviRoutePlanDelegate,BNNaviUIManagerDelegate>

@end
@implementation do_BaiduNavigate_SM
{
    BNCoordinate_Type navigateType;
}
#pragma mark - 方法
#pragma mark - 同步异步方法的实现
//同步
- (void)start:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
    NSString *startPoint = [doJsonHelper GetOneText:_dictParas :@"startPoint" :@""];
    NSString *endPoint = [doJsonHelper GetOneText:_dictParas :@"endPoint" :@""];
    NSString *coType = [doJsonHelper GetOneText:_dictParas :@"coType" :@"BD09LL"];
    if ([coType isEqualToString:@"BD09LL"]) {
        navigateType = BNCoordinate_BaiduMapSDK;
    }
    else if ([coType isEqualToString:@"WGS84"])
    {
        navigateType = BNCoordinate_OriginalGPS;
    }
    NSMutableArray *nodesArray = [[NSMutableArray alloc]initWithCapacity:2];
    NSArray *startPoints = [startPoint componentsSeparatedByString:@","];
    NSArray *endPoints = [endPoint componentsSeparatedByString:@","];
    //开始点
    BNRoutePlanNode *startNode = [[BNRoutePlanNode alloc] init];
    startNode.pos = [[BNPosition alloc] init];
    startNode.pos.x = [[startPoints objectAtIndex:1] doubleValue];
    startNode.pos.y = [[startPoints objectAtIndex:0] doubleValue];
    startNode.pos.eType = BNCoordinate_BaiduMapSDK;
    [nodesArray addObject:startNode];
    //结束点
    BNRoutePlanNode *endNode = [[BNRoutePlanNode alloc] init];
    endNode.pos = [[BNPosition alloc] init];
    endNode.pos.x = [[endPoints objectAtIndex:1] doubleValue];
    endNode.pos.y = [[endPoints objectAtIndex:0] doubleValue];
    endNode.pos.eType = BNCoordinate_BaiduMapSDK;
    [nodesArray addObject:endNode];
    if (![self checkServicesInited]) return;
    // 不跳转百度地图
    [BNCoreServices_RoutePlan setDisableOpenUrl:YES];
    [BNCoreServices_RoutePlan startNaviRoutePlan:BNRoutePlanMode_Recommend naviNodes:nodesArray time:nil delegete:self userInfo:nil];
    
    [self.EventCenter FireEvent:@"begin" :nil];
}

// 安静退出导航
- (void)stop:(NSArray *)parms
{
    [BNCoreServices_UI exitPage:EN_BNavi_ExitTopVC animated:YES extraInfo:nil];
    
    
}

//算路成功回调
-(void)routePlanDidFinished:(NSDictionary *)userInfo
{
    NSLog(@"算路成功");
    //路径规划成功，开始导航
    [self.EventCenter FireEvent:@"success" :nil];
    //    [BNCoreServices_UI showNaviUI:BN_NaviTypeReal delegete:self isNeedLandscape:YES];
    //    [BNCoreServices_UI showDigitDogUI:YES delegete:self];
    [BNCoreServices_UI showPage:BNaviUI_NormalNavi delegate:self extParams:nil];
    
}


//算路失败回调
- (void)routePlanDidFailedWithError:(NSError *)error andUserInfo:(NSDictionary *)userInfo
{
    
    switch ([error code]%10000)
    {
        case BNAVI_ROUTEPLAN_ERROR_LOCATIONFAILED:
            NSLog(@"暂时无法获取您的位置,请稍后重试");
            break;
        case BNAVI_ROUTEPLAN_ERROR_ROUTEPLANFAILED:
            NSLog(@"无法发起导航");
            break;
        case BNAVI_ROUTEPLAN_ERROR_LOCATIONSERVICECLOSED:
            NSLog(@"定位服务未开启,请到系统设置中打开定位服务。");
            break;
        case BNAVI_ROUTEPLAN_ERROR_NODESTOONEAR:
            NSLog(@"起终点距离起终点太近");
            break;
        default:
            NSLog(@"算路失败");
            break;
    }
    [self.EventCenter FireEvent:@"fail" :nil];
}

//算路取消回调
-(void)routePlanDidUserCanceled:(NSDictionary*)userInfo {
    NSLog(@"算路取消");
}

#pragma mark - BNNaviUIManagerDelegate
//退出导航页面回调
- (void)onExitPage:(BNaviUIType)pageType  extraInfo:(NSDictionary*)extraInfo
{
    if (pageType == BNaviUI_NormalNavi)
    {
        NSLog(@"退出导航");
    }
    else if (pageType == BNaviUI_Declaration)
    {
        NSLog(@"退出导航声明页面");
    }
}

#pragma  mark - 私有方法
- (BOOL)checkServicesInited
{
    if(![BNCoreServices_Instance isServicesInited])
    {
        NSLog(@"引擎尚未初始化完成，请稍后再试");
        return NO;
    }
    return YES;
}


@end
