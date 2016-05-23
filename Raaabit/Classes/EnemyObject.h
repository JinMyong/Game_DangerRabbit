//
//  EnemyObject.h
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameObject.h"

#define kEnemyBee           601
#define kEnemyBlueBee       602
#define kEnemyBear          603
#define kEnemyBird          604
#define kEnemyTurtle        605

#define kPositionLeft       11
#define kPositionRight      12

@interface EnemyObject : GameObject {
    CGPoint     startPos;
    NSInteger   amplitude;
    NSInteger   moveType;
    NSInteger   enemyType;
    bool        isDead;
    NSInteger   moveState;
    bool        isFirstRun;
}

@property NSInteger enemyType;
@property bool isDead;

-(void) startAnimationFly;
-(void) initEnemyWithPos: (CGPoint) pos amplitude: (NSInteger) ampl;
-(void) initEnemyWithPos: (CGPoint) pos horizontalAmplitude: (NSInteger) ampl isStarted: (bool) started;
-(void) updateSpeed;
-(void) updateHorizontalSpeed;
-(void) kill;

@end
