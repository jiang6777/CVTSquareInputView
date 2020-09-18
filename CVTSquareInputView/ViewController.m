//
//  ViewController.m
//  CVTSquareInputView
//
//  Created by hejiangshan on 2020/9/17.
//  Copyright © 2020 hejiangshan. All rights reserved.
//


#import "ViewController.h"
#import "CVTCustomTextField.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()

@property (nonatomic, strong) CVTCustomTextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.textField = [[CVTCustomTextField alloc] initWithFrame:CGRectMake(20, 10, kScreenWidth - 40, 60)];
    [self.textField setBorderColor:[UIColor colorWithRed:45/255.0 green:129/255.0 blue:255/255.0 alpha:1.0] forState:CVTCustomTextFieldStateWaiting];
    [self.textField setBackgroundColor:[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0] forState:CVTCustomTextFieldStateInitial];
    self.textField.inputFieldCount = 6;
    self.textField.cornerRadius = 5;
    self.textField.autoResignFirstResponderWhenInputFinished = NO;
    [self.view addSubview:self.textField];
}

- (IBAction)changeSixCodeAction:(UIButton *)sender {
    self.textField.inputFieldCount = 6;
    self.textField.eachInputViewSize = CGSizeMake(40, 40);
}

- (IBAction)changeNineCodeAction:(id)sender {
    self.textField.inputFieldCount = 9;
    self.textField.eachInputViewSize = CGSizeMake(28, 32);
}

- (IBAction)changeNumberKeyboardAction:(id)sender {
    self.textField.inputFieldCount = 9;
}

- (IBAction)mixKeyboardAction:(id)sender {
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view.window endEditing:YES];
}


@end
