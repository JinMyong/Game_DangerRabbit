//
//  DifficultyLayer.h
//  Raaabit
//
//  Created by Anna Valova on 1/9/14.
//  Copyright 2014 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <GameKit/GameKit.h>

@interface DifficultyLayer : CCLayer <GKLeaderboardViewControllerDelegate> {
    
}

+(CCScene *) scene;

-(void) showLeaderboard: (id) sender;

@end
