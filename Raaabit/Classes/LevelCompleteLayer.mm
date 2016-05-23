//
//  LevelCompleteLayer.m
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "LevelCompleteLayer.h"
#import "MainMenuLayer.h"
#import "GameLayer.h"
#import "MyMenuItemSprite.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "GameProgressController.h"
#import "SimpleAudioEngine.h"
#import "ShopLayer.h"
#import "GameController.h"
#import "SelectAreaLayer.h"
#import <GameController.h>
#import <FacebookController.h>
#import "SelectLevelLayer.h"
#import "CutScenes2Layer.h"
#import "FinalLayer.h"
#import "LevelStartLayer.h"
#import "NotEnoughStarsLayer.h"

#import "SWTableView.h"
#import "ScoresTable.h"
#import "GameController.h"
#import "Util.h"
#import "CCLabelBMFontAnimated.h"

#define kLoginButtonTag     1234567

@implementation LevelCompleteLayer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	LevelCompleteLayer *layer = [LevelCompleteLayer node];
	[scene addChild: layer];
	
	return scene;
}

-(id) init {
	if((self=[super init])) {

        congratsSound = [[SimpleAudioEngine sharedEngine] playEffect:@"LevelCompleted.mp3"];

        AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];

        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"levelCompleteAtl.plist"];
     
        NSString *bgName = @"bg1.jpg";
        switch (appDelegate.currArea) {
            case 1:
                bgName = @"bg1.jpg";
                break;
            case 2:
                bgName = @"bg2.jpg";
                break;
            case 3:
                bgName = @"bg3.jpg";
                break;
            case 4:
                bgName = @"bg4.jpg";
                break;
            case 5:
                bgName = @"bg5.jpg";
                break;
        }
        CCSprite *bg = [CCSprite spriteWithFile:bgName];
        [bg setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg z:-2];

        CCSprite *bg1 = [CCSprite spriteWithSpriteFrameName:@"levelCompleteBase.png"];
        [bg1 setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg1 z:-1];
        
        //High Scores
        NSInteger highScoreValue = [[GameProgressController sharedGProgressCtrl] getScoreForLevel:appDelegate.currLevel];
        
        highScoreLabel = [[CCLabelBMFont alloc] initWithString:[NSString stringWithFormat:@"%ld", (long)highScoreValue]
                                                       fntFile:@"font_lc_top_scores.fnt"];
        [self addChild:highScoreLabel z:0];
        [highScoreLabel setAnchorPoint:ccp(0.0f, 0.5f)];
        [highScoreLabel setPosition:ccp(kScreenCenterX + 40, 80+24)];
        
        NSInteger tempScore = appDelegate.bounceScores +
        appDelegate.enemiesScore +
        appDelegate.currLevelScores;
        
        if (highScoreValue <= tempScore ) {
            [highScoreLabel setOpacity:0];
            [highScoreLabel setScale:5.0f];
            
            id scaleAction1 = [CCSequence actions:
                               [CCDelayTime actionWithDuration:3.4f],
                               [CCFadeIn actionWithDuration:0.2f],
                               [CCScaleTo actionWithDuration:0.1f scale:1.f],
                               [CCCallFunc actionWithTarget:self selector:@selector(playHighScoreSound)],
                               nil];
            [highScoreLabel runAction:scaleAction1];
        }

        //Total scores
        levelScoreLabel = [CCLabelBMFontAnimated labelWithValue:0 fntFile:@"font_lc_top_scores.fnt"];
        [self addChild:levelScoreLabel z:0];
        [levelScoreLabel setAnchorPoint:ccp(0.0f, 0.5f)];
        [levelScoreLabel setScale:0.85f];
        [levelScoreLabel setPosition:ccp(kScreenCenterX - 72, 80+23)];

        //Planks scores
        bounceScoreLabel = [CCLabelBMFontAnimated labelWithValue:0 fntFile:@"font_lc_planks.fnt"];
        [self addChild:bounceScoreLabel z:0];
        [bounceScoreLabel setAnchorPoint:ccp(0.0f, 0.5f)];
        [bounceScoreLabel setPosition:ccp(kScreenCenterX - 41, 148+25)];

        //Carrots earned
        coinsScoreLabel = [CCLabelBMFontAnimated labelWithValue:0 fntFile:@"font_lc_planks.fnt"];
        [self addChild:coinsScoreLabel z:0];
        [coinsScoreLabel setAnchorPoint:ccp(0.0f, 0.5f)];
        [coinsScoreLabel setPosition:ccp(kScreenCenterX - 41, 127+25)];

        //Kill bonus
        enemiesScoreLabel = [CCLabelBMFontAnimated labelWithValue:0 fntFile:@"font_lc_planks.fnt"];
        [self addChild:enemiesScoreLabel z:0];
        [enemiesScoreLabel setAnchorPoint:ccp(0.0f, 0.5f)];
        [enemiesScoreLabel setPosition:ccp(kScreenCenterX - 41, 106+26)];
        
        [bounceScoreLabel setEffect:nil];
        [bounceScoreLabel updateValue:(long) appDelegate.bounceScores animated:YES];
        [levelScoreLabel updateValue:(long) appDelegate.bounceScores animated:YES];
        
// Added By Hans For Carrot flying
        
        //carrots count by Hans(1)
        carrotscountLabel = [CCLabelBMFontAnimated labelWithValue:[GameController sharedGameCtrl].carrotsCount
                             - appDelegate.carrotsEarned fntFile:@"font_lc_planks.fnt"];
        [self addChild:carrotscountLabel z:0];
        [carrotscountLabel setPosition:ccp(kScreenWidth - 40, kScreenHeight - 20)];
        
        // Add carrot image
        carrot_image = [CCSprite spriteWithFile:@"carrot.png"];
        [self addChild:carrot_image z:0];
        [carrot_image setPosition:ccp(kScreenWidth - 65 * kFactor, kScreenHeight - 25 * kFactor)];
        
        GameController* controller = [GameController sharedGameCtrl];
        countCarrot = controller.carrotsCount - appDelegate.carrotsEarned;
        earnedCarrot = appDelegate.carrotsEarned;
        
        NSMutableArray* array = [[NSMutableArray alloc] init];
        
        [array addObject:[CCDelayTime actionWithDuration:1.5f]];
        [array addObject:[CCCallFunc actionWithTarget:self selector:@selector(showCarrotsLevelScore)]];
        [array addObject:[CCDelayTime actionWithDuration:1.5f]];
        [array addObject:[CCCallFunc actionWithTarget:self selector:@selector(showLevelScore)]];
        
        for (int i = 1; i <= appDelegate.carrotsEarned ; i++) {
            
            CCDelayTime* delay = [CCDelayTime actionWithDuration:0.5f];
            CCCallFunc* removeCarrot = [CCCallFunc actionWithTarget:self selector:@selector(decCarrotsEarned)];
            CCCallFunc* flyCarrot = [CCCallFunc actionWithTarget:self selector:@selector(moveCarrots)];
            CCCallFunc* addcarrot = [CCCallFunc actionWithTarget:self selector:@selector(incCarrotsCount)];
            
            [array addObject:delay];
            [array addObject:removeCarrot];
            [array addObject:flyCarrot];
            [array addObject:addcarrot];
            
        }
// Add end
        id actionResults = nil;
//        actionResults = [CCSequence actions:
//                         [CCDelayTime actionWithDuration:1.5f],
//                         [CCCallFunc actionWithTarget:self selector:@selector(showCarrotsLevelScore)],
//                         [CCDelayTime actionWithDuration:1.5f],
//                         [CCCallFunc actionWithTarget:self selector:@selector(showLevelScore)],
//                        nil];     // Remarked By Hans.
        actionResults = [CCSequence actionWithArray:array];     // Added By Hans
        [self runAction:actionResults];
        
        
        
        //Curr level
//        NSInteger areaNum = 1 + (appDelegate.currLevel - 1) / kLevelsCountInArea;
//        CCSprite *currAreaName = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"area_name_%d.png", areaNum]];
//        [currAreaName setAnchorPoint:ccp(0.0f, 0.5f)];
//        [self addChild:currAreaName z:1];
//        
//        [currAreaName setPosition:ccp(kScreenCenterX - 21 * kFactor, 238)];

        //Menu
        menu = [CCMenu menuWithItems:nil];
        [menu setPosition:CGPointZero];
        [self addChild: menu z:20];

        //Next
        CCMenuItemSprite *nextItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"next.png"]
                                                             selectedSprite:[CCSprite spriteWithSpriteFrameName:@"next_p.png"]
                                                             disabledSprite:nil
                                                                     target:self
                                                                   selector:@selector(nextLevelHandler)];
        [nextItem setPosition:ccp(kScreenCenterX + 85 * kFactor, 50 * kFactor)];
        [menu addChild:nextItem];
        
        //Replay
        CCMenuItemSprite *replayItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"retry.png"]
                                                               selectedSprite:[CCSprite spriteWithSpriteFrameName:@"retry_p.png"]
                                                               disabledSprite:nil
                                                                       target:self
                                                                     selector:@selector(replayLevelHandler)];
        [replayItem setPosition:ccp(kScreenCenterX - 58, 51 * kFactor)];
        [menu addChild:replayItem];
        
        //Select Level
        CCMenuItemSprite *mainMenuItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"menu.png"]
                                                                 selectedSprite:[CCSprite spriteWithSpriteFrameName:@"menu_p.png"]
                                                                 disabledSprite:nil
                                                                         target:self
                                                                       selector:@selector(mainMenuHandler)];
        [mainMenuItem setPosition:ccp(kScreenCenterX - 126 * kFactor, 67 * kFactor)];
        [menu addChild:mainMenuItem];
        
        //Shop
        CCSprite *storeSprite = [CCSprite spriteWithSpriteFrameName:@"shop.png"];
        CCSprite *storeSprite_p = [CCSprite spriteWithSpriteFrameName:@"shop_p.png"];
        
        if([GameController sharedGameCtrl].carrotsCount >= 100) {
            CCSprite *badge1 = [CCSprite spriteWithSpriteFrameName:@"lc_box_count.png"];
            [badge1 setPosition:ccp(62 * kFactor, 62 * kFactor)];
            [storeSprite addChild:badge1];
            
            CCSprite *badge2 = [CCSprite spriteWithSpriteFrameName:@"lc_box_count.png"];
            [badge2 setPosition:ccp(62 * kFactor, 62 * kFactor)];
            [storeSprite_p addChild:badge2];
            
            if([[Util sharedUtil] isiPad]) {
                [badge1 setPosition:ccp(70 * kFactor, 70 * kFactor)];
                [badge2 setPosition:ccp(70 * kFactor, 70 * kFactor)];
            }
        }

        CCMenuItemSprite *shopItem = [CCMenuItemSprite itemWithNormalSprite:storeSprite
                                                             selectedSprite:storeSprite_p
                                                             disabledSprite:nil
                                                                     target:self
                                                                   selector:@selector(shopHandler)];
        [shopItem setPosition:ccp(kScreenCenterX + 12 * kFactor, 47 * kFactor)];
        [menu addChild:shopItem];
        
        for(NSUInteger i = 1; i <= 3; ++i) {
            CCSprite *starSprite = nil;
            if(appDelegate.currLevelStars < i) {
                starSprite = [CCSprite spriteWithSpriteFrameName:@"star_grey.png"];
            }
            else {
                starSprite = [CCSprite spriteWithSpriteFrameName:@"star_gold.png"];
            }
            
            [starSprite setScale:0.0f];
            starNumber = i;
            id scaleAction = [CCSequence actions:
                              [CCDelayTime actionWithDuration:0.4f + 0.25f * i],
                              [CCScaleTo actionWithDuration:0.35f scale:1.4f],
                              [CCCallFunc actionWithTarget:self selector:@selector(playStarSound)],
                              [CCScaleTo actionWithDuration:0.1f scale:1.0f],
                              nil];
            [starSprite runAction:scaleAction];
            
            if(!VERSION_IPHONE) {
                [starSprite setPosition:ccp(kScreenCenterX - 60 * kFactor + 48 * kFactor * (i - 1), 475)];
            }
            else {
                [starSprite setPosition:ccp(kScreenCenterX - 63 * kFactor + 48 * kFactor * (i - 1), 200)];
            }
            [self addChild:starSprite];
        }

        NSString *areaName = @"FREEDOM FIELDS";
        
        switch (appDelegate.currArea) {
            case 1:
                areaName = @"FREEDOM FIELDS";
                break;
            case 2:
                areaName = @"FOSSIL FOREST";
                break;
            case 3:
                areaName = @"LOST DESERT";
                break;
            case 4:
                areaName = @"JUNGLE FEVER";
                break;
            case 5:
                areaName = @"DUNGEON CAVES";
                break;
        }
        
        if(!VERSION_IPHONE) {
            [highScoreLabel setPosition:ccp(619, 251)];
            [levelScoreLabel setPosition:ccp(364, 249)];
            
            [bounceScoreLabel setPosition:ccp(424, 409)];
            [coinsScoreLabel setPosition:ccp(424, 362)];
            [enemiesScoreLabel setPosition:ccp(424, 317)];

            [mainMenuItem setPosition:ccp(236, 178)];
            [replayItem setPosition:ccp(378, 130)];
            [shopItem setPosition:ccp(539, 120)];
            [nextItem setPosition:ccp(706, 137)];
            
            [[Util sharedUtil] showLabel:[NSString stringWithFormat:@"LEVEL %ld %@",  (long)appDelegate.currLevel, areaName]
                                  atNode:self 
                              atPosition:ccp(kScreenCenterX - 20, 560)
                                fontName:@"BradyBunchRemastered" 
                                fontSize:22 * kFactor 
                               fontColor:ccc3(255, 102, 0) 
                             anchorPoint:ccp(0.5f, 0.5f)
                               isEnabled:YES 
                                     tag:1 
                              dimensions:CGSizeMake(500, 56) 
                                rotation:0 
                                 bgColor:ccc3(102, 0, 0)]; 

        }
        else {
            [[Util sharedUtil] showLabel:[NSString stringWithFormat:@"LEVEL %ld %@",  (long)appDelegate.currLevel, areaName]
                                  atNode:self
                              atPosition:ccp(kScreenCenterX - 10, 238)
                                fontName:@"BradyBunchRemastered"
                                fontSize:19 * kFactor
                               fontColor:ccc3(255, 102, 0)
                             anchorPoint:ccp(0.5f, 0.5f)
                               isEnabled:YES
                                     tag:1
                              dimensions:CGSizeMake(500, 56)
                                rotation:0
                                 bgColor:ccc3(102, 0, 0)];
        }
	}
	return self;
}

-(void) onEnter {
    [SimpleAudioEngine sharedEngine].backgroundMusicVolume = 0.0f;
	[super onEnter];
}

-(void) onExit {
    [[SimpleAudioEngine sharedEngine] stopEffect:congratsSound];
    
    if ([GameController sharedGameCtrl].isMusicOff == YES) {
        [SimpleAudioEngine sharedEngine].backgroundMusicVolume = 0;
    }
    else {
        [SimpleAudioEngine sharedEngine].backgroundMusicVolume = kBackgroundMusicVolume;
    }
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"levelCompleteAtl.plist"];
    [super onExit];
}

-(void) nextLevelHandler {
    [self stopAllActions];

    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];

    ++[GameController sharedGameCtrl].completedLevels;
    if([GameController sharedGameCtrl].completedLevels >= 5) {
        [GameController sharedGameCtrl].completedLevels = 0;
        [appDelegate showAdBanner];
        return;
    }

    if(appDelegate.currLevel % kLevelsCountInArea == 0) {
        if (appDelegate.currArea == kAreasCount) {
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f
                                                                                         scene:[FinalLayer scene]]];
        }
        else {
            GameController *gC = [GameController sharedGameCtrl];
            NSInteger starsInWorld = [[GameProgressController sharedGProgressCtrl] getStarsForWorld:appDelegate.currArea];
            
            bool isCurrTabUnlocked = YES;
            
            if (appDelegate.currArea == 1 &&
                starsInWorld < 40 &&
                !kTestMode &&
                !gC.isAllWorldsUnlocked &&
                ((!gC.isWorld2UnlockedE && gC.difficultyLevel == kDifficultyEasy) ||
                 (!gC.isWorld2UnlockedM && gC.difficultyLevel == kDifficultyMedium) ||
                 (!gC.isWorld2UnlockedH && gC.difficultyLevel == kDifficultyHard))) {
                isCurrTabUnlocked = NO;
            }
            else if (appDelegate.currArea == 2 &&
                     starsInWorld < 50 &&
                     !kTestMode &&
                     !gC.isAllWorldsUnlocked &&
                     ((!gC.isWorld3UnlockedE && gC.difficultyLevel == kDifficultyEasy) ||
                      (!gC.isWorld3UnlockedM && gC.difficultyLevel == kDifficultyMedium) ||
                      (!gC.isWorld3UnlockedH && gC.difficultyLevel == kDifficultyHard))) {
                isCurrTabUnlocked = NO;
            }
            else if (appDelegate.currArea == 3 &&
                     starsInWorld < 50 &&
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
                        if(gC.difficultyLevel == kDifficultyEasy) {
                            if(!gC.isWasWorld2UnlockedAnimationE) {
                                needShowAnimation = YES;
                            }
                        }
                        else if(gC.difficultyLevel == kDifficultyMedium) {
                            if(!gC.isWasWorld2UnlockedAnimationM) {
                                needShowAnimation = YES;
                            }
                        }
                        else {
                            if(!gC.isWasWorld2UnlockedAnimationH) {
                                needShowAnimation = YES;
                            }
                        }
                        break;
                    case 2:
                        if(gC.difficultyLevel == kDifficultyEasy) {
                            if(!gC.isWasWorld3UnlockedAnimationE) {
                                needShowAnimation = YES;
                            }
                        }
                        else if(gC.difficultyLevel == kDifficultyMedium) {
                            if(!gC.isWasWorld3UnlockedAnimationM) {
                                needShowAnimation = YES;
                            }
                        }
                        else {
                            if(!gC.isWasWorld3UnlockedAnimationH) {
                                needShowAnimation = YES;
                            }
                        }
                        break;
                    case 3:
                        if(gC.difficultyLevel == kDifficultyEasy) {
                            if(!gC.isWasWorld4UnlockedAnimationE) {
                                needShowAnimation = YES;
                            }
                        }
                        else if(gC.difficultyLevel == kDifficultyMedium) {
                            if(!gC.isWasWorld4UnlockedAnimationM) {
                                needShowAnimation = YES;
                            }
                        }
                        else {
                            if(!gC.isWasWorld4UnlockedAnimationH) {
                                needShowAnimation = YES;
                            }
                        }
                        break;
                }
                
                if(needShowAnimation) {
                    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.7f
                                                                                                 scene:[CutScenes2Layer scene]
                                                                                             withColor:ccc3( 0, 0, 0 ) ] ];
                }
                else {
                    [GameController sharedGameCtrl].needInitNextWorld = YES;
                    [GameController sharedGameCtrl].needShowLockAnimation = YES;

                    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.7f
                                                                                                 scene:[SelectAreaLayer scene]
                                                                                             withColor:ccc3( 0, 0, 0 ) ] ];
                }
            }
            else {
                [GameController sharedGameCtrl].needInitNextWorld = YES;
                [GameController sharedGameCtrl].needShowLockAnimation = YES;

                [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.7f
                                                                                             scene:[NotEnoughStarsLayer scene]
                                                                                         withColor:ccc3( 0, 0, 0 ) ] ];
            }
        }
    }
    else {
        ++appDelegate.currLevel;
        [[CCDirector sharedDirector] replaceScene: [LevelStartLayer scene]];
    }
}

-(void) replayLevelHandler {
    [[CCDirector sharedDirector] replaceScene: [LevelStartLayer scene]];
    
}

-(void) mainMenuHandler {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0
                                                                                 scene:[SelectLevelLayer scene]]];
}

-(void) shopHandler {
    ShopLayer *sl = [ShopLayer node];
    [self addChild:sl z:100];
}

- (void) showLevelScore {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    NSInteger tempScore = appDelegate.bounceScores +
                          appDelegate.enemiesScore +
                          appDelegate.currLevelScores;

    [enemiesScoreLabel setEffect:nil];
    [enemiesScoreLabel updateValue:(long) appDelegate.enemiesScore animated:YES];
    [levelScoreLabel updateValue:(long) tempScore animated:YES];
}

-(void) showCarrotTotalScore {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    
    [enemiesScoreLabel updateValue:(long) [GameController sharedGameCtrl].carrotsCount animated:YES];

    NSInteger tempScore = appDelegate.bounceScores +
                          appDelegate.currLevelScores;

    [levelScoreLabel updateValue:(long) tempScore animated:YES];
}

-(void) showCarrotsLevelScore {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];

    [coinsScoreLabel setEffect:nil];
    [coinsScoreLabel updateValue:(long) appDelegate.carrotsEarned animated:YES];

    NSInteger tempScore = appDelegate.bounceScores +
                          appDelegate.currLevelScores;
    [levelScoreLabel updateValue:(long) tempScore animated:YES];
}

-(void) playStarSound {
    [[SimpleAudioEngine sharedEngine] playEffect:[NSString stringWithFormat:@"%ldCoin.mp3", (long)starNumber]];
}

-(void) showHighScore {
//    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
}

-(void) playHighScoreSound {
    [[SimpleAudioEngine sharedEngine] playEffect:@"Yes.mp3"];
}

// Added by Hans(1) for showCarrowCount
-(void) incCarrotsCount{
    CCSprite* carrotspt = (CCSprite*)[self getActionByTag:200];
    [carrotspt removeFromParent];
    
    countCarrot++;
    [carrotscountLabel setEffect:nil];
    [carrotscountLabel updateValue:(long)countCarrot animated:NO];
    CCLOG(@"Total Carrot Count %@", carrotscountLabel.string);
}
-(void) decCarrotsEarned{
    earnedCarrot -- ;
    [coinsScoreLabel setEffect:nil];
    [coinsScoreLabel updateValue:(long)earnedCarrot animated:NO];
    CCLOG(@"Earned Carrot Count %@", coinsScoreLabel.string);
}

-(void) moveCarrots{
    CCLOG(@"Move Carrots");
    
    if (earnedCarrot >= 0)
    {
        CCSprite* carrotspt = [CCSprite spriteWithFile:@"carrot.png"];
        [self addChild:carrotspt z:0 tag:200];
        [carrotspt setPosition:coinsScoreLabel.position];
        CCMoveTo* moveAction = [CCMoveTo actionWithDuration:0.4f position:carrot_image.position];
        [carrotspt runAction:moveAction];
        
    }
}
// Added end

@end