//
//  ShopNode.m
//  Raaabit
//
//  Created by Dmitry Valov on 07.10.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "ShopNode.h"
#import "Util.h"

@implementation ShopNode

- (id) init {
	if( (self=[super init]) ) {
        isiPad = [[Util sharedUtil] isiPad];
        
        table = [CCNode node];
        [self addChild:table];
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

- (void)visit {
    glEnable(GL_SCISSOR_TEST);
//    NSInteger scale = [[UIScreen mainScreen] scale];
    
    if(isiPad) {
//        glScissor(startPosition.x * scale, startPosition.y * scale, 277 * scale, 95 * scale);
    }
    else {
//        glScissor(startPosition.x * scale, startPosition.y * scale, 134 * scale, 44 * scale);
    }
    [super visit];
    glDisable(GL_SCISSOR_TEST);
}

@end
