//
//  MainMenuLayer.h
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MainMenuLayer : CCLayer <UIAlertViewDelegate> {
    CCMenuItem *itemServer;
    CCMenuItem *itemLocal;
    
    bool m_postingInProgress;
}

+(CCScene *) scene;

-(void) playHandler;
-(void) optionsHandler;
-(void) storeHandler;
-(void) facebookHandler;

-(void) postWithText: (NSString*) message
           ImageName: (NSString*) image
                 URL: (NSString*) url
             Caption: (NSString*) caption
                Name: (NSString*) name
      andDescription: (NSString*) description;
-(void) postToWall: (NSMutableDictionary*) params;

@end
