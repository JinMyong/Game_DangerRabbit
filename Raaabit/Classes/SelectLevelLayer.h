//
//  SelectLevelLayer.h
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <GameKit/GameKit.h>

@interface SelectLevelLayer : CCLayer <GKLeaderboardViewControllerDelegate> {
    CCMenu *levelMenu;
    CCMenuItemSprite *backItem;
    CCMenuItemSprite *forwardItem;
    NSInteger   currPage;
    bool        isInProgress;
}

+(CCScene *) scene;

-(void) startLevel: (CCMenuItemLabel *) item;
-(void) backHandler;
-(void) showNextItem;
-(void) hideNextItem;
-(void) leaderboardsHandler;

@end
