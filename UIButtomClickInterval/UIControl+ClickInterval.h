//
//  UIControl+ClickInterval.h
//  UIButton点击间隔
//
//  Created by 程天效 on 2020/11/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIControl (ClickInterval)
//点击事件响应的时间间隔,不设置或者大于0时为默认间隔
@property(nonatomic,assign)NSTimeInterval clickInterval;
//是否忽略相应的时间间隔
@property(nonatomic,assign)BOOL ignoreClickInterval;
+(void)ExchangeCLickMethod;
@end

NS_ASSUME_NONNULL_END
