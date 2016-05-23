//
//  GroundObject.h
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "GameObject.h"

@interface GroundObject : GameObject {
    NSInteger groundType;
}

@property NSInteger groundType;


-(void) startAnimationSwing;
-(void) startAnimationIdleSwing;

@end
