//
//  HUDLayer.h
//  Raaabit
//
//  Created by Dmitry Valov on 11.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BulletMeter.h"

@interface HUDLayer : CCLayer {
    CCSprite *trampolinBG;
    CCSprite *coinBG;

    CCLabelBMFont *livesValue;
    CCLabelBMFont *countTrampolinesValue;
    CCLabelTTF    *countTrampolinesStickValue;
    CCSprite      *stickyTrampolinesSign;
    CCLabelTTF    *countTrampolinesPurpleValue;
    CCSprite      *purpleTrampolinesSign;
    CCLabelTTF    *countBombsValue;
    CCSprite      *bombsSign;

    
    CCLabelBMFont *coinsValue;
    CCLabelBMFont *scoresValue;
    
    CCMenu *menu;
    
    bool isTrampolinesLabelAnimated;
    
    BulletMeter *bulletMeterNode_;
    
    NSInteger numberOfPurple;
    NSInteger numberOfSticky;
}

@property (nonatomic, retain) BulletMeter *bulletMeterNode;

-(void)createMenu;

-(void)updateLives: (NSInteger) lives;
-(void)updateTrampolines: (NSInteger) count;
-(void)updateTrampolinesStick:(NSInteger)count;
-(void)updateTrampolinesPurple:(NSInteger)count;
-(void) updateBombs: (NSInteger) count;
-(void)updateCoins: (NSInteger) coins withTotal: (NSInteger) total;
-(void)updateScores: (NSInteger) scores;

-(NSString *)secondsToString: (NSInteger) seconds;
-(void)pauseHandler;
-(void)showSaveMe;
-(void)saveMeHandler: (id) sender;
-(void)restartLevel;
-(void)removeSaveMenu: (id) sender;

-(void) showBulletMeter;
-(void) hideBulletMeter;

-(void) updateTrampolinesBorder;

@end
