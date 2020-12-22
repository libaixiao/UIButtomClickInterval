//
//  UIControl+ClickInterval.m
//  UIButton点击间隔
//
//  Created by 程天效 on 2020/11/26.
//

#import "UIControl+ClickInterval.h"
#import <objc/runtime.h>
@interface  UIControl()
//是否可以点击
@property(nonatomic,assign)BOOL IsIgnoreClick;
//上次按钮相应的方法名
@property(nonatomic,strong)NSString *oldactionname;
@end
//默认点击间隔
static double DefaultInterval = 1;

static const  NSString *clickIntervalKey       = @"clickIntervalKey";
static const  NSString *IgnoreClickKey         = @"IgnoreClickKey";
static const  NSString *ignoreClickIntervalKey = @"ignoreClickIntervalKey";
static const  NSString *oldactionnameKey       = @"oldactionnameKey";
@implementation UIControl (ClickInterval)
//可以手动添加在项目中
+ (void)ExchangeCLickMethod{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originalsel = @selector(sendAction:to:forEvent:);
        SEL newsel      = @selector(sendclickIntervalAction:to:forEvent:);
        Method originalmethod = class_getInstanceMethod(self, originalsel);
        Method newmethod      = class_getInstanceMethod(self, newsel);
        
        //判断方法是否已经存在,如果已经存在了，返回NO,也可以避免源方法没有存在的情况;如果方法没有存在,我们则先尝试添加被替换的方法实现
        BOOL IsAddNewMethod = class_addMethod(self,
                                              originalsel,
                                              method_getImplementation(newmethod),
                                             "v@:");
        if (IsAddNewMethod) {
            class_replaceMethod(self,
                                newsel,
                                method_getImplementation(originalmethod),
                                "v@:");
        }else{
            method_exchangeImplementations(originalmethod, newmethod);
        }
    });
}

-(void)sendclickIntervalAction:(SEL)action to:(id)target forEvent:(UIEvent*)event{
    if ([self isKindOfClass:[UIButton class]]&&!self.ignoreClickInterval) {
        if (self.clickInterval<=0) {
            self.clickInterval = DefaultInterval;
        }
        
        NSString *currentselname = NSStringFromSelector(action);
        if (self.IsIgnoreClick&&[self.oldactionname isEqualToString:currentselname]) {
            return;
        }
        
        if (self.clickInterval > 0) {
            self.IsIgnoreClick = YES;
            self.oldactionname = currentselname;
            [self performSelector:@selector(ignoreClickState:)
                       withObject:@(NO)
                       afterDelay:self.clickInterval];
        }
    }
    
    [self sendclickIntervalAction:action to:target forEvent:event];
    
}

-(void)ignoreClickState:(NSNumber*)igoreclickstate{
    self.IsIgnoreClick = igoreclickstate.boolValue;
    self.oldactionname = @"";
}

#pragma mark 利用runtime实现属性
- (NSTimeInterval)clickInterval{
//    _cmd 是隐藏的参数，表示当前方法的selector，他和self表示当前方法调用的对象实例。
//    使用_cmd可以直接使用该@selector的名称，即someCategoryMethod，并且能保证改名称不重复
//    return [objc_getAssociatedObject(self, _cmd) boolValue];
    return [objc_getAssociatedObject(self, &clickIntervalKey) doubleValue];
}


- (void)setClickInterval:(NSTimeInterval)clickInterval{
    objc_setAssociatedObject(self,
                             &clickIntervalKey,
                             @(clickInterval),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (BOOL)ignoreClickInterval{
    
    return [objc_getAssociatedObject(self, &ignoreClickIntervalKey) boolValue];
    
}

- (void)setIgnoreClickInterval:(BOOL)ignoreClickInterval{
    objc_setAssociatedObject(self,
                             &ignoreClickIntervalKey,
                             @(ignoreClickInterval),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)IsIgnoreClick{
    return [objc_getAssociatedObject(self, &IgnoreClickKey) boolValue];
}


- (void)setIsIgnoreClick:(BOOL)IsIgnoreClick{
    objc_setAssociatedObject(self,
                             &IgnoreClickKey,
                             @(IsIgnoreClick),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)oldactionname{
    return objc_getAssociatedObject(self,&oldactionnameKey);
}


- (void)setOldactionname:(NSString *)oldactionname{
    objc_setAssociatedObject(self,
                             &oldactionnameKey,
                             oldactionname,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
