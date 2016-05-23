//
//  GunObject.mm
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "GunObject.h"
#import "Constants.h"
#import "HeroObject.h"
#import "GameLayer.h"
#import "BulletObject.h"
#import "SimpleAudioEngine.h"

@implementation GunObject

@synthesize alreadyUsed;

- (id) init {
	if( (self=[super init]))  {
        self.typeOfObject = kTypeGun;
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

- (void) initCannon {
    gun = [CCSprite spriteWithSpriteFrameName:@"gun_top_part_1.png"];
    [gun setAnchorPoint:ccp(0.22f, 0.16f)];
    [gun setPosition:ccp(20.0f * kFactor, 18.0f * kFactor)];
    
    [gun setRotation:-35.0f];
    [self addChild:gun z:-1];
    self.typeOfObject = kTypeGun;
}

- (float) getAngle{
    return gun.rotation;
}

- (float) setTargetPosition: (CGPoint) position {
    angle = CC_RADIANS_TO_DEGREES(atanf((self.position.x - position.x) / (self.position.y - position.y)));
    if(position.y > self.position.y) {
        angle -= 90;
    }
    else {
        angle += 90;
    }
    
    if(angle < -55.0f) {
        angle = -55.0f;
    }
    else if(angle > 55.0f) {
        angle = 55.0f;
    }
    [gun setRotation:angle];
    
    return angle;
}

- (void) addRabbit: (HeroObject *) hero {
    [hero setPosition:ccp(26.0f * kFactor, 34.0f * kFactor)];
    [gun addChild:hero];
}

- (void) shot {
    [[SimpleAudioEngine sharedEngine] playEffect:@"GunSingle.mp3"];
    BulletObject *bullet = [BulletObject spriteWithSpriteFrameName:@"bullet.png"];
    [bullet setPosition:ccp(self.position.x + 20.0f * kFactor * sinf(CC_DEGREES_TO_RADIANS(angle)) + 81.0f * kFactor * cosf(CC_DEGREES_TO_RADIANS(-angle)),
                            self.position.y + 20.0f * kFactor * cosf(CC_DEGREES_TO_RADIANS(angle)) + 81.0f * kFactor * sinf(CC_DEGREES_TO_RADIANS(-angle)))];
    GameLayer *gl = (GameLayer *)self.parent;
    [gl addChild:bullet z:20];
    [gl.listOfBullets addObject:bullet];
    
    [gun stopAllActions];
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"gun_top_part"];
    id action = [CCAnimate actionWithAnimation:animation];
    [gun runAction:action];
    
    [bullet setRotation:angle];
    [bullet setSpeedX:320 * cosf(CC_DEGREES_TO_RADIANS(-angle)) * kFactor];
    [bullet setSpeedY:320 * sinf(CC_DEGREES_TO_RADIANS(-angle)) * kFactor];
}

- (CGPoint) getRabbitPoss {
    CGPoint pos = ccp(self.position.x + gun.position.x + 10 * kFactor,
                      self.position.y + gun.position.y);
    return pos;
}

@end
