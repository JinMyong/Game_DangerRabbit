//
//  ContinuePackLayer.m
//  Raaabit
//
//  Created by Anna Valova on 11/18/13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "ContinuePackLayer.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "MyMenuItemSprite.h"
#import "Util.h"
#import "SimpleAudioEngine.h"
#import "NoCarrotsLayer.h"
#import "GameController.h"
#import "SelectLevelLayer.h"

@implementation ContinuePackLayer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	ContinuePackLayer *layer = [ContinuePackLayer node];
	[scene addChild: layer];
	
	return scene;
}


-(id) init {
	if((self=[super init])) {
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"continuePackAtl.plist"];
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"menuSwoosh.mp3"];

        CCSprite *bg2 = [CCSprite spriteWithSpriteFrameName:@"cp_shadow.png"];
        [bg2 setScale:8];
        [bg2 setOpacity:0.0f];
        [bg2 setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg2 z:-2];

        id shadowAction = [CCFadeIn actionWithDuration:0.3f];
        [bg2 runAction:shadowAction];

        CCNode *containerNode = [CCNode node];
		[containerNode setContentSize:CGSizeMake(kScreenWidth, kScreenHeight)];
        float offset = 0.0f;
		[containerNode setPosition:ccp(offset, kScreenHeight)];
		[self addChild:containerNode z:1];

        CCSprite *bg = [CCSprite spriteWithFile:@"continuePackBg.png"];
        [bg setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [containerNode addChild:bg z:-1];

        //Menu
        CCMenu *menu = [CCMenu menuWithItems:nil];
        [menu setPosition:CGPointZero];
        [containerNode addChild: menu z:1];
        
        MyMenuItemSprite *closeItem = [MyMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"cp_x.png"]
                                                              selectedSprite:nil
                                                              disabledSprite:nil
                                                                      target:self
                                                                    selector:@selector(closeHandler)];
        [closeItem setPosition:ccp(kScreenCenterX + 220 * kFactor, kScreenCenterY + bg.contentSize.height / 2 - 20 * kFactor)];
        [menu addChild:closeItem];
        
        //Buy
        CCMenuItemSprite *buy5PackItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"5pack.png"]
                                                                 selectedSprite:[CCSprite spriteWithSpriteFrameName:@"5pack_p.png"]
                                                                 disabledSprite:nil
                                                                         target:self
                                                                       selector:@selector(buy5PackHandler)];
        [buy5PackItem setPosition:ccp(kScreenWidth / 4, kScreenCenterY - 40 * kFactor)];
        [menu addChild:buy5PackItem];
        
        NSString *priceString1 = [[GameController sharedGameCtrl].listOfPrices objectForKey:kAppleID_5Continues];
        if(!priceString1 || [priceString1 length] <= 0) {
            priceString1 = @"n/a";
        }

        [[Util sharedUtil] showLabel:priceString1
                              atNode:containerNode
                          atPosition:ccp(buy5PackItem.position.x, buy5PackItem.position.y - 65 * kFactor)
                            fontName:@"BradyBunchRemastered" 
                            fontSize:20 * kFactor 
                           fontColor:ccc3(255, 204, 102) 
                         anchorPoint:ccp(0.5, 0.5) 
                           isEnabled:YES 
                                 tag:1 
                          dimensions:CGSizeMake(100, 100) 
                            rotation:0 
                             bgColor:ccc3(51, 0, 0)];
        
        CCMenuItemSprite *buy15PackItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"15pack.png"]
                                                                  selectedSprite:[CCSprite spriteWithSpriteFrameName:@"15pack_p.png"]
                                                                  disabledSprite:nil
                                                                          target:self
                                                                        selector:@selector(buy15PackHandler)];
        [buy15PackItem setPosition:ccp(kScreenCenterX, kScreenCenterY - 40 * kFactor)];
        [menu addChild:buy15PackItem];
        
        NSString *priceString2 = [[GameController sharedGameCtrl].listOfPrices objectForKey:kAppleID_15Continues];
        if(!priceString2 || [priceString2 length] <= 0) {
            priceString2 = @"n/a";
        }

        [[Util sharedUtil] showLabel:priceString2
                              atNode:containerNode
                          atPosition:ccp(buy15PackItem.position.x, buy15PackItem.position.y - 65 * kFactor)
                            fontName:@"BradyBunchRemastered" 
                            fontSize:20 * kFactor 
                           fontColor:ccc3(255, 204, 102) 
                         anchorPoint:ccp(0.5, 0.5) 
                           isEnabled:YES 
                                 tag:1 
                          dimensions:CGSizeMake(100, 100) 
                            rotation:0 
                             bgColor:ccc3(51, 0, 0)];
        
        CCMenuItemSprite *buy30PackItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"30pack.png"]
                                                                  selectedSprite:[CCSprite spriteWithSpriteFrameName:@"30pack_p.png"]
                                                                  disabledSprite:nil
                                                                          target:self
                                                                        selector:@selector(buy30PackHandler)];
        [buy30PackItem setPosition:ccp(kScreenCenterX + kScreenWidth / 4, kScreenCenterY - 40 * kFactor)];
        [menu addChild:buy30PackItem];
        
        NSString *priceString3 = [[GameController sharedGameCtrl].listOfPrices objectForKey:kAppleID_30Continues];
        if(!priceString3 || [priceString3 length] <= 0) {
            priceString3 = @"n/a";
        }

        [[Util sharedUtil] showLabel:priceString3
                              atNode:containerNode
                          atPosition:ccp(buy30PackItem.position.x, buy30PackItem.position.y - 65 * kFactor)
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

-(void) buy5PackHandler {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    [appDelegate purchase:kShopID_5Continues];
}

-(void) buy15PackHandler {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    [appDelegate purchase:kShopID_15Continues];
}

-(void) buy30PackHandler {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    [appDelegate purchase:kShopID_30Continues];
}

- (void) showNotEnoughCarrots {
    NoCarrotsLayer *ncl = [NoCarrotsLayer node];
    [self addChild:ncl z:1000];
}

- (void) showEnjoyAlert:(NSString*) caption {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Enjoy"
                                                        message:[NSString stringWithFormat:@"You have got %@!", caption]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

@end
