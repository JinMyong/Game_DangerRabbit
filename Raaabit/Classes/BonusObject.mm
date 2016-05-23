//
//  BonusObject.mm
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "BonusObject.h"
#import "Constants.h"


@implementation BonusObject

- (id) init {
	if( (self=[super init]))  {
        self.typeOfObject = kTypeBonus;
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

@end
