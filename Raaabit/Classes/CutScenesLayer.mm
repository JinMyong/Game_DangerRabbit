//
//  CutScenesLayer.m
//  Raaabit
//
//  Created by Anna Valova on 11/21/13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "CutScenesLayer.h"
#import "GameController.h"
#import "Constants.h"
#import "Util.h"
#import "GameLayer.h"
#import "SimpleAudioEngine.h"
#import "AppDelegate.h"
#import "LoadingLayer.h"
#import "MyMenuItemSprite.h"

@implementation CutScenesLayer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	CutScenesLayer *layer = [CutScenesLayer node];
	[scene addChild: layer];
	
	return scene;
}

-(id) init {
	if((self=[super init])) {
        interval = 0.0f;
        idx = 1;
		self.touchEnabled = YES;
        [self scheduleUpdate];
        
        MyMenuItemSprite *skipItem = [MyMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"com_green_button.png"]
                                                             selectedSprite:nil
                                                             disabledSprite:nil
                                                                     target:self
                                                                   selector:@selector(skipIntro)];
        [skipItem setPosition:ccp(kScreenWidth - 25 * kFactor, kScreenHeight - 25 * kFactor)];
        [skipItem setScale:0.8f];
        
        CCMenu *menu = [CCMenu menuWithItems:skipItem, nil];
        [menu setPosition:CGPointZero];
        [self addChild: menu z:20];
    }
    return self;
}

-(void) onEnter {
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"DrabbitStoryLoop.mp3" loop:YES];
    [super onEnter];
}

-(void) onExit {
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Chapter_1.mp3" loop:YES];
    [super onExit];
}

-(void) update:(ccTime)delta {
    if (interval <= 0.0f) {
        if(idx >= 6) {
            [self unscheduleUpdate];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f
                                                                                         scene:[LoadingLayer scene]]];
        }
        else {
            [self showScene:idx];
        }
        idx++;
    }
    interval -= delta;
}

#pragma mark -
#pragma mark Touches

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(idx >= 6) {
        [self unscheduleUpdate];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f
                                                                                     scene:[LoadingLayer scene]]];
    }
    else {
        [self showScene:idx];
    }
    idx++;
}

-(void) showScene:(int) index {
    if(currentScene) {
        [currentScene removeFromParentAndCleanup:YES];
    }
    currentScene = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%iscene.jpeg", index]];
    currentScene.position = ccp(kScreenCenterX, kScreenCenterY);
    if(kScreenWidth == 960 || kScreenWidth == 480) {
        currentScene.scaleX = (float)kScreenWidth / 1136.0f * 2.0f;
    }
    [self addChild:currentScene];

    if (index >= 5) {
        interval = 6.0f;
    }
    else {
        interval = 5.0f;
    }
}

- (void) skipIntro {
    [self unscheduleUpdate];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f
                                                                                 scene:[LoadingLayer scene]]];
}

@end