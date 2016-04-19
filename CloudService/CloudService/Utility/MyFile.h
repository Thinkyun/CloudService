//
//  MyFile.h
//  备忘录
//
//  Created by apple32 on 15/8/18.
//  Copyright (c) 2015年 蓝桥. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyFile : NSObject

//存入Document目录
+(NSString *)fileDocumentPath: (NSString *)filePath;

//存入Library目录
+(NSString *)fileLibraryPath: (NSString *)filePath;

@end
