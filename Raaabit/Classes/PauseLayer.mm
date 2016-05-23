//
//  PauseLayer.m
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "PauseLayer.h"
#import "SelectLevelLayer.h"
#import "GameLayer.h"
#import "MyMenuItemSprite.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "GameProgressController.h"
#import "Util.h"
#import "LevelStartLayer.h"

@implementation PauseLayer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	PauseLayer *layer = [PauseLayer node];
	[scene addChild: layer];
	
	return scene;
}

-(id) init {
	if((self=[super init])) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"pauseAtl.plist"];
     
        CCSprite *bg = [CCSprite spriteWithSpriteFrameName:@"p_shadowMenu.png"];
        [bg setScale:8];
        [bg setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg z:-2];

        CCSprite *bg1 = [CCSprite spriteWithSpriteFrameName:@"gamePaused.png"];
        [bg1 setPosition:ccp(kScreenCenterX, kScreenCenterY + 60 * kFactor)];
        [self addChild:bg1 z:-1];

        //Menu
        CCMenu *menu = [CCMenu menuWithItems:nil];
        [menu setPosition:CGPointZero];
        [self addChild: menu z:20];

        //Replay
        CCMenuItemSprite *replayItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"p_retry.png"]
                                                               selectedSprite:[CCSprite spriteWithSpriteFrameName:@"p_retry_p.png"]
                                                               disabledSprite:nil
                                                                       target:self
                                                                     selector:@selector(replayHandler)];
        [replayItem setPosition:ccp(kScreenCenterX - 85 * kFactor, kScreenCenterY - 45 * kFactor)];
         [menu addChild:replayItem];
        
        //Main menu
        CCMenuItemSprite *mainMenuItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"p_menu.png"]
                                                                 selectedSprite:[CCSprite spriteWithSpriteFrameName:@"p_menu_p.png"]
                                                                 disabledSprite:nil
                                                                         target:self
                                                                       selector:@selector(mainMenuHandler)];
        [mainMenuItem setPosition:ccp(kScreenCenterX, kScreenCenterY - 35 * kFactor)];
        [menu addChild:mainMenuItem];
        
        //Next
        CCMenuItemSprite *resumeItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"p_play.png"]
                                                               selectedSprite:[CCSprite spriteWithSpriteFrameName:@"p_play_p.png"]
                                                               disabledSprite:nil
                                                                       target:self
                                                                     selector:@selector(resumeHandler)];
        [resumeItem setPosition:ccp(kScreenCenterX + 85 * kFactor, kScreenCenterY - 45 * kFactor)];
        [menu addChild:resumeItem];
        
        AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
        
        [[Util sharedUtil] showLabel:[NSString stringWithFormat:@"LEVEL %d",  appDelegate.currLevel]
                              atNode:self 
                          atPosition:ccp(kScreenCenterX, kScreenCenterY - 100 * kFactor)
                            fontName:@"BradyBunchRemastered" 
                            fontSize:36 * kFactor 
                           fontColor:ccc3(255, 255, 255) 
                         anchorPoint:ccp(0.5f, 0.5f) 
                           isEnabled:YES 
                                 tag:1 
                          dimensions:CGSizeMake(500, 56) 
                            rotation:0 
                             bgColor:ccc3(255, 102, 0)]; 
	}
	return self;
}

-(void) onEnter {
	[super onEnter];
}

-(void) onExit {
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"pauseAtl.plist"];
    [super onExit];
}

-(void) replayHandler {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    [appDelegate spendLife];
    [[CCDirector sharedDirector] resume];
    [[CCDirector sharedDirector] replaceScene: [LevelStartLayer scene]];
}

-(void) resumeHandler {
    GameLayer *gl = (GameLayer *)[self.parent getChildByTag:kGameLayerTag];
    gl.isMenuShown = NO;
    [[CCDirector sharedDirector] resume];
    [self removeFromParentAndCleanup:YES];
}

-(void) mainMenuHandler {
    [[CCDirector sharedDirector] resume];
    [[CCDirector sharedDirector] replaceScene: [SelectLevelLayer scene]];
}

@end