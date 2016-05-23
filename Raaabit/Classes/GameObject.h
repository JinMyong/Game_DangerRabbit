//
//  GameObject.h
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright Dmitry Valov 2013. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"

#define kStateNewObject			1
#define kStateGoalAchieved      2
#define kStateNeedRemove        3
#define kStateNeedLoad          4
#define kStateNeedShoot         5
#define kStateNeedDead          6
#define kStateNeedSwing         7
#define kStateSticked           8
#define kStateInGun             9
#define kStateNeedLoadInGun     10
#define kStateInShoot           11
#define kStateNeedRemoveBoulder 12
#define kStateLoadingInGun      13

@interface GameObject: CCSprite 
{
	NSInteger	state;
    NSInteger   preState;
	NSInteger	typeOfObject;
    NSInteger   objectID;
    b2Body      *_body;
}

@property (nonatomic, assign) NSInteger typeOfObject;
@property (nonatomic, assign) NSInteger state;
@property NSInteger objectID;

- (void) removeObject;
- (void) fadeRemoveObject;
- (void) setState: (NSInteger) newState withDelay: (float) delay;
- (void) updateState;
- (void) setBody: (b2Body *) body;
- (b2Body *) getBody;

@end
