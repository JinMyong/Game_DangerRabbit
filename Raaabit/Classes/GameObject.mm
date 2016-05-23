//
//  GameObject.mm
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright Dmitry Valov 2013. All rights reserved.
//

#import "GameObject.h"

@implementation GameObject

@synthesize typeOfObject;
@synthesize state;
@synthesize objectID;

- (id) init {
	if( (self=[super init]))  {
		state = kStateNewObject;
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

- (void) removeObject {
	[self removeFromParentAndCleanup:YES];
}

- (void) fadeRemoveObject {
	id action = [CCSequence actions:
				 [CCFadeOut actionWithDuration:0.5f],
				 [CCCallFunc actionWithTarget:self selector:@selector(removeObject)],
				 nil];
	[self runAction:action];
}

- (void) setState: (NSInteger) newState withDelay: (float) delay {
    preState = newState;
	id action = [CCSequence actions:
				 [CCDelayTime actionWithDuration:delay],
				 [CCCallFunc actionWithTarget:self selector:@selector(updateState)],
				 nil];
	[self runAction:action];
}

- (void) updateState {
    self.state = preState;
}

- (void) setBody: (b2Body *) body {
    _body = body;
}

- (b2Body *) getBody {
    return _body;
}

@end