//
//  GroundObject.mm
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "GroundObject.h"
#import "Constants.h"

@implementation GroundObject

@synthesize groundType;

- (id) init {
	if( (self=[super init]))  {
        self.typeOfObject = kTypePlatform;
        self.groundType = kTypePlatform;
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

-(void) startAnimationSwing {
    switch (self.groundType) {
        case 103: {
            [self stopAllActions];
            CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"tram2"];
            id action = [CCSequence actions:
                         [CCAnimate actionWithAnimation:animation],
                         [CCCallFunc actionWithTarget:self selector:@selector(startAnimationIdleSwing)],
                         nil];
            [self runAction:action];
            break;
        }
        case 104: {
            [self stopAllActions];
            CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"tram3"];
            id action = [CCSequence actions:
                         [CCAnimate actionWithAnimation:animation],
                         [CCCallFunc actionWithTarget:self selector:@selector(startAnimationIdleSwing)],
                         nil];
            [self runAction:action];
            break;
        }
        case 105: {
            [self stopAllActions];
            CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"tram4"];
            id action = [CCSequence actions:
                         [CCAnimate actionWithAnimation:animation],
                         [CCCallFunc actionWithTarget:self selector:@selector(startAnimationIdleSwing)],
                         nil];
            [self runAction:action];
            break;
        }
    }
}

-(void) startAnimationIdleSwing {
    switch (self.groundType) {
        case 103 : {
            CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"tramI2"];
            id action = [CCRepeatForever actionWithAction:
                         [CCSequence actions:
                          [CCAnimate actionWithAnimation:animation],
                          [CCDelayTime actionWithDuration:1.0f],
                          nil]];
            [self runAction:action];
            break;
        }
        case 104 : {
            CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"tramI3"];
            id action = [CCRepeatForever actionWithAction:
                         [CCSequence actions:
                          [CCAnimate actionWithAnimation:animation],
                          [CCDelayTime actionWithDuration:1.1f],
                          nil]];
            [self runAction:action];
            break;
        }
        case 105 : {
            CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"tramI4"];
            id action = [CCRepeatForever actionWithAction:
                         [CCSequence actions:
                          [CCAnimate actionWithAnimation:animation],
                          [CCDelayTime actionWithDuration:1.2f],
                          nil]];
            [self runAction:action];
            break;
        }
    }
}

@end
