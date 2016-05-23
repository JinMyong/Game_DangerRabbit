//
//  GameProgressController.h
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright Dmitry Valov 2013. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"

@interface GameProgressController : CCNode {
    NSMutableArray  *starsInWorld;
    NSMutableArray  *scoresInWorld;
    NSMutableArray  *openedLevelsInWorld;
    NSMutableArray  *chaptersProgress;
    
}

@property (nonatomic, retain) NSMutableArray *starsInWorld;
@property (nonatomic, retain) NSMutableArray *scoresInWorld;
@property (nonatomic, retain) NSMutableArray *openedLevelsInWorld;
@property (nonatomic, retain) NSMutableArray *chaptersProgress;

+ (GameProgressController*) sharedGProgressCtrl;

- (void) load;
- (void) save;

- (NSInteger) getStarsCount;
- (void)setScore:(NSInteger)score forLevel:(NSInteger)level withStars:(NSInteger)stars withCarrots:(NSInteger) carrots;
- (NSInteger) getStarsForLevel: (NSInteger) level;
- (NSInteger) getScoresForWorld:(NSInteger) worldNum;
- (NSInteger) getScoreForLevel: (NSInteger) level;
- (void) zeroProgress;
- (BOOL) isProgress;
- (NSInteger)getFullScores;
- (NSInteger) getCompletedLevelsForDifficulty: (NSInteger) difficulty;
- (NSInteger) getCompletedLevelsForChapter: (NSInteger) chapterNum;
- (NSInteger) getStarsForWorld:(NSInteger) worldNum;
- (void) loadDifficulty: (NSInteger) difficulty;

@end