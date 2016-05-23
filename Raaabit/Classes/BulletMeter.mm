//
//  BulletMeter.mm
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "BulletMeter.h"
#import "Constants.h"

#define countBullets    40

@implementation BulletMeter

@synthesize listOfBullets = listOfBullets_;

- (id) init {
	if( (self=[super init]))  {
        delay = 0.0f;
        
        background = [CCSprite spriteWithSpriteFrameName:@"meter_base.png"];
        [self setContentSize:background.contentSize];
        [background setPosition:ccp(0.0f, 0.0f)];
        [self addChild:background];
        
        listOfBullets_ = [[NSMutableArray alloc] init];
        
        CGPoint startPos = ccp(11 * kFactor,
                               background.contentSize.height / 2.0f);
        for(NSUInteger i = 0; i < countBullets; ++i) {
            CCSprite *bullet = [CCSprite spriteWithSpriteFrameName:@"bullet1.png"];
            [bullet setPosition:startPos];
            startPos.x += bullet.contentSize.width;
            [background addChild:bullet z:1];
            
            [listOfBullets_ addObject:bullet];
        }
	}
	return self;
}

- (void) dealloc {
    [listOfBullets_ release];
	[super dealloc];
}

- (bool) update: (ccTime) dt withState: (NSInteger) state {
    delay += dt;
    if(state == kBulletMeterStateShooting) {
        if(delay > 0.08f) {
            delay = 0.0f;
            if([listOfBullets_ count] > 0) {
                CCSprite *bullet = (CCSprite *)[listOfBullets_ lastObject];
                if(bullet) {
                    [bullet removeFromParentAndCleanup:YES];
                }
                [listOfBullets_ removeLastObject];
                return YES;
            }
            else {
                return NO;
            }
        }
    }
    else if(state == kBulletMeterStateRest) {
        if(delay > 0.2f) {
            delay = 0.0f;
            if([listOfBullets_ count] < countBullets) {
                CCSprite *bullet = [CCSprite spriteWithSpriteFrameName:@"bullet1.png"];
                CGPoint startPos = ccp(11 * kFactor,
                                       background.contentSize.height / 2.0f);
                startPos.x += bullet.contentSize.width * [listOfBullets_ count];
                [bullet setPosition:startPos];
                [background addChild:bullet z:1];
                [listOfBullets_ addObject:bullet];
            }
        }
    }
    return NO;
}

@end
