//
//  ReviveLayer.m
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "ReviveLayer.h"
#import "MainMenuLayer.h"
#import "GameLayer.h"
#import "MyMenuItemSprite.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "GameProgressController.h"
#import "Util.h"
#import "InviteLayer.h"
#import "GameController.h"
#import "NoCarrotsLayer.h"

@implementation ReviveLayer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	ReviveLayer *layer = [ReviveLayer node];
	[scene addChild: layer];
	
	return scene;
}

-(id) init {
	if((self=[super init])) {
        AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"reviveAtl.plist"];
     
        CCSprite *bg1 = [CCSprite spriteWithFile:@"bg1.jpg"];
        [bg1 setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg1 z:-3];

        CCSprite *bg = [CCSprite spriteWithSpriteFrameName:@"rev_shadow.png"];
        [bg setScale:8];
        [bg setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg z:-2];

        CCSprite *text = [CCSprite spriteWithSpriteFrameName:@"rev_revive.png"];
        [text setPosition:ccp(kScreenCenterX, kScreenCenterY + 40 * kFactor)];
        [self addChild:text z:1];
        
        //Menu
        CCMenu *menu = [CCMenu menuWithItems:nil];
        [menu setPosition:CGPointZero];
        [self addChild: menu z:20];

        MyMenuItemSprite *closeItem = [MyMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"rev_x.png"]
                                                              selectedSprite:nil
                                                              disabledSprite:nil
                                                                      target:self
                                                                    selector:@selector(closeHandler)];
        [closeItem setPosition:ccp(kScreenCenterX + 115 * kFactor, kScreenCenterY + 87 * kFactor)];
        [menu addChild:closeItem];

        float deltaX = 0;
        if(appDelegate.numberRevivesFB > 0) {
            deltaX = 50 * kFactor;
            //Facebook
            CCMenuItemSprite *facebookItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"rev_fb.png"]
                                                                     selectedSprite:[CCSprite spriteWithSpriteFrameName:@"rev_fb_p.png"]
                                                                     disabledSprite:nil
                                                                             target:self
                                                                           selector:@selector(facebookHandler)];
            [facebookItem setPosition:ccp(kScreenCenterX - 50 * kFactor, kScreenCenterY - 80 * kFactor)];
            [menu addChild:facebookItem];
            
            CCSprite *fbCount = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"rev_%d.png", appDelegate.numberRevivesFB]];
            [fbCount setPosition:ccp(63 * kFactor, 64 * kFactor)];
            [facebookItem addChild:fbCount];
        }
        
        //Buy
        CCMenuItemSprite *buyItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"rev_coin.png"]
                                                            selectedSprite:[CCSprite spriteWithSpriteFrameName:@"rev_coin_p.png"]
                                                            disabledSprite:nil
                                                                    target:self
                                                                  selector:@selector(buyHandler)];
        [buyItem setPosition:ccp(kScreenCenterX + deltaX, kScreenCenterY - 80 * kFactor)];
        [menu addChild:buyItem];
	}
	return self;
}

-(void) onEnter {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(friendInvited)
                                                 name:kFBFriendInvitedNotification
                                               object:nil];
	[super onEnter];
}

-(void) onExit {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"reviveAtl.plist"];
    [super onExit];
}

-(void) closeHandler {
    GameLayer *gl = (GameLayer *)[self.parent getChildByTag:kGameLayerTag];
    [self removeFromParentAndCleanup:YES];
    [gl restartLevel];
}

-(void) facebookHandler {
    [[FacebookController sharedFacebookCtrl] inviteFriends];
}

-(void) buyHandler {
    if([GameController sharedGameCtrl].carrotsCount >= kBuyPlankCarrotPrice) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"You have %d carrots.", [GameController sharedGameCtrl].carrotsCount]
                                                                     message:[NSString stringWithFormat:@"Revive and get %d more planks for %d carrots?", kBuyPlankCount,kBuyPlankCarrotPrice]
                                                                     delegate:self
                                                                     cancelButtonTitle:@"Cancel"
                                                                     otherButtonTitles:@"Confirm", nil];
                                  [alertView show];
                                  [alertView release];
    }
    else {
        NoCarrotsLayer *ncl = [NoCarrotsLayer node];
        [self addChild:ncl z:100];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 1) {
        [self removeFromParentAndCleanup:YES];
        [[GameController sharedGameCtrl] spendCoins:kBuyPlankCarrotPrice];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAdd10PlanksNotification
                                                            object:nil];
	}
}

- (void) friendInvited {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    --appDelegate.numberRevivesFB;
    [appDelegate saveOptions];
    
    [self removeFromParentAndCleanup:YES];
    [[GameController sharedGameCtrl] spendCoins:150];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAdd10PlanksNotification
                                                        object:nil];
}

@end
