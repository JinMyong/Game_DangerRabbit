//
//  SelectAreaLayer.h
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface SelectAreaLayer : CCLayer {
    CCMenu      *areasMenu;
    
    CCSprite    *spriteForAnimation;
    NSInteger   worldForAnimation;
}

+(CCScene *) scene;

-(void) startArea: (CCMenuItemLabel *) item;
-(void) backHandler;
-(void) showAlertForArea;
-(void) removeNode: (id) sender;
-(void) showLockAnimation;

@end
