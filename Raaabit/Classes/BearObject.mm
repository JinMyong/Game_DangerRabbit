//
//  BearObject.m
//  Raaabit
//
//  Created by Dmitry Valov on 01.08.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "BearObject.h"
#import "Constants.h"
#import "SimpleAudioEngine.h"

@implementation BearObject

@synthesize isInRoar;
@synthesize livesCount;

+(id)spriteWithSpriteFrameName:(NSString*)spriteFrameName
{
	CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName];
	return [self spriteWithSpriteFrame:frame];
}

+(id)spriteWithSpriteFrame:(CCSpriteFrame*)spriteFrame
{
	return [[[self alloc] initWithSpriteFrame:spriteFrame] autorelease];
}

- (id) initWithSpriteFrame:(CCSpriteFrame*)spriteFrame
{
	NSAssert(spriteFrame!=nil, @"Invalid spriteFrame for sprite");
    
	id ret = [self initWithTexture:spriteFrame.texture rect:spriteFrame.rect];
	[self setDisplayFrame:spriteFrame];
	return ret;
}

- (id) init {
	if( (self=[super init]))  {
        self.enemyType = kEnemyBear;
        self.isInRoar = NO;
        livesCount = 2;
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

-(void) startAnimationWalk {
    [self stopAllActions];
    CCAnimation *animation = nil;
    switch (enemyType) {
        case kEnemyBear:
            animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"Bear_walk/Bearwalk"];
            break;
    }
    id action = [CCRepeatForever actionWithAction:
                 [CCAnimate actionWithAnimation:animation]];
    [self runAction:action];
}

-(void) startAnimationRoar {
    [self stopAllActions];
    self.isInRoar = YES;
    CCAnimation *animation = nil;
    switch (enemyType) {
        case kEnemyBear:
            animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"Bear_roar/Bearroar"];
            break;
    }
    id action = [CCSequence actions:
                 [CCRepeat actionWithAction:
                  [CCAnimate actionWithAnimation:animation] times:1],
                 [CCCallFunc actionWithTarget:self selector:@selector(endRoar)],
                 nil];
    [self runAction:action];
}

-(void) startAnimationHited {
    [self stopAllActions];
    CCAnimation *animation = nil;
    switch (enemyType) {
        case kEnemyBear:
            animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"Bear_flash/Bearflash"];
            break;
    }
    id action = [CCAnimate actionWithAnimation:animation];
    [self runAction:action];
}

-(void) endRoar {
    self.isInRoar = NO;
}

-(bool) loseLife {
    if(!isLoseLife) {
        --livesCount;
        isLoseLife = YES;
        
        CCLOG(@"Lose life");
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"HurtEnemy.mp3"];
        [self startAnimationHited];
        
        id action = [CCSequence actions:
                     [CCDelayTime actionWithDuration:0.5f],
                     [CCCallFunc actionWithTarget:self selector:@selector(endLifeDelay)],
                     nil];
        [self runAction:action];
        if(livesCount <= 0) {
            return YES;
        }
    }
    return NO;
}

-(void) endLifeDelay {
    isLoseLife = NO;
}

-(void) updateHorizontalSpeedWithHeroPosition: (CGPoint) pos {
    if(!isDead){
        if(moveType == kMoveNone) {
            if(isFirstRun) {
                isFirstRun = NO;
                if(pos.x < self.position.x && moveState == kPositionLeft) {
                    [self setFlipX:NO];
                    [self startAnimationRoar];
                }
                else if(pos.x > self.position.x && moveState == kPositionRight) {
                    [self setFlipX:YES];
                    [self startAnimationRoar];
                }
            }
            if(pos.x < self.position.x && moveState == kPositionRight) {
                moveType = kMoveLeft;
                _body->SetLinearVelocity(b2Vec2(-kEnemySpeed, 0));
                [self setFlipX:NO];
                [self startAnimationWalk];
                self.isInRoar = NO;
            }
            else if(pos.x > self.position.x && moveState == kPositionLeft) {
                moveType = kMoveRight;
                _body->SetLinearVelocity(b2Vec2(kEnemySpeed, 0));
                [self setFlipX:YES];
                [self startAnimationWalk];
                self.isInRoar = NO;
            }
            else {
                _body->SetLinearVelocity(b2Vec2(0, 0));
                return;
            }
        }
        else if(moveType == kMoveRight) {
            if((self.position.x > startPos.x + amplitude && amplitude > 0) ||
               (self.position.x > startPos.x && amplitude < 0)) {
                _body->SetLinearVelocity(b2Vec2(0, 0));
                moveType = kMoveNone;
                moveState = kPositionRight;
                [self startAnimationRoar];
            }
        }
        else if(moveType == kMoveLeft) {
            if((self.position.x < startPos.x + amplitude && amplitude < 0) ||
               (self.position.x < startPos.x && amplitude > 0)) {
                _body->SetLinearVelocity(b2Vec2(0, 0));
                moveType = kMoveNone;
                moveState = kPositionLeft;
                [self startAnimationRoar];
            }
        }
    }
}

@end