//
//  CutScenes2Layer.h
//  Raaabit
//
//  Created by Anna Valova on 11/21/13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CutScenes2Layer : CCLayer {
    float interval; 
    int idx;
    CCSprite *currentScene;
}

+(CCScene *) scene;

@end
