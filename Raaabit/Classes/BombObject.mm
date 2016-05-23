//
//  BombObject.m
//  Raaabit
//
//  Created by Dmitry Valov on 01.08.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "BombObject.h"
#import "Constants.h"

@implementation BombObject

@synthesize explosionPos;

- (id) init {
	if( (self=[super init]))  {
	}
	return self;
}

- (void) dealloc {
    [loopBombSound stop];
    [loopBombSound release];
    loopBombSound = nil;

	[super dealloc];
}

-(void) startAnimationFuse {
    [self stopAllActions];
    
    loopBombSound = [[SimpleAudioEngine sharedEngine] soundSourceForFile:@"Fuse.mp3"];
    loopBombSound.looping = YES;
    [loopBombSound play];
    [loopBombSound retain];

    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"fuse/fuse"];
    fuseAction = [CCRepeatForever actionWithAction:
                 [CCAnimate actionWithAnimation:animation]];
    [self runAction:fuseAction];
}

-(void) startAnimationExplosion {
    [self stopAction:fuseAction];
    [[SimpleAudioEngine sharedEngine] playEffect:@"bomb.mp3"];
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"explosion/explosion"];
    id action = [CCSequence actions:
                 [CCAnimate actionWithAnimation:animation],
                 [CCCallFunc actionWithTarget:self selector:@selector(removeObject)],
                 nil];
    [self runAction:action];
}

-(void) setTrampoline1:(b2Body *)trampoline {
    trampoline1 = trampoline;
}

-(void) setTrampoline2:(b2Body *)trampoline {
    trampoline2 = trampoline;
}

- (b2Body *) getTrampoline1 {
    return trampoline1;
}

- (b2Body *) getTrampoline2 {
    return trampoline2;
}

-(void) checkTrampoline:(b2Body *)trampoline {
    if(trampoline == trampoline1) {
        trampoline1 = nil;
    }
    else if(trampoline == trampoline2) {
        trampoline2 = nil;
    }
}


@end