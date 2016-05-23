//
//  EnemyObject.mm
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "EnemyObject.h"
#import "Constants.h"

@implementation EnemyObject

@synthesize enemyType;
@synthesize isDead;

- (id) init {
	if( (self=[super init]))  {
        self.typeOfObject = kTypeEnemy;
        self.enemyType = kEnemyBee;
        self.isDead = NO;
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

-(void) startAnimationFly {
    [self stopAllActions];
    
    CCAnimation *animation = nil;
    switch (enemyType) {
        case kEnemyBee:
            animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"bee"];
            break;
        case kEnemyBlueBee:
            animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"blueBee"];
            break;
        case kEnemyBird:
            animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"Birdflying"];
            break;
        default:
            animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"bee"];
            break;
    }
    id action = [CCRepeatForever actionWithAction:
                 [CCAnimate actionWithAnimation:animation]];
    [self runAction:action];
}

-(void) initEnemyWithPos: (CGPoint) pos amplitude: (NSInteger) ampl {
    startPos = pos;
    amplitude = ampl;
    
    if(amplitude > 0) {
        moveType = kMoveTop;
        _body->SetLinearVelocity(b2Vec2(0, kEnemySpeed));
    }
    else if(amplitude < 0) {
        moveType = kMoveDown;
        _body->SetLinearVelocity(b2Vec2(0, -kEnemySpeed));
    }
    else {
        moveType = kMoveNone;
    }
}

-(void) updateSpeed {
    if(isDead) {
        
    }
    else {
        if(moveType == kMoveNone) {
            return;
        }
        else if(moveType == kMoveTop) {
            if((self.position.y > startPos.y + amplitude && amplitude > 0) ||
               (self.position.y > startPos.y && amplitude < 0)) {
                _body->SetLinearVelocity(b2Vec2(0, -kEnemySpeed));
                moveType = kMoveDown;
            }
        }
        else if(moveType == kMoveDown) {
            if((self.position.y < startPos.y + amplitude && amplitude < 0) ||
               (self.position.y < startPos.y && amplitude > 0)) {
                _body->SetLinearVelocity(b2Vec2(0, kEnemySpeed));
                moveType = kMoveTop;
            }
        }
    }
}

-(void) initEnemyWithPos: (CGPoint) pos horizontalAmplitude: (NSInteger) ampl isStarted: (bool) started {
    startPos = pos;
    amplitude = ampl;
    moveType = kMoveNone;
    isFirstRun = YES;
    
    if(amplitude > 0) {
        if(started) {
            moveType = kMoveRight;
        }
        moveState = kPositionLeft;

        if(typeOfObject != kEnemyBear) {
            _body->SetLinearVelocity(b2Vec2(kEnemySpeed, 0));
            [self setFlipX:YES];
        }
    }
    else if(amplitude < 0) {
        if(started) {
            moveType = kMoveLeft;
        }
        moveState = kPositionRight;

        if(typeOfObject != kEnemyBear) {
            _body->SetLinearVelocity(b2Vec2(-kEnemySpeed, 0));
            [self setFlipX:NO];
        }
    }
    else {
        moveType = kMoveNone;
    }
}

-(void) updateHorizontalSpeed {
    if(isDead) {
    }
    else {
        if(moveType == kMoveNone) {
            return;
        }
        else if(moveType == kMoveRight) {
            if((self.position.x > startPos.x + amplitude && amplitude > 0) ||
               (self.position.x > startPos.x && amplitude < 0)) {
                _body->SetLinearVelocity(b2Vec2(-kEnemySpeed, 0));
                moveType = kMoveLeft;
                [self setFlipX:NO];
            }
        }
        else if(moveType == kMoveLeft) {
            if((self.position.x < startPos.x + amplitude && amplitude < 0) ||
               (self.position.x < startPos.x && amplitude > 0)) {
                _body->SetLinearVelocity(b2Vec2(kEnemySpeed, 0));
                moveType = kMoveRight;
                [self setFlipX:YES];
            }
        }
    }
}

-(void) kill {
    isDead = YES;
}

@end