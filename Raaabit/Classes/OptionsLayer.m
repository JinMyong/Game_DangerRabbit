//
//  OptionsLayer.m
//  Raaabit
//
//  Created by Anna Valova on 2/3/14.
//  Copyright 2014 Dmitry Valov. All rights reserved.
//

#import "OptionsLayer.h"
#import "Constants.h"
#import "MainMenuLayer.h"
#import "GameController.h"
#import "SimpleAudioEngine.h"
#import "CreditsLayer.h"

@implementation OptionsLayer
+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	OptionsLayer *layer = [OptionsLayer node];
	[scene addChild: layer];
	
	return scene;
}

-(id) init {
	if((self=[super init])) {
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"optionsAtl.plist"];

        CCSprite *bg = [CCSprite spriteWithFile:@"mainMenuBg.jpg"];
        [bg setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg z:-21];
        
        CCSprite *bg2 = [CCSprite spriteWithSpriteFrameName:@"o_shadow.png"];
        [bg2 setScale:8];
        [bg2 setOpacity:200];
        [bg2 setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg2 z:-20];
        
        //Menu
        menu = [CCMenu menuWithItems:nil];
        [menu setPosition:CGPointZero];
        [self addChild: menu];
        
        CCMenuItemSprite *creditsItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"o_credits.png"]
                                                              selectedSprite:[CCSprite spriteWithSpriteFrameName:@"o_credits_p.png"]
                                                              disabledSprite:nil
                                                                      target:self
                                                                    selector:@selector(creditsHandler)];
        [creditsItem setPosition:ccp(kScreenCenterX + 100 * kFactor, kScreenCenterY + 80 * kFactor)];
        [menu addChild:creditsItem];
        
        CCMenuItemSprite *backItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"o_back.png"]
                                                             selectedSprite:[CCSprite spriteWithSpriteFrameName:@"o_back_p.png"]
                                                             disabledSprite:nil
                                                                     target:self
                                                                   selector:@selector(backHandler)];
        [backItem setPosition:ccp(36 * kFactor, 36 * kFactor)];
        [menu addChild:backItem];
        
        [self reloadMusicMenu];
        [self reloadSFXMenu];
    }
    return self;
}

-(void) reloadMusicMenu {
    GameController *gC = [GameController sharedGameCtrl];
        CCSprite *musicButtion = [CCSprite spriteWithSpriteFrameName:@"o_music.png"];
    if (gC.isMusicOff == YES) {
        musicButtion = [CCSprite spriteWithSpriteFrameName:@"o_music_p.png"];
    }
   
    CCMenuItemSprite *musicItem = [CCMenuItemSprite itemWithNormalSprite:musicButtion
                                                          selectedSprite:nil
                                                          disabledSprite:nil
                                                                  target:self
                                                                selector:@selector(musicHandler:)];
    [musicItem setPosition:ccp(kScreenCenterX - 100 * kFactor, kScreenCenterY + 80 * kFactor)];
    [musicItem setTag:1];
    [menu addChild:musicItem];
}

-(void) musicHandler:(CCMenuItemSprite *)sender {
    GameController *gC = [GameController sharedGameCtrl];
    if (sender.tag == 1) {
        if (gC.isMusicOff == YES) {
            gC.isMusicOff = NO;
            [SimpleAudioEngine sharedEngine].backgroundMusicVolume = kBackgroundMusicVolume;
            [gC save];
        }
        else if (gC.isMusicOff == NO) {
            gC.isMusicOff = YES;
            [SimpleAudioEngine sharedEngine].backgroundMusicVolume = 0;
            [gC save];
        }
    }
    [self reloadMusicMenu];
}


-(void) reloadSFXMenu {
    GameController *gC = [GameController sharedGameCtrl];
    CCSprite *sfxButtion = [CCSprite spriteWithSpriteFrameName:@"o_sfx.png"];
    if (gC.isSFXOff == YES) {
        sfxButtion = [CCSprite spriteWithSpriteFrameName:@"o_sfx_p.png"];
    }
    
    CCMenuItemSprite *sfxItem = [CCMenuItemSprite itemWithNormalSprite:sfxButtion
                                                          selectedSprite:nil
                                                          disabledSprite:nil
                                                                  target:self
                                                                selector:@selector(sfxHandler:)];
    [sfxItem setPosition:ccp(kScreenCenterX, kScreenCenterY - 80 * kFactor)];
    [menu addChild:sfxItem];
    [sfxItem setTag:2];
}

-(void) sfxHandler:(CCMenuItemSprite *)sender {
    GameController *gC = [GameController sharedGameCtrl];
    if (sender.tag == 2) {
        if (gC.isSFXOff == YES) {
            gC.isSFXOff = NO;
            [SimpleAudioEngine sharedEngine].effectsVolume = kBackgroundMusicVolume;
            [gC save];
        }
        else if (gC.isSFXOff == NO) {
            gC.isSFXOff = YES;
            [SimpleAudioEngine sharedEngine].effectsVolume = 0;
            [gC save];
        }
    }
    [self reloadSFXMenu];
}


-(void) creditsHandler {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f
                                                                                 scene:[CreditsLayer scene]]];
    
}

-(void) backHandler {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f
                                                                                 scene:[MainMenuLayer scene]]];
   
}

@end
