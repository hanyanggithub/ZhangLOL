//
//  BaseModel.m
//  ZhangLOL
//
//  Created by mac on 17/4/4.
//  Copyright © 2017年 rengukeji. All rights reserved.
//

#import "BaseModel.h"
#import <objc/runtime.h>

@implementation BaseModel

- (instancetype)initWithDic:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        for (NSString *key in dic) {
            NSString *str1 = [key substringToIndex:1];
            NSString *str2 = [key substringFromIndex:1];
            SEL sel = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:",str1.uppercaseString,str2]);
            id value = [dic objectForKey:key];
            if ([self respondsToSelector:sel] && value != nil) {
                // 跑模拟器可以，真机crash
//                void (*funtion)(id ,SEL, ...) = (void *)[self methodForSelector:sel];
//                funtion(self,sel,value);
                
                
                void (*funtion)(id ,SEL, id) = (void *)[self methodForSelector:sel];
                funtion(self,sel,value);
                
//                IMP imp =  [self methodForSelector:sel];
//                void (*funtion)(id ,SEL, id) = (void *)imp;
//                funtion(self,sel,value);

                
//                #pragma clang diagnostic push
//                #pragma clang diagnostic ignored"-Warc-performSelector-leaks"
//                [self performSelector:sel withObject:value];
//                
//                #pragma clang diagnostic pop
            }
        }
    }
    return self;
}
- (NSMutableDictionary *)transitionToDic {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    Class selfClass = [self class];
    unsigned int propertyCount;
    objc_property_t *pArray = class_copyPropertyList(selfClass, &propertyCount);
    for (int i = 0; i < propertyCount; i++) {
        objc_property_t property = pArray[i];
        const char *property_name = property_getName(property);
        NSString *propertyName = [[NSString alloc] initWithUTF8String:property_name];
        SEL sel = NSSelectorFromString(propertyName);
        id (*funtion)(id ,SEL) = (void *)[self methodForSelector:sel];
        id result = funtion(self,sel);
        if (result) {
            [dic setObject:result forKey:propertyName];
        }
    }
    free(pArray);
    return dic;
}
@end
