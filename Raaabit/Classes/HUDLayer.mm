//
//  HUDLayer.m
//  Raaabit
//
//  Created by Dmitry Valov on 11.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "HUDLayer.h"
#import "GameLayer.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "SelectLevelLayer.h"
#import "PauseLayer.h"
#import "BulletMeter.h"

@implementation HUDLayer

@synthesize bulletMeterNode = bulletMeterNode_;

-(id) init {
	if( (self=[super init])) {
        isTrampolinesLabelAnimated = NO;
        [self createMenu];
	}
	return self;
}

-(void) onEnter {
	[super onEnter];
}

-(void) createMenu {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"UIAtl.plist"];
    
    float delta = 5 * kFactor;
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    
    //Lives
    CCSprite *livesBG = [CCSprite spriteWithSpriteFrameName:@"livesui.png"];
    [livesBG setAnchorPoint:ccp(0.0f, 1.0f)];
    [livesBG setPosition:ccp(0, kScreenHeight - delta)];
    [self addChild:livesBG];
    
    NSInteger lives = appDelegate.livesCount;
    if(lives < 0) {
        lives = 0;
    }
    livesValue = [[CCLabelBMFont alloc] initWithString:[NSString stringWithFormat:@"%d", lives]
                                               fntFile:@"font_ui_timer.fnt"];
    [self addChild:livesValue z:0];
    [livesValue setPosition:ccp(livesBG.position.x + 10 * kFactor + livesBG.contentSize.width / 2,
                                livesBG.position.y - livesBG.contentSize.height / 2 + 3 * kFactor)];

    //Trampolines
    trampolinBG = [CCSprite spriteWithSpriteFrameName:@"trampolineui.png"];
    [trampolinBG setAnchorPoint:ccp(0.0f, 1.0f)];
    [trampolinBG setPosition:ccp(livesBG.position.x + livesBG.contentSize.width, kScreenHeight - delta)];
    [self addChild:trampolinBG];
    
    countTrampolinesValue = [[CCLabelBMFont alloc] initWithString:@"0"
                                               fntFile:@"font_ui_timer.fnt"];
    [self addChild:countTrampolinesValue z:0];
    [countTrampolinesValue setColor:ccWHITE];
    [countTrampolinesValue setPosition:ccp(trampolinBG.position.x + 12 * kFactor + trampolinBG.contentSize.width / 2,
                               trampolinBG.position.y - trampolinBG.contentSize.height / 2 + 3 * kFactor)];

    //Coins
    coinBG = [CCSprite spriteWithSpriteFrameName:@"coinui.png"];
    [coinBG setAnchorPoint:ccp(0.0f, 1.0f)];
    [coinBG setPosition:ccp(trampolinBG.position.x + trampolinBG.contentSize.width, kScreenHeight - delta)];
    [self addChild:coinBG];
    
    coinsValue = [[CCLabelBMFont alloc] initWithString:[NSString stringWithFormat:@"%d/%d", 0, 0]
                                               fntFile:@"font_ui_timer.fnt"];    
    [self addChild:coinsValue z:0];
    [coinsValue setPosition:ccp(coinBG.position.x + 14 * kFactor + coinBG.contentSize.width / 2,
                                coinBG.position.y - coinBG.contentSize.height / 2 + 3 * kFactor)];

    //Scores
    CCSprite *scoreBG = [CCSprite spriteWithSpriteFrameName:@"scoreui.png"];
    [scoreBG setAnchorPoint:ccp(0.0f, 1.0f)];
    [scoreBG setPosition:ccp(coinBG.position.x + coinBG.contentSize.width, kScreenHeight - delta)];
    [self addChild:scoreBG];
    
    scoresValue = [[CCLabelBMFont alloc] initWithString:@"0"
                                                fntFile:@"font_ui_score.fnt"];
    [self addChild:scoresValue z:0];
    [scoresValue setAnchorPoint:ccp(0.0f, 0.5f)];
    [scoresValue setPosition:ccp(scoreBG.position.x + scoreBG.contentSize.width,
                                 scoreBG.position.y - scoreBG.contentSize.height / 2 + 7 * kFactor)];

    //Pause
    CCMenuItemSprite *pauseItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"pause.png"]
                                                          selectedSprite:[CCSprite spriteWithSpriteFrameName:@"pause_p.png"]
                                                          disabledSprite:nil
                                                                  target:self
                                                                selector:@selector(pauseHandler)];
    [pauseItem setPosition:ccp(kScreenWidth - 21 * kFactor, kScreenHeight - 21 * kFactor)];

	menu = [CCMenu menuWithItems:pauseItem, nil];
	[menu setPosition:CGPointZero];
	[self addChild: menu z:20];
}

-(void)onExit {
//    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"UIAtl.plist"];
    [super onExit];
}

-(void)updateLives: (NSInteger) lives {
    if(lives < 0) {
        lives = 0;
    }
    [livesValue setString:[NSString stringWithFormat:@"%d", lives]];
}

-(void)updateTrampolines: (NSInteger) count {
    [countTrampolinesValue setString:[NSString stringWithFormat:@"%d", count]];
    if(count <= 3) {
        [countTrampolinesValue setColor:ccRED];
        
        if(!isTrampolinesLabelAnimated) {
            isTrampolinesLabelAnimated = YES;
            id actionBlink = [CCRepeatForever actionWithAction:
                              [CCSequence actions:
                               [CCScaleTo actionWithDuration:0.4f scale:1.5f],
                               [CCScaleTo actionWithDuration:0.4f scale:1.0f],
                               nil]];
            [countTrampolinesValue runAction:actionBlink];
        }
    }
    else {
        if(isTrampolinesLabelAnimated) {
            isTrampolinesLabelAnimated = NO;
            [countTrampolinesValue stopAllActions];
        }
        [countTrampolinesValue setColor:ccWHITE];
    }
}

-(void)updateTrampolinesStick:(NSInteger)count {
    numberOfSticky = count;

    if(countTrampolinesStickValue != nil) {
        if(count > 0) {
            [countTrampolinesStickValue setString:[NSString stringWithFormat:@"+%d", count]];
        }
        else {
            [countTrampolinesStickValue removeFromParentAndCleanup:YES];
            countTrampolinesStickValue = nil;
            [stickyTrampolinesSign removeFromParentAndCleanup:YES];
            stickyTrampolinesSign = nil;
        }
    }
    else if(count > 0){
        countTrampolinesStickValue = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"+%d", count]
                                                               fontName:@"BradyBunchRemastered"
                                                               fontSize:18 * kFactor];
        [self addChild:countTrampolinesStickValue z:1];
        [countTrampolinesStickValue setColor:ccc3(255, 255, 255)]; // origin 211, 112, 34 by Hans
        [countTrampolinesStickValue setPosition:ccp(30 * kFactor, kScreenHeight - 60 * kFactor)];
        
        stickyTrampolinesSign = [CCSprite spriteWithFile:@"tramStickBonus.png"];
        CCLOG(@"Fctore is %d", kFactor);
        [stickyTrampolinesSign setPosition:ccp(24 * kFactor, kScreenHeight - 68 * kFactor)];
//        [stickyTrampolinesSign setScale:kFactor];
        [self addChild:stickyTrampolinesSign z:0];
    }
    [self updateTrampolinesBorder];
}

-(void)updateTrampolinesPurple:(NSInteger)count {
    numberOfPurple = count;

    if(countTrampolinesPurpleValue != nil) {
        if(count > 0) {
            [countTrampolinesPurpleValue setString:[NSString stringWithFormat:@"+%d", count]];
        }
        else {
            [countTrampolinesPurpleValue removeFromParentAndCleanup:YES];
            countTrampolinesPurpleValue = nil;
            [purpleTrampolinesSign removeFromParentAndCleanup:YES];
            purpleTrampolinesSign = nil;
        }
    }
    else if(count > 0){
        countTrampolinesPurpleValue = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"+%d", count]
                                                               fontName:@"BradyBunchRemastered"
                                                               fontSize:18 * kFactor];
        [self addChild:countTrampolinesPurpleValue z:1];
        [countTrampolinesPurpleValue setColor:ccc3(124, 59, 135)];
        [countTrampolinesPurpleValue setPosition:ccp(30 * kFactor, kScreenHeight - 60 * kFactor)];

        purpleTrampolinesSign = [CCSprite spriteWithFile:@"purpleBonus.png"];// Added by Hans
        [purpleTrampolinesSign setPosition:ccp(24 * kFactor, kScreenHeight - 68 * kFactor)];
        CCLOG(@"Fctore is %d", kFactor);
//        [purpleTrampolinesSign setScale:kFactor];
        [self addChild:purpleTrampolinesSign z:0];
    }
    [self updateTrampolinesBorder];
}

-(void) updateBombs: (NSInteger) count {
    if(countBombsValue != nil) {
        if(count > 0) {
            [countBombsValue setString:[NSString stringWithFormat:@"+%d", count]];
        }
        else {
            [countBombsValue removeFromParentAndCleanup:YES];
            countBombsValue = nil;
            [bombsSign removeFromParentAndCleanup:YES];
            bombsSign = nil;
        }
    }
    else if(count > 0){
        countBombsValue = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"+%d", count]
                                                    fontName:@"BradyBunchRemastered"
                                                    fontSize:18 * kFactor];
        [self addChild:countBombsValue z:0];
        [countBombsValue setColor:ccc3(60, 60, 60)];
        [countBombsValue setPosition:ccp(37 * kFactor, kScreenHeight - 80 * kFactor)];
        
        bombsSign = [CCSprite spriteWithSpriteFrameName:@"ui_bomb.png"];
        [bombsSign setPosition:ccp(20 * kFactor, kScreenHeight - 79 * kFactor)];
        [self addChild:bombsSign];
    }
}

-(void)updateCoins: (NSInteger) coins withTotal: (NSInteger) total {
    [coinsValue setString:[NSString stringWithFormat:@"%d/%d", coins, total]];
}

-(void)updateScores: (NSInteger) scores {
    [scoresValue setString:[NSString stringWithFormat:@"%d", scores]];
}

-(NSString *)secondsToString: (NSInteger) seconds {
    NSInteger min = seconds / 60;
    NSInteger sec = seconds - min * 60;
    NSString *result;
    
    if(seconds <= 0) {
        result = [NSString stringWithFormat:@"0:00"];
    }
    else if(min < 10 && sec < 10) {
        result = [NSString stringWithFormat:@"%d:0%d", min, sec];
    }
    else if (min < 10) {
        result = [NSString stringWithFormat:@"%d:%d", min, sec];
    }
    else if (sec < 10) {
        result = [NSString stringWithFormat:@"%d:0%d", min, sec];
    }
    else {
        result = [NSString stringWithFormat:@"%d:%d", min, sec];
    }
    return result;
}

-(void)pauseHandler {
    GameLayer *gl = (GameLayer *)[self.parent getChildByTag:kGameLayerTag];
    if(gl.isMenuShown == YES) {
        return;
    }
    gl.isMenuShown = YES;
    PauseLayer *pl = [PauseLayer node];
    [self.parent addChild:pl z:1000];
    [[CCDirector sharedDirector] pause];
}

-(void)showSaveMe {
    GameLayer *gl = (GameLayer *)[self.parent getChildByTag:kGameLayerTag];
    gl.isMenuShown = YES;
    CCMenuItemSprite *saveItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"coinui.png"]
                                                         selectedSprite:[CCSprite spriteWithSpriteFrameName:@"scoreui.png"]
                                                         disabledSprite:nil
                                                                 target:self
                                                               selector:@selector(saveMeHandler:)];
    [saveItem setPosition:ccp(kScreenCenterX, -100 * kFactor)];
    [menu addChild:saveItem];
    
    id action = [CCSequence actions:
                 [CCMoveTo actionWithDuration:0.5f position:ccp(kScreenCenterX, 70 * kFactor)],
                 [CCDelayTime actionWithDuration:3.0f],
                 [CCMoveTo actionWithDuration:0.5f position:ccp(kScreenCenterX, -100 * kFactor)],
                 [CCCallFuncN actionWithTarget:self selector:@selector(restartLevel)],
                 nil];
    [saveItem runAction:action];
}

-(void)saveMeHandler: (id) sender {
    CCMenuItemSprite *saveItem = (CCMenuItemSprite *)sender;
    [saveItem stopAllActions];
    id action = [CCSequence actions:
                 [CCMoveTo actionWithDuration:0.5f position:ccp(kScreenCenterX, -100 * kFactor)],
                 [CCCallFuncN actionWithTarget:self selector:@selector(removeSaveMenu:)],
                 nil];
    [saveItem runAction:action];
}

-(void)restartLevel {
    GameLayer *gl = (GameLayer *)[self.parent getChildByTag:kGameLayerTag];
    [gl restartLevel];
}

-(void)removeSaveMenu: (id) sender {
    CCMenuItemSprite *saveItem = (CCMenuItemSprite *)sender;
    [saveItem removeFromParentAndCleanup:YES];
    
    GameLayer *gl = (GameLayer *)[self.parent getChildByTag:kGameLayerTag];
    gl.isMenuShown = NO;
    [gl saveHero];
}

-(void) showBulletMeter {
    bulletMeterNode_ = [BulletMeter node];
    [bulletMeterNode_ setAnchorPoint:ccp(0.0f, 0.5f)];
    [bulletMeterNode_ setPosition:ccp(coinBG.position.x + 10.0f * kFactor, coinBG.position.y)];
    [self addChild:bulletMeterNode_ z:1000];
    
    [trampolinBG setVisible:NO];
    [coinBG setVisible:NO];
    [countTrampolinesValue setVisible:NO];
    [coinsValue setVisible:NO];
}

-(void) hideBulletMeter {
    [bulletMeterNode_ removeFromParentAndCleanup:YES];
    bulletMeterNode_ = nil;
    
    [trampolinBG setVisible:YES];
    [coinBG setVisible:YES];
    [countTrampolinesValue setVisible:YES];
    [coinsValue setVisible:YES];
}

-(void) updateTrampolinesBorder {
    CCSpriteFrame *frame = nil;
    
    if(numberOfSticky > 0 && numberOfPurple > 0) {
        frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"trampolineui_both.png"];
    }
    else if(numberOfSticky > 0) {
        frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"trampolineui_sticky.png"];
    }
    else if(numberOfPurple > 0) {
        frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"trampolineui_super.png"];
    }
    else {
        frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"trampolineui.png"];
    }
    [trampolinBG setDisplayFrame:frame];
}

@end
