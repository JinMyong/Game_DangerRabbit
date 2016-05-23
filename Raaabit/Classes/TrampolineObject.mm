//
//  TrampolineObject.mm
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "TrampolineObject.h"
#import "Constants.h"
#import "SimpleAudioEngine.h"

@implementation TrampolineObject

@synthesize trampolineType;
@synthesize centerPos;

-(id) init {
	if( (self=[super init]))  {
        self.typeOfObject = kTypeTrampoline;
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

-(void) startAnimationSwing {
    [self stopAllActions];
    CCAnimation *animation =nil;
    switch (self.trampolineType) {
        case kTrampolineRegular:
            [[SimpleAudioEngine sharedEngine] playEffect:@"Plank.mp3"];
            animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"tram"];
            break;
        case kTrampolinePurple:
            [[SimpleAudioEngine sharedEngine] playEffect:@"Superplank.mp3"];
            animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"purpleTram"];
            break;
        default:
            break;
    }
    id action = [CCSequence actions:
                 [CCAnimate actionWithAnimation:animation],
                 [CCFadeOut actionWithDuration:0.2f],
                 [CCCallFunc actionWithTarget:self selector:@selector(removeObject)],
                 nil];
    [self runAction:action];
}

-(void) startAnimationStickSwing {
    [self stopAllActions];
    [[SimpleAudioEngine sharedEngine] playEffect:@"StickPlatformVoice.mp3"];
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"stickTram"];
    id action = [CCSequence actions:
                 [CCAnimate actionWithAnimation:animation],
                 [CCFadeOut actionWithDuration:0.2f],
                 [CCCallFunc actionWithTarget:self selector:@selector(removeObject)],
                 nil];
    [self runAction:action];
}

-(void) startAnimationPurpleSwing {
    [self stopAllActions];
    [[SimpleAudioEngine sharedEngine] playEffect:@"Superplank.mp3"];
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"purpleTram"];
    id action = [CCSequence actions:
                 [CCAnimate actionWithAnimation:animation],
                 [CCFadeOut actionWithDuration:0.2f],
                 [CCCallFunc actionWithTarget:self selector:@selector(removeObject)],
                 nil];
    [self runAction:action];
}

@end