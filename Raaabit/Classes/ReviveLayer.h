//
//  ReviveLayer.h
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MyPopupLayer.h"

@interface ReviveLayer : MyPopupLayer <UIAlertViewDelegate>{
    
}

+(CCScene *) scene;

-(void) closeHandler;
-(void) facebookHandler;
-(void) buyHandler;
-(void) friendInvited;

@end
