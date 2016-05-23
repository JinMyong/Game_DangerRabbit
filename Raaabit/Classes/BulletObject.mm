//
//  BulletObject.mm
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "BulletObject.h"
#import "Constants.h"


@implementation BulletObject

@synthesize speedX = _speedX;
@synthesize speedY = _speedY;

- (id) init {
	if( (self=[super init]))  {
        _speedX = 0.0f;
        _speedY = 0.0f;
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

@end
