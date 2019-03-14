//
//  WindowInfoManager.h
//  test
//
//  Created by mgfjx on 2019/3/12.
//  Copyright © 2019 mgfjx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WindowInfoManager : NSObject

+ (instancetype)manager ;

- (void)addToWindow:(UIWindow *)window ;

@end

@interface UIViewController (getName)

@end
