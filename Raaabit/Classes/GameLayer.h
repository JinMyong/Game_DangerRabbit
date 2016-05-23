//
//  GameLayer.h
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright Dmitry Valov 2013. All rights reserved.
//


//#import <GameKit/GameKit.h>

#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "CocosDenshion.h"

#import "ContactListener.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32.0f

#define kLevelStateInProgress   1
#define kLevelStateComplete     2
#define kLevelStateFailed       3

#define kHudLayerTag    10001
#define kGameLayerTag   10002

@class HeroObject;
@class CannonObject;
@class GunObject;

@interface GameLayer : CCLayer
{
	CCTexture2D     *spriteTexture_;	// weak ref
	b2World         *world;				// strong ref
	GLESDebugDraw   *m_debugDraw;		// strong ref
    ContactListener *contactListener;
    CCNode          *coinsCounterNode;
    NSInteger       collectedCarrots;
    GunObject       *currGun;
    
    NSInteger       cameraState;
    
    

    NSMutableArray  *_listOfCoins;
    NSMutableArray  *_listOfBonuses;
    NSMutableArray  *_listOfPlatforms;
    NSMutableArray  *_listOfEnemies;
    NSMutableArray  *_listOfHints;
    NSMutableArray  *_listOfBombs;
    
    NSDictionary    *typicalObjects;
    
    NSInteger       levelScores;
    NSInteger       enemiesBonus;

    CGPoint         goalPos;
    CGPoint         firstTouch;
    CGPoint         secondTouch;
    bool            wasFirstTouch;
    bool            isStickyTrampoline;
    float           trampolineAngle;
    float           trampolinePower;
    NSInteger       usedTrampolines;
    
    NSInteger       levelState;
    NSInteger       levelWidth;
    NSInteger       levelHeight;
    
    HeroObject      *_hero;
    
    b2Body          *groundBody;
    
    b2Body          *currTrampoline;
    b2Body          *bombTrampoline1;
    b2Body          *bombTrampoline2;
    
    NSInteger       availableTrampolines;
    NSInteger       stickyTrampolines;
    NSInteger       purpleTrampolines;
    NSInteger       shieldsCount;
    NSInteger       bombsCount;
    bool            needUpdateTrampolines;
    CGSize          screenSize;
    
    CCSprite        *bg;

    bool            wasLevelUpdated;
    
    bool            isMenuShown;
    bool            isGameStarted;
    bool            isLevelShown;
    bool            isHintShown;
    bool            isHintAnimatedShown;
    bool            isGoalAnimated;
    
    CDSoundSource   *loopBeeSound;
    bool            isBeeExist;
    CDSoundSource   *loopBirdSound;
    bool            isBirdExist;
    CDSoundSource   *loopAirSound;
    bool            isAirExist;
    
    CGPoint         endTrampoline;
    CGPoint         prevPoint1;
    CGPoint         prevPoint2;
    CGPoint         crossPoint;
    NSDate          *prevTime;
    
    float           levelTimer;
    NSInteger       coinNumber;
    
    bool            isShoting;
    float           shotDelay;
    bool            isBulletsExist;
    NSMutableArray  *_listOfBullets;
    NSMutableArray  *_listOfSparrows;
    NSString        *objNameGoal;
    
    float           massHero;
    NSInteger       currAnimationID;
}

@property (nonatomic, retain) NSMutableArray  *listOfCoins;
@property (nonatomic, retain) NSMutableArray  *listOfBonuses;
@property (nonatomic, retain) NSMutableArray  *listOfPlatforms;
@property (nonatomic, retain) NSMutableArray  *listOfEnemies;
@property (nonatomic, retain) NSMutableArray  *listOfHints;
@property (nonatomic, retain) NSMutableArray  *listOfBombs;
@property (nonatomic, retain) NSMutableArray  *listOfBullets;
@property (nonatomic, retain) NSMutableArray  *listOfSparrows;

@property (nonatomic, retain) HeroObject      *hero;


@property (nonatomic, retain) NSDate          *prevTime;

@property bool isMenuShown;

+(CCScene *) scene;

-(void) loadLevel: (NSInteger) levelNum;
-(void) nextLevel;
-(void) showFailedLevel;
-(void) showResultsLevel;
-(void) restartLevel;
-(void) levelComplete;

-(NSInteger) createTrampolineObject: (CGPoint) pos1 pos2: (CGPoint) pos2 withType: (NSInteger) type;
-(void) createGoalObject: (CGPoint) pos;
-(void) createHeroObject: (CGPoint) pos;
-(void) createGround: (CGPoint) pos withType: (NSInteger) type withAngle: (NSInteger) angle;
-(void) createCannon: (CGPoint) pos;
-(void) createGun: (CGPoint) pos withParam1: (NSInteger) p1 withParam2: (NSInteger) p2 withParam3: (NSInteger) p3;
-(void) createBoulder: (CGPoint) pos withType: (NSInteger) type;
-(void) createBomb: (CGPoint) pos;
-(void) createEnemy: (CGPoint) pos withType: (NSInteger) type withAmplitude: (NSInteger) ampl;
-(void) createAirduct: (CGPoint) pos withType: (NSInteger) type withAngle: (NSInteger) angle withParam1: (NSInteger) param1;
-(void) loadCannon: (CannonObject *) cannon;
-(void) loadGun: (GunObject *) gun;
-(void) loadGunPart2;
-(void) createSparrows;
-(void) createBGObject: (CGPoint) pos withRotation: (NSInteger) angle withType: (NSInteger) type;
-(void) createHint: (CGPoint) pos withRotation: (NSInteger) angle withType: (NSInteger) type withMove: (NSInteger) move;
-(void) removeHints;
-(void) createBonus: (CGPoint) pos withType: (NSInteger) type;
-(void) checkBonuses;
-(void) updateLivesCount;
-(void) updateTrampolinesCount;
-(void) updateTrampolinesStickCount;
-(void) updateTrampolinesPurpleCount;
-(void) updateCamera: (ccTime) dt;
-(void) deadRabit;
-(void) showContinueScreen;
-(void) showReviveScreenWithDelay;
-(void) showReviveScreen;
-(void) showLevel;
-(void) endShowLevel;
-(void) saveHero;
-(void) checkPlatforms;
-(void) checkBees;
-(void) checkBird;
-(bool) checkCrossForPoint1: (CGPoint) start1
                  endPoint1: (CGPoint) end1
                     Point2: (CGPoint) start2
                  endPoint2: (CGPoint) end2;
-(void) explodeEnemies: (id) sender;
-(void) removeNode: (id) sender;
-(void) startRaabit;
-(void) add10Planks;
-(void) continueGame;

-(void) moveBullets: (float) dt;
-(void) showCollectedBonuseEffectWithType: (NSInteger) type withPos: (CGPoint) pos;

-(void) showHintAnimationWithType: (NSInteger) type;
-(void) createHintAnimationNormal;
-(void) createHintAnimationSticky;
-(void) createHintAnimationSuper;
-(void) activateButton: (id) sender;
-(void) hideHintAnimation;
-(void) restartHintAnimation;

-(void) createCoin: (CGPoint) pos;
-(void) checkCoins;
-(bool) addCollectedCarrot;
-(void) removeCollectedCarrot;

-(b2Vec2) getTrajectoryPoint:(b2Vec2) startingPosition andStartVelocity:(b2Vec2) startingVelocity andSteps: (float)n;

@end