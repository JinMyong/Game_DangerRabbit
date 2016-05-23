//
//  GoalObject.mm
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "GoalObject.h"
#import "Constants.h"

@implementation GoalObject

- (id) init {
	if( (self=[super init]))  {
        self.typeOfObject = kTypeGoal;
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

-(void) startAnimationGoal {
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"goal_animation"];
    
    id action = [CCRepeatForever actionWithAction:
                 [CCAnimate actionWithAnimation:animation]];
    [self runAction:action];
}

@end
