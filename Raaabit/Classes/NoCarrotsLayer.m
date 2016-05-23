//
//  ContinuePackLayer.m
//  Raaabit
//
//  Created by Anna Valova on 11/18/13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "NoCarrotsLayer.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "MyMenuItemSprite.h"
#import "Util.h"
#import "GameController.h"
#import "SimpleAudioEngine.h"

@implementation NoCarrotsLayer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	NoCarrotsLayer *layer = [NoCarrotsLayer node];
	[scene addChild: layer];
	
	return scene;
}


-(id) init {
	if((self=[super init])) {
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"noCarrotsAtl.plist"];
        
        CCSprite *bg = [CCSprite spriteWithFile:@"noCarrotsBg.png"];
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"menuSwoosh.mp3"];
        
        CCSprite *bg1 = [CCSprite spriteWithSpriteFrameName:@"nc_shadow.png"];
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

        [bg setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [containerNode addChild:bg z:-10];

        //Menu
        CCMenu *menu = [CCMenu menuWithItems:nil];
        [menu setPosition:CGPointZero];
        [containerNode addChild: menu];
        
        MyMenuItemSprite *closeItem = [MyMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"nc_x.png"]
                                                              selectedSprite:nil
                                                              disabledSprite:nil
                                                                      target:self
                                                                    selector:@selector(closeHandler)];
        [closeItem setPosition:ccp(kScreenCenterX + 220 * kFactor, kScreenCenterY + bg.contentSize.height / 2 - 20 * kFactor)];
        [menu addChild:closeItem];
        
        //Buy
        NSString *priceString = nil;
        
        priceString = [[GameController sharedGameCtrl].listOfPrices objectForKey:kAppleID_1kCarrots];
        if(!priceString || [priceString length] <= 0) {
            priceString = @"n/a";
        }
        CCMenuItemSprite *buy1kCarrotsItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"nc_1kcarrots.png"]
                                                                     selectedSprite:[CCSprite spriteWithSpriteFrameName:@"nc_1kcarrots_p.png"]
                                                                     disabledSprite:nil
                                                                             target:self
                                                                           selector:@selector(buy1kCarrotsHandler)];
        [buy1kCarrotsItem setPosition:ccp(kScreenCenterX - 106 * kFactor, kScreenCenterY - 48 * kFactor)]; //kScreenWidth / 6
        [menu addChild:buy1kCarrotsItem];
        
        
        [[Util sharedUtil] showLabel:priceString
                              atNode:containerNode
                          atPosition:ccp(buy1kCarrotsItem.position.x, buy1kCarrotsItem.position.y - 50 * kFactor) 
                            fontName:@"BradyBunchRemastered" 
                            fontSize:20 * kFactor 
                           fontColor:ccc3(255, 204, 102) 
                         anchorPoint:ccp(0.5, 0.5) 
                           isEnabled:YES 
                                 tag:1 
                          dimensions:CGSizeMake(100, 100) 
                            rotation:0 
                             bgColor:ccc3(51, 0, 0)];
        
        priceString = [[GameController sharedGameCtrl].listOfPrices objectForKey:kAppleID_2kCarrots];
        if(!priceString || [priceString length] <= 0) {
            priceString = @"n/a";
        }
        CCMenuItemSprite *buy2kCarrotsItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"nc_2kcarrots.png"]
                                                                     selectedSprite:[CCSprite spriteWithSpriteFrameName:@"nc_2kcarrots_p.png"]
                                                                     disabledSprite:nil
                                                                             target:self
                                                                           selector:@selector(buy2kCarrotsHandler)];
        [buy2kCarrotsItem setPosition:ccp(kScreenCenterX - 0 * kFactor, kScreenCenterY - 48 * kFactor)];
        [menu addChild:buy2kCarrotsItem];
        
        [[Util sharedUtil] showLabel:priceString
                              atNode:containerNode
                          atPosition:ccp(buy2kCarrotsItem.position.x, buy2kCarrotsItem.position.y - 50 * kFactor) 
                            fontName:@"BradyBunchRemastered" 
                            fontSize:20 * kFactor 
                           fontColor:ccc3(255, 204, 102) 
                         anchorPoint:ccp(0.5, 0.5) 
                           isEnabled:YES 
                                 tag:1 
                          dimensions:CGSizeMake(100, 100) 
                            rotation:0 
                             bgColor:ccc3(51, 0, 0)];
        
        
        priceString = [[GameController sharedGameCtrl].listOfPrices objectForKey:kAppleID_4kCarrots];
        if(!priceString || [priceString length] <= 0) {
            priceString = @"n/a";
        }
        CCMenuItemSprite *buy4kCarrotsItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"nc_4kcarrots.png"]
                                                                  selectedSprite:[CCSprite spriteWithSpriteFrameName:@"nc_4kcarrots_p.png"]
                                                                  disabledSprite:nil
                                                                          target:self
                                                                        selector:@selector(buy4kCarrotsHandler)];
        [buy4kCarrotsItem setPosition:ccp(kScreenCenterX + 106 * kFactor, kScreenCenterY - 48 * kFactor)];
        [menu addChild:buy4kCarrotsItem];
        
        [[Util sharedUtil] showLabel:priceString
                              atNode:containerNode
                          atPosition:ccp(buy4kCarrotsItem.position.x, buy4kCarrotsItem.position.y - 50 * kFactor) 
                            fontName:@"BradyBunchRemastered" 
                            fontSize:20 * kFactor 
                           fontColor:ccc3(255, 204, 102) 
                         anchorPoint:ccp(0.5, 0.5) 
                           isEnabled:YES 
                                 tag:1 
                          dimensions:CGSizeMake(100, 100) 
                            rotation:0 
                             bgColor:ccc3(51, 0, 0)];
        
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
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"continuePackAtl.plist"];
    [super onExit];
}

//pragma mark Handlers
-(void) closeHandler {
    [self removeFromParentAndCleanup:YES];
}

-(void) buy1kCarrotsHandler {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    [appDelegate purchase:kShopID_1kCarrots];
    [self removeFromParentAndCleanup:YES];
}

-(void) buy2kCarrotsHandler {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    [appDelegate purchase:kShopID_2kCarrots];
    [self removeFromParentAndCleanup:YES];
}

-(void) buy4kCarrotsHandler {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    [appDelegate purchase:kShopID_4kCarrots];
    [self removeFromParentAndCleanup:YES];
}

@end
