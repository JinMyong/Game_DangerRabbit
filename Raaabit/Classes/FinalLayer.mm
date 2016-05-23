//
//  FinalLayer.m
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "FinalLayer.h"
#import "Util.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "MainMenuLayer.h"
#import "Appirater.h"

@implementation FinalLayer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	FinalLayer *layer = [FinalLayer node];
	[scene addChild: layer];
	
	return scene;
}

-(id) init {
	if((self=[super init])) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"finalAtl.plist"];
        
        CCSprite *bg = [CCSprite spriteWithFile:@"bgFinal.jpg"];
        [bg setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg];
 
        //Main Menu
        CCMenuItemSprite *menuItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"fs_backButton.png"]
                                                             selectedSprite:[CCSprite spriteWithSpriteFrameName:@"fs_backButton_p.png"]
                                                             disabledSprite:nil
                                                                     target:self
                                                                   selector:@selector(mainMenuHandler)];
        [menuItem setPosition:ccp(45 * kFactor, 45 * kFactor)];

        //Facebook
        CCMenuItemSprite *facebookItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"fs_fbButton.png"]
                                                                 selectedSprite:[CCSprite spriteWithSpriteFrameName:@"fs_fbButton_p.png"]
                                                                 disabledSprite:nil
                                                                         target:self
                                                                       selector:@selector(facebookHandler)];
        [facebookItem setPosition:ccp(kScreenCenterX, kScreenCenterY - 102 * kFactor)];

        
        //Rate
        CCMenuItemSprite *rateItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"fs_rateButton.png"]
                                                             selectedSprite:[CCSprite spriteWithSpriteFrameName:@"fs_rateButton_p.png"]
                                                             disabledSprite:nil
                                                                     target:self
                                                                   selector:@selector(rateHandler)];
        [rateItem setPosition:ccp(kScreenCenterX - 120 * kFactor, kScreenCenterY - 25 * kFactor)];
        
        //Email
        CCMenuItemSprite *emailItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"fs_mailButton.png"]
                                                              selectedSprite:[CCSprite spriteWithSpriteFrameName:@"fs_mailButton_p.png"]
                                                              disabledSprite:nil
                                                                      target:self
                                                                    selector:@selector(emailHandler)];
        [emailItem setPosition:ccp(kScreenCenterX + 120 * kFactor, kScreenCenterY - 25 * kFactor)];
        
        
        if([[Util sharedUtil] isiPad]) {
            [facebookItem setPosition:ccp(kScreenCenterX, kScreenCenterY - 138 * kFactor)];
            [rateItem setPosition:ccp(kScreenCenterX - 140 * kFactor, kScreenCenterY - 25 * kFactor)];
            [emailItem setPosition:ccp(kScreenCenterX + 140 * kFactor, kScreenCenterY - 25 * kFactor)];
        }
        
        CCMenu *menu = [CCMenu menuWithItems: menuItem, facebookItem, rateItem, emailItem, nil];
        [menu setPosition:CGPointZero];
        [self addChild: menu z:20];
	}
	return self;
}

-(void) onEnter {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    [appDelegate unloadResourcesForGame];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [appDelegate loadResourcesForMenu];
	[super onEnter];
}

-(void) onExit {
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"finalAtl.plist"];
    [super onExit];
}

-(void) mainMenuHandler {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f
                                                                                 scene:[MainMenuLayer scene]]];
}

-(void) facebookHandler {
    NSString *facebookUrlString = kFacebookURL;
    
    if ([[facebookUrlString pathComponents] count] > 0) {
        if ([[facebookUrlString pathComponents][1] isEqualToString:@"www.facebook.com"]) {
            NSMutableArray *pathComponents = [[facebookUrlString pathComponents] mutableCopy];
            [pathComponents replaceObjectAtIndex:1 withObject:@"facebook.com"];
            facebookUrlString = [NSString pathWithComponents:pathComponents];
        }
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:facebookUrlString]];
}

-(void) rateHandler {
    [Appirater userDidSignificantEvent2:YES];
}

-(void) emailHandler {
    AppController *appDelegate = (AppController *)[UIApplication sharedApplication].delegate;
    [appDelegate.navController sendEmail];
}

@end
