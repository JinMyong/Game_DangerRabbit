//
//  SparrowObject.mm
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "SparrowObject.h"
#import "Constants.h"
#import "SimpleAudioEngine.h"


@implementation SparrowObject

@synthesize isStarted = _isStarted;

- (id) init {
	if( (self=[super init]))  {
        _isStarted = NO;
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

-(void) startAnimationFly {
    _isStarted = YES;

    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"fly/sparrow"];

    id action = [CCRepeatForever actionWithAction:
                 [CCAnimate actionWithAnimation:animation]];

    [self runAction:action];
}

-(void) startAnimationDeath {
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"death/sparrow_death"];
    
    id action = [CCAnimate actionWithAnimation:animation];
    [self runAction:action];
}

-(void) startChirp {
    id action = [CCSequence actions:
                 [CCDelayTime actionWithDuration:1.0f],
                 [CCCallFunc actionWithTarget:self selector:@selector(Chirp)],
                 nil];
    
    [self runAction:action];
}

-(void) Chirp {
    [[SimpleAudioEngine sharedEngine] playEffect:@"Chirp.mp3"];
}

@end