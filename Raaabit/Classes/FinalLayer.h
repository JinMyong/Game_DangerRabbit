//
//  FinalLayer.h
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface FinalLayer : CCLayer {
}

+(CCScene *) scene;

-(void) mainMenuHandler;
-(void) facebookHandler;
-(void) rateHandler;
-(void) emailHandler;

@end
