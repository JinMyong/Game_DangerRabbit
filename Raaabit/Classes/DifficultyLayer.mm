//
//  DifficultyLayer.m
//  Raaabit
//
//  Created by Anna Valova on 1/9/14.
//  Copyright 2014 Dmitry Valov. All rights reserved.
//

#import "DifficultyLayer.h"
#import "Constants.h"
#import "MyMenuItemSprite.h"
#import "GameController.h"
#import "SelectAreaLayer.h"
#import "MainMenuLayer.h"
#import "GameProgressController.h"
#import "SimpleAudioEngine.h"
#import "FacebookController.h"
#import "AppDelegate.h"
#import "CutScenes2Layer.h"

@implementation DifficultyLayer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	DifficultyLayer *layer = [DifficultyLayer node];
	[scene addChild: layer];
	
	return scene;
}

-(id) init {
	if((self=[super init])) {	
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"difficultyAtl.plist"];
        
        CCSprite *bg = [CCSprite spriteWithFile:@"mainMenuBg.jpg"];
        [bg setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg z:-11];
        
        CCSprite *bg1 = [CCSprite spriteWithSpriteFrameName:@"d_shadow.png"];
        [bg1 setScale:8];
        [bg1 setOpacity:200];
        [bg1 setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg1 z:-2];
        
        NSInteger tempDifficulty = [GameController sharedGameCtrl].difficultyLevel;
        NSInteger easyLevelScore = [[GameProgressController sharedGProgressCtrl] getCompletedLevelsForDifficulty:kDifficultyEasy];
        NSInteger mediumLevelScore = [[GameProgressController sharedGProgressCtrl] getCompletedLevelsForDifficulty:kDifficultyMedium];
        NSInteger hardLevelScore = [[GameProgressController sharedGProgressCtrl] getCompletedLevelsForDifficulty:kDifficultyHard];
        [[GameProgressController sharedGProgressCtrl] loadDifficulty:tempDifficulty];

        int offsetY = 6 * kFactor;
        int totalLevels = kLevelsCountInArea * kAreasCount;
        
        if (!VERSION_IPHONE) {
            offsetY = 10 * kFactor;
        }
        
        //Menu
        CCMenu *menu = [CCMenu menuWithItems:nil];
        [menu setPosition:CGPointZero];
        [self addChild: menu];
        
        //Easy
        MyMenuItemSprite *easyItem = [MyMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"d_easy.png"]
                                                             selectedSprite:nil
                                                             disabledSprite:nil
                                                                     target:self
                                                                   selector:@selector(easyHandler)];
        [easyItem setPosition:ccp(kScreenCenterX - 25 * kFactor, kScreenCenterY + 100 * kFactor)];
        [menu addChild:easyItem];
        
        CCMenuItemSprite *easyLBItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"d_leaderboard.png"]
                                                               selectedSprite:[CCSprite spriteWithSpriteFrameName:@"d_leaderboard_p.png"]
                                                               disabledSprite:[CCSprite spriteWithSpriteFrameName:@"d_leaderboard_l.png"]
                                                                       target:self
                                                                     selector:@selector(showLeaderboard:)];
        [easyLBItem setPosition:ccp(kScreenCenterX + 165 * kFactor, kScreenCenterY + 100 * kFactor)];
        [easyLBItem setTag:kDifficultyEasy];
        [menu addChild:easyLBItem];

        CCLabelBMFont *easyItemLabel = [[CCLabelBMFont alloc] initWithString:[NSString stringWithFormat:@"%ld/%d", (long)easyLevelScore, totalLevels]
                                                                     fntFile:@"d_font.fnt"];
        [easyItemLabel setAnchorPoint:ccp(1, 0)];
        [easyItemLabel setPosition:ccp(easyItem.contentSize.width - 10 * kFactor,
                                       easyItem.contentSize.height / 2 + offsetY)];
        [easyItem addChild:easyItemLabel];
        
        //Medium
        MyMenuItemSprite *mediumItem = [MyMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"d_medium.png"]
                                                               selectedSprite:nil
                                                               disabledSprite:[CCSprite spriteWithSpriteFrameName:@"d_medium_gray.png"]
                                                                       target:self
                                                                     selector:@selector(mediumHandler)];
        [mediumItem setPosition:ccp(kScreenCenterX - 25 * kFactor, kScreenCenterY)];
        [menu addChild:mediumItem];
        
        CCMenuItemSprite *mediumLBItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"d_leaderboard.png"]
                                                                 selectedSprite:[CCSprite spriteWithSpriteFrameName:@"d_leaderboard_p.png"]
                                                                 disabledSprite:[CCSprite spriteWithSpriteFrameName:@"d_leaderboard_l.png"]
                                                                         target:self
                                                                       selector:@selector(showLeaderboard:)];
        [mediumLBItem setPosition:ccp(kScreenCenterX + 165 * kFactor, kScreenCenterY)];
        [mediumLBItem setTag:kDifficultyMedium];
        [menu addChild:mediumLBItem];

        if(easyLevelScore < 40 && !kTestMode) {
            [mediumItem setIsEnabled:NO];
            [mediumLBItem setIsEnabled:NO];
        }
        else {
            CCLabelBMFont *mediumItemLabel = [[CCLabelBMFont alloc] initWithString:[NSString stringWithFormat:@"%ld/%d", (long)mediumLevelScore, totalLevels]
                                                                           fntFile:@"d_font.fnt"];
            [mediumItemLabel setAnchorPoint:ccp(1, 0)];
            [mediumItemLabel setPosition:ccp(mediumItem.contentSize.width - 10 * kFactor,
                                             mediumItem.contentSize.height / 2 + offsetY)];
            [mediumItem addChild:mediumItemLabel];
        }
        
        //Hard
        MyMenuItemSprite *hardItem = [MyMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"d_hard.png"]
                                                             selectedSprite:nil
                                                             disabledSprite:[CCSprite spriteWithSpriteFrameName:@"d_hard_gray.png"]
                                                                     target:self
                                                                   selector:@selector(hardHandler)];
        [hardItem setPosition:ccp(kScreenCenterX - 25 * kFactor, kScreenCenterY - 100 * kFactor)];
        [menu addChild:hardItem];
        
        CCMenuItemSprite *hardLBItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"d_leaderboard.png"]
                                                               selectedSprite:[CCSprite spriteWithSpriteFrameName:@"d_leaderboard_p.png"]
                                                               disabledSprite:[CCSprite spriteWithSpriteFrameName:@"d_leaderboard_l.png"]
                                                                       target:self
                                                                     selector:@selector(showLeaderboard:)];
        [hardLBItem setPosition:ccp(kScreenCenterX + 165 * kFactor, kScreenCenterY - 100 * kFactor)];
        [hardLBItem setTag:kDifficultyHard];
        [menu addChild:hardLBItem];

        if(mediumLevelScore < 40 && !kTestMode) {
            [hardItem setIsEnabled:NO];
            [hardLBItem setIsEnabled:NO];
        }
        else {
            CCLabelBMFont *hardItemLabel = [[CCLabelBMFont alloc] initWithString:[NSString stringWithFormat:@"%ld/%d", (long)hardLevelScore, totalLevels]
                                                                         fntFile:@"d_font.fnt"];
            [hardItemLabel setAnchorPoint:ccp(1, 0)];
            [hardItemLabel setPosition:ccp(hardItem.contentSize.width - 10 * kFactor,
                                           hardItem.contentSize.height / 2 + offsetY)];
            [hardItem addChild:hardItemLabel];
        }
        
        CCMenuItemSprite *backItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"d_back.png"]
                                                             selectedSprite:[CCSprite spriteWithSpriteFrameName:@"d_back_p.png"]
                                                             disabledSprite:nil
                                                                     target:self
                                                                   selector:@selector(backHandler)];
        [backItem setPosition:ccp(36 * kFactor, 36 * kFactor)];
        [menu addChild:backItem];
    }
	return self;
}

#pragma mark -
#pragma mark Handlers

-(void) backHandler {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f
                                                                                 scene:[MainMenuLayer scene]]];
}

-(void) easyHandler {
    [GameController sharedGameCtrl].difficultyLevel = kDifficultyEasy;
    [[GameProgressController sharedGProgressCtrl] load];
    
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    GameController *gC = [GameController sharedGameCtrl];
    NSInteger starsInWorld = [[GameProgressController sharedGProgressCtrl] getStarsForWorld:appDelegate.currArea];
    
    bool isCurrTabUnlocked = YES;
    
    if (appDelegate.currArea == 1 &&
        (starsInWorld < 40 ||
         [[GameProgressController sharedGProgressCtrl] getStarsForLevel:kLevelsCountInArea * 1] < 1) &&
        !kTestMode &&
        !gC.isAllWorldsUnlocked &&
        (!gC.isWorld2UnlockedE && gC.difficultyLevel == kDifficultyEasy)) {
        isCurrTabUnlocked = NO;
    }
    else if (appDelegate.currArea == 2 &&
             (starsInWorld < 50 ||
             [[GameProgressController sharedGProgressCtrl] getStarsForLevel:kLevelsCountInArea * 2] < 1) &&
             !kTestMode &&
             !gC.isAllWorldsUnlocked &&
             (!gC.isWorld3UnlockedE && gC.difficultyLevel == kDifficultyEasy)) {
        isCurrTabUnlocked = NO;
    }
    else if (appDelegate.currArea == 3 &&
             (starsInWorld < 50 ||
             [[GameProgressController sharedGProgressCtrl] getStarsForLevel:kLevelsCountInArea * 3] < 1) &&
             !kTestMode &&
             !gC.isAllWorldsUnlocked &&
             (!gC.isWorld4UnlockedE && gC.difficultyLevel == kDifficultyEasy)) {
        isCurrTabUnlocked = NO;
    }
    
    if(isCurrTabUnlocked) {
        bool needShowAnimation = NO;
        
        switch (appDelegate.currArea) {
            case 1:
                if(!gC.isWasWorld2UnlockedAnimationE && gC.difficultyLevel == kDifficultyEasy) {
                    needShowAnimation = YES;
                }
                break;
            case 2:
                if(!gC.isWasWorld3UnlockedAnimationE && gC.difficultyLevel == kDifficultyEasy) {
                    needShowAnimation = YES;
                }
                break;
            case 3:
                if(!gC.isWasWorld4UnlockedAnimationE && gC.difficultyLevel == kDifficultyEasy) {
                    needShowAnimation = YES;
                }
                break;
        }
        
        if(needShowAnimation) {
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.7f
                                                                                         scene:[CutScenes2Layer scene]
                                                                                     withColor:ccc3( 0, 0, 0 ) ] ];
        }
        else {
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.7f
                                                                                         scene:[SelectAreaLayer scene]
                                                                                     withColor:ccc3( 0, 0, 0 ) ] ];
        }
    }
    else {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0
                                                                                     scene:[SelectAreaLayer scene]]];
    }
}

-(void) mediumHandler {
    [GameController sharedGameCtrl].difficultyLevel = kDifficultyMedium;
    [[GameProgressController sharedGProgressCtrl] load];
    
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    GameController *gC = [GameController sharedGameCtrl];
    NSInteger starsInWorld = [[GameProgressController sharedGProgressCtrl] getStarsForWorld:appDelegate.currArea];
    
    bool isCurrTabUnlocked = YES;
    
    if (appDelegate.currArea == 1 &&
        starsInWorld < 40 &&
        !kTestMode &&
        !gC.isAllWorldsUnlocked &&
        (!gC.isWorld2UnlockedM && gC.difficultyLevel == kDifficultyMedium)) {
        isCurrTabUnlocked = NO;
    }
    else if (appDelegate.currArea == 2 &&
             starsInWorld < 50 &&
             !kTestMode &&
             !gC.isAllWorldsUnlocked &&
             (!gC.isWorld3UnlockedM && gC.difficultyLevel == kDifficultyMedium)) {
        isCurrTabUnlocked = NO;
    }
    else if (appDelegate.currArea == 3 &&
             starsInWorld < 50 &&
             !kTestMode &&
             !gC.isAllWorldsUnlocked &&
             (!gC.isWorld3UnlockedM && gC.difficultyLevel == kDifficultyMedium)) {
        isCurrTabUnlocked = NO;
    }
    
    if(isCurrTabUnlocked) {
        bool needShowAnimation = NO;
        
        switch (appDelegate.currArea) {
            case 1:
                if(!gC.isWasWorld2UnlockedAnimationM && gC.difficultyLevel == kDifficultyMedium) {
                    needShowAnimation = YES;
                }
                break;
            case 2:
                if(!gC.isWasWorld3UnlockedAnimationM && gC.difficultyLevel == kDifficultyMedium) {
                    needShowAnimation = YES;
                }
                break;
            case 3:
                if(!gC.isWasWorld4UnlockedAnimationM && gC.difficultyLevel == kDifficultyMedium) {
                    needShowAnimation = YES;
                }
                break;
        }
        
        if(needShowAnimation) {
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.7f
                                                                                         scene:[CutScenes2Layer scene]
                                                                                     withColor:ccc3( 0, 0, 0 ) ] ];
        }
        else {
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.7f
                                                                                         scene:[SelectAreaLayer scene]
                                                                                     withColor:ccc3( 0, 0, 0 ) ] ];
        }
    }
    else {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0
                                                                                     scene:[SelectAreaLayer scene]]];
    }
}

-(void) hardHandler {
    [GameController sharedGameCtrl].difficultyLevel = kDifficultyHard;
    [[GameProgressController sharedGProgressCtrl] load];
    
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    GameController *gC = [GameController sharedGameCtrl];
    NSInteger starsInWorld = [[GameProgressController sharedGProgressCtrl] getStarsForWorld:appDelegate.currArea];
    
    bool isCurrTabUnlocked = YES;
    
    if (appDelegate.currArea == 1 &&
        starsInWorld < 40 &&
        !kTestMode &&
        !gC.isAllWorldsUnlocked &&
        (!gC.isWorld2UnlockedH && gC.difficultyLevel == kDifficultyHard)) {
        isCurrTabUnlocked = NO;
    }
    else if (appDelegate.currArea == 2 &&
             starsInWorld < 50 &&
             !kTestMode &&
             !gC.isAllWorldsUnlocked &&
             (!gC.isWorld3UnlockedH && gC.difficultyLevel == kDifficultyHard)) {
        isCurrTabUnlocked = NO;
    }
    else if (appDelegate.currArea == 3 &&
             starsInWorld < 50 &&
             !kTestMode &&
             !gC.isAllWorldsUnlocked &&
             (!gC.isWorld3UnlockedH && gC.difficultyLevel == kDifficultyHard)) {
        isCurrTabUnlocked = NO;
    }
    
    if(isCurrTabUnlocked) {
        bool needShowAnimation = NO;
        
        switch (appDelegate.currArea) {
            case 1:
                if(!gC.isWasWorld2UnlockedAnimationH && gC.difficultyLevel == kDifficultyHard) {
                    needShowAnimation = YES;
                }
                break;
            case 2:
                if(!gC.isWasWorld3UnlockedAnimationH && gC.difficultyLevel == kDifficultyHard) {
                    needShowAnimation = YES;
                }
                break;
            case 3:
                if(!gC.isWasWorld4UnlockedAnimationH && gC.difficultyLevel == kDifficultyHard) {
                    needShowAnimation = YES;
                }
                break;
        }
        
        if(needShowAnimation) {
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.7f
                                                                                         scene:[CutScenes2Layer scene]
                                                                                     withColor:ccc3( 0, 0, 0 ) ] ];
        }
        else {
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.7f
                                                                                         scene:[SelectAreaLayer scene]
                                                                                     withColor:ccc3( 0, 0, 0 ) ] ];
        }
    }
    else {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0
                                                                                     scene:[SelectAreaLayer scene]]];
    }
}


#pragma mark -
#pragma mark GameKit Delegate

- (void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

-(void) showLeaderboard: (id) sender {
    NSInteger difficulty = ((CCMenuItemSprite *)sender).tag;
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
	if([appDelegate isGameCenterAvailable]) {
		GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
		if (leaderboardController != nil) {
			leaderboardController.leaderboardDelegate = self;
            float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
            if (sysVer < 7) {
                leaderboardController.leaderboardCategory = [appDelegate getTotalScoresLeaderboardWithDifficulty:difficulty];
            }
            else {
                leaderboardController.leaderboardIdentifier = [appDelegate getTotalScoresLeaderboardWithDifficulty:difficulty];
            }
			[appDelegate.navController presentViewController:leaderboardController animated:YES completion:nil];
			[leaderboardController release];
		}
	}
}

@end
