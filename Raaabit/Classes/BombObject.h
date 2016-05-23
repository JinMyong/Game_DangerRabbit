//
//  BombObject.h
//  Raaabit
//
//  Created by Dmitry Valov on 01.08.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameObject.h"
#import "SimpleAudioEngine.h"

@interface BombObject : GameObject {
    id fuseAction;
    CGPoint explosionPos;
    
    b2Body          *trampoline1;
    b2Body          *trampoline2;
    
    CDSoundSource   *loopBombSound;
}

@property CGPoint explosionPos;

-(void) startAnimationFuse;
-(void) startAnimationExplosion;
-(void) setTrampoline1:(b2Body *)trampoline;
-(void) setTrampoline2:(b2Body *)trampoline;
- (b2Body *) getTrampoline1;
- (b2Body *) getTrampoline2;
-(void) checkTrampoline:(b2Body *)trampoline;

@end
