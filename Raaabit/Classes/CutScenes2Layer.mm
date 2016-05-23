//
//  CutScenes2Layer.m
//  Raaabit
//
//  Created by Anna Valova on 11/21/13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "CutScenes2Layer.h"
#import "GameController.h"
#import "Constants.h"
#import "Util.h"
#import "SelectAreaLayer.h"
#import "SimpleAudioEngine.h"
#import "AppDelegate.h"

@implementation CutScenes2Layer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	CutScenes2Layer *layer = [CutScenes2Layer node];
	[scene addChild: layer];
	
	return scene;
}

-(id) init {
	if((self=[super init])) {
        interval = 0.0f;
        idx = 1;
		self.touchEnabled = YES;
        [self scheduleUpdate];
        
    }
    return self;

}

-(void) onEnter {
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"DrabbitStoryLoop.mp3" loop:YES];
    [super onEnter];
}

-(void) onExit {
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Menu.mp3" loop:YES];
    [super onExit];
}

-(void) update:(ccTime)delta {
    if (interval <= 0.0f) {
        if(idx >= 2) {
            [self unscheduleUpdate];
            AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
            [[CCTextureCache sharedTextureCache] removeUnusedTextures];
            [appDelegate loadResourcesForGame];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f
                                                                                         scene:[SelectAreaLayer scene]]];
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
    if(idx >= 2) {
        [self unscheduleUpdate];
        AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
        [appDelegate loadResourcesForGame];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f
                                                                                     scene:[SelectAreaLayer scene]]];
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

    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.currArea == 1) {
        currentScene = [CCSprite spriteWithFile:@"scene_w1.jpeg"];
    }
    else if(appDelegate.currArea == 2) {
        currentScene = [CCSprite spriteWithFile:@"scene_w2.jpeg"];
    }
    else if(appDelegate.currArea == 3) {
        currentScene = [CCSprite spriteWithFile:@"scene_w3.jpeg"];
    }
    else {
        currentScene = [CCSprite spriteWithFile:@"scene_w1.jpeg"];
    }
    currentScene.position = ccp(kScreenCenterX, kScreenCenterY);
    if(kScreenWidth == 960 || kScreenWidth == 480) {
        currentScene.scaleX = (float)kScreenWidth / 1136.0f * 2.0f;
    }
    [self addChild:currentScene];

    interval = 6.0f;
}

@end
