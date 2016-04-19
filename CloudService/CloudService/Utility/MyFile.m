//
//  MyFile.m
//  备忘录
//
//  Created by apple32 on 15/8/18.
//  Copyright (c) 2015年 蓝桥. All rights reserved.
//

#import "MyFile.h"

@implementation MyFile
//存入Document目录
+(NSString *)fileDocumentPath: (NSString *)filePath{
    //获取Document目录
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath=[paths objectAtIndex:0];
    AYCLog(@"%@",documentPath);
     NSString *pathStr=[documentPath stringByAppendingString:filePath];
    return pathStr;
}

//存入Library目录
+(NSString *)fileLibraryPath: (NSString *)filePath{
    //获取Document目录
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentPath=[paths objectAtIndex:0];
    NSString *pathStr=[documentPath stringByAppendingString:filePath];
    return pathStr;
}
@end
