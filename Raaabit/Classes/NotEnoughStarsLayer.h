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
#import "MyPopupLayer.h"

@interface NotEnoughStarsLayer : MyPopupLayer <UIAlertViewDelegate> {
    CCLabelBMFont *carrotBankLabel;
    CCMenu *menu;
}

+(CCScene *) scene;

-(void) mainMenuHandler;
-(void) facebookHandler;
-(void) keyHandler;
-(void) selectAreaHandler;

- (void) showEnjoyAlert:(NSString*) caption;
- (void) showEnjoyAlert2:(NSString*) caption;
- (void) showNotEnoughCarrots;

@end
