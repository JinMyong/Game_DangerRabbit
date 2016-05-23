//
//  BulletMeter.h
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define kBulletMeterStateShooting   1
#define kBulletMeterStateRest       2


@interface BulletMeter : CCNode {
    CCSprite *background;
    NSMutableArray *listOfBullets_;
    float delay;
}

@property (nonatomic, retain) NSMutableArray *listOfBullets;

- (bool) update: (ccTime) dt withState: (NSInteger) state;

@end
