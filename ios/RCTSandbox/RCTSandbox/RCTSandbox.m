//
//  RCTSandbox.m
//  RCTSandbox
//
//  Created by 福有李 on 17/7/26.
//  Copyright © 2017年 福有李. All rights reserved.
//

#import "RCTSandbox.h"

@implementation RCTSandboxBridgeModel

RCT_EXPORT_MODULE(SandboxModule);
//*获取某个目录下的文件列表*/
//RCT_EXPORT_METHOD(fileListWithPath:(NSString *)filePath resolver:(RCTPromiseResolveBlock)resolve
//                  rejecter:(RCTPromiseRejectBlock)reject){
//    resolve(@[@"123",@"1223"]);
//    return;
//}

//获取文件列表
/**{
 type:directory  | application/img ....
 url: /User/.../document.doc
 name:文件名
}
 */
RCT_REMAP_METHOD(fileListWithPath,filePath:(NSString *)filePath resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject){

    NSLog(@"filePath = %@",filePath);
//
//    resolve(@[@{@"name":@"123"}]);
//    return;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSError *error = nil;
    NSArray *fileList = [fm contentsOfDirectoryAtPath:filePath error:&error];
    
    NSMutableArray *urls = @[].mutableCopy;
    
    for (NSString *fileName in fileList) {
        [urls addObject:[self getPath:filePath fileName:fileName]];
    }
    
    fileList = urls;
    
    if (error == nil) {
        
        NSMutableArray *result = [NSMutableArray array];
        for (NSString *filePath in fileList) {
            NSMutableDictionary *dic = @{}.mutableCopy;
            [dic setObject:filePath forKey:@"url"];
            [dic setObject:[filePath lastPathComponent] forKey:@"name"];
            NSString *type = nil;
            
            
            BOOL isDirectory = NO;
            [fm fileExistsAtPath:filePath isDirectory:&isDirectory];
            if (isDirectory) {
                [dic setObject:@"directory" forKey:@"type"];
            }else{
                [dic setObject:[self getMIMETypeURLRequestAtPath:filePath] forKey:@"type"];
            };
            
            [result addObject:dic];
            
        }
        //获分目录或文件
        resolve(result);
    }else{
        reject([NSString stringWithFormat:@"%d",error.code],error.localizedDescription,error);
    }
}

RCT_REMAP_METHOD(deleteFile, deleteFilePath:(NSString *)filePath resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject){
    NSFileManager *fm = [NSFileManager defaultManager];

    NSError *error = nil;
    if([fm removeItemAtPath:filePath error:&error]){
        resolve(@YES);
    }else{
        reject([NSString stringWithFormat:@"%d",error.code],error.localizedDescription,error);
    };
}

RCT_REMAP_METHOD(copy, from:(NSString *)from to:(NSString *)to resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject){
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm copyItemAtURL:[NSURL fileURLWithPath:from] toURL:[NSURL fileURLWithPath:to] error:&error]){
        resolve(@YES);
    }else{
        reject([NSString stringWithFormat:@"%d",error.code],error.localizedDescription,error);
    };
}


//  进行设置封装常量给JavaScript进行调用，//**获取根目录*/
-(NSDictionary *)constantsToExport
{
    // 此处定义的常量为js订阅原生通知的通知名
    return @{@"RCTSandboxRootDir":NSHomeDirectory(),@"RCTSandboxDocumentDir":NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject};
}


-(NSString *)getPath:(NSString *)basePath fileName:(NSString *)fileName{
    if ([basePath hasSuffix:@"/"]) {
        return [NSString stringWithFormat:@"%@%@",basePath,fileName];
    }else{
        return [NSString stringWithFormat:@"%@/%@",basePath,fileName];
    }
}
//向该文件发送请求,根据请求头拿到该文件的MIMEType
 -(NSString *)getMIMETypeURLRequestAtPath:(NSString*)path
{
     //1.确定请求路径
    NSURL *url = [NSURL fileURLWithPath:path];
    //2.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //3.发送请求
    NSHTTPURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSString *mimeType = response.MIMEType;
    
    if (mimeType == nil) {
        return @"application/stream";
    }
    return mimeType;
}
@end
