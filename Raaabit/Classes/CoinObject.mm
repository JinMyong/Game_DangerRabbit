//
//  CoinObject.mm
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "CoinObject.h"
#import "Constants.h"


@implementation CoinObject

- (id) init {
	if( (self=[super init]))  {
        self.typeOfObject = kTypeCoin;
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

-(void) startAnimationRotate {
    [self stopAllActions];
    float delay = (arc4random() % 10) / 10.0f;
    id action = [CCSequence actions:
                 [CCDelayTime actionWithDuration:delay],
                 [CCCallFunc actionWithTarget:self selector:@selector(startSwing)],
                 nil];
    [self runAction:action];
}

-(void) startSwing {
    id action = [CCRepeatForever actionWithAction:
                 [CCSequence actions:
                  [CCMoveBy actionWithDuration:0.7f position:ccp(0.0f, -5.0f * kFactor)],
                  [CCMoveBy actionWithDuration:0.7f position:ccp(0.0f, 5.0f * kFactor)],
                  nil]];
    [self runAction:action];
}

-(void) collectAnimation {
    [self stopAllActions];
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"coin"];
    id action = [CCSequence actions:
                 [CCAnimate actionWithAnimation:animation],
                 [CCCallFuncN actionWithTarget:self selector:@selector(removeCoin:)],
                 nil];
    [self runAction:action];
}

-(void) removeCoin: (id) sender {
    CoinObject *coin = (CoinObject *)sender;
    if(coin) {
        [coin removeFromParentAndCleanup:YES];
    }
}

@end
