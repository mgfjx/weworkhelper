//
//  MainKeyMananer.h
//  test
//
//  Created by mgfjx on 2019/3/17.
//  Copyright © 2019 mgfjx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainKeyMananer : NSObject

+ (instancetype)manager ;

@property (nonatomic, assign) BOOL on ;
@property (nonatomic, assign) BOOL fakeLocation ;
@property (nonatomic, assign) BOOL selectFromAlbum ;
@property (nonatomic, assign) BOOL photoEdit ;

@end
