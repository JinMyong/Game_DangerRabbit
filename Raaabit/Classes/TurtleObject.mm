//
//  TurtleObject.m
//  Raaabit
//
//  Created by Dmitry Valov on 01.08.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "TurtleObject.h"
#import "Constants.h"

@implementation TurtleObject

- (id) init {
	if( (self=[super init]))  {
        self.enemyType = kEnemyTurtle;
        pause = 0.0f;
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

-(void) startAnimationWalk {
    [self stopAllActions];
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"turtlewalk"];

    id action = [CCRepeatForever actionWithAction:
                 [CCAnimate actionWithAnimation:animation]];
    [self runAction:action];
}

-(void) updateHorizontalSpeed: (ccTime) dt {
    if(!isDead){
        if(pause > 0) {
            pause -= dt;
        }
        else {
            if(moveType == kMoveNone) {
                if(moveState == kPositionRight) {
                    moveType = kMoveLeft;
                    _body->SetLinearVelocity(b2Vec2(-kEnemySpeed / 2.0f, 0));
                    [self setFlipX:NO];
                    [self startAnimationWalk];
                }
                else if(moveState == kPositionLeft) {
                    moveType = kMoveRight;
                    _body->SetLinearVelocity(b2Vec2(kEnemySpeed / 2.0f, 0));
                    [self setFlipX:YES];
                    [self startAnimationWalk];
                }
                else {
                    return;
                }
            }
            else if(moveType == kMoveRight) {
                if((self.position.x > startPos.x + amplitude && amplitude > 0) ||
                   (self.position.x > startPos.x && amplitude < 0)) {
                    _body->SetLinearVelocity(b2Vec2(0, 0));
                    moveType = kMoveNone;
                    [self stopAllActions];
                    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"turtlewalk_1.png"];
                    [self setDisplayFrame:frame];
                    moveState = kPositionRight;
                    pause = 2.0f;
                }
            }
            else if(moveType == kMoveLeft) {
                if((self.position.x < startPos.x + amplitude && amplitude < 0) ||
                   (self.position.x < startPos.x && amplitude > 0)) {
                    _body->SetLinearVelocity(b2Vec2(0, 0));
                    moveType = kMoveNone;
                    [self stopAllActions];
                    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"turtlewalk_1.png"];
                    [self setDisplayFrame:frame];
                    moveState = kPositionLeft;
                    pause = 2.0f;
                }
            }
        }
    }
}

@end