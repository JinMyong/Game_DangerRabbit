//
//  SelectLevelLayer.m
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "SelectLevelLayer.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "GameLayer.h"
#import "SelectAreaLayer.h"
#import "MyMenuItemSprite.h"
#import "GameProgressController.h"
#import "Util.h"
#import "SimpleAudioEngine.h"
#import "CutScenesLayer.h"
#import "GameController.h"
#import "ContinueLayer.h"
#import "CutScenes2Layer.h"
#import "GameController.h"
#import "LoadingLayer.h"

#import "NotEnoughStarsLayer.h"

@implementation SelectLevelLayer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	SelectLevelLayer *layer = [SelectLevelLayer node];
	[scene addChild: layer];
	
	return scene;
}

-(id) init {
	if((self=[super init])) {
        currPage = 1;
        isInProgress = NO;

        AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"selectLevelAtl.plist"];

        CCSprite *bg = [CCSprite spriteWithFile:@"selectLevelBg.jpg"];
        [bg setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg z:-2];

        [CCMenuItemFont setFontSize:40 * kFactor];

        CCMenu *menu = [CCMenu menuWithItems:nil];
        [menu setPosition:CGPointZero];
        [self addChild: menu z:20];

        levelMenu = [CCMenu menuWithItems:nil];
        [levelMenu setPosition:CGPointZero];
        [self addChild: levelMenu z:20];
        
        for(NSUInteger i = 0; i < kLevelsCountInArea; ++i) {
            NSInteger levelNum = (appDelegate.currArea - 1) * kLevelsCountInArea + i + 1;
            MyMenuItemSprite *item = [MyMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"0star.png"]
                                                             selectedSprite:nil
                                                             disabledSprite:[CCSprite spriteWithSpriteFrameName:@"gray.png"]
                                                                     target:self
                                                                   selector:@selector(startLevel:)];

            [item setColor:ccc3(255, 255, 255)];
            [item setTag:levelNum];
            
            NSInteger lastUnlocked = [[[GameProgressController sharedGProgressCtrl].openedLevelsInWorld objectAtIndex:appDelegate.currArea - 1] intValue];
            
            if (i + 1 > lastUnlocked) {
                [item setIsEnabled:NO];
            }
            else {
                NSInteger starsCount = [[GameProgressController sharedGProgressCtrl] getStarsForLevel:levelNum];
                if(starsCount != 1 && starsCount != 2 && starsCount != 3) starsCount = 0;
                item.normalImage = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%ldstar.png", (long)starsCount]];
            }
            
            NSString *font = @"BradyBunchRemastered";
            NSString *name = [NSString stringWithFormat:@"%d", i + 1 + kLevelsCountInArea * (appDelegate.currArea - 1)];
            [[Util sharedUtil] showLabel:name
                                  atNode:item.normalImage
                              atPosition:ccp([item.normalImage contentSize].width / 2.0f - 6 * kFactor, [item.normalImage contentSize].height / 2.0f)
                                fontName:font
                                fontSize:kFactor * 24.0f
                               fontColor:ccc3(255, 255, 255)
                             anchorPoint:ccp(0.5f, 0.5f)
                                 bgColor:ccc3(200,20,17)];

            [[Util sharedUtil] showLabel:name
                                  atNode:item.disabledImage
                              atPosition:ccp([item.normalImage contentSize].width / 2.0f - 6 * kFactor, [item.normalImage contentSize].height / 2.0f)
                                fontName:font
                                fontSize:kFactor * 24.0f
                               fontColor:ccc3(205, 205, 205)
                             anchorPoint:ccp(0.5f, 0.5f)
                                 bgColor:ccc3(97,97,97)];

            NSInteger index = i;
            NSInteger deltaX = 0;
            
            if(i >= 10) {
                index = i - 10;
                deltaX = kScreenWidth;
            }
            NSInteger row = index / 5;
            NSInteger col = index % 5;
            
            [item setPosition:ccp(deltaX + kScreenCenterX - 70 * kFactor * 2 + 70 * kFactor * col,
                                  kScreenCenterY +  45 * kFactor - 45 * kFactor * 2 * row)];
            [levelMenu addChild:item];
        }
        
        backItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"sl_back.png"]
                                           selectedSprite:[CCSprite spriteWithSpriteFrameName:@"sl_back_p.png"]
                                           disabledSprite:nil
                                                   target:self
                                                 selector:@selector(backHandler)];
        [backItem setPosition:ccp(36 * kFactor, 36 * kFactor)];
        [menu addChild:backItem];
        
        forwardItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"sl_forward.png"]
                                              selectedSprite:[CCSprite spriteWithSpriteFrameName:@"sl_forward_p.png"]
                                              disabledSprite:nil
                                                      target:self
                                                    selector:@selector(nextHandler)];
        [forwardItem setPosition:ccp(kScreenWidth - 36 * kFactor, 36 * kFactor)];
        [menu addChild:forwardItem];
        
        CCMenuItemSprite *scoresItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"sl_leaderboard.png"]
                                                               selectedSprite:[CCSprite spriteWithSpriteFrameName:@"sl_leaderboard_p.png"]
                                                               disabledSprite:nil
                                                                       target:self
                                                                     selector:@selector(leaderboardsHandler)];
        [scoresItem setPosition:ccp(kScreenCenterX + 75 * kFactor, 36 * kFactor)];
        [scoresItem setScale:0.85f];
        [menu addChild:scoresItem];

        NSInteger score = [[GameProgressController sharedGProgressCtrl] getScoresForWorld:appDelegate.currArea];
        if(!VERSION_IPHONE) {
            [[Util sharedUtil] showLabel:[NSString stringWithFormat:@"SCORE: %d", score]
                                  atNode:self
                              atPosition:ccp(kScreenCenterX + 190, 80)
                                fontName:@"BradyBunchRemastered"
                                fontSize:60
                               fontColor:ccc3(255, 255, 255)
                             anchorPoint:ccp(1.0f, 0.5f)
                               isEnabled:YES
                                     tag:1
                              dimensions:CGSizeMake(500, 56)
                                rotation:0
                                 bgColor:ccc3(157, 35, 46)];
        }
        else {
            [[Util sharedUtil] showLabel:[NSString stringWithFormat:@"SCORE: %d",  score]
                                  atNode:self
                              atPosition:ccp(kScreenCenterX + 220, 40)
                                fontName:@"BradyBunchRemastered"
                                fontSize:30
                               fontColor:ccc3(255, 255, 255)
                             anchorPoint:ccp(1.0f, 0.5f)
                               isEnabled:YES
                                     tag:1
                              dimensions:CGSizeMake(500, 56)
                                rotation:0
                                 bgColor:ccc3(157, 35, 46)];
        }
	}
	return self;
}

-(void) onEnter {
	[super onEnter];
}

-(void) onExit {
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"selectLevelAtl.plist"];
    [super onExit];
}

-(void) startLevel: (CCMenuItemLabel *) item {
    GameController* gC = [GameController sharedGameCtrl];
    NSInteger timeCounter = -[gC.timeContinue timeIntervalSinceNow];
    timeCounter = kTimeAddLife - timeCounter;

    [[SimpleAudioEngine sharedEngine] playEffect:@"Select.mp3"];
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    appDelegate.currLevel = item.tag;
    if (timeCounter <= 0 && appDelegate.livesCount <= 0) {
        appDelegate.livesCount = kLivesBonus;
        [appDelegate saveOptions];
    }
    if(appDelegate.livesCount <= 0 && timeCounter > 0) {
        ContinueLayer *cl = [ContinueLayer node];
        cl.sceneType = kSceneSelectLevel;
        [self.parent addChild:cl z:1000];
    }
    else {
        if(appDelegate.currLevel == 1) {
            [appDelegate unloadResourcesForMenu];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f
                                                                                         scene:[CutScenesLayer scene]]];
        }
        else {
            [appDelegate unloadResourcesForMenu];
            NSString *musicFile = @"Chapter_1.mp3";
            if(appDelegate.currArea == 1) {
                musicFile = @"Chapter_1.mp3";
            }
            else if(appDelegate.currArea == 2) {
                musicFile = @"Chapter_4.mp3";
            }
            else if(appDelegate.currArea == 3) {
                musicFile = @"Chapter_2.mp3";
            }
            else if(appDelegate.currArea == 4) {
                musicFile = @"Chapter_3.mp3";
            }
            else {
                musicFile = @"Chapter_4.mp3";
            }
            
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:musicFile loop:YES];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f
                                                                                         scene:[LoadingLayer scene]]];
        }
    }
}

-(void) backHandler {
    if(currPage == 2 && !isInProgress) {
        isInProgress = YES;
        currPage = 1;
        id moveMenu = [CCSequence actions:
                       [CCMoveTo actionWithDuration:0.7f position:ccp(0, 0)],
                       [CCCallFunc actionWithTarget:self selector:@selector(showNextItem)],
                       [CCCallFunc actionWithTarget:self selector:@selector(endProgress)],
                       nil];
        [levelMenu runAction:moveMenu];
    }
    else if(currPage == 1 && !isInProgress) {
        AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
        GameController *gC = [GameController sharedGameCtrl];
        NSInteger starsInWorld = [[GameProgressController sharedGProgressCtrl] getStarsForWorld:appDelegate.currArea];
        
        bool isCurrTabUnlocked = YES;
        
        if (appDelegate.currArea == 1 &&
            (starsInWorld < 40 ||
             [[GameProgressController sharedGProgressCtrl] getStarsForLevel:kLevelsCountInArea * 1] < 1) &&
            !kTestMode &&
            !gC.isAllWorldsUnlocked &&
            ((!gC.isWorld2UnlockedE && gC.difficultyLevel == kDifficultyEasy) ||
             (!gC.isWorld2UnlockedM && gC.difficultyLevel == kDifficultyMedium) ||
             (!gC.isWorld2UnlockedH && gC.difficultyLevel == kDifficultyHard))) {
            isCurrTabUnlocked = NO;
        }
        else if (appDelegate.currArea == 2 &&
                 (starsInWorld < 50 ||
                  [[GameProgressController sharedGProgressCtrl] getStarsForLevel:kLevelsCountInArea * 2] < 1) &&
                 !kTestMode &&
                 !gC.isAllWorldsUnlocked &&
                 ((!gC.isWorld3UnlockedE && gC.difficultyLevel == kDifficultyEasy) ||
                  (!gC.isWorld3UnlockedM && gC.difficultyLevel == kDifficultyMedium) ||
                  (!gC.isWorld3UnlockedH && gC.difficultyLevel == kDifficultyHard))) {
            isCurrTabUnlocked = NO;
        }
        else if (appDelegate.currArea == 3 &&
                 (starsInWorld < 50 ||
                  [[GameProgressController sharedGProgressCtrl] getStarsForLevel:kLevelsCountInArea * 3] < 1) &&
                 !kTestMode &&
                 !gC.isAllWorldsUnlocked &&
                 ((!gC.isWorld4UnlockedE && gC.difficultyLevel == kDifficultyEasy) ||
                  (!gC.isWorld4UnlockedM && gC.difficultyLevel == kDifficultyMedium) ||
                  (!gC.isWorld4UnlockedH && gC.difficultyLevel == kDifficultyHard))) {
            isCurrTabUnlocked = NO;
        }
        
        if(isCurrTabUnlocked) {
            bool needShowAnimation = NO;
            
            switch (appDelegate.currArea) {
                case 1:
                    if((!gC.isWasWorld2UnlockedAnimationE && gC.difficultyLevel == kDifficultyEasy) ||
                       (!gC.isWasWorld2UnlockedAnimationM && gC.difficultyLevel == kDifficultyMedium) ||
                       (!gC.isWasWorld2UnlockedAnimationH && gC.difficultyLevel == kDifficultyHard)) {
                        needShowAnimation = YES;
                    }
                    break;
                case 2:
                    if((!gC.isWasWorld3UnlockedAnimationE && gC.difficultyLevel == kDifficultyEasy) ||
                       (!gC.isWasWorld3UnlockedAnimationM && gC.difficultyLevel == kDifficultyMedium) ||
                       (!gC.isWasWorld3UnlockedAnimationH && gC.difficultyLevel == kDifficultyHard)) {
                        needShowAnimation = YES;
                    }
                    break;
                case 3:
                    if((!gC.isWasWorld4UnlockedAnimationE && gC.difficultyLevel == kDifficultyEasy) ||
                       (!gC.isWasWorld4UnlockedAnimationM && gC.difficultyLevel == kDifficultyMedium) ||
                       (!gC.isWasWorld4UnlockedAnimationH && gC.difficultyLevel == kDifficultyHard)) {
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
}

-(void) nextHandler {
    if(currPage == 1 && !isInProgress) {
        isInProgress = YES;
        currPage = 2;
        id moveMenu = [CCSequence actions:
                       [CCMoveTo actionWithDuration:0.7f position:ccp(-kScreenWidth, 0)],
                       [CCCallFunc actionWithTarget:self selector:@selector(hideNextItem)],
                       [CCCallFunc actionWithTarget:self selector:@selector(endProgress)],
                       nil];
        [levelMenu runAction:moveMenu];
    }
}

-(void) endProgress {
    isInProgress = NO;
}

-(void) showNextItem {
    [forwardItem setVisible:YES];
}

-(void) hideNextItem {
    [forwardItem setVisible:NO];
}

#pragma mark -
#pragma mark GameKit Delegate

- (void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) leaderboardsHandler {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
	if([appDelegate isGameCenterAvailable]) {
		GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
		if (leaderboardController != nil) {
			leaderboardController.leaderboardDelegate = self;
            float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
            if (sysVer < 7) {
                leaderboardController.leaderboardCategory = [appDelegate getLeaderBoardNameForCurrArea];
            }
            else {
                leaderboardController.leaderboardIdentifier = [appDelegate getLeaderBoardNameForCurrArea];
            }
			[appDelegate.navController presentViewController:leaderboardController animated:YES completion:nil];
			[leaderboardController release];
		}
	}
}

@end