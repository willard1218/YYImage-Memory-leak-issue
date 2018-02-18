//
//  NSData+Helper.m
//  YYImage-Memory-leak-issue
//
//  Created by willard on 2018/2/18.
//  Copyright © 2018年 willard. All rights reserved.
//

#import "NSData+Helper.h"
#import <objc/runtime.h>
@implementation NSData (Helper)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = NSSelectorFromString(@"dealloc");
        SEL swizzledSelector = NSSelectorFromString(@"xxx_dealloc");
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        // ...
        // Method originalMethod = class_getClassMethod(class, originalSelector);
        // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)xxx_dealloc {
    NSLog(@"NSData delloc");
    [self xxx_dealloc];
}
@end
