//
//  UIView+TABLayerout.m
//  AnimatedDemo
//
//  Created by tigerAndBull on 2018/9/21.
//  Copyright © 2018年 tigerAndBull. All rights reserved.
//

#import "UIView+TABLayerout.h"
#import "UIView+Animated.h"
#import "TABViewAnimated.h"
#import "TABMethod.h"
#import <objc/runtime.h>

@implementation UIView (TABLayerout)

+ (void)load {
    
    //Ensure that the exchange method executed only once.
    //保证交换方法只执行一次
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        //Gets the viewDidLoad method to the class,whose type is a pointer to a objc_method structure.
        //获取到这个类的viewDidLoad方法，它的类型是一个objc_method结构体的指针
        Method  originMethod = class_getInstanceMethod([self class], @selector(layoutSubviews));
        
        //Get the method you created.
        //获取自己创建的方法
        Method newMethod = class_getInstanceMethod([self class], @selector(tab_layoutSubviews));
        
        IMP newIMP = method_getImplementation(newMethod);
        
        BOOL isAdd = class_addMethod([self class], @selector(tab_layoutSubviews), newIMP, method_getTypeEncoding(newMethod));
        
        if (isAdd) {
            
            //replace
            class_replaceMethod([self class], @selector(layoutSubviews), newIMP, method_getTypeEncoding(newMethod));
        }else {
            //exchange
            method_exchangeImplementations(originMethod, newMethod);
        }
    });
}

#pragma mark -  Exchange Method

- (void)tab_layoutSubviews {
    
    [self tab_layoutSubviews];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.animatedStyle != TABViewAnimationDefault) {
            
            for (int i = 0; i < self.subviews.count; i++) {
                
                UIView *v = self.subviews[i];
                
                if (v.loadStyle != TABViewLoadAnimationDefault) {
                    if (v.frame.size.width == 0) {
                        if (v.loadStyle == TABViewLoadAnimationShort) {
                            v.frame = CGRectMake(v.frame.origin.x, v.frame.origin.y, v.tabViewWidth>0?v.tabViewWidth:200, v.frame.size.height);
                        }else {
                            if (v.loadStyle == TABViewLoadAnimationLong) {
                                v.frame = CGRectMake(v.frame.origin.x, v.frame.origin.y, v.tabViewWidth>0?v.tabViewWidth:130, v.frame.size.height);
                            }
                        }
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( self.animatedStyle != TABViewAnimationRuning ) {
                    //运行动画/移除动画
                    [[TABViewAnimated sharedAnimated]startOrEndViewAnimated:self];
                }
            });
        }
    });
}

@end
