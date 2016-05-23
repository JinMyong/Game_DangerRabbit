//
//  GunObject.h
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "GameObject.h"

@class HeroObject;

@interface GunObject : GameObject {
    CCSprite *gun;
    float angle;
    bool alreadyUsed;
}

@property bool alreadyUsed;

- (void) initCannon;
- (float) getAngle;
- (float) setTargetPosition:(CGPoint) position;

- (void) addRabbit:(HeroObject *) hero;
- (void) shot;

- (CGPoint) getRabbitPoss;

@end