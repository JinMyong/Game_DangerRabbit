//
//  HeroObject.mm
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "HeroObject.h"
#import "CannonObject.h"
#import <GunObject.h>
#import "Constants.h"
#import "GameController.h"
#import "GroundObject.h"

@implementation HeroObject

@synthesize groundConnections = _groundConnections;
@synthesize moveType = _moveType;
@synthesize cannon = _cannon;
@synthesize gun = _gun;
@synthesize goalPosition;
@synthesize speedFactor;
@synthesize isInAirFlow;
@synthesize flowAngle;
@synthesize isStarted;
@synthesize isRun;
@synthesize canWalk;
@synthesize isGoalAvailable;
@synthesize isKillMode;
@synthesize lastGround;

- (id) init {
	if( (self=[super init]))  {
        self.typeOfObject = kTypeHero;
        canWalk = NO;
        isStarted = NO;
        speedFactor = 1.0f;
        _moveType = kMoveNone;
        isInAirFlow = NO;
        isGoalAvailable = NO;
        isKillMode = NO;
        self.lastGround = nil;
        
        if([[GameController sharedGameCtrl] countLevelStars] >= 1) {
            self.isGoalAvailable = YES;
        }
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

-(bool) isOnTheGround {
    if(self.groundConnections > 0) {
       return YES;
    }
    return NO;
}

-(void) startAnimationStarryEyed {
    if(self.state == kStateLoadingInGun) {
        return;
    }
    if(self.state != kStateInShoot) {
        [self stopAllActions];
    }
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"starry_eyed/starry_eyed"];
    id action = [CCSequence actions:
                 [CCAnimate actionWithAnimation:animation],
                 [CCDelayTime actionWithDuration:0.2f],
                 [CCCallFunc actionWithTarget:self selector:@selector(startMoveRight)],
                 nil];
    [self runAction:action];
}

-(void) startAnimationFly {
    if(self.state == kStateLoadingInGun) {
        return;
    }
    if(self.groundConnections <= 0) {
        if(self.state != kStateInShoot) {
            [self stopAllActions];
        }
        CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"fly/fly"];
        id action = [CCAnimate actionWithAnimation:animation];
        [self runAction:action];
    }
    else {
        [self startAnimationWalk];
    }
}

-(void) startAnimationJump {
    if(self.state == kStateLoadingInGun) {
        return;
    }
    if(self.groundConnections <= 0) {
        canWalk = NO;
        if(self.state != kStateInShoot) {
            [self stopAllActions];
        }
        CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"jump/jump"];
        id action = [CCSequence actions:
                     [CCAnimate actionWithAnimation:animation],
                     [CCCallFunc actionWithTarget:self selector:@selector(allowWalk)],
                     [CCCallFunc actionWithTarget:self selector:@selector(startAnimationFly)],
                     nil];
        [self runAction:action];
    }
}

-(void) startAnimationShot {
    if(self.state != kStateInShoot) {
        [self stopAllActions];
    }
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"shoot/shoot"];
    id action = [CCRepeatForever actionWithAction:
                 [CCAnimate actionWithAnimation:animation]];
    [self runAction:action];
}

-(void) startAnimationStand {
    if(self.state == kStateLoadingInGun) {
        return;
    }
    if(self.state != kStateInShoot) {
        [self stopAllActions];
    }
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"stand/stand"];
    id action = [CCAnimate actionWithAnimation:animation];
    [self runAction:action];
}

-(void) startAnimationWalk {
    if(self.state == kStateLoadingInGun) {
        return;
    }
    if(!canWalk || self.state == kStateInShoot) {
        return;
    }
    [self stopAllActions];
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"walk/walk"];
    id action = [CCRepeatForever actionWithAction:
                 [CCAnimate actionWithAnimation:animation]];
    [self runAction:action];
}

-(void) startAnimationRun {
    if(self.state == kStateLoadingInGun) {
        return;
    }
    if(!canWalk || self.state == kStateInShoot) {
        return;
    }
    [self stopAllActions];
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"run/run"];
    id action = [CCRepeatForever actionWithAction:
                 [CCAnimate actionWithAnimation:animation]];
    [self runAction:action];
}

-(void) startAnimationJumpInGun {
    if(self.state == kStateLoadingInGun) {
        return;
    }
    [self stopAllActions];
    [self setFlipX:NO];
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"jumpInGun/jumpInGun"];
    id action = [CCAnimate actionWithAnimation:animation];
    [self runAction:action];
}

-(void) addConnection {
    self.isKillMode = NO;
    if(self.state != kStateInShoot) {
        [self startAnimationWalk];
        ++self.groundConnections;
    }
}

-(void) removeConnection {
    --self.groundConnections;
    if(self.groundConnections < 0) {
        self.groundConnections = 0;
    }
    if(self.groundConnections == 0) {
        isRun = NO;
        [self startAnimationJump];
    }
}

-(void) setJoint: (b2Joint*) jnt {
    joint = jnt;
}

-(b2Joint *) getJoint {
    return joint;
}

-(void) allowWalk {
    canWalk = YES;
    if(self.groundConnections > 0) {
        [self startAnimationWalk];
    }
}

-(void) setInFlowWithAngle: (float) angle {
    isInAirFlow = YES;
    flowAngle = angle;
    flowCounter = 1.0f;
}

-(void) updateFlowCounter: (ccTime) dt {
    flowCounter -= dt;
    
    if(flowCounter <= 0) {
        isInAirFlow = NO;
    }
}

-(void) startMoveRight {
    isRun = YES;
    canWalk = YES;
    isStarted = YES;
    _moveType = kMoveRight;
    [self startAnimationRun];
}

- (void) setNormalStateWithDelay {
    id action = [CCSequence actions:
                 [CCDelayTime actionWithDuration:0.5f],
                 [CCCallFunc actionWithTarget:self selector:@selector(setNormalState)],
                 nil];
    [self runAction:action];
}

- (void) setNormalState {
    self.state = kStateNewObject;
}

- (void) setFrameInGun {
    [self setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"jumpInGun/jumpInGun_8.png"]];
}

@end
