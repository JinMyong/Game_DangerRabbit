//
//  PauseLayer.h
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface PauseLayer : CCLayer {
    
}

+(CCScene *) scene;


-(void) replayHandler;
-(void) resumeHandler;
-(void) mainMenuHandler;

@end
