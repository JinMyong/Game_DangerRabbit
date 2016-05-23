//
//  GameProgressController.m
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright Dmitry Valov 2013. All rights reserved.
//

#import "GameProgressController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "GameController.h"

#define kOpenedLevelsInWorldKey     @"OpenedLevelsInWorld_%d"
#define kProgressChapterKey         @"ProgressChapter_%d"

#define kScoresKey                  @"Scores"
#define kStarsKey                   @"Stars"
#define kCarrotsKey                 @"Carrots"

#define kProgressFileNameEasy			@"progressEasy.plist"
#define kProgressFileNameMedium			@"progressMedium.plist"
#define kProgressFileNameHard			@"progressHard.plist"

#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@implementation GameProgressController

@synthesize starsInWorld;
@synthesize scoresInWorld;
@synthesize openedLevelsInWorld;
@synthesize chaptersProgress;

static GameProgressController *gameProgressControllerInstance;

+ (GameProgressController*) sharedGProgressCtrl {
	return gameProgressControllerInstance;
}

- (id) init {
	if ((self = [super init]) != nil) {
		gameProgressControllerInstance = self;
        self.starsInWorld = [NSMutableArray array];
        self.scoresInWorld = [NSMutableArray array];
        self.openedLevelsInWorld = [NSMutableArray array];
        self.chaptersProgress = [NSMutableArray array];
        
        for(int i = 0; i < kAreasCount; ++i) {
            [starsInWorld insertObject:[NSNumber numberWithInt:0] atIndex:i];
            [scoresInWorld insertObject:[NSNumber numberWithInt:0] atIndex:i];
        }
        [self load];

        for(int i = 0; i < kAreasCount; ++i) {
            [self updateStarsForWorld:i + 1];
        }
	}
	return self;
}

-(void)dealloc {
	[self save];

    self.starsInWorld = nil;
    self.scoresInWorld = nil;
    self.openedLevelsInWorld = nil;
    for(int i = 0; i < [chaptersProgress count]; ++i) {
        [[self.chaptersProgress objectAtIndex:i] release];
    }
    self.chaptersProgress = nil;
	[super dealloc];
}

-(void)load {
    NSString *filePath = [DOCUMENTS stringByAppendingPathComponent:kProgressFileNameHard];
    if([GameController sharedGameCtrl].difficultyLevel == kDifficultyMedium) {
        filePath = [DOCUMENTS stringByAppendingPathComponent:kProgressFileNameMedium];
    }
    else if([GameController sharedGameCtrl].difficultyLevel == kDifficultyEasy) {
        filePath = [DOCUMENTS stringByAppendingPathComponent:kProgressFileNameEasy];
    }
    
    [openedLevelsInWorld removeAllObjects];
    [chaptersProgress removeAllObjects];
    
    NSDictionary *progress = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        progress = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        NSString *key = nil;
        for (int i = 0; i < kAreasCount; ++i) {
            key = [NSString stringWithFormat: kOpenedLevelsInWorldKey, i + 1];
            if (kTestMode) {
                [openedLevelsInWorld insertObject:[NSNumber numberWithInt:kLevelsCountInArea] atIndex:i];
            }
            else if([progress objectForKey:key] != nil) {
                [openedLevelsInWorld insertObject:[NSNumber numberWithInt: [[progress objectForKey:key] intValue]] atIndex:i];
            }
            else {
                [openedLevelsInWorld insertObject:[NSNumber numberWithInt:1] atIndex:i];
            }
            key = [NSString stringWithFormat: kProgressChapterKey, i + 1];
            if([progress objectForKey:key] != nil) {
                [chaptersProgress insertObject:[NSMutableDictionary dictionaryWithDictionary:[progress objectForKey:key]] atIndex:i];
            }
            else {
                [chaptersProgress insertObject:[NSMutableDictionary dictionary] atIndex:i];
            }
        }
        [progress release];
    }
    else {
        for (int i = 0; i < kAreasCount; ++i) {
            if (kTestMode) {
                [openedLevelsInWorld insertObject:[NSNumber numberWithInt:kLevelsCountInArea] atIndex:i];
            }
            else {
                [openedLevelsInWorld insertObject:[NSNumber numberWithInt:1] atIndex:i];
            }
            [chaptersProgress insertObject:[NSMutableDictionary dictionary] atIndex:i];
        }
    }
    
    for(int i = 0; i < kAreasCount; ++i) {
        [self updateStarsForWorld:i + 1];
    }
}

-(void)save {
    NSString *filePath = [DOCUMENTS stringByAppendingPathComponent:kProgressFileNameHard];
    if([GameController sharedGameCtrl].difficultyLevel == kDifficultyMedium) {
        filePath = [DOCUMENTS stringByAppendingPathComponent:kProgressFileNameMedium];
    }
    else if([GameController sharedGameCtrl].difficultyLevel == kDifficultyEasy) {
        filePath = [DOCUMENTS stringByAppendingPathComponent:kProgressFileNameEasy];
    }
  	NSMutableDictionary *progress = nil;
	
	if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		progress = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
	}
	else {
		progress = [[NSMutableDictionary alloc] init];
	}
    
    NSString *key = nil;
    for (int i = 0; i < kAreasCount; ++i) {
        key = [NSString stringWithFormat: kOpenedLevelsInWorldKey, i + 1];
        [progress setObject:[openedLevelsInWorld objectAtIndex:i] forKey:key]; 
        key = [NSString stringWithFormat: kProgressChapterKey, i + 1];
        [progress setObject:[chaptersProgress objectAtIndex:i] forKey:key]; 
    }
	
	[progress writeToFile:filePath atomically:YES];	
	[progress release];
}

-(NSInteger)getStarsCount {    
    NSInteger sum = 0;
    for(int i = 0; i < [starsInWorld count]; ++i) {
        sum += [[starsInWorld objectAtIndex:i] intValue];
    }
	return sum;
}

-(NSInteger) getStarsForWorld:(NSInteger) worldNum {
    if (starsInWorld.count >= worldNum) {
        return [[starsInWorld objectAtIndex:worldNum - 1] intValue];
    }
    return 0;
}

-(NSInteger) getScoresForWorld:(NSInteger) worldNum {
    if (scoresInWorld.count >= worldNum) {
        return [[scoresInWorld objectAtIndex:worldNum - 1] intValue];
    }
    return 0;
}

-(void)setScore:(NSInteger)score forLevel:(NSInteger)level withStars:(NSInteger)stars withCarrots:(NSInteger) carrots {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    NSMutableDictionary *currDict = nil;
    NSInteger levelInChapter = 1 + (level - 1) % kLevelsCountInArea;
    NSInteger worldNum = (level - 1)/ kLevelsCountInArea + 1;
    NSInteger additionalCarrots = 0;
    currDict = [self.chaptersProgress objectAtIndex:worldNum - 1];
    if(levelInChapter >= [[self.openedLevelsInWorld objectAtIndex:worldNum - 1] intValue]) {
        [self.openedLevelsInWorld replaceObjectAtIndex:worldNum - 1 withObject:[NSNumber numberWithInteger:levelInChapter + 1]];
        [self save];
    }

    NSString *keyName = [NSString stringWithFormat:@"level%ld", (long)levelInChapter];
    NSMutableDictionary *currLevelParams = [NSMutableDictionary dictionaryWithDictionary:[currDict objectForKey:keyName]];
    if(currLevelParams != nil) {
        bool needUpdate = NO;
        NSInteger prevScore = [[currLevelParams objectForKey:kScoresKey] intValue];
        NSInteger prevStars = [[currLevelParams objectForKey:kStarsKey] intValue];
        NSInteger prevCarrots = [[currLevelParams objectForKey:kCarrotsKey] intValue];

        if(score > prevScore) {
            [currLevelParams setObject:[NSNumber numberWithFloat:score] forKey:kScoresKey]; 
            needUpdate = YES;
        }
        if(stars > prevStars) {
            [currLevelParams setObject:[NSNumber numberWithFloat:stars] forKey:kStarsKey]; 
            needUpdate = YES;
        }
        if(carrots > prevCarrots) {
            additionalCarrots = carrots - prevCarrots;
            [currLevelParams setObject:[NSNumber numberWithFloat:carrots] forKey:kCarrotsKey];
            needUpdate = YES;
        }
        if(needUpdate == YES) {
            [currDict setObject:currLevelParams forKey:keyName];
            [self save];
        }
    }
    else {
        currLevelParams = [[NSMutableDictionary alloc] init];
        [currLevelParams setObject:[NSNumber numberWithFloat:score] forKey:kScoresKey]; 
        [currLevelParams setObject:[NSNumber numberWithFloat:stars] forKey:kStarsKey]; 
        [currLevelParams setObject:[NSNumber numberWithFloat:carrots] forKey:kCarrotsKey];
        additionalCarrots = carrots;
        [currDict setObject:currLevelParams forKey:keyName];
        [currLevelParams release];
        [self save];
    }
    
    if(stars >= 2) {
        [[GameController sharedGameCtrl] addCoins:carrots];
        appDelegate.carrotsEarned = carrots;
    }
    else {
        if(additionalCarrots > 0) {
            [[GameController sharedGameCtrl] addCoins:additionalCarrots];
            appDelegate.carrotsEarned = additionalCarrots;
        }
        else {
            appDelegate.carrotsEarned = 0;
        }
    }
    [self updateStarsForWorld:worldNum];
}

-(NSInteger)getStarsForLevel: (NSInteger) level {
    NSInteger stars = -1;
    NSInteger levelInChapter = 1 + (level - 1) % kLevelsCountInArea;
    NSInteger worldNum = (level - 1)/ kLevelsCountInArea + 1;
    NSMutableDictionary *currDict = [chaptersProgress objectAtIndex:worldNum - 1];
    
    NSString *keyName = [NSString stringWithFormat:@"level%ld", (long)levelInChapter];
    NSMutableDictionary *currLevelParams = [NSMutableDictionary dictionaryWithDictionary:[currDict objectForKey:keyName]];
    if(currLevelParams != nil) {
        stars = [[currLevelParams objectForKey:kStarsKey] intValue];        
    }
    return stars;
}

-(NSInteger)getScoreForLevel: (NSInteger) level {
    NSInteger score = 0;
    NSInteger levelInChapter = 1 + (level - 1) % kLevelsCountInArea;
    NSInteger worldNum = (level - 1)/ kLevelsCountInArea + 1;
    NSMutableDictionary *currDict = [chaptersProgress objectAtIndex:worldNum - 1];
    
    NSString *keyName = [NSString stringWithFormat:@"level%ld", (long)levelInChapter];
    NSMutableDictionary *currLevelParams = [NSMutableDictionary dictionaryWithDictionary:[currDict objectForKey:keyName]];
    if(currLevelParams != nil) {
        score = [[currLevelParams objectForKey:kScoresKey] intValue];
    }
    return score;
}

- (void) updateStarsForWorld:(NSInteger)worldNum {
    NSMutableDictionary *currDict = [chaptersProgress objectAtIndex:worldNum - 1];
    NSInteger sumStars = 0;
    NSInteger sumScores = 0;
    NSArray *allValues = [currDict allValues];
    for(NSUInteger i = 0; i < [allValues count]; ++i) {
        NSMutableDictionary *currLevelParams = [allValues objectAtIndex:i];
        sumStars += [[currLevelParams objectForKey:kStarsKey] intValue];
        sumScores += [[currLevelParams objectForKey:kScoresKey] intValue];
    }
    
    [starsInWorld replaceObjectAtIndex:worldNum - 1 withObject:[NSNumber numberWithInteger:sumStars]];
    [scoresInWorld replaceObjectAtIndex:worldNum - 1 withObject:[NSNumber numberWithInteger:sumScores]];
}

- (void) zeroProgress {
    NSString *filePath = [DOCUMENTS stringByAppendingPathComponent:kProgressFileNameHard];
    if([GameController sharedGameCtrl].difficultyLevel == kDifficultyMedium) {
        filePath = [DOCUMENTS stringByAppendingPathComponent:kProgressFileNameMedium];
    }
    else if([GameController sharedGameCtrl].difficultyLevel == kDifficultyEasy) {
        filePath = [DOCUMENTS stringByAppendingPathComponent:kProgressFileNameEasy];
    }

	if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    CCLOG(@"%d", ([[NSFileManager defaultManager] fileExistsAtPath:filePath]));
    for (int i = 0; i < kAreasCount; ++i) {
        [starsInWorld replaceObjectAtIndex:i withObject:[NSNumber numberWithInteger:0]];
        [scoresInWorld replaceObjectAtIndex:i withObject:[NSNumber numberWithInteger:0]];
    }
    [openedLevelsInWorld removeAllObjects];
    [chaptersProgress removeAllObjects];
    [self load];
} 

- (BOOL) isProgress {
    NSString *filePath = [DOCUMENTS stringByAppendingPathComponent:kProgressFileNameHard];
    if([GameController sharedGameCtrl].difficultyLevel == kDifficultyMedium) {
        filePath = [DOCUMENTS stringByAppendingPathComponent:kProgressFileNameMedium];
    }
    else if([GameController sharedGameCtrl].difficultyLevel == kDifficultyEasy) {
        filePath = [DOCUMENTS stringByAppendingPathComponent:kProgressFileNameEasy];
    }
    CCLOG(@"%d", ([[NSFileManager defaultManager] fileExistsAtPath:filePath]));
    return ([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
}

- (NSInteger)getFullScores {
    NSInteger sum = 0;
    for(int i = 0; i < [scoresInWorld count]; ++i) {
        sum += [[scoresInWorld objectAtIndex:i] intValue];
    }
	return sum;
}

- (NSInteger) getCompletedLevelsForDifficulty: (NSInteger) difficulty {
    [GameController sharedGameCtrl].difficultyLevel = difficulty;
    [self load];
    
    NSInteger levelsCount = 0;
    for (int i = 0; i < kAreasCount; ++i) {
        NSMutableDictionary *currDict = [chaptersProgress objectAtIndex:i];
        levelsCount += [currDict count];
    }
    return levelsCount;
}

- (NSInteger) getCompletedLevelsForChapter: (NSInteger) chapterNum {
    NSMutableDictionary *currDict = [chaptersProgress objectAtIndex:chapterNum];
    return [currDict count];
}

- (void) loadDifficulty: (NSInteger) difficulty {
    [GameController sharedGameCtrl].difficultyLevel = difficulty;
    [self load];
}

@end