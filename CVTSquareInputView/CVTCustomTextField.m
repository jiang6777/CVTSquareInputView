//
//  JQUnitField.m
//  JQUnitField
//
//  Created by hejiangshan on 2020/9/17.
//  Copyright © 2020年 hejiangshan. All rights reserved.
//

#import "CVTCustomTextField.h"

#define kCursor_Tag 10

#define kFillLabel_Tag 11

#define DEFAULT_CONTENT_SIZE_WITH_UNIT_COUNT(c) CGSizeMake(44 * c, 44)

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
    NSNotificationName const JQUnitFieldDidBecomeFirstResponderNotification = @"JQUnitFieldDidBecomeFirstResponderNotification";
    NSNotificationName const JQUnitFieldDidResignFirstResponderNotification = @"JQUnitFieldDidResignFirstResponderNotification";
#else
    NSString *const JQUnitFieldDidBecomeFirstResponderNotification = @"JQUnitFieldDidBecomeFirstResponderNotification";
    NSString *const JQUnitFieldDidResignFirstResponderNotification = @"JQUnitFieldDidResignFirstResponderNotification";
#endif

@interface CVTCustomTextField () <UIKeyInput>


@property (nonatomic, strong) NSMutableArray *textFieldArrays;

@property (nonatomic, strong) NSMutableArray *eachInputStateArrays;

/// 保存不同State下的颜色值
@property (nonatomic, strong) NSMutableDictionary *stateToBacgroundColorDic;

@property (nonatomic, strong) NSMutableDictionary *stateToBorderColorDic;

@property (nonatomic, strong) NSMutableArray *inputStringArray;

@end

@implementation CVTCustomTextField

@synthesize secureTextEntry = _secureTextEntry;
@synthesize enablesReturnKeyAutomatically = _enablesReturnKeyAutomatically;
@synthesize keyboardType = _keyboardType;
@synthesize returnKeyType = _returnKeyType;

#pragma mark - Life
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _initParams];
        [self _initSubViews];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _initParams];
        [self _initSubViews];
    }
    
    return self;
}

- (void)_initParams {
    _eachInputViewSize = CGSizeMake(40, 40);
    _inputFieldCount = 6;
    _inputFieldSpace = 10;
    _cornerRadius = 0;
    _isHideCursor = NO;
    _cursorHeight = 20;
    _inputTextFontSize = 15;
    _inputTextColor = [UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0];
    _stateToBacgroundColorDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], @(CVTCustomTextFieldStateInitial), [UIColor whiteColor], @(CVTCustomTextFieldStateWaiting), [UIColor colorWithRed:238.0/255 green:238.0/255 blue:238.0/255 alpha:1.0], @(CVTCustomTextFieldStateFinished), nil];
    _stateToBorderColorDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[UIColor clearColor], @(CVTCustomTextFieldStateInitial), [UIColor clearColor], @(CVTCustomTextFieldStateWaiting), [UIColor clearColor], @(CVTCustomTextFieldStateFinished), nil];
    _inputStringArray = [NSMutableArray array];
    _autoResignFirstResponderWhenInputFinished = YES;
}

- (void)_initSubViews {
    self.textFieldArrays = [NSMutableArray array];
    self.eachInputStateArrays = [NSMutableArray array];
    [self createView];
    [self becomeFirstResponder];
}

- (void)createView {
    for (int i = 0; i < self.inputFieldCount; i++) {
        [self.eachInputStateArrays addObject:@(CVTCustomTextFieldStateInitial)];
    }
    self.eachInputStateArrays[0] = @(CVTCustomTextFieldStateWaiting);
    for (int i = 0; i < self.inputFieldCount; i++) {
        CVTCustomTextFieldState state = (CVTCustomTextFieldState)[self.eachInputStateArrays[i] integerValue];
        UIView *customTextFieldView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
//        customTextFieldView.backgroundColor = [UIColor whiteColor];
        [self addSubview:customTextFieldView];
        [self.textFieldArrays addObject:customTextFieldView];
        if (_cornerRadius > 0) {
            customTextFieldView.layer.cornerRadius = _cornerRadius;
            customTextFieldView.layer.masksToBounds = YES;
        }
        
        UIView *cursorLineView = [[UIView alloc] initWithFrame:CGRectZero];
        cursorLineView.backgroundColor = [UIColor colorWithRed:34.0/255.0 green:34.0/255.0 blue:34.0/255.0 alpha:1.0];
        cursorLineView.tag = kCursor_Tag;
        [customTextFieldView addSubview:cursorLineView];
        
        UILabel *fillLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        fillLabel.font = [UIFont systemFontOfSize:_inputTextFontSize];
        fillLabel.textColor = _inputTextColor;
        fillLabel.tag = kFillLabel_Tag;
        fillLabel.textAlignment = NSTextAlignmentCenter;
        [customTextFieldView addSubview:fillLabel];
        
        [self updateState:state withCustomTextFiledView:customTextFieldView];
    }
}

- (void)updateState:(CVTCustomTextFieldState)state withCustomTextFiledView:(UIView *)textFiled {
    UIView *cursorLineView = [textFiled viewWithTag:kCursor_Tag];
    UILabel *fillLabel = [textFiled viewWithTag:kFillLabel_Tag];
    textFiled.backgroundColor = [self.stateToBacgroundColorDic objectForKey:@(state)];
    textFiled.layer.borderWidth = 1.0;
    textFiled.layer.borderColor = ((UIColor *)[self.stateToBorderColorDic objectForKey:@(state)]).CGColor;
    switch (state) {
        case CVTCustomTextFieldStateInitial:
        {
            cursorLineView.hidden = YES;
            fillLabel.hidden = YES;
        }
            break;
        case CVTCustomTextFieldStateWaiting:
        {
            cursorLineView.hidden = _isHideCursor;
            fillLabel.hidden = YES;
            [self startCursorAnimation:cursorLineView];
        }
            break;
        case CVTCustomTextFieldStateFinished:
        {
            cursorLineView.hidden = YES;
            fillLabel.hidden = NO;
        }
            break;
            
        default:
            break;
    }
}

- (void)setEachInputViewSize:(CGSize)eachInputViewSize
{
    _eachInputViewSize = eachInputViewSize;
    NSInteger index = 0;
    for (int i = 0; i < self.eachInputStateArrays.count; i++) {
        CVTCustomTextFieldState state = (CVTCustomTextFieldState)[self.eachInputStateArrays[i] integerValue];
        if (state == CVTCustomTextFieldStateWaiting) {
            index = i;
            break;
        }
    }
    UIView *customTextFieldView = (UIView *)[self.textFieldArrays objectAtIndex:index];
    [self stopCursorAnimation:[customTextFieldView viewWithTag:11]];
    [self layoutAllSubView];
    [self startCursorAnimation:[customTextFieldView viewWithTag:11]];
}

- (void)setInputFieldCount:(uint8_t)inputFieldCount
{
    if (inputFieldCount <= 0 || inputFieldCount > 9) {
        return;
    }
    _inputFieldCount = inputFieldCount;
    for (UIView *textFieldView in self.textFieldArrays) {
        [textFieldView removeFromSuperview];
    }
    [self.textFieldArrays removeAllObjects];
    [self.eachInputStateArrays removeAllObjects];
    [self.inputStringArray removeAllObjects];
    [self createView];
    [self layoutAllSubView];
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    if (cornerRadius < 0 || cornerRadius >= _eachInputViewSize.width) {
        return;
    }
    _cornerRadius = cornerRadius;
    for (UIView *textFieldView in self.textFieldArrays) {
        if (cornerRadius == 0) {
            textFieldView.layer.cornerRadius = 0;
        } else {
            textFieldView.layer.cornerRadius = _cornerRadius;
        }
        textFieldView.layer.masksToBounds = YES;
    }
}

- (void)setIsHideCursor:(BOOL)isHideCursor
{
    _isHideCursor = isHideCursor;
    for (int i = 0; i < self.textFieldArrays.count; i++) {
        CVTCustomTextFieldState state = (CVTCustomTextFieldState)[self.eachInputStateArrays[i] integerValue];
        UIView *customTextField = self.textFieldArrays[i];
        UIView *sursorLineView = [customTextField viewWithTag:kCursor_Tag];
        if (_isHideCursor) {
            sursorLineView.hidden = YES;
            if (state == CVTCustomTextFieldStateWaiting) {
                [self stopCursorAnimation:sursorLineView];
            }
        } else {
            [self updateState:state withCustomTextFiledView:customTextField];
        }
    }
}

- (void)setCursorHeight:(CGFloat)cursorHeight
{
    if (cursorHeight > _eachInputViewSize.height) {
        cursorHeight = _eachInputViewSize.height;
    }
    if (cursorHeight < 0) {
        return;
    }
    _cursorHeight = cursorHeight;
    for (int i = 0; i < self.textFieldArrays.count; i++) {
        UIView *customTextField = self.textFieldArrays[i];
        UIView *sursorLineView = [customTextField viewWithTag:kCursor_Tag];
        sursorLineView.frame = CGRectMake(CGRectGetMinX(sursorLineView.frame), (CGRectGetHeight(customTextField.frame) - _cursorHeight)/2, 1, _cursorHeight);
    }
}

- (void)setInputTextFontSize:(CGFloat)inputTextFontSize
{
    if (inputTextFontSize <= 0) {
        return;
    }
    _inputTextFontSize = inputTextFontSize;
    for (int i = 0; i < self.textFieldArrays.count; i++) {
        UIView *customTextField = self.textFieldArrays[i];
        UILabel *fillLabel = (UILabel *)[customTextField viewWithTag:kFillLabel_Tag];
        fillLabel.font = [UIFont systemFontOfSize:inputTextFontSize];
    }
}

- (void)setInputTextColor:(UIColor *)inputTextColor
{
    _inputTextColor = inputTextColor;
    for (int i = 0; i < self.textFieldArrays.count; i++) {
        UIView *customTextField = self.textFieldArrays[i];
        UILabel *fillLabel = (UILabel *)[customTextField viewWithTag:kFillLabel_Tag];
        fillLabel.textColor = _inputTextColor;
    }
}

 /// 设置输入框在不同状态下的背景颜色
 /// @param color 背景颜色
 /// @param state 状态
 - (void)setBackgroundColor:(UIColor *)color forState:(CVTCustomTextFieldState)state
{
    [self.stateToBacgroundColorDic setObject:color forKey:@(state)];
    for (int i = 0; i < self.textFieldArrays.count; i++) {
        CVTCustomTextFieldState state = (CVTCustomTextFieldState)[[self.eachInputStateArrays objectAtIndex:i] integerValue];
        UIView *customTextField = self.textFieldArrays[i];
        [self updateState:state withCustomTextFiledView:customTextField];
    }
}

 /// 设置边框颜色
 /// @param color 边框颜色
 /// @param state 状态
 - (void)setBorderColor:(UIColor *)color forState:(CVTCustomTextFieldState)state
{
    [self.stateToBorderColorDic setObject:color forKey:@(state)];
    for (int i = 0; i < self.textFieldArrays.count; i++) {
        CVTCustomTextFieldState state = (CVTCustomTextFieldState)[[self.eachInputStateArrays objectAtIndex:i] integerValue];
        UIView *customTextField = self.textFieldArrays[i];
        [self updateState:state withCustomTextFiledView:customTextField];
    }
}

- (void)startCursorAnimation:(UIView *)aniSuperView {
    CABasicAnimation *basicAnima = [CABasicAnimation animationWithKeyPath:@"opacity"];
    basicAnima.fromValue = @0;
    basicAnima.toValue = @1.0;
    basicAnima.duration = 0.8;
    basicAnima.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    basicAnima.autoreverses = YES;
    basicAnima.removedOnCompletion = NO;
    basicAnima.repeatCount = MAXFLOAT;
    [aniSuperView.layer addAnimation:basicAnima forKey:nil];
}

- (void)stopCursorAnimation:(UIView *)aniSuperView {
    [aniSuperView.layer removeAllAnimations];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutAllSubView];
}

- (void)layoutAllSubView {
    CGFloat side = (CGRectGetWidth(self.frame) - (self.inputFieldCount - 1) * self.inputFieldSpace - self.eachInputViewSize.width * self.inputFieldCount)/2;
    for (UIView *customTextFiled in self.textFieldArrays) {
        NSInteger index = [self.textFieldArrays indexOfObject:customTextFiled];
        customTextFiled.frame = CGRectMake(side + index * self.inputFieldSpace + index * self.eachInputViewSize.width, (CGRectGetHeight(self.frame) - self.eachInputViewSize.height)/2, self.eachInputViewSize.width, self.eachInputViewSize.height);
        UIView *cursorLineView = [customTextFiled viewWithTag:kCursor_Tag];
        UILabel *fillLabel = [customTextFiled viewWithTag:kFillLabel_Tag];
        cursorLineView.frame = CGRectMake((CGRectGetWidth(customTextFiled.frame) - 1)/2, (CGRectGetHeight(customTextFiled.frame) - _cursorHeight)/2, 1, _cursorHeight);
        fillLabel.frame = customTextFiled.bounds;
    }
}

#pragma mark - Property
- (NSString *)text {
    if (_inputStringArray.count == 0) return nil;
    return [_inputStringArray componentsJoinedByString:@""];
}

#pragma mark- Event
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self becomeFirstResponder];
}

#pragma mark - Override
- (BOOL)canBecomeFirstResponder {
    NSLog(@"%s", __func__);
    return YES;
}

- (BOOL)becomeFirstResponder {
    NSLog(@"%s", __func__);
    BOOL result = [super becomeFirstResponder];
//    [self _showOrHideCursorIfNeeded];
    
//    if (result ==  YES) {
////        [self sendActionsForControlEvents:UIControlEventEditingDidBegin];
//        [[NSNotificationCenter defaultCenter] postNotificationName:JQUnitFieldDidBecomeFirstResponderNotification object:nil];
//    }
//    return result;
    return result;
}

- (BOOL)canResignFirstResponder {
    NSLog(@"%s", __func__);
    return YES;
}

- (BOOL)resignFirstResponder {
    NSLog(@"%s", __func__);
    BOOL result = [super resignFirstResponder];
//    [self _showOrHideCursorIfNeeded];
    
    if (result) {
        [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
        [[NSNotificationCenter defaultCenter] postNotificationName:JQUnitFieldDidResignFirstResponderNotification object:nil];
    }
    return result;
}

#pragma mark - UIKeyInput
- (BOOL)hasText {
    return _inputStringArray != nil && _inputStringArray.count > 0;
}

- (void)insertText:(NSString *)text {
    NSLog(@"text: %@\n", text);
    if (_inputStringArray.count >= _inputFieldCount) {
        if (_autoResignFirstResponderWhenInputFinished == YES) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self resignFirstResponder];
            }];
        }
        return;
    }

    if ([text isEqualToString:@" "]) {
        return;
    }

    if ([self.delegate respondsToSelector:@selector(unitField:shouldChangeCharactersInRange:replacementString:)]) {
        if ([self.delegate unitField:self shouldChangeCharactersInRange:NSMakeRange(_inputStringArray.count - 1, 1) replacementString:text] == NO) {
            return;
        }
    }

    NSRange range;
    BOOL addSuccess = NO;
    for (int i = 0; i < text.length; i += range.length) {
        range = [text rangeOfComposedCharacterSequenceAtIndex:i];
        [_inputStringArray addObject:[text substringWithRange:range]];
        addSuccess = YES;
    }

    if (_inputStringArray.count >= _inputFieldCount) {
        [_inputStringArray removeObjectsInRange:NSMakeRange(_inputFieldCount, _inputStringArray.count - _inputFieldCount)];
        [self sendActionsForControlEvents:UIControlEventEditingChanged];

        if (_autoResignFirstResponderWhenInputFinished == YES) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self resignFirstResponder];
            }];
        }
    } else {
        [self sendActionsForControlEvents:UIControlEventEditingChanged];
    }
    [self updateKeyboardInput];
}

- (void)deleteBackward {
    NSLog(@"delete text");
    if ([self hasText] == NO)
        return;

    if ([self.delegate respondsToSelector:@selector(unitField:shouldChangeCharactersInRange:replacementString:)]) {
        if ([self.delegate unitField:self shouldChangeCharactersInRange:NSMakeRange(_inputStringArray.count - 1, 0) replacementString:@""] == NO) {
            return;
        }
    }
    [_inputStringArray removeLastObject];
    [self updateKeyboardInput];
    
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
    
}

- (void)updateKeyboardInput {
    NSInteger inputStringCount = self.inputStringArray.count;
    NSInteger index = 0;
    for (int i = 0; i < self.eachInputStateArrays.count; i++) {
        CVTCustomTextFieldState state = (CVTCustomTextFieldState)[self.eachInputStateArrays[i] integerValue];
        if (state == CVTCustomTextFieldStateWaiting) {
            index = i;
            break;
        }
    }
    UIView *customTextFieldView = (UIView *)[self.textFieldArrays objectAtIndex:index];
    [self stopCursorAnimation:[customTextFieldView viewWithTag:11]];
    for (int i = 0; i < self.textFieldArrays.count; i++) {
        UIView *customTextFieldView = [self.textFieldArrays objectAtIndex:i];
        UILabel *fullLabel = [customTextFieldView viewWithTag:kFillLabel_Tag];
        CVTCustomTextFieldState state = CVTCustomTextFieldStateInitial;
        if (i < inputStringCount) {
            NSString *inputString = self.inputStringArray[i];
            fullLabel.text = inputString;
            state = CVTCustomTextFieldStateFinished;
        } else if (i == inputStringCount) {
            state = CVTCustomTextFieldStateWaiting;
        } else {
            fullLabel.text = @"";
        }
        [self.eachInputStateArrays replaceObjectAtIndex:i withObject:@(state)];
        [self updateState:state withCustomTextFiledView:customTextFieldView];
    }
}

- (UIKeyboardType)keyboardType {
    NSLog(@"%s", __func__);
//    if (_defaultKeyboardType == JQKeyboardTypeASCIICapable) {
//        return UIKeyboardTypeASCIICapable;
//    }
    return UIKeyboardTypeNumberPad;
}

- (UITextAutocorrectionType)autocorrectionType {
    NSLog(@"%s", __func__);
    return UITextAutocorrectionTypeNo;
}

- (UIReturnKeyType)returnKeyType {
    NSLog(@"%s", __func__);
    return UIReturnKeyDone;
}

@end
