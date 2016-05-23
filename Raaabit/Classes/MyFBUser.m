//
//  MyFBUser.m
//  Raaabit
//
//  Created by Dmitry Valov on 23.01.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MyFBUser.h"
#import "MyFBLevelScore.h"

@implementation MyFBUser

@synthesize userID;
@synthesize userName;
@synthesize userFirstName;
@synthesize score;
@synthesize listOfScores = listOfScores_;

-(id)init {
	if((self = [super init]) != nil) {
        self.userID = @"";
        self.userName = @"";
        self.userFirstName = @"";
        self.score = @"";
        listOfScores_ = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) dealloc {
    self.userID = nil;
    self.userName = nil;
    self.userFirstName = nil;
    self.score = nil;
    
    [listOfScores_ release];
    listOfScores_ = nil;
    
	[super dealloc];
}

- (MyFBLevelScore *) getScoreForLevel: (NSInteger) levelNum {
    MyFBLevelScore *scoreForLevel = nil;
    for(NSUInteger i = 0; i < [listOfScores_ count]; ++i) {
        scoreForLevel = (MyFBLevelScore *)[listOfScores_ objectAtIndex:i];
        if(scoreForLevel.level == levelNum) {
            return scoreForLevel;
        }
    }
    scoreForLevel = [[[MyFBLevelScore alloc] init] autorelease];
    scoreForLevel.score = -1;
    return scoreForLevel;
}

- (NSInteger) getCompletedLevelsCount {
    NSInteger completedLevels = 0;
    MyFBLevelScore *scoreForLevel = nil;
    for(NSUInteger i = 0; i < [listOfScores_ count]; ++i) {
        scoreForLevel = (MyFBLevelScore *)[listOfScores_ objectAtIndex:i];
        if(scoreForLevel.level > completedLevels) {
            completedLevels = scoreForLevel.level;
        }
    }
    return completedLevels;
}

- (MyFBLevelScore *) setScore: (NSInteger) newScore forLevel: (NSInteger) levelNum {
    MyFBLevelScore *scoreForLevel = nil;
    bool existScore = NO;
    for(NSUInteger i = 0; i < [listOfScores_ count]; ++i) {
        scoreForLevel = (MyFBLevelScore *)[listOfScores_ objectAtIndex:i];
        if(scoreForLevel.level == levelNum) {
            existScore = YES;
            if(newScore > scoreForLevel.score) {
                
            }
            return scoreForLevel;
        }
    }
    scoreForLevel = [[[MyFBLevelScore alloc] init] autorelease];
    scoreForLevel.score = -1;
    return scoreForLevel;
}

- (void) addScore: (MyFBLevelScore *) levelScore {
    bool isScoreExist = NO;
    for(NSUInteger i = 0; i < [listOfScores_ count]; ++i) {
        MyFBLevelScore *scoreForLevel = (MyFBLevelScore *)[listOfScores_ objectAtIndex:i];
        if(levelScore.score > 0 && scoreForLevel.score == levelScore.score && scoreForLevel.level == levelScore.level) {
            isScoreExist = YES;
            scoreForLevel.scoreID = levelScore.scoreID;
            break;
        }
    }
    if(!isScoreExist) {
        [listOfScores_ addObject:levelScore];
    }
}

- (void) removeScoreWithID: (NSString *) scoreID {
    for(NSUInteger i = 0; i < [listOfScores_ count]; ++i) {
        MyFBLevelScore *scoreForLevel = (MyFBLevelScore *)[listOfScores_ objectAtIndex:i];
        if([scoreForLevel.scoreID isEqualToString:scoreID]) {
            [listOfScores_ removeObjectAtIndex:i];
            return;
        }
    }
}

@end