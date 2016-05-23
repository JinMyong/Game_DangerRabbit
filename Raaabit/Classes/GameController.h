//
//  GameController.h
//  CombiCats
//
//  Created by Dmitry Valov on 21.08.13.
//  Copyright Dmitry Valov 2013. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"

#define kScreenLoading      0
#define kScreenMainMenu     1
#define kScreenPreGame      2
#define kScreenGame         3
#define kScreenPostGame     4
#define kScreenSlotMachine  5

#define kDifficultyEasy     101
#define kDifficultyMedium   102
#define kDifficultyHard     103


@interface GameController : CCNode {
    bool needShowLockAnimation;
    
    NSInteger carrotsCount;
    NSInteger planksCount;
    NSInteger stickyPlanksCount;
    NSInteger superPlanksCount;
    NSInteger worldsCount;
    NSInteger bombsCount;
    NSInteger difficultyLevel;
    
    NSDate    *timeContinue;

    NSDate    *timeStart;
    bool      wasAllLivesSpend;
    
    bool      needInitNextWorld;
    
    NSMutableArray *listOfShields_;
    
    bool isMusicOff;
    bool isSFXOff;
    
    NSInteger totalCoins;
    NSInteger collectedCoins;
    NSInteger levelStars;
    NSInteger lostLives;
    bool isAllWorldsUnlocked;
    bool isWorld2UnlockedE;
    bool isWorld3UnlockedE;
    bool isWorld4UnlockedE;
    bool isWorld5UnlockedE;
    bool isWorld2UnlockedM;
    bool isWorld3UnlockedM;
    bool isWorld4UnlockedM;
    bool isWorld5UnlockedM;
    bool isWorld2UnlockedH;
    bool isWorld3UnlockedH;
    bool isWorld4UnlockedH;
    bool isWorld5UnlockedH;

    bool isWasWorld2UnlockedAnimationE;
    bool isWasWorld3UnlockedAnimationE;
    bool isWasWorld4UnlockedAnimationE;
    bool isWasWorld5UnlockedAnimationE;
    bool isWasWorld2UnlockedAnimationM;
    bool isWasWorld3UnlockedAnimationM;
    bool isWasWorld4UnlockedAnimationM;
    bool isWasWorld5UnlockedAnimationM;
    bool isWasWorld2UnlockedAnimationH;
    bool isWasWorld3UnlockedAnimationH;
    bool isWasWorld4UnlockedAnimationH;
    bool isWasWorld5UnlockedAnimationH;
    
    bool wasWorld1PerfectE;
    bool wasWorld2PerfectE;
    bool wasWorld3PerfectE;
    bool wasWorld4PerfectE;
    bool wasWorld5PerfectE;
    bool wasWorld1PerfectM;
    bool wasWorld2PerfectM;
    bool wasWorld3PerfectM;
    bool wasWorld4PerfectM;
    bool wasWorld5PerfectM;
    bool wasWorld1PerfectH;
    bool wasWorld2PerfectH;
    bool wasWorld3PerfectH;
    bool wasWorld4PerfectH;
    bool wasWorld5PerfectH;
    
    
    bool isUnlimitedLife;           // Added By Hans_1127
    
    NSArray *listOfScoresForLevel_;
    NSMutableDictionary *listOfPrices;
    
    bool wasPurchase;
    NSInteger completedLevels;
    
    bool wasFacebookLike;
}

@property bool needShowLockAnimation;
@property NSInteger carrotsCount;
@property NSInteger planksCount;
@property NSInteger stickyPlanksCount;
@property NSInteger superPlanksCount;
@property NSInteger worldsCount;
@property NSInteger bombsCount;
@property bool needInitNextWorld;
@property NSInteger difficultyLevel;
@property bool isMusicOff;
@property bool isSFXOff;
@property NSInteger totalCoins;
@property NSInteger collectedCoins;
@property NSInteger levelStars;
@property NSInteger lostLives;

@property (nonatomic, retain) NSDate *timeStart;
@property bool wasAllLivesSpend;

@property (nonatomic, retain) NSMutableDictionary *listOfPrices;
@property (nonatomic, retain) NSDate *timeContinue;
@property (nonatomic, retain) NSMutableArray *listOfShields;
@property bool isAllWorldsUnlocked;
@property bool isWorld2UnlockedE;
@property bool isWorld3UnlockedE;
@property bool isWorld4UnlockedE;
@property bool isWorld5UnlockedE;
@property bool isWorld2UnlockedM;
@property bool isWorld3UnlockedM;
@property bool isWorld4UnlockedM;
@property bool isWorld5UnlockedM;
@property bool isWorld2UnlockedH;
@property bool isWorld3UnlockedH;
@property bool isWorld4UnlockedH;
@property bool isWorld5UnlockedH;

@property bool wasWorld1PerfectE;
@property bool wasWorld2PerfectE;
@property bool wasWorld3PerfectE;
@property bool wasWorld4PerfectE;
@property bool wasWorld5PerfectE;
@property bool wasWorld1PerfectM;
@property bool wasWorld2PerfectM;
@property bool wasWorld3PerfectM;
@property bool wasWorld4PerfectM;
@property bool wasWorld5PerfectM;
@property bool wasWorld1PerfectH;
@property bool wasWorld2PerfectH;
@property bool wasWorld3PerfectH;
@property bool wasWorld4PerfectH;
@property bool wasWorld5PerfectH;

@property bool isWasWorld2UnlockedAnimationE;
@property bool isWasWorld3UnlockedAnimationE;
@property bool isWasWorld4UnlockedAnimationE;
@property bool isWasWorld5UnlockedAnimationE;
@property bool isWasWorld2UnlockedAnimationM;
@property bool isWasWorld3UnlockedAnimationM;
@property bool isWasWorld4UnlockedAnimationM;
@property bool isWasWorld5UnlockedAnimationM;
@property bool isWasWorld2UnlockedAnimationH;
@property bool isWasWorld3UnlockedAnimationH;
@property bool isWasWorld4UnlockedAnimationH;
@property bool isWasWorld5UnlockedAnimationH;

@property bool isUnlimitedLife;           // Added By Hans_1127

@property (nonatomic, retain) NSArray *listOfScoresForLevel;

@property bool wasPurchase;
@property NSInteger completedLevels;
@property bool wasFacebookLike;


+ (GameController*) sharedGameCtrl;

- (void) load;
- (void) save;

- (bool) getShieldForLevel: (NSInteger) level;
- (void) setShieldForLevel: (NSInteger) level;

- (void) addCoins: (NSInteger) coins;
- (bool) spendCoins: (NSInteger) coins;

- (void) clearPlanks;

- (NSInteger) countLevelStars;

- (NSInteger) unlockNextLevel;
- (void) unlockNextWorld;
- (void) unlockAllWorlds;
- (void) loadListOfScoresForLevel: (NSInteger) level;
- (void) spendLife;

@end
