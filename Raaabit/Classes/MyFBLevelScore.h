//
//  MyFBLevelScore.h
//  Raaabit
//
//  Created by Dmitry Valov on 23.01.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MyFBLevelScore : NSObject {
    NSString *scoreID;
    NSString *userID;
    NSInteger level;
    NSInteger score;
}

@property (nonatomic, retain) NSString *scoreID;
@property (nonatomic, retain) NSString *userID;
@property NSInteger level;
@property NSInteger score;

@end