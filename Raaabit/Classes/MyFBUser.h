//
//  MyFBUser.h
//  Raaabit
//
//  Created by Dmitry Valov on 23.01.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class MyFBLevelScore;

@interface MyFBUser : NSObject {

    NSString *userID;
    NSString *userName;
    NSString *userFirstName;
    NSString *score;
    
    NSMutableArray *listOfScores_;
}

@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *userFirstName;
@property (nonatomic, retain) NSString *score;

@property (nonatomic, retain) NSMutableArray *listOfScores;

- (MyFBLevelScore *) getScoreForLevel: (NSInteger) levelNum;
- (NSInteger) getCompletedLevelsCount;
- (MyFBLevelScore *) setScore: (NSInteger) newScore forLevel: (NSInteger) levelNum;
- (void) addScore: (MyFBLevelScore *) levelScore;
- (void) removeScoreWithID: (NSString *) scoreID;

@end