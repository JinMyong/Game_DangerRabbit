//
//  PerfectWorldLayer.m
//  Raaabit
//
//  Created by Anna Valova on 11/18/13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "PerfectWorldLayer.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "MyMenuItemSprite.h"
#import "Util.h"
#import "GameController.h"
#import "SimpleAudioEngine.h"
#import "SelectAreaLayer.h"

@implementation PerfectWorldLayer

@synthesize needLockAnimation;

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	PerfectWorldLayer *layer = [PerfectWorldLayer node];
	[scene addChild: layer];
	
	return scene;
}


-(id) init {
	if((self=[super init])) {
        
        needLockAnimation = YES;
        
        [[GameController sharedGameCtrl] addCoins:200];
        
        CCSprite *bg = [CCSprite spriteWithSpriteFrameName:@"perfect_world_completion.png"];
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"menuSwoosh.mp3"];
        
        CCSprite *bg1 = [CCSprite spriteWithSpriteFrameName:@"sa_shadow.png"];
        [bg1 setScale:8];
        [bg1 setOpacity:0.0f];
        [bg1 setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg1 z:-11];
        
        id shadowAction = [CCFadeIn actionWithDuration:0.3f];
        [bg1 runAction:shadowAction];

		CCNode *containerNode = [CCNode node];
		[containerNode setContentSize:CGSizeMake(kScreenWidth, kScreenHeight)];
        float offset = 0.0f;
		[containerNode setPosition:ccp(offset, kScreenHeight)];
		[self addChild:containerNode z:1];

        [bg setPosition:ccp(kScreenCenterX, kScreenCenterY + 14 * kFactor)];
        [containerNode addChild:bg z:-10];

        //Menu
        CCMenu *menu = [CCMenu menuWithItems:nil];
        [menu setPosition:CGPointZero];
        [containerNode addChild: menu];
        
        MyMenuItemSprite *closeItem = [MyMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"sa_green_button.png"]
                                                              selectedSprite:nil
                                                              disabledSprite:nil
                                                                      target:self
                                                                    selector:@selector(closeHandler)];
        [closeItem setPosition:ccp(kScreenCenterX, kScreenCenterY - 95 * kFactor)];
        [menu addChild:closeItem];
        
        id move = [CCMoveBy actionWithDuration:0.5f position:ccp(0.0f, -kScreenHeight)];
        id action = [CCSequence actions:
                     [CCEaseBackOut actionWithAction:move],
                     nil];
        [containerNode runAction:action];
    }
    
    return self;
}

-(void) onEnter {
	[super onEnter];
}

-(void) onExit {
    [super onExit];
}

-(void) closeHandler {
    if(needLockAnimation) {
        SelectAreaLayer *sal = (SelectAreaLayer *)self.parent;
        [sal showLockAnimation];
    }
    [self removeFromParentAndCleanup:YES];
    
}

@end
