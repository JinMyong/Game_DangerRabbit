//
//  LevelStartLayer.m
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "NotEnoughStarsLayer.h"
#import "MainMenuLayer.h"
#import "GameLayer.h"
#import "MyMenuItemSprite.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "GameProgressController.h"
#import "ShopLayer.h"
#import "GameController.h"
#import "SelectAreaLayer.h"
#import "GameController.h"
#import "FacebookController.h"
#import "SelectLevelLayer.h"
#import "CutScenes2Layer.h"
#import "FinalLayer.h"
#import "NoCarrotsLayer.h"
#import "SelectAreaLayer.h"

#import "SWTableView.h"
#import "ScoresTable.h"
#import "GameController.h"
#import "Util.h"
#import "CCLabelBMFontAnimated.h"

@implementation NotEnoughStarsLayer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
    
//    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];

	NotEnoughStarsLayer *layer = [NotEnoughStarsLayer node];
	[scene addChild: layer];
	
	return scene;
}

-(id) init {
	if((self=[super init])) {
        AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];

        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"notEnoughStarsAtl.plist"];
        CCNode *containerNode = [CCNode node];
		[containerNode setContentSize:CGSizeMake(kScreenWidth, kScreenHeight)];
        float offset = 0.0f;
		[containerNode setPosition:ccp(offset, kScreenHeight)];
		[self addChild:containerNode z:1];

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

        
        CCSprite *bg1 = [CCSprite spriteWithSpriteFrameName:@"nes_frame.png"];
        [bg1 setPosition:ccp(kScreenCenterX, kScreenCenterY + 45)];
        [containerNode addChild:bg1 z:-1];
        
        NSInteger numberOfStars = 0;
        if (appDelegate.currArea == 1 &&
            [[GameProgressController sharedGProgressCtrl] getStarsForWorld:1] < 40) {
            numberOfStars = 40 - [[GameProgressController sharedGProgressCtrl] getStarsForWorld:1];
        }
        else if (appDelegate.currArea == 2 &&
                 [[GameProgressController sharedGProgressCtrl] getStarsForWorld:2] < 50) {
            numberOfStars = 50 - [[GameProgressController sharedGProgressCtrl] getStarsForWorld:2];
        }
        else if (appDelegate.currArea == 3 &&
                 [[GameProgressController sharedGProgressCtrl] getStarsForWorld:3] < 50) {
            numberOfStars = 50 - [[GameProgressController sharedGProgressCtrl] getStarsForWorld:3];
        }
        
        NSString *nextArea = [NSString stringWithFormat:@"%d", appDelegate.currArea + 1];
        NSString *starCount = [NSString stringWithFormat:@"%d%@", numberOfStars, @"smore stars needed"];
        
        CCLabelBMFont *missedStarLabel = [CCLabelBMFont labelWithString:starCount fntFile:@"font_lc_area_name.fnt"];
        [missedStarLabel setScale:0.8f];
        [missedStarLabel setPosition:ccp(kScreenCenterX - 142, kScreenCenterY + 163)];
        [containerNode addChild:missedStarLabel];
        
        CCLabelBMFont *missedChapterLabel = [CCLabelBMFont labelWithString:nextArea fntFile:@"font_lc_area_name.fnt"];
        [missedChapterLabel setScale:0.8f];
        [missedChapterLabel setPosition:ccp(kScreenCenterX + 310, kScreenCenterY + 163)];
        [containerNode addChild:missedChapterLabel];

        //Menu
        menu = [CCMenu menuWithItems:nil];
        [menu setPosition:CGPointZero];
        [containerNode addChild: menu z:20];

        //Menu
        MyMenuItemSprite *mainMenuItem = [MyMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"nes_menu_button.png"]
                                                                 selectedSprite:nil
                                                                 disabledSprite:nil
                                                                         target:self
                                                                       selector:@selector(mainMenuHandler)];
        [mainMenuItem setPosition:ccp(kScreenCenterX - 85 * kFactor, 66 * kFactor)];
        [menu addChild:mainMenuItem];

        //Facebook
        MyMenuItemSprite *facebookItem = [MyMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"nes_fb_button.png"]
                                                                 selectedSprite:nil
                                                                 disabledSprite:nil
                                                                         target:self
                                                                       selector:@selector(facebookHandler)];
        [facebookItem setPosition:ccp(kScreenCenterX , 66 * kFactor)];
        [menu addChild:facebookItem];
        
        //Key
        MyMenuItemSprite *keyItem = [MyMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"nes_key_button.png"]
                                                            selectedSprite:nil
                                                            disabledSprite:nil
                                                                    target:self
                                                                  selector:@selector(keyHandler)];
        [keyItem setPosition:ccp(kScreenCenterX + 85 * kFactor, 66 * kFactor)];
        [menu addChild:keyItem];
        
        if(!VERSION_IPHONE) {
        }
        else {
            [bg1 setPosition:ccp(kScreenCenterX, kScreenCenterY + 25)];
            [bg1 setScaleY:0.9f];

            [mainMenuItem setPosition:ccp(kScreenCenterX - 85 * kFactor, 48 * kFactor)];
            [facebookItem setPosition:ccp(kScreenCenterX, 48 * kFactor)];
            [keyItem setPosition:ccp(kScreenCenterX + 85 * kFactor, 48 * kFactor)];
            
            [missedStarLabel setPosition:ccp(kScreenCenterX - 61, kScreenCenterY + 79)];
                                                            //71
//            [missedChapterLabel setPosition:ccp(kScreenCenterX + 156, kScreenCenterY + 79)];
        }
        
        id move = [CCMoveBy actionWithDuration:0.5f position:ccp(0.0f, -kScreenHeight)];
        id action = [CCSequence actions:
                     [CCDelayTime actionWithDuration:0.7f],
                     [CCEaseBackOut actionWithAction:move],
                     nil];
        [containerNode runAction:action];
        
        NSString *priceString = [[GameController sharedGameCtrl].listOfPrices objectForKey:kAppleID_NextWorld];
        if(!priceString || [priceString length] <= 0) {
            priceString = @"$0.99";
        }
        
        [[Util sharedUtil] showLabel:priceString
                              atNode:containerNode
                          atPosition:ccp(keyItem.position.x, keyItem.position.y - 34 * kFactor)
                            fontName:@"BradyBunchRemastered"
                            fontSize:20 * kFactor
                           fontColor:ccc3(255, 204, 102)
                         anchorPoint:ccp(0.5, 0.5)
                           isEnabled:YES
                                 tag:1
                          dimensions:CGSizeMake(100, 100)
                            rotation:0
                             bgColor:ccc3(51, 0, 0)];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(selectAreaHandler)
                                                     name:kWorldUnlockedNotification
                                                   object:nil];

	}
	return self;
}

-(void) onEnter {
	[super onEnter];
}

-(void) onExit {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"notEnoughStarsAtl.plist"];
    [super onExit];
}

-(void) mainMenuHandler {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0
                                                                                 scene:[SelectLevelLayer scene]]];
}

-(void) facebookHandler {
    [[FacebookController sharedFacebookCtrl] inviteFriends];
}

-(void) keyHandler {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    [appDelegate purchase:kShopID_NextWorld];
}

-(void) selectAreaHandler {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0
                                                                                 scene:[SelectAreaLayer scene]]];
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

-(void) showEnjoyAlert2:(NSString*) caption {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Enjoy"
                                                        message:[NSString stringWithFormat:@"%@ will be active next level", caption]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

-(void) showNotEnoughCarrots {
    NoCarrotsLayer *ncl = [NoCarrotsLayer node];
    [self addChild:ncl z:1000];
}

-(void) alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger) buttonIndex {
    if (buttonIndex == 0) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0
                                                                                     scene:[SelectAreaLayer scene]]];
    }
}

@end