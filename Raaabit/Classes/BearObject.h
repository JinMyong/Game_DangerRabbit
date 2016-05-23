//
//  BearObject.h
//  Raaabit
//
//  Created by Dmitry Valov on 01.08.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "EnemyObject.h"

@interface BearObject : EnemyObject {
    bool        isInRoar;
    NSInteger   livesCount;
    float       pause;
    bool        isLoseLife;
}

@property bool isInRoar;
@property NSInteger livesCount;

-(void) startAnimationWalk;
-(void) startAnimationRoar;
-(void) startAnimationHited;
-(void) endRoar;
-(bool) loseLife;
-(void) endLifeDelay;
-(void) updateHorizontalSpeedWithHeroPosition: (CGPoint) pos;

@end
