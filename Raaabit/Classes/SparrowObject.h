//
//  SparrowObject.h
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "SparrowObject.h"

@interface SparrowObject : CCSprite {
    bool _isStarted;
}

@property bool isStarted;

-(void) startAnimationFly;
-(void) startAnimationDeath;
-(void) startChirp;
-(void) Chirp;

@end
