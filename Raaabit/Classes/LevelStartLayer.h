//
//  LevelStartLayer.h
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCLabelBMFontAnimated.h"
#import "SimpleAudioEngine.h"

@class MyMenuItemSprite;

@interface LevelStartLayer : CCLayer {
    CCLabelBMFont *carrotBankLabel;
    CCMenu *menu;
    
    MyMenuItemSprite *powerup1Item;
    MyMenuItemSprite *powerup2Item;
}

+(CCScene *) scene;

-(void) startLevelHandler;
-(void) shopHandler;
-(void) mainMenuHandler;

-(void) buySuperPlanks;
-(void) buyStickyPlanks;

- (void) showEnjoyAlert2:(NSString*) caption;
- (void) showNotEnoughCarrots;

- (void) updateCoins;

@end
