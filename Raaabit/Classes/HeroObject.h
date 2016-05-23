//
//  HeroObject.h
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

#import "GameObject.h"

@class CannonObject;
@class GunObject;
@class GroundObject;

@interface HeroObject : GameObject {
    NSInteger _groundConnections;
    NSInteger _moveType;

    CannonObject *_cannon;
    GunObject *_gun;
    CGPoint goalPosition;
    
    b2Joint *joint;
    bool canWalk;
    bool isStarted;
    bool isRun;
    float speedFactor;
    bool isInAirFlow;
    float flowAngle;
    float flowCounter;
    bool isGoalAvailable;
    bool isKillMode;
    GroundObject *lastGround;
}

@property NSInteger groundConnections;
@property NSInteger moveType;
@property CGPoint goalPosition;
@property float speedFactor;
@property (nonatomic, retain) CannonObject *cannon;
@property (nonatomic, retain) GunObject *gun;
@property bool isInAirFlow;
@property float flowAngle;
@property bool isStarted;
@property bool isRun;
@property bool canWalk;
@property bool isGoalAvailable;
@property bool isKillMode;
@property (nonatomic, retain) GroundObject *lastGround;


-(bool) isOnTheGround;

-(void) startAnimationStarryEyed;
-(void) startAnimationFly;
-(void) startAnimationJump;
-(void) startAnimationShot;
-(void) startAnimationStand;
-(void) startAnimationWalk;
-(void) startAnimationRun;
-(void) startAnimationJumpInGun;

-(void) addConnection;
-(void) removeConnection;

-(void) setJoint: (b2Joint*) jnt;
-(b2Joint *) getJoint;
-(void) setInFlowWithAngle: (float) angle;
-(void) updateFlowCounter: (ccTime) dt;
-(void) startMoveRight;

- (void) setNormalStateWithDelay;
- (void) setNormalState;
- (void) setFrameInGun;

@end
