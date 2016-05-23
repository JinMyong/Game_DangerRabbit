//
//  SelectAreaLayer.m
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "SelectAreaLayer.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "SelectLevelLayer.h"
#import "MyMenuItemSprite.h"
#import "DifficultyLayer.h"
#import "GameProgressController.h"
#import "GameController.h"
#import "SimpleAudioEngine.h"
#import "Util.h"
#import "PerfectWorldLayer.h"
#import "NotEnoughStarsLayer.h"

#define kAlertSpriteTag     1001

@implementation SelectAreaLayer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	SelectAreaLayer *layer = [SelectAreaLayer node];
	[scene addChild: layer];
	
	return scene;
}

-(id) init {
	if((self=[super init])) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"selectAreaAtl.plist"];
        AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
        GameController *gC = [GameController sharedGameCtrl];

        [appDelegate loadAnimCacheWithName:@"unlock2" delay:0.2f maxFrames:8];
        [appDelegate loadAnimCacheWithName:@"unlock3" delay:0.2f maxFrames:8];
        [appDelegate loadAnimCacheWithName:@"unlock4" delay:0.2f maxFrames:8];
        [appDelegate loadAnimCacheWithName:@"unlock5" delay:0.2f maxFrames:8];
        
        CCSprite *bg = [CCSprite spriteWithFile:@"selectArea.jpg"];
        [bg setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg z:-2];

        float shiftItemX = (kAreasCount - 1.0f) / 2.0f;
        
        areasMenu = [CCMenu menuWithItems:nil];
        [areasMenu setPosition:CGPointZero];
        [self addChild: areasMenu z:20];
        
        CCMenu *menu = [CCMenu menuWithItems:nil];
        [menu setPosition:CGPointZero];
        [self addChild: menu z:20];
        
        for(NSUInteger i = 0; i < kAreasCount; ++i) {
            CCSprite *normalSprite = nil;
            MyMenuItemSprite *item = nil;
            
            if (i == 1 &&
                ([[GameProgressController sharedGProgressCtrl] getStarsForWorld:i] < 40 ||
                 [[GameProgressController sharedGProgressCtrl] getStarsForLevel:kLevelsCountInArea] < 1) &&
                !kTestMode &&
                !gC.isAllWorldsUnlocked &&
                ((!gC.isWorld2UnlockedE && gC.difficultyLevel == kDifficultyEasy) ||
                 (!gC.isWorld2UnlockedM && gC.difficultyLevel == kDifficultyMedium) ||
                 (!gC.isWorld2UnlockedH && gC.difficultyLevel == kDifficultyHard))) {
                
                normalSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"unlock%lu_1.png", i + 1]];
                item = [MyMenuItemSprite itemWithNormalSprite:normalSprite
                                               selectedSprite:nil
                                               disabledSprite:nil
                                                       target:self
                                                     selector:@selector(showAlertForArea)];
            }
            else if (i == 2 &&
                     ([[GameProgressController sharedGProgressCtrl] getStarsForWorld:i] < 50 ||
                      [[GameProgressController sharedGProgressCtrl] getStarsForLevel:kLevelsCountInArea * 2] < 1) &&
                     !kTestMode &&
                     !gC.isAllWorldsUnlocked &&
                     ((!gC.isWorld3UnlockedE && gC.difficultyLevel == kDifficultyEasy) ||
                      (!gC.isWorld3UnlockedM && gC.difficultyLevel == kDifficultyMedium) ||
                      (!gC.isWorld3UnlockedH && gC.difficultyLevel == kDifficultyHard))) {
                normalSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"unlock%lu_1.png", i + 1]];
                item = [MyMenuItemSprite itemWithNormalSprite:normalSprite
                                               selectedSprite:nil
                                               disabledSprite:nil
                                                       target:self
                                                     selector:@selector(showAlertForArea)];
            }
            else if (i == 3 &&
                     ([[GameProgressController sharedGProgressCtrl] getStarsForWorld:i] < 50 ||
                      [[GameProgressController sharedGProgressCtrl] getStarsForLevel:kLevelsCountInArea * 3] < 1) &&
                     !kTestMode &&
                     !gC.isAllWorldsUnlocked &&
                     ((!gC.isWorld4UnlockedE && gC.difficultyLevel == kDifficultyEasy) ||
                      (!gC.isWorld4UnlockedM && gC.difficultyLevel == kDifficultyMedium) ||
                      (!gC.isWorld4UnlockedH && gC.difficultyLevel == kDifficultyHard))) {
                normalSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"unlock%lu_1.png", i + 1]];
                item = [MyMenuItemSprite itemWithNormalSprite:normalSprite
                                               selectedSprite:nil
                                               disabledSprite:nil
                                                       target:self
                                                     selector:@selector(showAlertForArea)];
            }
            else {
                normalSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"unlock%lu_8.png", i + 1]];
                item = [MyMenuItemSprite itemWithNormalSprite:normalSprite
                                               selectedSprite:nil
                                               disabledSprite:nil
                                                       target:self
                                                     selector:@selector(startArea:)];
            }
            [item setTag:i + 1];
            
            NSInteger completedLevels = [[GameProgressController sharedGProgressCtrl] getCompletedLevelsForChapter:i];
            
            bool isCurrTabUnlocked = YES;

            if ( i == 0) {
                [item setIsEnabled:YES];
            }
            else if (i == 1 &&
                     ([[GameProgressController sharedGProgressCtrl] getStarsForWorld:i] < 40 ||
                      [[GameProgressController sharedGProgressCtrl] getStarsForLevel:kLevelsCountInArea] < 1) &&
                     !kTestMode &&
                     !gC.isAllWorldsUnlocked &&
                     ((!gC.isWorld2UnlockedE && gC.difficultyLevel == kDifficultyEasy) ||
                      (!gC.isWorld2UnlockedM && gC.difficultyLevel == kDifficultyMedium) ||
                      (!gC.isWorld2UnlockedH && gC.difficultyLevel == kDifficultyHard))) {
                isCurrTabUnlocked = NO;
            }
            else if (i == 2 &&
                     ([[GameProgressController sharedGProgressCtrl] getStarsForWorld:i] < 50 ||
                      [[GameProgressController sharedGProgressCtrl] getStarsForLevel:kLevelsCountInArea * 2] < 1) &&
                     !kTestMode &&
                     !gC.isAllWorldsUnlocked &&
                     ((!gC.isWorld3UnlockedE && gC.difficultyLevel == kDifficultyEasy) ||
                      (!gC.isWorld3UnlockedM && gC.difficultyLevel == kDifficultyMedium) ||
                      (!gC.isWorld3UnlockedH && gC.difficultyLevel == kDifficultyHard))) {
                isCurrTabUnlocked = NO;
            }
            else if (i == 3 &&
                     ([[GameProgressController sharedGProgressCtrl] getStarsForWorld:i] < 50 ||
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
                
                switch (i) {
                    case 1:
                        if(gC.difficultyLevel == kDifficultyEasy) {
                            if(!gC.isWasWorld2UnlockedAnimationE) {
                                needShowAnimation = YES;
                                gC.isWasWorld2UnlockedAnimationE = YES;
                                [gC save];
                            }
                        }
                        else if(gC.difficultyLevel == kDifficultyMedium) {
                            if(!gC.isWasWorld2UnlockedAnimationM) {
                                needShowAnimation = YES;
                                gC.isWasWorld2UnlockedAnimationM = YES;
                                [gC save];
                            }
                        }
                        else {
                            if(!gC.isWasWorld2UnlockedAnimationH) {
                                needShowAnimation = YES;
                                gC.isWasWorld2UnlockedAnimationH = YES;
                                [gC save];
                            }
                        }
                        break;
                    case 2:
                        if(gC.difficultyLevel == kDifficultyEasy) {
                            if(!gC.isWasWorld3UnlockedAnimationE) {
                                needShowAnimation = YES;
                                gC.isWasWorld3UnlockedAnimationE = YES;
                                [gC save];
                            }
                        }
                        else if(gC.difficultyLevel == kDifficultyMedium) {
                            if(!gC.isWasWorld3UnlockedAnimationM) {
                                needShowAnimation = YES;
                                gC.isWasWorld3UnlockedAnimationM = YES;
                                [gC save];
                            }
                        }
                        else {
                            if(!gC.isWasWorld3UnlockedAnimationH) {
                                needShowAnimation = YES;
                                gC.isWasWorld3UnlockedAnimationH = YES;
                                [gC save];
                            }
                        }
                        break;
                    case 3:
                        if(gC.difficultyLevel == kDifficultyEasy) {
                            if(!gC.isWasWorld4UnlockedAnimationE) {
                                needShowAnimation = YES;
                                gC.isWasWorld4UnlockedAnimationE = YES;
                                [gC save];
                            }
                        }
                        else if(gC.difficultyLevel == kDifficultyMedium) {
                            if(!gC.isWasWorld4UnlockedAnimationM) {
                                needShowAnimation = YES;
                                gC.isWasWorld4UnlockedAnimationM = YES;
                                [gC save];
                            }
                        }
                        else {
                            if(!gC.isWasWorld4UnlockedAnimationH) {
                                needShowAnimation = YES;
                                gC.isWasWorld4UnlockedAnimationH = YES;
                                [gC save];
                            }
                        }
                        break;
                }
                
                if(needShowAnimation) {
                    worldForAnimation = i + 1;
                    spriteForAnimation = normalSprite;
                    if([[GameProgressController sharedGProgressCtrl] getStarsForWorld:appDelegate.currArea] >= 60) {
                        bool needPerfectWorld = NO;
                        
                        if(i == 0) {
                            if(gC.difficultyLevel == kDifficultyEasy) {
                                if(![GameController sharedGameCtrl].wasWorld1PerfectE) {
                                    [GameController sharedGameCtrl].wasWorld1PerfectE = YES;
                                    [[GameController sharedGameCtrl] save];
                                    needPerfectWorld = YES;
                                }
                            }
                            else if(gC.difficultyLevel == kDifficultyMedium) {
                                if(![GameController sharedGameCtrl].wasWorld1PerfectM) {
                                    [GameController sharedGameCtrl].wasWorld1PerfectM = YES;
                                    [[GameController sharedGameCtrl] save];
                                    needPerfectWorld = YES;
                                }
                            }
                            else {
                                if(![GameController sharedGameCtrl].wasWorld1PerfectH) {
                                    [GameController sharedGameCtrl].wasWorld1PerfectH = YES;
                                    [[GameController sharedGameCtrl] save];
                                    needPerfectWorld = YES;
                                }
                            }
                        }
                        else if(i == 1) {
                            if(gC.difficultyLevel == kDifficultyEasy) {
                                if(![GameController sharedGameCtrl].wasWorld2PerfectE) {
                                    [GameController sharedGameCtrl].wasWorld2PerfectE = YES;
                                    [[GameController sharedGameCtrl] save];
                                    needPerfectWorld = YES;
                                }
                            }
                            else if(gC.difficultyLevel == kDifficultyMedium) {
                                if(![GameController sharedGameCtrl].wasWorld2PerfectM) {
                                    [GameController sharedGameCtrl].wasWorld2PerfectM = YES;
                                    [[GameController sharedGameCtrl] save];
                                    needPerfectWorld = YES;
                                }
                            }
                            else {
                                if(![GameController sharedGameCtrl].wasWorld2PerfectH) {
                                    [GameController sharedGameCtrl].wasWorld2PerfectH = YES;
                                    [[GameController sharedGameCtrl] save];
                                    needPerfectWorld = YES;
                                }
                            }
                        }
                        else if(i == 2) {
                            if(gC.difficultyLevel == kDifficultyEasy) {
                                if(![GameController sharedGameCtrl].wasWorld3PerfectE) {
                                    [GameController sharedGameCtrl].wasWorld3PerfectE = YES;
                                    [[GameController sharedGameCtrl] save];
                                    needPerfectWorld = YES;
                                }
                            }
                            else if(gC.difficultyLevel == kDifficultyMedium) {
                                if(![GameController sharedGameCtrl].wasWorld3PerfectM) {
                                    [GameController sharedGameCtrl].wasWorld3PerfectM = YES;
                                    [[GameController sharedGameCtrl] save];
                                    needPerfectWorld = YES;
                                }
                            }
                            else {
                                if(![GameController sharedGameCtrl].wasWorld3PerfectH) {
                                    [GameController sharedGameCtrl].wasWorld3PerfectH = YES;
                                    [[GameController sharedGameCtrl] save];
                                    needPerfectWorld = YES;
                                }
                            }
                        }
                        else if(i == 3) {
                            if(gC.difficultyLevel == kDifficultyEasy) {
                                if(![GameController sharedGameCtrl].wasWorld4PerfectE) {
                                    [GameController sharedGameCtrl].wasWorld4PerfectE = YES;
                                    [[GameController sharedGameCtrl] save];
                                    needPerfectWorld = YES;
                                }
                            }
                            else if(gC.difficultyLevel == kDifficultyMedium) {
                                if(![GameController sharedGameCtrl].wasWorld4PerfectM) {
                                    [GameController sharedGameCtrl].wasWorld4PerfectM = YES;
                                    [[GameController sharedGameCtrl] save];
                                    needPerfectWorld = YES;
                                }
                            }
                            else {
                                if(![GameController sharedGameCtrl].wasWorld4PerfectH) {
                                    [GameController sharedGameCtrl].wasWorld4PerfectH = YES;
                                    [[GameController sharedGameCtrl] save];
                                    needPerfectWorld = YES;
                                }
                            }
                        }

                        if(needPerfectWorld) {
                            PerfectWorldLayer *pwl = [PerfectWorldLayer node];
                            [self addChild:pwl z:1000];
                        }
                        else {
                            [self showLockAnimation];
                        }
                    }
                    else {
                        [self showLockAnimation];
                    }
                }
            }
            
            [item setPosition:ccp(kScreenCenterX - shiftItemX * 116 * kFactor + i * 116 * kFactor, kScreenCenterY + 10 * kFactor)];
            [areasMenu addChild:item];
            
            [[Util sharedUtil] showLabel:[NSString stringWithFormat:@"%ld/20", (long)completedLevels]
                                  atNode:self 
                              atPosition:ccp(kScreenCenterX - shiftItemX * 116 * kFactor + i * 116 * kFactor, kScreenCenterY + 107 * kFactor)
                                fontName:@"BradyBunchRemastered"
                                fontSize:24 * kFactor 
                               fontColor:ccc3(255, 255, 255) 
                             anchorPoint:ccp(0.5, 0.5) 
                               isEnabled:YES 
                                     tag:1 
                              dimensions:CGSizeMake(500, 56) 
                                rotation:0 
                                 bgColor:ccc3(204, 0, 0)];
            
            NSInteger starsInWorld = [[GameProgressController sharedGProgressCtrl] getStarsForWorld:i + 1];
            [[Util sharedUtil] showLabel:[NSString stringWithFormat:@"%ld/60", (long)starsInWorld]
                                  atNode:self
                              atPosition:ccp(kScreenCenterX - shiftItemX * 116 * kFactor + i * 116 * kFactor - 10 * kFactor, kScreenCenterY - 84 * kFactor)
                                fontName:@"BradyBunchRemastered"
                                fontSize:24 * kFactor
                               fontColor:ccc3(255, 255, 255)
                             anchorPoint:ccp(0.5, 0.5)
                               isEnabled:YES
                                     tag:1
                              dimensions:CGSizeMake(500, 56)
                                rotation:0
                                 bgColor:ccc3(204, 0, 0)];
            
            CCSprite *starSprite = [CCSprite spriteWithSpriteFrameName:@"sa_star_gold.png"];
            [starSprite setScale:0.5f];
            [starSprite setPosition:ccp(kScreenCenterX - shiftItemX * 116 * kFactor + i * 116 * kFactor + 26 * kFactor,
                                        kScreenCenterY - 84 * kFactor)];
            [self addChild:starSprite];
            
            if([[GameProgressController sharedGProgressCtrl] getStarsForWorld:appDelegate.currArea] >= 60) {
                bool needPerfectWorld = NO;
                
                if(appDelegate.currArea == 0) {
                    if(gC.difficultyLevel == kDifficultyEasy) {
                        if(![GameController sharedGameCtrl].wasWorld1PerfectE) {
                            [GameController sharedGameCtrl].wasWorld1PerfectE = YES;
                            [[GameController sharedGameCtrl] save];
                            needPerfectWorld = YES;
                        }
                    }
                    else if(gC.difficultyLevel == kDifficultyMedium) {
                        if(![GameController sharedGameCtrl].wasWorld1PerfectM) {
                            [GameController sharedGameCtrl].wasWorld1PerfectM = YES;
                            [[GameController sharedGameCtrl] save];
                            needPerfectWorld = YES;
                        }
                    }
                    else {
                        if(![GameController sharedGameCtrl].wasWorld1PerfectH) {
                            [GameController sharedGameCtrl].wasWorld1PerfectH = YES;
                            [[GameController sharedGameCtrl] save];
                            needPerfectWorld = YES;
                        }
                    }
                }
                else if(appDelegate.currArea == 1) {
                    if(gC.difficultyLevel == kDifficultyEasy) {
                        if(![GameController sharedGameCtrl].wasWorld2PerfectE) {
                            [GameController sharedGameCtrl].wasWorld2PerfectE = YES;
                            [[GameController sharedGameCtrl] save];
                            needPerfectWorld = YES;
                        }
                    }
                    else if(gC.difficultyLevel == kDifficultyMedium) {
                        if(![GameController sharedGameCtrl].wasWorld2PerfectM) {
                            [GameController sharedGameCtrl].wasWorld2PerfectM = YES;
                            [[GameController sharedGameCtrl] save];
                            needPerfectWorld = YES;
                        }
                    }
                    else {
                        if(![GameController sharedGameCtrl].wasWorld2PerfectH) {
                            [GameController sharedGameCtrl].wasWorld2PerfectH = YES;
                            [[GameController sharedGameCtrl] save];
                            needPerfectWorld = YES;
                        }
                    }
                }
                else if(appDelegate.currArea == 2) {
                    if(gC.difficultyLevel == kDifficultyEasy) {
                        if(![GameController sharedGameCtrl].wasWorld3PerfectE) {
                            [GameController sharedGameCtrl].wasWorld3PerfectE = YES;
                            [[GameController sharedGameCtrl] save];
                            needPerfectWorld = YES;
                        }
                    }
                    else if(gC.difficultyLevel == kDifficultyMedium) {
                        if(![GameController sharedGameCtrl].wasWorld3PerfectM) {
                            [GameController sharedGameCtrl].wasWorld3PerfectM = YES;
                            [[GameController sharedGameCtrl] save];
                            needPerfectWorld = YES;
                        }
                    }
                    else {
                        if(![GameController sharedGameCtrl].wasWorld3PerfectH) {
                            [GameController sharedGameCtrl].wasWorld3PerfectH = YES;
                            [[GameController sharedGameCtrl] save];
                            needPerfectWorld = YES;
                        }
                    }
                }
                else if(appDelegate.currArea == 3) {
                    if(gC.difficultyLevel == kDifficultyEasy) {
                        if(![GameController sharedGameCtrl].wasWorld4PerfectE) {
                            [GameController sharedGameCtrl].wasWorld4PerfectE = YES;
                            [[GameController sharedGameCtrl] save];
                            needPerfectWorld = YES;
                        }
                    }
                    else if(gC.difficultyLevel == kDifficultyMedium) {
                        if(![GameController sharedGameCtrl].wasWorld4PerfectM) {
                            [GameController sharedGameCtrl].wasWorld4PerfectM = YES;
                            [[GameController sharedGameCtrl] save];
                            needPerfectWorld = YES;
                        }
                    }
                    else {
                        if(![GameController sharedGameCtrl].wasWorld4PerfectM) {
                            [GameController sharedGameCtrl].wasWorld4PerfectM = YES;
                            [[GameController sharedGameCtrl] save];
                            needPerfectWorld = YES;
                        }
                    }
                }
                
                if(needPerfectWorld) {
                    PerfectWorldLayer *pwl = [PerfectWorldLayer node];
                    pwl.needLockAnimation = NO;
                    [self addChild:pwl z:1000];
                }
            }

        }

        CCMenuItemSprite *backItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"sa_back.png"]
                                                             selectedSprite:[CCSprite spriteWithSpriteFrameName:@"sa_back_p.png"]
                                                             disabledSprite:nil
                                                                     target:self
                                                                   selector:@selector(backHandler)];
        [backItem setPosition:ccp(36 * kFactor, 36 * kFactor)];
        [menu addChild:backItem];
        
        gC.needShowLockAnimation = NO;
	}
	return self;
}

-(void) onEnter {
	[super onEnter];
}

-(void) onExit {
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"unlock2"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"unlock3"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"unlock4"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"unlock5"];

    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"selectAreaAtl.plist"];
    [super onExit];
}

-(void) startArea: (CCMenuItemLabel *) item {
    [[SimpleAudioEngine sharedEngine] playEffect:@"Select.mp3"];
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    appDelegate.currArea = item.tag;
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0
                                                                                 scene:[SelectLevelLayer scene]]];
}

-(void) backHandler {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0
                                                                                 scene:[DifficultyLayer scene]]];
}

- (void) showAlertForArea {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.7f
                                                                                 scene:[NotEnoughStarsLayer scene]
                                                                             withColor:ccc3( 0, 0, 0 ) ] ];
}

- (void) removeNode: (id) sender {
    CCNode *node = (CCNode *)sender;
    if(node) {
        [node removeFromParentAndCleanup:YES];
    }
}

- (void) showLockAnimation {
    CCSprite *lockSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"unlock%ld_1.png", (long)worldForAnimation]];
    [lockSprite setPosition:ccp(spriteForAnimation.contentSize.width / 2.0f,
                                spriteForAnimation.contentSize.height / 2.0f)];
    [spriteForAnimation addChild:lockSprite];
    
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:[NSString stringWithFormat:@"unlock%ld", (long)worldForAnimation]];
    id action = [CCSequence actions:
                 [CCDelayTime actionWithDuration:0.7f],
                 [CCAnimate actionWithAnimation:animation],
                 nil];
    [lockSprite runAction:action];
}

@end