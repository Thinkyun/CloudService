//
//  Utility.m
//  OATest
//
//  Created by zhangqiang on 15/9/2.
//  Copyright (c) 2015年 zhangqiang. All rights reserved.
//

#import "Utility.h"
#import "User.h"
#import <MJExtension.h>
#import <CommonCrypto/CommonDigest.h>
#import "CommonCrypto/CommonCryptor.h"
static User *user = nil;

@implementation Utility

+ (User *)shareUser {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *infoDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
        user = [User mj_objectWithKeyValues:infoDict];
    });
    return user;
}

+ (NSString*)sha256WithString:(NSString *)string
{
    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:string.length];
    
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(data.bytes,(uint32_t)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

+ (BOOL)isFirstLoadding {
    
    BOOL flag = [[NSUserDefaults standardUserDefaults] boolForKey:@"isFirstLoadding"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstLoadding"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return !flag;
}

+(void)setLoginStates:(BOOL )isLogin {
    
    [[NSUserDefaults standardUserDefaults] setBool:isLogin forKey:@"isLogin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+(BOOL )isLogin {
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"];
    
}

+ (NSString *)location {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"locate"];
}

+(NSDictionary *)getUserInfoFromLocal
{
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] valueForKey:@"userInfo"];
    return dict;
}

+(void)saveUserInfo:(NSDictionary *)dict
{
    [[NSUserDefaults standardUserDefaults] setValue:dict forKey:@"userInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)saveLocation:(NSString *)locate {
    
    [[NSUserDefaults standardUserDefaults] setValue:locate forKey:@"locate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isRemberPassWord {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"remberPassWord"];
}

+(void)remberPassWord:(BOOL )isRemberPwd {
    
    [[NSUserDefaults standardUserDefaults] setBool:isRemberPwd forKey:@"remberPassWord"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)saveUserName:(NSString *)userName passWord:(NSString *)passWord {
    
    [[NSUserDefaults standardUserDefaults] setValue:userName forKey:@"userName"];
    [[NSUserDefaults standardUserDefaults] setValue:passWord forKey:@"passWord"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+(NSString *)userName {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"userName"];
}

+(NSString *)passWord {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"passWord"];
}

+(void)saveVersion:(BOOL )isNewVersion {
    
    [[NSUserDefaults standardUserDefaults] setBool:isNewVersion forKey:@"isNewVersion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+(BOOL )isNewVersion {
    
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"isNewVersion"];
    
}
+(void)checkNewVersion:(void(^)(BOOL hasNewVersion,NSString *updateUrl))versionCheckBlock{
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    __block double currentVersion = [[infoDict objectForKey:@"CFBundleShortVersionString"] doubleValue];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"iOS" forKey:@"clientType"];
    [MHNetworkManager postReqeustWithURL:kVersionAPI params:@{@"shortcut":@"ddyunfiOS",@"_api_key":@"2bd3be8388f881a5b188e170b623ce39"} successBlock:^(id returnData) {
        NSInteger code = [returnData[@"code"] integerValue];
        switch (code) {
            case 0:{
                NSDictionary *dict = [returnData objectForKey:@"data"];
                double newVersion = [[dict objectForKey:@"appVersion"] doubleValue];
                NSString *appkey = [dict valueForKey:@"appKey"];
                BOOL flag = newVersion > currentVersion;
                NSString *url = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=https://www.pgyer.com/app/plist/%@",appkey];
                
                versionCheckBlock(flag,url);
            }
                
                break;
                
            default:
                break;
        }
        
        
    } failureBlock:^(NSError *error) {
        versionCheckBlock(NO,@"");
    } showHUD:NO];
}

+(void)saveRegistrationID:(NSString *)RegistrationID{

    [[NSUserDefaults standardUserDefaults] setValue:RegistrationID forKey:@"RegistrationID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+(NSString *)RegistrationID {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"RegistrationID"];
}


+ (void)saveUrl:(NSString *)updateUrl {
    
    [[NSUserDefaults standardUserDefaults] setValue:updateUrl forKey:@"updateUrl"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)updateUrl {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"updateUrl"];
}

@end
