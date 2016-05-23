//
//  CannonObject.mm
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "CannonObject.h"
#import "Constants.h"

@implementation CannonObject

- (id) init {
	if( (self=[super init]))  {
        self.typeOfObject = kTypeCannon;
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

- (void) initCannon {
    gun = [CCSprite spriteWithSpriteFrameName:@"cannonTop.png"];
    [gun setAnchorPoint:ccp(0.23f, 0.5f)];
    [gun setPosition:ccp(14.0f * kFactor, 20.0f * kFactor)];
    
    [gun setRotation:-35.0f];
    [self addChild:gun z:-1];
    self.typeOfObject = kTypeCannon;
}

- (float) getAngle{
    return gun.rotation;
}

- (void) setTargetPosition: (CGPoint) position {
    float angle = CC_RADIANS_TO_DEGREES(atanf((self.position.x - position.x) / (self.position.y - position.y)));
    if(position.y > self.position.y) {
        angle -= 90;
    }
    else {
        angle += 90;
    }
    
    if(angle <= 90 && angle > 0) {
        angle = 0;
    }
    else if(angle > 90) {
        angle = -180;
    }
    [gun setRotation:angle];
}

@end
