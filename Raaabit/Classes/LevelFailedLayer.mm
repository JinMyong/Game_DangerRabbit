//
//  LevelFailedLayer.m
//  Raaabit
//
//  Created by Anna Valova on 1/31/14.
//  Copyright 2014 Dmitry Valov. All rights reserved.
//

#import "LevelFailedLayer.h"
#import "Constants.h"
#import "MainMenuLayer.h"
#import "ShopLayer.h"
#import "GameLayer.h"
#import "Util.h"
#import "GameController.h"
#import "SimpleAudioEngine.h"
#import "SelectLevelLayer.h"
#import "AppDelegate.h"
#import "LevelStartLayer.h"

@implementation LevelFailedLayer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	LevelFailedLayer *layer = [LevelFailedLayer node];
	[scene addChild: layer];
	
	return scene;
}

-(id) init {
	if((self=[super init])) {	
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"levelFailedAtl.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"UIAtl.plist"];

        AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];

        float delta = 5 * kFactor;
        
        //Lives
        CCSprite *livesBG = [CCSprite spriteWithSpriteFrameName:@"livesui.png"];
        [livesBG setAnchorPoint:ccp(0.0f, 1.0f)];
        [livesBG setPosition:ccp(0, kScreenHeight - delta)];
        [self addChild:livesBG];
        
        NSInteger lives = appDelegate.livesCount;
        if(lives < 0) {
            lives = 0;
        }
        CCLabelBMFont *livesValue = [[CCLabelBMFont alloc] initWithString:[NSString stringWithFormat:@"%ld", (long)lives]
                                                                  fntFile:@"font_ui_timer.fnt"];
        [self addChild:livesValue z:0];
        [livesValue setPosition:ccp(livesBG.position.x + 10 * kFactor + livesBG.contentSize.width / 2,
                                    livesBG.position.y - livesBG.contentSize.height / 2 + 3 * kFactor)];
        
        NSString *bgName = @"bg1.jpg";
        switch (appDelegate.currArea) {
            case 1:
                bgName = @"bg1.jpg";
                break;
            case 2:
                bgName = @"bg2.jpg";
                break;
            case 3:
                bgName = @"bg3.jpg";
                break;
            case 4:
                bgName = @"bg4.jpg";
                break;
            case 5:
                bgName = @"bg5.jpg";
                break;
        }
        CCSprite *bg1 = [CCSprite spriteWithFile:bgName];
        [bg1 setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg1 z:-21];
        
        CCSprite *bg = [CCSprite spriteWithSpriteFrameName:@"lf_base.png"];
        [bg setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg z:-11];
        
        CCSprite *bg2 = [CCSprite spriteWithSpriteFrameName:@"d_shadow.png"];
        [bg2 setScale:8];
        [bg2 setOpacity:200];
        [bg2 setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg2 z:-20];
        
        //Menu
        CCMenu *menu = [CCMenu menuWithItems:nil];
        [menu setPosition:CGPointZero];
        [self addChild: menu];
        
        CCMenuItemSprite *mainMenuItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"lf_menu.png"]
                                                             selectedSprite:[CCSprite spriteWithSpriteFrameName:@"lf_menu_p.png"]
                                                             disabledSprite:nil
                                                                     target:self
                                                                   selector:@selector(mainMenuHandler)];
        [mainMenuItem setPosition:ccp(kScreenCenterX - 70 * kFactor, kScreenCenterY - 80 * kFactor)];
        [menu addChild:mainMenuItem];

        
        CCMenuItemSprite *retryItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"lf_retry.png"]
                                                                 selectedSprite:[CCSprite spriteWithSpriteFrameName:@"lf_retry_p.png"]
                                                                 disabledSprite:nil
                                                                         target:self
                                                                       selector:@selector(retryHandler)];
        [retryItem setPosition:ccp(kScreenCenterX, kScreenCenterY - 90 * kFactor)];
        [menu addChild:retryItem];

        CCSprite *storeSprite = [CCSprite spriteWithSpriteFrameName:@"lf_shop.png"];
        CCSprite *storeSprite_p = [CCSprite spriteWithSpriteFrameName:@"lf_shop_p.png"];
        
        if([GameController sharedGameCtrl].carrotsCount >= 100) {
            CCSprite *badge1 = [CCSprite spriteWithSpriteFrameName:@"lf_box_count.png"];
            [badge1 setPosition:ccp(62 * kFactor, 62 * kFactor)];
            [storeSprite addChild:badge1];
            
            CCSprite *badge2 = [CCSprite spriteWithSpriteFrameName:@"lf_box_count.png"];
            [badge2 setPosition:ccp(62 * kFactor, 62 * kFactor)];
            [storeSprite_p addChild:badge2];

            if([[Util sharedUtil] isiPad]) {
                [badge1 setPosition:ccp(62 * kFactor, 62 * kFactor)];
                [badge2 setPosition:ccp(62 * kFactor, 62 * kFactor)];
            }
        }

        CCMenuItemSprite *shopItem = [CCMenuItemSprite itemWithNormalSprite:storeSprite
                                                             selectedSprite:storeSprite_p
                                                             disabledSprite:nil
                                                                     target:self
                                                                   selector:@selector(shopHandler)];
        [shopItem setPosition:ccp(kScreenCenterX + 78 * kFactor, kScreenCenterY - 80 * kFactor)];
        [menu addChild:shopItem];
        
        [[Util sharedUtil] showLabel:[NSString stringWithFormat:@"Carrot bank: %i",  [GameController sharedGameCtrl].carrotsCount]
                              atNode:self 
                          atPosition:ccp(kScreenCenterX, 25 * kFactor)
                            fontName:@"BradyBunchRemastered" 
                            fontSize:28 * kFactor 
                           fontColor:ccc3(255, 255, 255) 
                         anchorPoint:ccp(0.5, 0.5) 
                           isEnabled:YES 
                                 tag:1 
                          dimensions:CGSizeMake(500, 56) 
                            rotation:0 
                             bgColor:ccc3(255, 153, 51)];    
        
        if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { //iPad
            if( CC_CONTENT_SCALE_FACTOR() == 2 ) { //Retina Display
                [mainMenuItem setPosition:ccp(kScreenCenterX - 100 * kFactor, kScreenCenterY - 110 * kFactor)];
                [retryItem setPosition:ccp(kScreenCenterX, kScreenCenterY - 120 * kFactor)];
                [shopItem setPosition:ccp(kScreenCenterX + 110 * kFactor, kScreenCenterY - 110 * kFactor)];
            }
        }

    }
    return self;
}

-(void) mainMenuHandler {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0
                                                                                 scene:[SelectLevelLayer scene]]];
}

-(void) retryHandler {
    [[SimpleAudioEngine sharedEngine] playEffect:@"LetsGo.mp3"];
    [[CCDirector sharedDirector] replaceScene: [LevelStartLayer scene]];
}

-(void) shopHandler {
    ShopLayer *sl = [ShopLayer node];
    [self addChild:sl z:100];
}

-(void) onEnter {
    [SimpleAudioEngine sharedEngine].backgroundMusicVolume = 0.0f;
    [[SimpleAudioEngine sharedEngine] playEffect:@"LevelFailed.mp3"];
	[super onEnter];
}

-(void) onExit {
    if ([GameController sharedGameCtrl].isMusicOff == YES) {
        [SimpleAudioEngine sharedEngine].backgroundMusicVolume = 0;
    }
    else {
        [SimpleAudioEngine sharedEngine].backgroundMusicVolume = kBackgroundMusicVolume;
    }
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"levelFailedAtl.plist"];
    [super onExit];
}

@end
