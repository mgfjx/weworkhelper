//
//  WindowInfoManager.m
//  test
//
//  Created by mgfjx on 2019/3/12.
//  Copyright © 2019 mgfjx. All rights reserved.
//

#import "WindowInfoManager.h"

static WindowInfoManager *manager ;

@interface WindowInfoManager ()

@property (nonatomic, strong) UIWindow *window ;
@property (nonatomic, strong) UITextView *textView ;

@end

@implementation WindowInfoManager

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [WindowInfoManager new];
    });
    return manager;
}

- (void)addToWindow:(UIWindow *)superWindow {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 64, 150, 150)];
        [superWindow addSubview:window];
        [window makeKeyAndVisible];
        self.window = window;
        
        UITextView *textView = [[UITextView alloc] initWithFrame:window.bounds];
        textView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        textView.editable = NO;
        textView.textColor = [UIColor whiteColor];
        [window addSubview:textView];
        textView.layoutManager.allowsNonContiguousLayout = NO;
        self.textView = textView;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appendText:) name:@"kNotificationVCLoad" object:nil];
    });
    
}

- (void)appendText:(NSNotification *)notification {
    
    NSString *text = (NSString *)notification.object;
    
    NSString *content = self.textView.text;
    self.textView.text = [NSString stringWithFormat:@"%@%@\n",content,text];
    [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length, 1)];
    
}

@end


#import <objc/runtime.h>

@implementation UIViewController (getName)

+ (void)load {
    Method m1 = class_getInstanceMethod([self class], @selector(viewDidLoad));
    Method m2 = class_getInstanceMethod([self class], @selector(ex_viewDidLoad));
    method_exchangeImplementations(m1, m2);
}

- (void)ex_viewDidLoad {
    /*
    NSMutableString *string = [NSMutableString string];
    for (UIViewController *vc in self.navigationController.viewControllers) {
        [string appendString:NSStringFromClass([vc class])];
        [string appendString:@","];
    }
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationVCLoad" object:NSStringFromClass([self class])];
    [self ex_viewDidLoad];
}

@end
