//
//  BulletObject.h
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "GameObject.h"

@interface BulletObject : CCSprite {
    float _speedX;
    float _speedY;
}

@property float speedX;
@property float speedY;

@end
