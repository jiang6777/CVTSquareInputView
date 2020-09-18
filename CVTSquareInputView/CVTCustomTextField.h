//
//  JQUnitField.h
//  JQUnitField
//
//  Created by hejiangshan on 2020/9/17.
//  Copyright © 2020年 hejiangshan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CVTCustomTextFieldState) {
    CVTCustomTextFieldStateInitial,     //初始状态
    CVTCustomTextFieldStateWaiting,     //等待输入状态
    CVTCustomTextFieldStateFinished,    //输入完成的状态
};

NS_ASSUME_NONNULL_BEGIN

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
    UIKIT_EXTERN NSNotificationName const JQUnitFieldDidBecomeFirstResponderNotification;
    UIKIT_EXTERN NSNotificationName const JQUnitFieldDidResignFirstResponderNotification;
#else
    UIKIT_EXTERN NSString *const JQUnitFieldDidBecomeFirstResponderNotification;
    UIKIT_EXTERN NSString *const JQUnitFieldDidResignFirstResponderNotification;
#endif

typedef NS_ENUM(NSUInteger, CVTKeyboardType) {
    CVTKeyboardTypeNumberPad,   // 纯数字键盘
    CVTKeyboardTypeASCIICapable // ASCII 字符键盘
};

@protocol CVTUnitFieldDelegate;

IB_DESIGNABLE

@interface CVTCustomTextField : UIControl

@property (nullable, nonatomic, weak) id<CVTUnitFieldDelegate> delegate;

/// 每一个输入框的大小，默认为40 * 40
@property (nonatomic, assign) CGSize eachInputViewSize;


/// 输入框的个数，默认为6个,最多为9个
@property (nonatomic, assign) uint8_t inputFieldCount;


/// 输入框之间的间隔大小，默认为10像素
@property (nonatomic, assign) CGFloat inputFieldSpace;


/// 设置输入框的圆角大小, 默认为0
@property (nonatomic, assign) CGFloat cornerRadius;


/// 是否隐藏光标，默认为NO
@property (nonatomic, assign) BOOL isHideCursor;


/// 设置光标的高度，默认为输入框高度的一半
@property (nonatomic, assign) CGFloat cursorHeight;


/// 输入框的文字大小，默认为15号字体
@property (nonatomic, assign) CGFloat inputTextFontSize;


/// 输入框的文字颜色值, 默认为黑色
@property (nonatomic, strong) UIColor *inputTextColor;


/// 是否输入完成自动收起键盘，默认为YES
@property (nonatomic, assign) BOOL autoResignFirstResponderWhenInputFinished;


/// 设置输入框在不同状态下的背景颜色
/// @param color 背景颜色
/// @param state 状态
- (void)setBackgroundColor:(UIColor *)color forState:(CVTCustomTextFieldState)state;


/// 设置边框颜色
/// @param color 边框颜色
/// @param state 状态
- (void)setBorderColor:(UIColor *)color forState:(CVTCustomTextFieldState)state;

@end

@protocol CVTUnitFieldDelegate <NSObject>

@optional

- (BOOL)unitField:(CVTCustomTextField *)uniField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
