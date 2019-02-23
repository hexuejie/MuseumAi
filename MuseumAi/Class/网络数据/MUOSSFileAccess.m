//
//  MUOSSFileAccess.m
//  MuseumAi
//
//  Created by Kingo on 2018/10/12.
//  Copyright © 2018年 Weizh. All rights reserved.
//

#import "MUOSSFileAccess.h"
#import <AliyunOSSiOS/OSSService.h>

@implementation MUOSSFileAccess

+ (void)uploadData:(NSData *)data {
    
//    id<OSSCredentialProvider> credential = [[OSSCustomSignerCredentialProvider alloc] initWithImplementedSigner:^NSString *(NSString *contentToSign, NSError *__autoreleasing *error) {
//        // 您需要在这里依照OSS规定的签名算法，实现加签一串字符内容，并把得到的签名传拼接上AccessKeyId后返回
//        // 一般实现是，将字符内容post到您的业务服务器，然后返回签名
//        // 如果因为某种原因加签失败，描述error信息后，返回nil
//        NSString *signature = [OSSUtil calBase64Sha1WithData:contentToSign withSecret:@"<your accessKeySecret>"];
//        // 这里是用SDK内的工具函数进行本地加签，建议您通过业务server实现远程加签
//        if (signature != nil) {
//            *error = nil;
//        } else {
//            *error = [NSError errorWithDomain:@"<your domain>" code:-1001 userInfo:@"<your error info>"];
//            return nil;
//        }
//        return [NSString stringWithFormat:@"OSS %@:%@", @"<your accessKeyId>", signature];
//    }];
//    client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential];
}

@end
