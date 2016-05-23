//
//  TurtleObject.h
//  Raaabit
//
//  Created by Dmitry Valov on 01.08.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "EnemyObject.h"

@interface TurtleObject : EnemyObject {
    float       pause;
}

-(void) startAnimationWalk;
-(void) updateHorizontalSpeed: (ccTime) dt;

@end
