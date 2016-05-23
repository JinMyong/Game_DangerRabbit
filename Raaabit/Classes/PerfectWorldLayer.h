//
//  PerfectWorldLayer.h
//  Raaabit
//
//  Created by Anna Valova on 11/18/13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MyPopupLayer.h"

@interface PerfectWorldLayer : MyPopupLayer {
    bool needLockAnimation;
}

@property bool needLockAnimation;

+(CCScene *) scene;

-(void) closeHandler;

@end
