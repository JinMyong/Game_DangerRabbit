//
//  LevelStartLayer.m
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "LevelStartLayer.h"
#import "MainMenuLayer.h"
#import "GameLayer.h"
#import "MyMenuItemSprite.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "GameProgressController.h"
#import "ShopLayer.h"
#import "GameController.h"
#import "SelectAreaLayer.h"
#import <GameController.h>
#import <FacebookController.h>
#import "SelectLevelLayer.h"
#import "CutScenes2Layer.h"
#import "FinalLayer.h"
#import "NoCarrotsLayer.h"

#import "SWTableView.h"
#import "ScoresTable.h"
#import "GameController.h"
#import "Util.h"
#import "CCLabelBMFontAnimated.h"

@implementation LevelStartLayer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	LevelStartLayer *layer = [LevelStartLayer node];
	[scene addChild: layer];
	
	return scene;
}

-(id) init {
	if((self=[super init])) {
        AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
        GameController *gC = [GameController sharedGameCtrl];

        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"levelStartAtl.plist"];
     
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
        CCSprite *bg = [CCSprite spriteWithFile:bgName];
        [bg setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg z:-2];

        CCSprite *bg1 = [CCSprite spriteWithSpriteFrameName:@"ls_levelStartBG.png"];
        [bg1 setPosition:ccp(kScreenCenterX, kScreenCenterY + 25)];
        [self addChild:bg1 z:-1];
        
        //Carrot bank
        
        CCSprite *carrotBankSprite = [CCSprite spriteWithSpriteFrameName:@"ls_carrot bank.png"];
        [carrotBankSprite setPosition:ccp(kScreenCenterX - 90, 115 * kFactor)];
        [self addChild:carrotBankSprite];
        
        carrotBankLabel = [CCLabelBMFontAnimated labelWithValue:gC.carrotsCount fntFile:@"font_lc_top_scores.fnt"];
        [self addChild:carrotBankLabel z:0];
        [carrotBankLabel setAnchorPoint:ccp(0.0f, 0.5f)];
        [carrotBankLabel setPosition:ccp(kScreenCenterX, 120 * kFactor)];

        //Menu
        menu = [CCMenu menuWithItems:nil];
        [menu setPosition:CGPointZero];
        [self addChild: menu z:20];

        //Start
        CCMenuItemSprite *startItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"ls_continue.png"]
                                                              selectedSprite:[CCSprite spriteWithSpriteFrameName:@"ls_continue_p.png"]
                                                              disabledSprite:nil
                                                                      target:self
                                                                    selector:@selector(startLevelHandler)];
        [startItem setPosition:ccp(kScreenCenterX + 85 * kFactor, 50 * kFactor)];
        [menu addChild:startItem];
        
        //Menu
        CCMenuItemSprite *mainMenuItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"ls_menu.png"]
                                                                 selectedSprite:[CCSprite spriteWithSpriteFrameName:@"ls_menu_p.png"]
                                                                 disabledSprite:nil
                                                                         target:self
                                                                       selector:@selector(mainMenuHandler)];
        [mainMenuItem setPosition:ccp(kScreenCenterX - 85 * kFactor, 50 * kFactor)];
        [menu addChild:mainMenuItem];
        
        //Shop
        CCSprite *storeSprite = [CCSprite spriteWithSpriteFrameName:@"ls_shop.png"];
        CCSprite *storeSprite_p = [CCSprite spriteWithSpriteFrameName:@"ls_shop_p.png"];
        
        if([GameController sharedGameCtrl].carrotsCount >= 100) {
            CCSprite *badge1 = [CCSprite spriteWithSpriteFrameName:@"com_box_count.png"];
            [badge1 setPosition:ccp(62 * kFactor, 62 * kFactor)];
            [storeSprite addChild:badge1];
            
            CCSprite *badge2 = [CCSprite spriteWithSpriteFrameName:@"com_box_count.png"];
            [badge2 setPosition:ccp(62 * kFactor, 62 * kFactor)];
            [storeSprite_p addChild:badge2];
            
            if([[Util sharedUtil] isiPad]) {
                [badge1 setPosition:ccp(70 * kFactor, 70 * kFactor)];
                [badge2 setPosition:ccp(70 * kFactor, 70 * kFactor)];
            }
        }

        CCMenuItemSprite *shopItem = [CCMenuItemSprite itemWithNormalSprite:storeSprite
                                                             selectedSprite:storeSprite_p
                                                             disabledSprite:nil
                                                                     target:self
                                                                   selector:@selector(shopHandler)];
        [shopItem setPosition:ccp(kScreenCenterX + 0 * kFactor, 50 * kFactor)];
        [menu addChild:shopItem];
        
        NSString *areaName = @"FREEDOM FIELDS";
        switch (appDelegate.currArea) {
            case 1:
                areaName = @"FREEDOM FIELDS";
                break;
            case 2:
                areaName = @"FOSSIL FOREST";
                break;
            case 3:
                areaName = @"LOST DESERT";
                break;
            case 4:
                areaName = @"JUNGLE FEVER";
                break;
            case 5:
                areaName = @"DUNGEON CAVES";
                break;
        }
        
        //Powerups
        powerup1Item = [MyMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"ls_powerup1.png"]
                                               selectedSprite:nil
                                               disabledSprite:[CCSprite spriteWithSpriteFrameName:@"ls_powerup1_d.png"]
                                                       target:self
                                                     selector:@selector(buySuperPlanks)];
        [powerup1Item setPosition:ccp(kScreenCenterX - 45 * kFactor, kScreenCenterY - 30)];
        [menu addChild:powerup1Item];
        if([GameController sharedGameCtrl].carrotsCount < 100) {
            [powerup1Item setIsEnabled:NO];
        }
        
        CCSprite *carrot1Sprite = [CCSprite spriteWithSpriteFrameName:@"ls_smallCarrot.png"];
        [carrot1Sprite setPosition:ccp(kScreenCenterX - 55 * kFactor, kScreenCenterY - 94)];
        [self addChild:carrot1Sprite];

        powerup2Item = [MyMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"ls_powerup2.png"]
                                               selectedSprite:nil
                                               disabledSprite:[CCSprite spriteWithSpriteFrameName:@"ls_powerup2_d.png"]
                                                       target:self
                                                     selector:@selector(buyStickyPlanks)];
        [powerup2Item setPosition:ccp(kScreenCenterX + 45 * kFactor, kScreenCenterY - 30)];
        [menu addChild:powerup2Item];
        if([GameController sharedGameCtrl].carrotsCount < 100) {
            [powerup2Item setIsEnabled:NO];
        }

        CCSprite *carrot2Sprite = [CCSprite spriteWithSpriteFrameName:@"ls_smallCarrot.png"];
        [carrot2Sprite setPosition:ccp(kScreenCenterX + 35 * kFactor, kScreenCenterY - 94)];
        [self addChild:carrot2Sprite];
        
        
        if(!VERSION_IPHONE) {
            [[Util sharedUtil] showLabel:[NSString stringWithFormat:@"LEVEL %d %@",  appDelegate.currLevel, areaName]
                                  atNode:self 
                              atPosition:ccp(kScreenCenterX, 529)
                                fontName:@"BradyBunchRemastered" 
                                fontSize:22 * kFactor 
                               fontColor:ccc3(255, 102, 0) 
                             anchorPoint:ccp(0.5f, 0.5f)
                               isEnabled:YES 
                                     tag:1 
                              dimensions:CGSizeMake(500, 56) 
                                rotation:0 
                                 bgColor:ccc3(102, 0, 0)];
            
            [[Util sharedUtil] showLabel:[NSString stringWithFormat:@"%i",  100]
                                  atNode:self
                              atPosition:ccp(kScreenCenterX - 30 * kFactor, kScreenCenterY - 94)
                                fontName:@"BradyBunchRemastered"
                                fontSize:18 * kFactor
                               fontColor:ccc3(255, 204, 102)
                             anchorPoint:ccp(0.5, 0.5)
                               isEnabled:YES
                                     tag:2
                              dimensions:CGSizeMake(200, 40)
                                rotation:0
                                 bgColor:ccc3(51, 0, 0)];
            
            [[Util sharedUtil] showLabel:[NSString stringWithFormat:@"%i",  100]
                                  atNode:self
                              atPosition:ccp(kScreenCenterX + 60 * kFactor, kScreenCenterY - 94)
                                fontName:@"BradyBunchRemastered"
                                fontSize:18 * kFactor
                               fontColor:ccc3(255, 204, 102)
                             anchorPoint:ccp(0.5, 0.5)
                               isEnabled:YES
                                     tag:1
                              dimensions:CGSizeMake(200, 40)
                                rotation:0
                                 bgColor:ccc3(51, 0, 0)];
        }
        else {
            [[Util sharedUtil] showLabel:[NSString stringWithFormat:@"LEVEL %d %@",  appDelegate.currLevel, areaName]
                                  atNode:self
                              atPosition:ccp(kScreenCenterX, 242)
                                fontName:@"BradyBunchRemastered"
                                fontSize:19 * kFactor
                               fontColor:ccc3(255, 102, 0)
                             anchorPoint:ccp(0.5f, 0.5f)
                               isEnabled:YES
                                     tag:2
                              dimensions:CGSizeMake(500, 56)
                                rotation:0
                                 bgColor:ccc3(102, 0, 0)];
            
            [bg1 setPosition:ccp(kScreenCenterX, kScreenCenterY + 25)];
            [bg1 setScaleY:0.9f];

            [carrotBankSprite setPosition:ccp(kScreenCenterX - 50 * kFactor, 100 * kFactor)];
            [carrotBankLabel setPosition:ccp(kScreenCenterX, 105 * kFactor)];
          
            [startItem setPosition:ccp(kScreenCenterX + 85 * kFactor, 48 * kFactor)];
            [mainMenuItem setPosition:ccp(kScreenCenterX - 85 * kFactor, 48 * kFactor)];
            [shopItem setPosition:ccp(kScreenCenterX + 0 * kFactor, 48 * kFactor)];

            [powerup1Item setPosition:ccp(kScreenCenterX - 45 * kFactor, kScreenCenterY + 5 * kFactor)];
            [carrot1Sprite setPosition:ccp(kScreenCenterX - 55 * kFactor, kScreenCenterY - 32 * kFactor)];
            [powerup2Item setPosition:ccp(kScreenCenterX + 45 * kFactor, kScreenCenterY + 5 * kFactor)];
            [carrot2Sprite setPosition:ccp(kScreenCenterX + 35 * kFactor, kScreenCenterY - 32 * kFactor)];
            
            [[Util sharedUtil] showLabel:[NSString stringWithFormat:@"%i",  100]
                                  atNode:self
                              atPosition:ccp(kScreenCenterX - 30 * kFactor, kScreenCenterY - 32 * kFactor)
                                fontName:@"BradyBunchRemastered"
                                fontSize:18 * kFactor
                               fontColor:ccc3(255, 204, 102)
                             anchorPoint:ccp(0.5, 0.5)
                               isEnabled:YES
                                     tag:1
                              dimensions:CGSizeMake(200, 40)
                                rotation:0
                                 bgColor:ccc3(51, 0, 0)];
            
            [[Util sharedUtil] showLabel:[NSString stringWithFormat:@"%i",  100]
                                  atNode:self
                              atPosition:ccp(kScreenCenterX + 60 * kFactor, kScreenCenterY - 32 * kFactor)
                                fontName:@"BradyBunchRemastered"
                                fontSize:18 * kFactor
                               fontColor:ccc3(255, 204, 102)
                             anchorPoint:ccp(0.5, 0.5)
                               isEnabled:YES
                                     tag:1
                              dimensions:CGSizeMake(200, 40)
                                rotation:0
                                 bgColor:ccc3(51, 0, 0)];
        }
	}
	return self;
}

-(void) onEnter {
	[super onEnter];
}

-(void) onExit {
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"levelStartAtl.plist"];
    [super onExit];
}

-(void) startLevelHandler {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0
                                                                                 scene:[GameLayer scene]]];
}

-(void) mainMenuHandler {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0
                                                                                 scene:[SelectLevelLayer scene]]];
}

-(void) shopHandler {
    ShopLayer *sl = [ShopLayer node];
    [self addChild:sl z:100];
}

-(void) buySuperPlanks {
    GameController *gC = [GameController sharedGameCtrl];
    if (gC.carrotsCount >= 100) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"Activate 2 super planks in the next level?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Confirm", nil];
        [alertView setTag:1];
        [alertView show];
        [alertView release];
    }
    else {
        [self showNotEnoughCarrots];
    }
}

-(void) buyStickyPlanks {
    GameController *gC = [GameController sharedGameCtrl];
    if (gC.carrotsCount >= 100) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"Activate 2 sticky planks in the next level?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Confirm", nil];
        [alertView setTag:2];
        [alertView show];
        [alertView release];
    }
    else {
        [self showNotEnoughCarrots];
    }
}

-(void) showEnjoyAlert2:(NSString*) caption {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Enjoy"
                                                        message:[NSString stringWithFormat:@"%@ will be active next level", caption]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView setTag:100];
    [alertView show];
    [alertView release];
}

-(void) showNotEnoughCarrots {
    NoCarrotsLayer *ncl = [NoCarrotsLayer node];
    [self addChild:ncl z:1000];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    GameController *gC = [GameController sharedGameCtrl];
    if(alertView.tag == 1) {
        if(buttonIndex == 1) {
            if([gC spendCoins:100]) {
                [self updateCoins];
                gC.superPlanksCount += 2;
                [gC save];
                [self showEnjoyAlert2:@"2 SUPER PLANKS"];
            }
        }
    }
    else if(alertView.tag == 2) {
        if(buttonIndex == 1) {
            if([gC spendCoins:100]) {
                [self updateCoins];
                gC.stickyPlanksCount += 2;
                [gC save];
                [self showEnjoyAlert2:@"2 STICKY PLANKS"];
            }
        }
    }
}

-(void) updateCoins {
    GameController *gC = [GameController sharedGameCtrl];
    [carrotBankLabel setString:[NSString stringWithFormat:@"%d", gC.carrotsCount]];
    if(gC.carrotsCount < 100) {
        [powerup1Item setIsEnabled:NO];
        [powerup2Item setIsEnabled:NO];
    }
}

@end