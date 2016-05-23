//
//  LoadingLayer.m
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "LoadingLayer.h"
#import "GameLayer.h"
#import "Util.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "LevelStartLayer.h"

@implementation LoadingLayer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	LoadingLayer *layer = [LoadingLayer node];
	[scene addChild: layer];
	
	return scene;
}

-(id) init {
	if((self=[super init])) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"loadingAtl.plist"];
        
        AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
        [appDelegate loadAnimCacheWithName:@"ls_title" delay:0.2f maxFrames:4];

        CCSprite *bg = [CCSprite spriteWithFile:@"bgLoading.jpg"];
        [bg setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg];
        
        CCSprite *loading = [CCSprite spriteWithSpriteFrameName:@"ls_title_1.png"];
        [loading setPosition:ccp(kScreenCenterX, 45 * kFactor)];
        [self addChild:loading];
        
        CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"ls_title"];
        
        id action = [CCRepeatForever actionWithAction:
                     [CCAnimate actionWithAnimation:animation]];
        [loading runAction:action];
        
        interval = 0.0f;

        [self scheduleUpdate];
	}
	return self;
}

-(void) onEnter {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [appDelegate loadResourcesForGame];
	[super onEnter];
}

-(void) onExit {
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"ls_title"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"loadingAtl.plist"];
    [super onExit];
}

//-(void) update:(ccTime)delta {
//    interval += delta;
//    if (interval >= 1.9f) {
//            [self unscheduleUpdate];
//            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f
//                                                                                         scene:[GameLayer scene]]];
//    }
//}

-(void) update:(ccTime)delta {
    interval += delta;
    if (interval >= 1.9f) {
        [self unscheduleUpdate];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f
                                                                                     scene:[LevelStartLayer scene]]];
    }
}



@end
