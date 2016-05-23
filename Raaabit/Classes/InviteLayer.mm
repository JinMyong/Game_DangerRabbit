//
//  InviteLayer.m
//  Raaabit
//
//  Created by Anna Valova on 11/21/13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "InviteLayer.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "MyMenuItemSprite.h"
#import "MainMenuLayer.h"
#import "Util.h"
#import "SimpleAudioEngine.h"

@implementation InviteLayer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	InviteLayer *layer = [InviteLayer node];
	[scene addChild: layer];
	
	return scene;
}

-(id) init {
	if((self=[super init])) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"inviteAtl.plist"];
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"menuSwoosh.mp3"];

        CCNode *containerNode = [CCNode node];
		[containerNode setContentSize:CGSizeMake(kScreenWidth, kScreenHeight)];
        float offset = 0.0f;
		[containerNode setPosition:ccp(offset, kScreenHeight)];
		[self addChild:containerNode z:1];

        CCSprite *text = [CCSprite spriteWithSpriteFrameName:@"invite.png"];
        [text setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [containerNode addChild:text z:1];
        
        CCSprite *bg = [CCSprite spriteWithSpriteFrameName:@"i_shadow.png"];
        [bg setScale:8];
        [bg setOpacity:0.0f];
        [bg setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg z:0];

        id shadowAction = [CCFadeIn actionWithDuration:0.3f];
        [bg runAction:shadowAction];

        
        //Menu
        CCMenu *menu = [CCMenu menuWithItems:nil];
        [menu setPosition:CGPointZero];
        [containerNode addChild: menu z:20];
        
        MyMenuItemSprite *closeItem = [MyMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"i_x.png"]
                                                              selectedSprite:nil
                                                              disabledSprite:nil
                                                                      target:self
                                                                    selector:@selector(closeHandler)];
        [closeItem setPosition:ccp(kScreenCenterX + 200 * kFactor, kScreenCenterY + 141 * kFactor)];
        [menu addChild:closeItem];
        
        //Facebook
        for (int i = 0; i < 4; i++) {
            NSInteger xPos = 115 * kFactor + kScreenWidth /5.4 * i;
            if ([Util sharedUtil].isiPhone5) {
                xPos = 143 * kFactor + kScreenWidth /6 * i;
            }
            CCSprite *frame = [CCSprite spriteWithSpriteFrameName:@"i_frame.png"];
            [frame setPosition:ccp(xPos, kScreenCenterY - 50 * kFactor)];
            [containerNode addChild:frame z:100];
            
            [[Util sharedUtil] showLabel:@"NAME" 
                                  atNode:containerNode
                              atPosition:ccp(xPos, kScreenCenterY + 1 * kFactor) 
                                fontName:@"BradyBunchRemastered" 
                                fontSize:25 * kFactor 
                               fontColor:ccc3(255, 102, 0) 
                             anchorPoint:ccp(0.5, 0.5) 
                               isEnabled:YES 
                                     tag:1 
                              dimensions:CGSizeMake(320, 170) 
                                rotation:0 
                                 bgColor:ccc3(51, 0, 0)];
            
            [[Util sharedUtil] showLabel:@"INVITE" 
                                  atNode:containerNode 
                              atPosition:ccp(xPos, kScreenCenterY - 100 * kFactor) 
                                fontName:@"BradyBunchRemastered" 
                                fontSize:25 * kFactor 
                               fontColor:ccc3(255, 204, 102) 
                             anchorPoint:ccp(0.5, 0.5) 
                               isEnabled:YES 
                                     tag:1 
                              dimensions:CGSizeMake(320, 170) 
                                rotation:0 
                                 bgColor:ccc3(51, 0, 0)];
        }
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
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"inviteAtl.plist"];
    [super onExit];
}

-(void) closeHandler {
    [self removeFromParentAndCleanup:YES];
}

-(void) facebookHandler {    
}

@end
