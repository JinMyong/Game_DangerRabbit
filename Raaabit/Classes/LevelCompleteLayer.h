//
//  LevelCompleteLayer.h
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCLabelBMFontAnimated.h"
#import "SimpleAudioEngine.h"

@interface LevelCompleteLayer : CCLayer {
    CCLabelBMFont *highScoreLabel;
    CCLabelBMFontAnimated *levelScoreLabel;
    CCLabelBMFontAnimated *bounceScoreLabel;
    CCLabelBMFontAnimated *coinsScoreLabel;
    CCLabelBMFontAnimated *enemiesScoreLabel;
    CCLabelBMFontAnimated *carrotscountLabel;   // Added by Hans to show a carrot count
    CCSprite *carrot_image ;    // Added by Hans to add a carrot image Icon
    NSInteger countCarrot;      // Added by Hans to show Carrot Count
    NSInteger earnedCarrot;     // Added by Hans to shwo Carrot Count
    NSInteger starNumber;
    CCMenu *menu;
    NSInteger deltaY;
    NSInteger deltaX;
    ALuint congratsSound;
}

+(CCScene *) scene;

-(void) nextLevelHandler;
-(void) replayLevelHandler;
-(void) mainMenuHandler;

@end
