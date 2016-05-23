//
//  AirductObject.mm
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "AirductObject.h"
#import "Constants.h"

@implementation AirductObject

@synthesize typeOfAirduct;

- (id) init {
	if( (self=[super init]))  {
        self.typeOfObject = kTypeAirduct;
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

- (float) getAngleForAir {
    float angle = 0.0f;
    angle = self.rotation;
    
    if(self.typeOfAirduct == 1001) {
        angle -= 45.0f;
    }
    return angle;
}

- (void) initFlow {
    CCSprite *flow = [CCSprite spriteWithSpriteFrameName:@"wind_1.png"];
    [flow setAnchorPoint:ccp(0.0f, 0.5f)];
    [flow setPosition:ccp(self.contentSize.width - 30 * kFactor, self.contentSize.height / 2.0f + 5 * kFactor)];
    [self addChild:flow z:-1];

    if(self.typeOfAirduct == 1001) {
        [flow setRotation:-45];
    }
    
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"wind"];
    id action = [CCRepeatForever actionWithAction:
                 [CCAnimate actionWithAnimation:animation]];
    [flow runAction:action];
}

@end