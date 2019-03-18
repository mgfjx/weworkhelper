//
//  MainKeyMananer.m
//  test
//
//  Created by mgfjx on 2019/3/17.
//  Copyright © 2019 mgfjx. All rights reserved.
//

#import "MainKeyMananer.h"

@implementation MainKeyMananer

static id singleton = nil;

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    if (!singleton) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            singleton = [super allocWithZone:zone];
            NSObject *obj = [[NSUserDefaults standardUserDefaults] objectForKey:@"kSwitchOn"];
            if (!obj) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kFakeLocation"];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kSwitchOn"];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kSelectFromAlbum"];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kPhotoEdit"];
            }
        });
    }
    return singleton;
}

- (instancetype)init{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [super init];
    });
    return singleton;
}

- (id)copyWithZone:(NSZone *)zone{
    return singleton;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    return singleton;
}

+ (instancetype)manager{
    return [[self alloc] init];
}

- (BOOL)on {
    BOOL open = [[NSUserDefaults standardUserDefaults] boolForKey:@"kSwitchOn"];
    return open;
}

- (void)setOn:(BOOL)on {
    [[NSUserDefaults standardUserDefaults] setBool:on forKey:@"kSwitchOn"];
}

- (BOOL)fakeLocation {
    BOOL open = [[NSUserDefaults standardUserDefaults] boolForKey:@"kFakeLocation"];
    return open;
}

- (void)setFakeLocation:(BOOL)fakeLocation {
    [[NSUserDefaults standardUserDefaults] setBool:fakeLocation forKey:@"kFakeLocation"];
}

- (BOOL)selectFromAlbum {
    BOOL open = [[NSUserDefaults standardUserDefaults] boolForKey:@"kSelectFromAlbum"];
    return open;
}

- (void)setSelectFromAlbum:(BOOL)selectFromAlbum {
    [[NSUserDefaults standardUserDefaults] setBool:selectFromAlbum forKey:@"kSelectFromAlbum"];
}

- (BOOL)photoEdit {
    BOOL open = [[NSUserDefaults standardUserDefaults] boolForKey:@"kPhotoEdit"];
    return open;
}

- (void)setPhotoEdit:(BOOL)photoEdit {
    [[NSUserDefaults standardUserDefaults] setBool:photoEdit forKey:@"kPhotoEdit"];
}

@end
