//
//  GameLayer.mm
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright Dmitry Valov 2013. All rights reserved.
//

#import "HUDLayer.h"
#import "GameLayer.h"
#import "CCPhysicsSprite.h"

#import "AppDelegate.h"
#import "GB2ShapeCache.h"
#import "Reachability.h"

#import "Constants.h"
#import "GameObject.h"
#import "HeroObject.h"
#import "GoalObject.h"
#import "GroundObject.h"
#import "CoinObject.h"
#import "BombObject.h"
#import <GunObject.h>
#import "BonusObject.h"
#import "EnemyObject.h"
#import "TrampolineObject.h"
#import "CannonObject.h"
#import "GameProgressController.h"
#import "LevelCompleteLayer.h"
#import "ContinueLayer.h"
#import "BearObject.h"
#import "TurtleObject.h"
#import "AirductObject.h"
#import "SimpleAudioEngine.h"
#import "ReviveLayer.h"
#import "GameController.h"
#import "LevelFailedLayer.h"
#import "BulletObject.h"
#import "SparrowObject.h"
#import "SelectLevelLayer.h"
#import "MyMenuItemSprite.h"
#import "Util.h"

#import "AdTapsy.h"         // Added By Hans

#define zBGObject       1
#define zGround         2
#define zGoal           10
#define zEnemy          11
#define zGun            17
#define zHero           18
#define zCannon         20
#define zTrampoline     16
#define zBomb           25
#define zHint           35

#define kTagGoal            20001
#define kHintAnimationTag   20002
#define kDotSpriteTag       20003
#define kEmptyTag           20004

#define kAnimationNormal    1
#define kAnimationSticky    2
#define kAnimationSuper     3

enum {
	kTagParentNode = 1,
};

inline b2Vec2 toRatio(CGPoint value) {
	return b2Vec2(value.x / PTM_RATIO, value.y / PTM_RATIO);
}

inline CGPoint fromRatio(b2Vec2 value) {
	return ccp(value.x * PTM_RATIO, value.y * PTM_RATIO);
}

inline float32 toRatio(float32 value) {
	return value / PTM_RATIO;
}

inline float32 toRatioY(float32 value) {
	return (kScreenHeight - value) / PTM_RATIO;
}

inline float32 fromRatio(float32 value) {
	return value * PTM_RATIO;
}

#pragma mark - HelloWorldLayer

@interface GameLayer()
-(void) initPhysics;
@end

@implementation GameLayer

@synthesize listOfCoins = _listOfCoins;
@synthesize listOfBonuses = _listOfBonuses;
@synthesize listOfPlatforms = _listOfPlatforms;
@synthesize listOfEnemies = _listOfEnemies;
@synthesize listOfHints = _listOfHints;
@synthesize listOfBombs = _listOfBombs;
@synthesize listOfBullets = _listOfBullets;
@synthesize listOfSparrows = _listOfSparrows;
@synthesize hero = _hero;

@synthesize isMenuShown;
@synthesize prevTime;

+(CCScene *) scene {
	CCScene *scene = [CCScene node];

	HUDLayer *hl = [HUDLayer node];
	[scene addChild: hl z:2 tag:kHudLayerTag];

	GameLayer *gl = [GameLayer node];
	[scene addChild: gl z:1 tag:kGameLayerTag];

	 
    return scene;
}

-(id) init {
	if( (self=[super init])) {
        
    // Added By Hans_1127 for pushnotification
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    // Add End_1127
        
        screenSize = [CCDirector sharedDirector].winSize;
		// enable events
		self.touchEnabled = YES;
		self.accelerometerEnabled = YES;
        self.isMenuShown = NO;

        wasFirstTouch = NO;
        availableTrampolines = 5;
        
        coinsCounterNode = [CCNode node];
        [coinsCounterNode setPosition:ccp(-100, -100)];
        [self addChild:coinsCounterNode];
        
        _listOfCoins = [[NSMutableArray alloc] init];
        _listOfBonuses = [[NSMutableArray alloc] init];
        _listOfPlatforms = [[NSMutableArray alloc] init];
        _listOfEnemies = [[NSMutableArray alloc] init];
        _listOfHints = [[NSMutableArray alloc] init];
        _listOfBombs = [[NSMutableArray alloc] init];
        _listOfBullets = [[NSMutableArray alloc] init];
        _listOfSparrows = [[NSMutableArray alloc] init];

		[self initPhysics];
		
        AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
        [self loadLevel:appDelegate.currLevel];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(add10Planks)
                                                     name:kAdd10PlanksNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(continueGame)
                                                     name:kContinueGameNotification
                                                   object:nil];

        [self scheduleUpdate];
	}
	return self;
}

-(void) dealloc {
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
	
    [_listOfCoins release];
    [_listOfBonuses release];
    [_listOfPlatforms release];
    [_listOfEnemies release];
    [_listOfHints release];
    [_listOfBombs release];
    [_listOfBullets release];
    [_listOfSparrows release];
    
	[super dealloc];
}	

-(void)onEnter {
    [self checkBird];
    [self checkBees];
    [super onEnter];
}

-(void)onExit {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    if(isBeeExist) {
        [loopBeeSound stop];
        [loopBeeSound release];
        loopBeeSound = nil;
    }
    if(isAirExist) {
        [loopAirSound stop];
        [loopAirSound release];
        loopAirSound = nil;
    }
    if(isBirdExist) {
        [loopBirdSound stop];
        [loopBirdSound release];
        loopBirdSound = nil;
    }
    
    [typicalObjects release];
    [self.prevTime release];
	[super onExit];
}

-(void) initPhysics {
	b2Vec2 gravity;
	gravity.Set(0.0f, -8.0f * kFactor);
	world = new b2World(gravity);
	
	// Do we want to let bodies sleep?
	world->SetAllowSleeping(true);
	
	world->SetContinuousPhysics(true);
	
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	world->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
//	flags += b2Draw::e_shapeBit;
//  flags += b2Draw::e_jointBit;
//	flags += b2Draw::e_aabbBit;
//	flags += b2Draw::e_pairBit;
//	flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);
	
    contactListener = new ContactListener();
//    contactListener->gameLayer = self;
    world->SetContactListener(contactListener);

	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
    
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	groundBody = world->CreateBody(&groundBodyDef);
}

-(void) draw {
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
	//
	[super draw];
	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
	
	world->DrawDebugData();	
	
	kmGLPopMatrix();
}

-(void) update: (ccTime) dt {
    //dt *= 2;
    if(!wasLevelUpdated) {
        HUDLayer *hl = (HUDLayer *)[self.parent getChildByTag:kHudLayerTag];
        [hl updateCoins:[GameController sharedGameCtrl].collectedCoins withTotal:[GameController sharedGameCtrl].totalCoins];
        wasLevelUpdated = YES;
    }
    
    if(!isLevelShown) {
        return;
    }

    if(self.hero.state == kStateInGun) {
        HUDLayer *hl = (HUDLayer *)[self.parent getChildByTag:kHudLayerTag];
        if(isShoting) {
            isBulletsExist = [hl.bulletMeterNode update:dt withState:kBulletMeterStateShooting];
        }
        else {
            isBulletsExist = [hl.bulletMeterNode update:dt withState:kBulletMeterStateRest];
        }
    }
    
    if(needUpdateTrampolines) {
        [self updateTrampolinesCount];
        [self updateTrampolinesStickCount];
        [self updateTrampolinesPurpleCount];
        [self updateBombsCount];
        needUpdateTrampolines = NO;
        
//        if(!_hero.isGoalAvailable) {
//            if([[GameController sharedGameCtrl] countLevelStars] >= 2) {
//                _hero.isGoalAvailable = YES;
//                GoalObject *go = (GoalObject *)[self getChildByTag:kTagGoal];
//                [go startAnimationGoal];
//            }
//        }
    }
    
    if(levelWidth > screenSize.width || levelHeight > screenSize.height) {
        [self updateCamera:dt];
    }

    if(isHintShown) {
        return;
    }
    
    if(levelState != kLevelStateInProgress || self.isMenuShown || !isGameStarted) {
        return;
    }
    
    [self moveBullets:dt];

    if(isShoting) {
        shotDelay += dt;
        if(shotDelay >= 0.2f && isBulletsExist) {
            [_hero.gun shot];
            shotDelay = 0.0f;
        }
    }

    [self checkBees];
    [self checkSparrows];
    [self checkBird];

    levelTimer += dt;
    
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
    
    //Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext()) {
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			GameObject *myActor = (GameObject*)b->GetUserData();
            bool needMove = YES;
            
            if(myActor.typeOfObject == kTypeBoulder) {
                b2Vec2 speed = b->GetLinearVelocity();
                float speedLimit = kSpeedLimit * 0.91f;
                if(kFactor > 1.0f) {
                    speedLimit *= 1.08f;
                }
                
                if(speed.y < -speedLimit) {
                    speed.x = speed.x * -speedLimit / speed.y;
                    speed.y = -speedLimit;
                    b->SetLinearVelocity(speed);
                }
                else if(speed.y > speedLimit) {
                    speed.x = speed.x * speedLimit / speed.y;
                    speed.y = speedLimit;
                    b->SetLinearVelocity(speed);
                }
                if(speed.x < -speedLimit) {
                    speed.y = speed.y * -speedLimit / speed.x;
                    speed.x = -speedLimit;
                    b->SetLinearVelocity(speed);
                }
                else if(speed.x > speedLimit) {
                    speed.y = speed.y * speedLimit / speed.x;
                    speed.x = speedLimit;
                    b->SetLinearVelocity(speed);
                }
            }
            else if(myActor.typeOfObject == kTypeHero) {
                if(myActor.state == kStateSticked) {
                    continue;
                }
                else if(myActor.state == kStateNeedLoad) {
                    [self loadCannon:_hero.cannon];
                    needMove = NO;
                }
                else if(myActor.state == kStateNeedLoadInGun) {
                    cameraState = kStateNeedLoadInGun;
                    [self loadGun:_hero.gun];
                    needMove = NO;
                }
                else if(myActor.state == kStateNeedShoot || myActor.state == kStateInGun || myActor.state == kStateLoadingInGun) {
                    needMove = NO;
                }
                
                if(myActor.position.y < -50 * kFactor) {
                    if(availableTrampolines <= 0 && levelTimer >= 16.0f) {
                        [[SimpleAudioEngine sharedEngine] playEffect:@"FallOff.mp3"];
                        [self showReviveScreen];
                    }
                    else {
                        AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
                        [appDelegate logLoseLevel:appDelegate.currLevel withReason:@"Run out of planks"];
                        levelState = kLevelStateFailed;
                        [[SimpleAudioEngine sharedEngine] playEffect:@"FallOff.mp3"];
                        [self showFailedLevel];
                        break;
                    }
                }
                else if(myActor.state == kStateNeedDead) {
                    levelState = kLevelStateFailed;
                    [self deadRabit];
                    break;
                }
                
                b2Vec2 speed = b->GetLinearVelocity();
                float speedLimit = kSpeedLimit * _hero.speedFactor;
                if(kFactor > 1.0f) {
                    speedLimit *= 1.08f;
                }
                
                if(speed.y < -speedLimit) {
                    speed.x = speed.x * -speedLimit / speed.y;
                    speed.y = -speedLimit;
                    b->SetLinearVelocity(speed);
                }
                else if(speed.y > speedLimit) {
                    speed.x = speed.x * speedLimit / speed.y;
                    speed.y = speedLimit;
                    b->SetLinearVelocity(speed);
                }
                if(speed.x < -speedLimit) {
                    speed.y = speed.y * -speedLimit / speed.x;
                    speed.x = -speedLimit;
                    b->SetLinearVelocity(speed);
                }
                else if(speed.x > speedLimit) {
                    speed.y = speed.y * speedLimit / speed.x;
                    speed.x = speedLimit;
                    b->SetLinearVelocity(speed);
                }
                
                if(![((HeroObject *)myActor) isStarted]) {
                    continue;
                }
                else if([((HeroObject *)myActor) isOnTheGround]) {
                    if(((HeroObject *)myActor).moveType == kMoveRight) {
                        if(((HeroObject *)myActor).isRun) {
                            b->SetLinearVelocity(b2Vec2(kRabitSpeed * 2.5f, 0));
                        }
                        else {
                            b->SetLinearVelocity(b2Vec2(kRabitSpeed, 0));
                        }
                        [myActor setFlipX:NO];
                    }
                    else if (myActor.state != kStateNeedLoadInGun && myActor.state != kStateInGun && myActor.state != kStateLoadingInGun) {
                        b->SetLinearVelocity(b2Vec2(-kRabitSpeed, 0));
                        [myActor setFlipX:YES];
                    }
                }
                else {
                    if(b->GetLinearVelocity().x < 0) {
                        ((HeroObject *)myActor).moveType = kMoveLeft;
                    }
                    else {
                        ((HeroObject *)myActor).moveType = kMoveRight;
                    }
                }
                if(isAirExist) {
                    if([((HeroObject *)myActor) isInAirFlow]) {
                        [loopAirSound setPitch:1.0f];
                        b->ApplyForceToCenter(b2Vec2(70.0f * kFactor * kFactor * sinf(CC_DEGREES_TO_RADIANS(_hero.flowAngle + 90)),
                                                     70.0f * kFactor * kFactor * cosf(CC_DEGREES_TO_RADIANS(_hero.flowAngle + 90))));
                        [_hero updateFlowCounter:dt];
                    }
                    else {
                        [loopAirSound setPitch:0.0f];
                    }
                }
                if(myActor.state == kStateGoalAchieved) {
                        levelState = kLevelStateComplete;
                        [self levelComplete];
                }
            }
            else if(myActor.typeOfObject == kTypeTrampoline) {
                if(myActor.state == kStateNeedRemove || myActor.state == kStateNeedRemoveBoulder) {
                    for(NSUInteger i = 0; i < [_listOfBombs count]; ++i) {
                        BombObject *currBomb = (BombObject *)[_listOfBombs objectAtIndex:i];
                        [currBomb checkTrampoline:b];
                    }
                    
                    if(b == bombTrampoline2) {
                        self.prevTime = [[NSDate date] dateByAddingTimeInterval:-200];
                        bombTrampoline2 = nil;
                    }
                    else if(b == bombTrampoline1) {
                        self.prevTime = [[NSDate date] dateByAddingTimeInterval:-200];
                        bombTrampoline1 = nil;
                    }

                    if(myActor.state == kStateNeedRemove && stickyTrampolines > 0 && b == currTrampoline) { //Sticky
                        isStickyTrampoline = YES;
                        --stickyTrampolines;
                        --availableTrampolines;
                        ++usedTrampolines;
                        [self updateTrampolinesStickCount];
                        [self updateTrampolinesCount];
                        
                        currTrampoline = nil;
                        world->DestroyBody(b);
                        [myActor removeFromParentAndCleanup:YES];
                        
                        world->DestroyBody([_hero getBody]);
                        
                        [_hero stopAllActions];
                        _hero.state = kStateSticked;
                        [[SimpleAudioEngine sharedEngine] playEffect:@"StickPlatform.mp3"];
                        [self createTrampolineObject:firstTouch pos2:secondTouch withType:kTrampolineSticky];
                        continue;
                    }
                    else {
                        if(b == currTrampoline) {
                            currTrampoline = nil;
                            wasFirstTouch = NO;
                            --availableTrampolines;
                            ++usedTrampolines;
                            [self updateTrampolinesCount];
                        }
                        [_hero startAnimationJump];
                        world->DestroyBody(b);
                        [(TrampolineObject *)myActor startAnimationSwing];
                        continue;
                    }
                }
                needMove = NO;
            }
            else if(myActor.typeOfObject == kTypePlatform) {
                if(myActor.state == kStateNeedSwing) {
                    [(GroundObject *)myActor startAnimationSwing];
                    myActor.state = kStateNewObject;
                    continue;
                }
                needMove = NO;
            }            
            else if(myActor.typeOfObject == kTypeEnemy) {
                EnemyObject *eo = (EnemyObject *)myActor;
                if(eo.state == kStateNeedDead) {
                    levelScores += 100;
                    HUDLayer *hl = (HUDLayer *)[self.parent getChildByTag:kHudLayerTag];
                    [hl updateScores:levelScores];
                    enemiesBonus += 100;
                    [self showCollectedBonuseEffectWithType:100 withPos:myActor.position];
                    [[SimpleAudioEngine sharedEngine] playEffect:@"DefeatEnemy.mp3"];
                    world->DestroyBody(b);
                    [_listOfEnemies removeObject:eo];
                    id action = [CCSequence actions:
                                 [CCSpawn actions:
                                  [CCMoveBy actionWithDuration:1.5f position:ccp(0.0f, -screenSize.height)],
                                  [CCRotateBy actionWithDuration:1.5f angle:720.0f],
                                  nil],
                                 [CCCallFunc actionWithTarget:eo selector:@selector(removeObject)],
                                 nil];
                    [eo runAction:action];
                    [self checkBees];
                    [self checkBird];
                }
                else if(eo.enemyType == kEnemyBear) {
                    [(BearObject *)eo updateHorizontalSpeedWithHeroPosition: _hero.position];
                }
                else if(eo.enemyType == kEnemyTurtle) {
                    [(TurtleObject *)eo updateHorizontalSpeed:dt];
                }
                else if(eo.enemyType == kEnemyBird) {
                    [eo updateHorizontalSpeed];
                }
                else {
                    [eo updateSpeed];
                }
            }
            if(needMove) {
                myActor.position = CGPointMake(fromRatio(b->GetPosition().x), fromRatio(b->GetPosition().y));
                myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            }
		}
	}
    [self checkCoins];
    [self checkBonuses];
}

#pragma mark -
#pragma mark Touches

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(isHintAnimatedShown) {
        return;
    }
    if(isHintShown && isLevelShown) {
        [self removeHints];
        return;
    }

    if(self.isMenuShown || !isGameStarted || !isLevelShown) {
        return;
    }
    
	for(UITouch *touch in touches) {
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
        location = [self convertToNodeSpace:location];
        firstTouch = location;
        secondTouch = location;
        if(_hero.state == kStateNeedShoot) {
            [_hero.cannon setTargetPosition:location];
            
            CCSprite *dotSprite = nil;
            NSInteger idx = 1;

            for(NSUInteger i = 3; i < 120; ++i) {
                CannonObject *co = _hero.cannon;
                b2Vec2 speed = b2Vec2(100.0f * sinf(CC_DEGREES_TO_RADIANS([co getAngle] + 90)) * kFactor * kFactor / massHero,
                                      100.0f * cosf(CC_DEGREES_TO_RADIANS([co getAngle] + 90)) * kFactor * kFactor / massHero);
                float speedLimit = kSpeedLimit;
                
                if(speed.y < -speedLimit) {
                    speed.x = speed.x * -speedLimit / speed.y;
                    speed.y = -speedLimit;
                }
                else if(speed.y > speedLimit) {
                    speed.x = speed.x * speedLimit / speed.y;
                    speed.y = speedLimit;
                }
                if(speed.x < -speedLimit) {
                    speed.y = speed.y * -speedLimit / speed.x;
                    speed.x = -speedLimit;
                }
                else if(speed.x > speedLimit) {
                    speed.y = speed.y * speedLimit / speed.x;
                    speed.x = speedLimit;
                }
                
                //Magic
                speed.y += 1.18f;
                if([[Util sharedUtil] isiPad]) {
                    speed.y += 0.63f;
                }
                
                b2Vec2 point1 = [self getTrajectoryPoint:[_hero getBody]->GetPosition() andStartVelocity:speed andSteps:i];
                i += 7;
                
                NSString *dotSpriteName = [NSString stringWithFormat:@"circle%ld.png", (long)idx];
                idx += 1;
                if(idx > 4) {
                    idx = 1;
                }
                dotSprite = [CCSprite spriteWithSpriteFrameName:dotSpriteName];
                [dotSprite setScale:0.5f];
                [dotSprite setOpacity:210.0f];
                [dotSprite setPosition:ccp(fromRatio(point1.x), fromRatio(point1.y))];
                [self addChild:dotSprite z:zHero - 1 tag:kDotSpriteTag];
            }
        }
        else if(_hero.state == kStateInGun) {
            [_hero.gun setTargetPosition:location];
            isShoting = YES;
            [_hero.gun shot];
            shotDelay = 0.0f;
        }
        else if(_hero.state == kStateLoadingInGun) {
            
        }
        else {
            wasFirstTouch = YES;
        }
	}
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(isHintAnimatedShown) {
        return;
    }
    if(self.isMenuShown || !isGameStarted) {
        return;
    }
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
        location = [self convertToNodeSpace:location];
        secondTouch = location;
        
        if(_hero.state == kStateNeedShoot) {
            [_hero.cannon setTargetPosition:location];
            
            CCSprite *dotSprite = (CCSprite *)[self getChildByTag:kDotSpriteTag];
            NSInteger idx = 1;
            while (dotSprite) {
                [dotSprite removeFromParentAndCleanup:YES];
                dotSprite = (CCSprite *)[self getChildByTag:kDotSpriteTag];
            }
            
            for(NSUInteger i = 3; i < 120; ++i) {
                CannonObject *co = _hero.cannon;
                b2Vec2 speed = b2Vec2(100.0f * sinf(CC_DEGREES_TO_RADIANS([co getAngle] + 90)) * kFactor * kFactor / massHero,
                                      100.0f * cosf(CC_DEGREES_TO_RADIANS([co getAngle] + 90)) * kFactor * kFactor / massHero);
                float speedLimit = kSpeedLimit;
                
                if(speed.y < -speedLimit) {
                    speed.x = speed.x * -speedLimit / speed.y;
                    speed.y = -speedLimit;
                }
                else if(speed.y > speedLimit) {
                    speed.x = speed.x * speedLimit / speed.y;
                    speed.y = speedLimit;
                }
                if(speed.x < -speedLimit) {
                    speed.y = speed.y * -speedLimit / speed.x;
                    speed.x = -speedLimit;
                }
                else if(speed.x > speedLimit) {
                    speed.y = speed.y * speedLimit / speed.x;
                    speed.x = speedLimit;
                }
                
                //Magic
                speed.y += 1.18f;
                if([[Util sharedUtil] isiPad]) {
                    speed.y += 0.63f;
                }
                
                b2Vec2 point1 = [self getTrajectoryPoint:[_hero getBody]->GetPosition() andStartVelocity:speed andSteps:i];
                i += 7;
                
                NSString *dotSpriteName = [NSString stringWithFormat:@"circle%ld.png", (long)idx];
                idx += 1;
                if(idx > 4) {
                    idx = 1;
                }
                dotSprite = [CCSprite spriteWithSpriteFrameName:dotSpriteName];
                [dotSprite setScale:0.5f];
                [dotSprite setOpacity:210.0f];
                [dotSprite setPosition:ccp(fromRatio(point1.x), fromRatio(point1.y))];
                [self addChild:dotSprite z:zHero - 1 tag:kDotSpriteTag];
            }
        }
        else if(_hero.state == kStateInGun) {
            [_hero.gun setTargetPosition:location];
        }
        else if(_hero.state == kStateLoadingInGun) {
            
        }
        else {
            if(wasFirstTouch) {
                if(isStickyTrampoline) {
                    [self createTrampolineObject:firstTouch pos2:location withType:kTrampolineSticky];
                }
                else {
                    [self createTrampolineObject:firstTouch pos2:location withType:kTrampolineRegular];
                }
            }
        }
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(isHintAnimatedShown) {
        return;
    }
    if(!isGameStarted && !isLevelShown) {
        [self stopAllActions];
        [bg stopAllActions];
        [self endShowLevel];
        [self updateCamera:1.0f / 12.0f];
    }
    else if(self.isMenuShown) {
        return;
    }
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
        location = [self convertToNodeSpace:location];
        secondTouch = location;
        
        if(_hero.state == kStateSticked) {
            isStickyTrampoline = NO;
            if(currTrampoline != nil) {
                GameObject *to = (GameObject*)currTrampoline->GetUserData();
                [(TrampolineObject *)to startAnimationStickSwing];
                world->DestroyBody(currTrampoline);
                currTrampoline = nil;
            }
            CGPoint heroPos = _hero.position;
            [_hero stopAllActions];
            [_hero removeFromParentAndCleanup:YES];
            
            [self createHeroObject:heroPos];
            [_hero setIsStarted:YES];
            b2Body *heroBody = [_hero getBody];
            
            heroBody->ApplyLinearImpulse(b2Vec2(trampolinePower * 70.0f * sinf(CC_DEGREES_TO_RADIANS(trampolineAngle)) * kFactor * kFactor,
                                                trampolinePower * 70.0f * cosf(CC_DEGREES_TO_RADIANS(trampolineAngle)) * kFactor * kFactor),
                                         heroBody->GetPosition());
            [_hero setState:kStateNewObject];
            [_hero stopAllActions];
            [_hero startAnimationFly];
        }
        else if(_hero.state == kStateNeedShoot) {
            [_hero.cannon setTargetPosition:location];
            [self shotCannon];
            
            CCSprite *dotSprite = (CCSprite *)[self getChildByTag:kDotSpriteTag];
            while (dotSprite) {
                [dotSprite setTag:kEmptyTag];
                id fadeAction = [CCSequence actions:
                                 [CCFadeOut actionWithDuration:1.0f],
                                 [CCCallFuncN actionWithTarget:self selector:@selector(removeNode:)],
                                 nil];
                [dotSprite runAction:fadeAction];
                dotSprite = (CCSprite *)[self getChildByTag:kDotSpriteTag];
            }
        }
        else if(_hero.state == kStateInGun) {
            isShoting = NO;
        }
        else if(_hero.state == kStateLoadingInGun) {
            
        }
        else {
            if(wasFirstTouch) {
                NSInteger result =  [self createTrampolineObject:firstTouch pos2:location withType:kTrampolineRegular];
                
                if(bombTrampoline2) {
                    bombTrampoline1 = bombTrampoline2;
                }
                if(currTrampoline) {
                    bombTrampoline2 = currTrampoline;
                }

                if(bombTrampoline2 && bombTrampoline1) {
                    [self checkCrossForPoint1:prevPoint1
                                    endPoint1:prevPoint2
                                       Point2:firstTouch
                                    endPoint2:endTrampoline];
                }
                self.prevTime = [NSDate date];

                prevPoint1 = firstTouch;
                prevPoint2 = endTrampoline;

                currTrampoline = nil;
                if(result == kTrampolineRegular) {
                    --availableTrampolines;
                    ++usedTrampolines;
                    [self updateTrampolinesCount];
                }
                else if(result == kTrampolinePurple) {
                    --purpleTrampolines;
                    --availableTrampolines;
                    ++usedTrampolines;
                    if(purpleTrampolines < 0) {
                        purpleTrampolines = 0;
                    }
                    [self updateTrampolinesPurpleCount];
                    [self updateTrampolinesCount];
                }
                wasFirstTouch = NO;
            }
        }
	}
}

#pragma mark -
#pragma mark Levels management

-(void) loadLevel: (NSInteger) levelNum {
    cameraState = kStateNewObject;
    self.prevTime = [NSDate date];
    prevPoint1 = ccp(-1, -1);
    prevPoint2 = ccp(-1, -1);
    crossPoint = ccp(-1, -1);
    levelTimer = 0.0f;
    usedTrampolines = 0;
    isLevelShown = NO;
    isGoalAnimated = NO;
    isHintAnimatedShown = NO;
    
    levelScores = 0;
    enemiesBonus = 0;
    [GameController sharedGameCtrl].totalCoins = 0;
    [GameController sharedGameCtrl].collectedCoins = 0;
    wasLevelUpdated = NO;

    availableTrampolines = 0;
    stickyTrampolines = 0;
    purpleTrampolines = 0;
    bombsCount = 0;
    
    isStickyTrampoline = NO;
    isBeeExist = NO;
    isAirExist = NO;
    coinNumber = 1;
    isShoting = NO;
    shotDelay = 0.0f;
    isBirdExist = NO;

    CCLOG(@"Level loaded");
    AppController *appDelegate = (AppController *)[UIApplication sharedApplication].delegate;
    
    GameController *gC = [GameController sharedGameCtrl];
    
    if(gC.planksCount > 0) {
        availableTrampolines += gC.planksCount;
    }
    if(gC.stickyPlanksCount > 0) {
        stickyTrampolines += gC.stickyPlanksCount;
        availableTrampolines += gC.stickyPlanksCount;
    }
    if(gC.superPlanksCount > 0) {
        purpleTrampolines += gC.superPlanksCount;
        availableTrampolines += gC.superPlanksCount;
    }
    if(gC.bombsCount > 0) {
        bombsCount += gC.bombsCount;
    }

    if(appDelegate.currArea > kAreasCount) {
        bg = [CCSprite spriteWithFile:@"bg1.jpg"];
    }
    else {
        bg = [CCSprite spriteWithFile:[NSString stringWithFormat:@"bg%ld.jpg", (long)appDelegate.currArea]];
    }
    [bg setAnchorPoint:CGPointZero];
    [bg setPosition:CGPointZero];
    [self addChild:bg z:-2];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"TypicalObjects" ofType:@"plist"];
    typicalObjects = [[NSDictionary alloc] initWithContentsOfFile:path];

	NSString *levelNameNumber = [NSString stringWithFormat:@"level%02ld", (long)levelNum];
    NSString *levelsFilename = @"Raaabit_Levels";
    //levelsFilename = @"Raaabit_LevelsTest"; //Test
    
    //  Levels loading mode
	NSDictionary *levelsList = nil;
	if(appDelegate.loadLevelsFromServer) {
        MyReachability *r = [MyReachability reachabilityForInternetConnection];
        NetworkStatus internetStatus = [r currentReachabilityStatus];
        if(internetStatus == NotReachable) {
            NSString *path = [[NSBundle mainBundle] pathForResource:levelsFilename ofType:@"plist"];
            levelsList = [[NSDictionary alloc] initWithContentsOfFile:path];
        }
        else {
            NSString *urlStr = [NSString stringWithFormat:@"%@/%@.plist?seedVar=%f", kLevelsURL, levelsFilename, (float)random()/RAND_MAX];
            NSURL *url = [NSURL URLWithString:urlStr];
            levelsList = [[NSDictionary alloc] initWithContentsOfURL:url];
        }
	}
	else {
		NSString *path = [[NSBundle mainBundle] pathForResource:levelsFilename ofType:@"plist"];
		levelsList = [[NSDictionary alloc] initWithContentsOfFile:path];
	}

    bool needErrorAlert = NO;
    if([levelsList count] <= 0) {
        needErrorAlert = YES;
    }

    NSDictionary *level = [levelsList objectForKey:levelNameNumber];
    if(!needErrorAlert && [level count] <= 0) {
        needErrorAlert = YES;
    }
    
    NSArray *lstOfObjects = [level objectForKey:@"Objects"];
    if(!needErrorAlert && [lstOfObjects count] <= 0) {
        needErrorAlert = YES;
    }
    
    if(needErrorAlert) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Failed to load level."
                                                            message:@"Try to restart level in pause menu."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    else {
        [gC clearPlanks];

        bool needCenterObject = NO;
        levelWidth = [[level objectForKey:@"LevelWidth"] intValue] * kFactor;
        if(levelWidth < kScreenWidth) {
            levelWidth = kScreenWidth;
            needCenterObject = YES;
        }
        
        bool needUpdateY = NO;
        levelHeight = [[level objectForKey:@"LevelHeight"] intValue];
        NSInteger originaLevelHeight = levelHeight;
        if(levelHeight <= 320) {
            needUpdateY = YES;
            levelHeight = kScreenHeight;
        }
        else if([[Util sharedUtil] isiPad] && levelHeight <= 384) {
            needUpdateY = YES;
            levelHeight = kScreenHeight;
        }
        else {
            levelHeight *= kFactor;
        }
        
        /*
         levelHeight = [[level objectForKey:@"LevelHeight"] intValue] * kFactor;
         if(levelHeight < kScreenHeight) {
         needUpdateY = YES;
         levelHeight = kScreenHeight;
         }
         else if([[Util sharedUtil] isiPad]) {
         levelHeight = kScreenHeight / 2.0f - (320 - levelHeight / kFactor);
         levelHeight *= kFactor;
         }
         */
        
        //Level border
        b2EdgeShape groundBox;
        b2Filter filter;
        filter.groupIndex = kGroupIndexNotGround;
        
        // top wall
        groundBox.Set(b2Vec2(0,levelHeight/PTM_RATIO), b2Vec2(levelWidth/PTM_RATIO,levelHeight/PTM_RATIO));
        groundBody->CreateFixture(&groundBox,0);
        // left wall
        groundBox.Set(b2Vec2(0,levelHeight/PTM_RATIO), b2Vec2(0,0));
        b2Fixture *fix2 = groundBody->CreateFixture(&groundBox,0);
        fix2->SetFilterData(filter);
        // right wall
        groundBox.Set(b2Vec2(levelWidth/PTM_RATIO,levelHeight/PTM_RATIO), b2Vec2(levelWidth/PTM_RATIO,0));
        b2Fixture *fix3 = groundBody->CreateFixture(&groundBox,0);
        fix3->SetFilterData(filter);
        
        for(unsigned int i = 0; i < [lstOfObjects count]; ++i) {
            NSArray *obj = (NSArray *)[lstOfObjects objectAtIndex:i];
            NSInteger type = [[obj objectAtIndex:0] intValue];
            
            NSArray *objData = [typicalObjects objectForKey:[NSString stringWithFormat:@"%ld", (long)type]];
            NSInteger group = [[objData objectAtIndex:3] intValue];
            
            NSInteger xPos = [[obj objectAtIndex:1] intValue];
            if(needCenterObject) {
                xPos = xPos - kEditorHalfWidth;
                xPos = kScreenCenterX + xPos * kFactor;
            }
            else {
                xPos *= kFactor;
            }
            
            NSInteger yPos = [[obj objectAtIndex:2] intValue];
            if(needUpdateY) {
                yPos = kScreenHeight / kFactor - (originaLevelHeight - yPos);
            }
            yPos *= kFactor;

            NSInteger angle = [[obj objectAtIndex:3] intValue];
            NSInteger param1 = [[obj objectAtIndex:4] intValue];
            NSInteger param2 = [[obj objectAtIndex:5] intValue];
            NSInteger param3 = [[obj objectAtIndex:6] intValue];
            
            switch (group) {
                case kTypePlatform:
                    [self createGround:ccp(xPos, yPos) withType:type withAngle: angle];
                    break;
                case kTypeGoal:
                    [self createGoalObject:ccp(xPos, yPos)];
                    break;
                case kTypeCoin:
                    [self createCoin:ccp(xPos, yPos)];
                    break;
                case kTypeBonus:
                    [self createBonus:ccp(xPos, yPos) withType:type];
                    break;
                case kTypeHero:
                    [self createHeroObject:ccp(xPos, yPos - 2 * kFactor)];
                    availableTrampolines += param1;
                    if([GameController sharedGameCtrl].difficultyLevel == kDifficultyMedium) {
                        availableTrampolines += 3; //or 20%
                    }
                    else if([GameController sharedGameCtrl].difficultyLevel == kDifficultyEasy) {
                        availableTrampolines += 5; //or 33%
                    }
                    switch (param3) {
                        case 1:
                            currAnimationID = kAnimationNormal;
                            break;
                        case 2:
                            currAnimationID = kAnimationSuper;
                            break;
                        case 3:
                            currAnimationID = kAnimationSticky;
                            break;
                    }
                    break;
                case kTypeCannon:
                    [self createCannon:ccp(xPos, yPos)];
                    break;
                case kTypeGun:
                    [self createGun:ccp(xPos, yPos) withParam1:param1 withParam2:param2 withParam3:param3];
                    break;
                case kTypeBoulder:
                    [self createBoulder:ccp(xPos, yPos) withType:type];
                    break;
                case kTypeEnemy:
                    [self createEnemy:ccp(xPos, yPos) withType:type withAmplitude:param1];
                    break;
                case kTypeAirduct:
                    [self createAirduct:ccp(xPos, yPos) withType:type withAngle:angle withParam1:param1];
                    break;
                case kTypeBGObject:
                    [self createBGObject:ccp(xPos, yPos) withRotation:angle withType:type];
                    break;
                case kTypeHint:
                    [self createHint:ccp(xPos, yPos) withRotation:angle withType:param1 withMove:param2];
                    break;
                default:
                    break;
            }
        }
        levelState = kLevelStateInProgress;
        needUpdateTrampolines = YES;
        
        if(currAnimationID == kAnimationNormal) {
            [self showHintAnimationWithType:kAnimationNormal];
        }
        else if(currAnimationID == kAnimationSticky) {
            [self showHintAnimationWithType:kAnimationSticky];
        }
        else if(currAnimationID == kAnimationSuper) {
            [self showHintAnimationWithType:kAnimationSuper];
        }
        else {
            [self startRaabit];
        }
    }
}

-(void) nextLevel {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    ++appDelegate.currLevel;
    [[CCDirector sharedDirector] replaceScene: [GameLayer scene]];
}

-(void) showResultsLevel {
    [[CCDirector sharedDirector] replaceScene: [LevelCompleteLayer scene]];
}

-(void) showFailedLevel {
    isLevelShown = NO;
    
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    [appDelegate spendLife];
    [[CCDirector sharedDirector] resume];

    if(appDelegate.livesCount < 0) {
        if(isBeeExist) {
            [loopBeeSound stop];
            [loopBeeSound release];
            loopBeeSound = nil;
        }
        if(isAirExist) {
            [loopAirSound stop];
            [loopAirSound release];
            loopAirSound = nil;
        }
        if(isBirdExist) {
            [loopBirdSound stop];
            [loopBirdSound release];
            loopBirdSound = nil;
        }
        self.isMenuShown = NO;
        [self showContinueScreen];
    }
    else {
        CCLOG(@"Lost Lives = %d", [GameController sharedGameCtrl].lostLives);
        if ([GameController sharedGameCtrl].lostLives % 5 == 0) {
            [self showAdInterstitial];
        }
        [[CCDirector sharedDirector] replaceScene: [LevelFailedLayer scene]];
    }
}

-(void) restartLevel {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    if(isGameStarted) {
        [appDelegate spendLife];
    }
    [[CCDirector sharedDirector] resume];
    
    if(appDelegate.livesCount < 0) {
        if(isBeeExist) {
            [loopBeeSound stop];
            [loopBeeSound release];
            loopBeeSound = nil;
        }
        if(isAirExist) {
            [loopAirSound stop];
            [loopAirSound release];
            loopAirSound = nil;
        }
        if(isBirdExist) {
            [loopBirdSound stop];
            [loopBirdSound release];
            loopBirdSound = nil;
        }
        self.isMenuShown = NO;
        [self showContinueScreen];
    }
    else {
        [[CCDirector sharedDirector] replaceScene: [GameLayer scene]];
    }
}

-(void) levelComplete {
    if(isBeeExist) {
        [loopBeeSound stop];
        [loopBeeSound release];
        loopBeeSound = nil;
    }
    if(isBirdExist) {
        [loopBirdSound stop];
        [loopBirdSound release];
        loopBirdSound = nil;
    }
    if(isAirExist) {
        [loopAirSound stop];
        [loopAirSound release];
        loopAirSound = nil;
    }

    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];

    [[SimpleAudioEngine sharedEngine] playEffect:@"Goal.mp3"];
    
    [appDelegate logWinLevel:appDelegate.currLevel withNumberOfLoses:[GameController sharedGameCtrl].lostLives];
    
    [_hero stopAllActions];
    
    [GameController sharedGameCtrl].levelStars = [[GameController sharedGameCtrl] countLevelStars];
    
    appDelegate.bounceScores = availableTrampolines * 200;
    appDelegate.enemiesScore = enemiesBonus;
    appDelegate.currLevelScores = levelScores;
    
    NSInteger tempScore = appDelegate.bounceScores +
                          appDelegate.enemiesScore +
                          appDelegate.currLevelScores;
    
    
    appDelegate.currLevelStars = [GameController sharedGameCtrl].levelStars;
    appDelegate.planksUsed = usedTrampolines;

    [[GameController sharedGameCtrl]loadListOfScoresForLevel:appDelegate.currLevel];
    
    [[GameProgressController sharedGProgressCtrl] setScore:tempScore //levelScores
                                                  forLevel:appDelegate.currLevel
                                                 withStars:[GameController sharedGameCtrl].levelStars
                                               withCarrots:[GameController sharedGameCtrl].collectedCoins];

    NSInteger chapterScore = [[GameProgressController sharedGProgressCtrl] getScoresForWorld:appDelegate.currArea];
    NSInteger totalScore = [[GameProgressController sharedGProgressCtrl] getFullScores];
    
    [appDelegate submitHighScore:chapterScore leaderboard:[appDelegate getLeaderBoardNameForCurrArea]];
    [appDelegate submitHighScore:totalScore leaderboard:[appDelegate getTotalScoresLeaderboard]];
    
    id levelCompleteAction = [CCSequence actions:
                              [CCSpawn actions:
                               [CCFadeTo actionWithDuration:1.5f opacity:50.0f],
                               [CCMoveTo actionWithDuration:1.5f position:_hero.goalPosition],
                               [CCRotateBy actionWithDuration:1.5f angle:1000.0f],
                               [CCScaleTo actionWithDuration:1.5f scale:0.0f],
                               nil],
                              [CCCallFunc actionWithTarget:self selector:@selector(showResultsLevel)], nil];
    [_hero runAction:levelCompleteAction];
}

-(NSInteger) createTrampolineObject: (CGPoint) pos1 pos2: (CGPoint) pos2 withType: (NSInteger) type {
    if(availableTrampolines <= 0) {
        return kTrampolineNone;
    }
    NSInteger trampolineType = type;
    
    if(currTrampoline != nil) {
        GameObject *to = (GameObject*)currTrampoline->GetUserData();
        [to removeFromParentAndCleanup:YES];
        world->DestroyBody(currTrampoline);
        currTrampoline = nil;
    }
    
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0, 0);

    CGPoint angleVector = ccpSub(ccp(pos2.x, pos2.y), ccp(pos1.x, pos1.y));
	float angle = CC_RADIANS_TO_DEGREES(-ccpToAngle(angleVector));
    if(angle < 0) {
        angle += 360.0f;
    }

    trampolineAngle = angle;
    
    float dist = ccpDistance(pos1, pos2);
    
    float maxLength = kMaxTrampLength;
    if(purpleTrampolines > 0) {
        maxLength = kMaxTrampSuperLength;
    }
    
    if(dist > maxLength) {
        dist = maxLength;
        pos2.x = pos1.x + dist * cosf(CC_DEGREES_TO_RADIANS(angle));
        pos2.y = pos1.y + dist * -sinf(CC_DEGREES_TO_RADIANS(angle));
    }
    else if(dist < kMinTrampLength) {
        dist = kMinTrampLength;
        pos2.x = pos1.x + dist * cosf(CC_DEGREES_TO_RADIANS(angle));
        pos2.y = pos1.y + dist * -sinf(CC_DEGREES_TO_RADIANS(angle));
    }

    NSString *objName = nil;
    CGPoint anchorPoint = ccp(0.0f, 0.5f);
    float scaleFactor = dist/100.0f/kFactor;
    if(type == kTrampolineRegular) {
        if(dist > kMaxTrampLength) {
            objName = @"purpleTram_1.png";
            anchorPoint = ccp(0.1f, 0.5f);
            scaleFactor = dist/200.0f/kFactor;
            trampolineType = kTrampolinePurple;
        }
        else {
            objName = @"tram_1.png";
        }
    }
    else {
        anchorPoint = ccp(0.1f, 0.5f);
        objName = @"stickTram_1.png";
        CGPoint newPos = ccp((pos1.x + pos2.x) / 2.0f + sinf(CC_DEGREES_TO_RADIANS(angle)) * 17 * kFactor,
                             (pos1.y + pos2.y) / 2.0f + cosf(CC_DEGREES_TO_RADIANS(angle)) * 17 * kFactor);
        [_hero setPosition:newPos];
    }
        
    TrampolineObject *toSprite = [TrampolineObject spriteWithSpriteFrameName:objName];
    [toSprite setScaleX:scaleFactor];
    
    [toSprite setAnchorPoint:anchorPoint];
    [toSprite setPosition:pos1];
	[toSprite setTypeOfObject:kTypeTrampoline];
    [self addChild:toSprite z:zTrampoline];
    [toSprite setRotation:angle];
     [toSprite setTrampolineType:trampolineType];
    
    groundBodyDef.userData = toSprite;
    
    currTrampoline = world->CreateBody(&groundBodyDef);
    
    endTrampoline = pos2;
    
    toSprite.centerPos = ccp((pos1.x + pos2.x) / 2.0f, (pos1.y + pos2.y) / 2.0f);
    
    b2EdgeShape groundBox;
    groundBox.Set(b2Vec2(toRatio(pos1.x), toRatio(pos1.y)),
                  b2Vec2(toRatio(pos2.x), toRatio(pos2.y)));

    b2FixtureDef fixtureDef;
    fixtureDef.shape = &groundBox;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.3f;
    
    float power = kMinPower;
    
    if(dist <= kMinTrampLength) {
        power = kMinPower;
    }
    else if(dist > kMaxTrampLength) {
        power = kMinPower + (dist - kMinTrampLength) / (maxLength - kMinTrampLength) * (kMaxPower - kMinPower);
        power *= 3.0f;
    }
    else {
        power = kMinPower + (dist - kMinTrampLength) / (kMaxTrampLength - kMinTrampLength) * (kMaxPower - kMinPower);
    }
    trampolinePower = power;
    fixtureDef.restitution = power;
    currTrampoline->CreateFixture(&fixtureDef);
    
    return trampolineType;
}

-(void) createGoalObject: (CGPoint) pos {
    goalPos = pos;
    
    NSString* objName = @"goal_blackandwhite.png";
    GoalObject *goSprite = [GoalObject spriteWithSpriteFrameName:objName];
	[goSprite setTypeOfObject:kTypeGoal];
	[goSprite setPosition:pos];
    [self addChild:goSprite z:zGoal tag:kTagGoal];

    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;

    bodyDef.position.Set(toRatio(pos.x), toRatio(pos.y));
    bodyDef.userData = goSprite;
    b2Body *body = world->CreateBody(&bodyDef);

    NSString *physName = [objName stringByDeletingPathExtension];
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:body forShapeName:physName];
    [goSprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:physName]];
}

-(void) createHeroObject: (CGPoint) pos {
    NSString *shapeName = @"stand_1.png";
    NSString *objName = [NSString stringWithFormat:@"stand/%@", shapeName];
    _hero = [HeroObject spriteWithSpriteFrameName:objName];
    [_hero init];
	[_hero setTypeOfObject:kTypeHero];
	[_hero setPosition:pos];
    [_hero startAnimationStand];
    [self addChild:_hero z:zHero];
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    
    bodyDef.position.Set(toRatio(pos.x), toRatio(pos.y));
    bodyDef.userData = _hero;
    b2Body *body = world->CreateBody(&bodyDef);
    
    [_hero setBody:body];
    
    NSString *physName = [shapeName stringByDeletingPathExtension];
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:body forShapeName:physName];
    [_hero setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:physName]];
    
    massHero = 0.0f;
    for (b2Fixture* f = [_hero getBody]->GetFixtureList(); f; f = f->GetNext()) {
        b2MassData massData;
        f->GetMassData(&massData);
        massHero += massData.mass;
    }
}

-(void) createGround: (CGPoint) pos withType: (NSInteger) type withAngle: (NSInteger) angle {
    NSString *objName = @"basePlatform.png";
    bool needAdd = NO;
    NSInteger zOrder = zGround;
    
    switch (type) {
        case 130:
            objName = @"basePlatform.png";
            needAdd = YES;
            break;
        case 132:
            objName = @"wallOver.png";
            break;
        case 103:
            objName = @"tram2_1.png";
            zOrder = zGround - 1;
            break;
        case 104:
            objName = @"tram3_1.png";
            zOrder = zGround - 1;
            break;
        case 105:
            objName = @"tram4_1.png";
            zOrder = zGround - 1;
            break;
        case 131:
            objName = @"boulderPlatform.png";
            needAdd = YES;
            break;
        case 107:
            objName = @"lowerleft.png";
            break;
        case 108:
            objName = @"lowermiddle.png";
            break;
        case 109:
            objName = @"lowerright.png";
            break;
        case 113:
            objName = @"upperleft.png";
            needAdd = YES;
            break;
        case 115:
            objName = @"upperright.png";
            needAdd = YES;
            break;
        case 118:
            objName = @"3x5mid.png";
            break;
        case 122:
            objName = @"5x3mid.png";
            break;
        case 124:
            objName = @"5x5mid.png";
            break;
        case 125:
            objName = @"5xbottom.png";
            break;
        case 126:
            objName = @"5xleft.png";
            break;
        case 127:
            objName = @"5xright.png";
            break;
        case 128:
            objName = @"5xtop.png";
            needAdd = YES;
            break;
        case 101:
            objName = @"basePlatform0.png";
            needAdd = YES;
            break;
        case 106:
            objName = @"boulderPlatform0.png";
            needAdd = YES;
            break;
        case 102:
            objName = @"wallOver0.png";
            needAdd = YES;
            break;
        case 150:
            objName = @"basePlatform2.png";
            needAdd = YES;
            break;
        case 151:
            objName = @"wallOver2.png";
            break;
        case 152:
            objName = @"boulder2.png";
            break;
        case 153:
            objName = @"boulderPlatform2.png";
            needAdd = YES;
            break;
        case 170:
            objName = @"basePlatform3.png";
            needAdd = YES;
            break;
        case 171:
            objName = @"wallOver3.png";
            break;
        case 172:
            objName = @"boulderPlatform3.png";
            needAdd = YES;
            break;
        case 173:
            objName = @"boulderPlatformCenter3.png";
            needAdd = YES;
            break;
        case 174:
            objName = @"boulderPlatformLeft3.png";
            needAdd = YES;
            break;
        case 175:
            objName = @"boulderPlatformRight3.png";
            needAdd = YES;
            break;
        case 176:
            objName = @"boulderPlatformSmall3.png";
            needAdd = YES;
            break;
        case 190:
            objName = @"basePlatform4.png";
            needAdd = YES;
            break;
        case 191:
            objName = @"wallOver4.png";
            needAdd = YES;
            break;
        case 192:
            objName = @"boulderPlatformSmall4.png";
            needAdd = YES;
            break;
    }
    GroundObject *goSprite = [GroundObject spriteWithSpriteFrameName:objName];
	[goSprite setTypeOfObject:kTypePlatform];
	[goSprite setPosition:pos];
    [self addChild:goSprite z:zOrder];
	[goSprite setRotation:-angle];
    
    [goSprite setGroundType:type];
    [goSprite startAnimationIdleSwing];
    
    if(needAdd) {
        [_listOfPlatforms addObject:goSprite];
    }
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    
    bodyDef.position.Set(toRatio(pos.x), toRatio(pos.y));
	bodyDef.angle = CC_DEGREES_TO_RADIANS(360.0f + angle);
    bodyDef.userData = goSprite;
    b2Body *body = world->CreateBody(&bodyDef);
    
    NSString *physName = [objName stringByDeletingPathExtension];
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:body forShapeName:physName];
    [goSprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:physName]];
}

-(void) createEnemy: (CGPoint) pos withType: (NSInteger) type withAmplitude: (NSInteger) ampl {
    ampl *= kFactor;
    NSString *objName = @"bee_1.png";
    NSString *shapeName = objName;
    
    switch (type) {
        case kEnemyBee:
            isBeeExist = YES;
            objName = @"bee_1.png";
            shapeName = objName;
            break;
        case kEnemyBlueBee:
            isBeeExist = YES;
            objName = @"blueBee_1.png";
            shapeName = objName;
            break;
        case kEnemyBird:
            isBirdExist = YES;
            objName = @"Birdflying_1.png";
            shapeName = objName;
            break;
        case kEnemyBear:
            objName = @"Bear_walk/Bearwalk_1.png";
            shapeName = @"Bearwalk_1.png";
            break;
        case kEnemyTurtle:
            objName = @"turtlewalk_1.png";
            shapeName = objName;
            break;
    }
    
    EnemyObject *eoSprite = nil;
    BearObject *boSprite = nil;
    TurtleObject *toSprite = nil;
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_kinematicBody;
    bodyDef.position.Set(toRatio(pos.x), toRatio(pos.y));

    if(type == kEnemyBear) {
        boSprite = [BearObject spriteWithSpriteFrameName:objName];
        [boSprite setLivesCount:2];
        [boSprite setTypeOfObject:kTypeEnemy];
        [boSprite setEnemyType:type];
        [boSprite setPosition:pos];
        [self addChild:boSprite z:zEnemy];
        [_listOfEnemies addObject:boSprite];
        
        bodyDef.userData = boSprite;
    }
    else if(type == kEnemyTurtle) {
        toSprite = [TurtleObject spriteWithSpriteFrameName:objName];
        
        [toSprite setTypeOfObject:kTypeEnemy];
        [toSprite setEnemyType:type];
        [toSprite setPosition:pos];
        [self addChild:toSprite z:zEnemy];
        [_listOfEnemies addObject:toSprite];
        
        bodyDef.userData = toSprite;
    }
    else {
        eoSprite = [EnemyObject spriteWithSpriteFrameName:objName];
        [eoSprite setTypeOfObject:kTypeEnemy];
        [eoSprite setEnemyType:type];
        [eoSprite setPosition:pos];
        [self addChild:eoSprite z:zEnemy];
        [_listOfEnemies addObject:eoSprite];
        
        bodyDef.userData = eoSprite;
    }

    b2Body *body = world->CreateBody(&bodyDef);
    
    if(type == kEnemyBear) {
        [boSprite setBody:body];
        [boSprite initEnemyWithPos:pos horizontalAmplitude:ampl isStarted:NO];
    }
    else if(type == kEnemyTurtle) {
        [toSprite setBody:body];
        [toSprite initEnemyWithPos:pos horizontalAmplitude:ampl isStarted:NO];
    }
    else if(type == kEnemyBird) {
        [eoSprite setBody:body];
        [eoSprite startAnimationFly];
        [eoSprite initEnemyWithPos:pos horizontalAmplitude:ampl isStarted:YES];
    }
    else {
        [eoSprite setBody:body];
        [eoSprite startAnimationFly];
        [eoSprite initEnemyWithPos:pos amplitude:ampl];
    }
    
    NSString *physName = [shapeName stringByDeletingPathExtension];
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:body forShapeName:physName];
    [eoSprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:physName]];
}

-(void) createCannon: (CGPoint) pos {
    NSString* objName = @"cannonBase.png";
    CannonObject *coSprite = [CannonObject spriteWithSpriteFrameName:objName];
    [coSprite initCannon];
	[coSprite setTypeOfObject:kTypeCannon];
	[coSprite setPosition:pos];
    [self addChild:coSprite z:zCannon];
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    
    bodyDef.position.Set(toRatio(pos.x), toRatio(pos.y));
    bodyDef.userData = coSprite;
    b2Body *body = world->CreateBody(&bodyDef);

    [coSprite setBody:body];

    NSString *physName = [objName stringByDeletingPathExtension];
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:body forShapeName:physName];
    [coSprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:physName]];
}

-(void) createGun: (CGPoint) pos withParam1: (NSInteger) p1 withParam2: (NSInteger) p2 withParam3: (NSInteger) p3 {
    NSString* objName = @"gun_botttom_part.png";
    GunObject *goSprite = [GunObject spriteWithSpriteFrameName:objName];
    [goSprite initCannon];
	[goSprite setTypeOfObject:kTypeGun];
	[goSprite setPosition:pos];
    [self addChild:goSprite z:zGun];
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    
    bodyDef.position.Set(toRatio(pos.x), toRatio(pos.y));
    bodyDef.userData = goSprite;
    b2Body *body = world->CreateBody(&bodyDef);
    
    [goSprite setBody:body];
    
    NSString *physName = [objName stringByDeletingPathExtension];
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:body forShapeName:physName];
    [goSprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:physName]];
}

-(void) createBoulder: (CGPoint) pos withType: (NSInteger) type {
    NSString* objName = @"boulder.png";

    switch (type) {
        case 801:
            objName = @"boulder.png";
            break;
        case 802:
            objName = @"boulder2.png";
            break;
    }

    GameObject *goSprite = [GameObject spriteWithSpriteFrameName:objName];
	[goSprite setTypeOfObject:kTypeBoulder];
	[goSprite setPosition:pos];
    [self addChild:goSprite z:zGoal];
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    
    bodyDef.position.Set(toRatio(pos.x), toRatio(pos.y));
    bodyDef.userData = goSprite;
    b2Body *body = world->CreateBody(&bodyDef);
    
    NSString *physName = [objName stringByDeletingPathExtension];
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:body forShapeName:physName];
    [goSprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:physName]];
}

-(void) createBomb: (CGPoint) pos {
    if(bombsCount <= 0) {
        return;
    }
    
    prevPoint1 = ccp(-1, -1);
    prevPoint2 = ccp(-1, -1);
    crossPoint = ccp(-1, -1);
    
    self.prevTime = [[NSDate date] dateByAddingTimeInterval:-200];
    
    --bombsCount;
    [self updateBombsCount];

    NSString* objName = @"fuse/fuse_1.png";
    
    BombObject *boSprite = [BombObject spriteWithSpriteFrameName:objName];
    boSprite.explosionPos = pos;
	[boSprite setPosition:ccp(pos.x + 160 * kFactor, -50 * kFactor)];
    [boSprite startAnimationFuse];
    [self addChild:boSprite z:zBomb];
    
    [boSprite setTrampoline1:bombTrampoline1];
    [boSprite setTrampoline2:bombTrampoline2];
    
    ccBezierConfig config;
    config.endPosition = ccp(pos.x, pos.y + 30 * kFactor);
    config.controlPoint_1 = ccp(pos.x + 110 * kFactor, pos.y + 100 * kFactor);
    config.controlPoint_2 = ccp(pos.x + 50 * kFactor, pos.y + 150 * kFactor);
    
    id bezierAction = [CCBezierTo actionWithDuration:2.2f bezier:config];
    id actionBomb = [CCSpawn actions:
                     bezierAction,
                     [CCSequence actions:
                      [CCRotateBy actionWithDuration:1.9f angle:-360 * 3],
                      [CCCallFunc actionWithTarget:boSprite selector:@selector(startAnimationExplosion)],
                      [CCDelayTime actionWithDuration:0.3f],
                      [CCCallFuncN actionWithTarget:self selector:@selector(explodeEnemies:)],
                      nil],
                     nil];
    [boSprite runAction:actionBomb];
    
    [_listOfBombs addObject:boSprite];
    
    bombTrampoline2 = nil;
    bombTrampoline1 = nil;
}

-(void) createAirduct: (CGPoint) pos withType: (NSInteger) type withAngle: (NSInteger) angle withParam1: (NSInteger) param1 {
    NSString *objName = @"airductFloor.png";
    
    switch (type) {
        case 1001:
            isAirExist = YES;
            objName = @"airductFloor.png";
            break;
        case 1002:
            isAirExist = YES;
            objName = @"airductSide.png";
            break;
        default:
            NSAssert(0, @"Airduct: Unknown object type.");
            break;
    }
    
    AirductObject *aoSprite = [AirductObject spriteWithSpriteFrameName:objName];
	[aoSprite setTypeOfObject:kTypeAirduct];
	[aoSprite setPosition:pos];
    [aoSprite setTypeOfAirduct:type];
    [aoSprite initFlow];
    
    if(param1 < 0 ) {
        [self addChild:aoSprite z:zGround - 1];
    }
    else {
        [self addChild:aoSprite z:zGround + 1];
    }
	[aoSprite setRotation:-angle];

    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    
    bodyDef.position.Set(toRatio(pos.x), toRatio(pos.y));
	bodyDef.angle = CC_DEGREES_TO_RADIANS(360.0f + angle);
    bodyDef.userData = aoSprite;
    b2Body *body = world->CreateBody(&bodyDef);
    
    [aoSprite setBody:body];
    
    NSString *physName = [objName stringByDeletingPathExtension];
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:body forShapeName:physName];

    if(angle != 0 && angle != 180 && angle != -180) {
        for (b2Fixture* f = body->GetFixtureList(); f; f = f->GetNext()) {
            b2Filter filterData = f->GetFilterData();
            filterData.groupIndex = 1;
            f->SetFilterData(filterData);
        }
    }
    [aoSprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:physName]];
}

-(void) loadCannon: (CannonObject *) cannon {
    [[SimpleAudioEngine sharedEngine] playEffect:@"CanonFuseWithClank.mp3"];
    [_hero startAnimationShot];
    [_hero setScale:0.2f];
    [_hero setPosition:ccpAdd(cannon.position, ccp(-6 * kFactor, 10 * kFactor))];
    [_hero setState:kStateNeedShoot];
    
    b2Body *heroBody = [_hero getBody];
    heroBody->SetTransform(toRatio(ccpAdd(cannon.position, ccp(-6 * kFactor, 10 * kFactor))), 0);
    heroBody->SetLinearVelocity(b2Vec2(0, 0));
    
    b2WeldJointDef wjd;
    wjd.Initialize(heroBody, groundBody, heroBody->GetPosition());
    b2Joint *wj = world->CreateJoint(&wjd);
    [_hero setJoint:wj];
}

-(void) loadGun: (GunObject *) gun {
    currGun = gun;
    [_hero setState:kStateLoadingInGun];
    
    b2Body *heroBody = [_hero getBody];
    heroBody->SetTransform(toRatio(ccpAdd(currGun.position, ccp(20 * kFactor, 30 * kFactor))), 0);
    heroBody->SetLinearVelocity(b2Vec2(0, 0));
    
    b2WeldJointDef wjd;
    wjd.Initialize(heroBody, groundBody, heroBody->GetPosition());
    b2Joint *wj = world->CreateJoint(&wjd);
    [_hero setJoint:wj];
    
    [_hero stopAllActions];
    
    CGPoint endPoint = ccpAdd(currGun.position, ccp(-1 * kFactor, 25 * kFactor));
    float distance = ccpDistance(_hero.position, endPoint);
    distance /= kFactor;
    float timeMove = distance / 280;
    
    id actionJump = [CCSequence actions:
                     [CCMoveTo actionWithDuration:timeMove position:endPoint],
                     [CCCallFunc actionWithTarget:self selector:@selector(loadGunPart2)],
                     nil];
    [_hero runAction:actionJump];

    NSInteger deltaX = endPoint.x - _hero.position.x;
    id actionBG = [CCMoveTo actionWithDuration:timeMove position:ccp(bg.position.x + deltaX * 0.88f, bg.position.y)];
    [bg runAction:actionBG];
}

-(void) loadGunPart2 {
    [self createSparrows];
    [_hero setState:kStateInGun];
    
    HUDLayer *hl = (HUDLayer *)[self.parent getChildByTag:kHudLayerTag];
    [hl showBulletMeter];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"CanonFuseWithClank.mp3"];
    [_hero startAnimationJumpInGun];
    [_hero setPosition:ccpAdd(currGun.position, ccp(6 * kFactor, 10 * kFactor))];
    
    [_hero removeFromParentAndCleanup:NO];
    [currGun addRabbit:_hero];
    
    id actionGun = [CCSequence actions:
                    [CCDelayTime actionWithDuration:0.81f],
                    [CCCallFunc actionWithTarget:_hero selector:@selector(setFrameInGun)],
                    nil];
    [currGun runAction:actionGun];
}
/*
-(void) createSparrows {
//    First wave in position 1, as per http://awesomescreenshot.com/0832bfi237, 5 birds in wave.
//    Second wave starts 5 seconds after wave 1, in position 3, 6 birds in wave.
//    Third wave starts 4 seconds after wave 2, in position 4, 7 birds in wave.
//    Fourth wave starts 5 seconds after wave 3, in position 2, 5 birds in wave.
    
    float delayTime = 0.0f;
    float timeBetweenBirds = 0.45f;
    
    for(NSInteger i = 0; i < 5; ++i) {
        CGPoint pos = ccp(_hero.gun.position.x + kScreenWidth + 30 * kFactor, _hero.position.y + 100 * kFactor);
        CGPoint posEnd = [_hero.gun getRabbitPoss];
        SparrowObject *so = [SparrowObject spriteWithSpriteFrameName:@"fly/sparrow_1.png"];
        [so setIsStarted:NO];
        [so setPosition:pos];
        [self addChild:so z:zHero];
        
        ccBezierConfig config;
        config.endPosition = posEnd;
        config.controlPoint_1 = ccp(posEnd.x + kScreenWidth * 2.0f / 3.0f, posEnd.y + 120 * kFactor);
        config.controlPoint_2 = ccp(posEnd.x + kScreenWidth * 1.0f / 3.0f, posEnd.y + 120 * kFactor);
        id bezierAction = [CCBezierTo actionWithDuration:2.5f bezier:config];

        delayTime += timeBetweenBirds;
        id action = [CCSequence actions:
                     [CCDelayTime actionWithDuration:delayTime],
                     [CCCallFunc actionWithTarget:so selector:@selector(startAnimationFly)],
                     [CCCallFunc actionWithTarget:so selector:@selector(startChirp)],
                     bezierAction,
                     [CCCallFunc actionWithTarget:self selector:@selector(deadRabit)],
                     nil];
        [so runAction:action];
        
        [_listOfSparrows addObject:so];
    }
    
    delayTime += 4.0f;
    
    for(NSInteger i = 0; i < 6; ++i) {
        CGPoint pos = ccp(_hero.gun.position.x + kScreenWidth + 30 * kFactor, _hero.position.y + 20 * kFactor);
        CGPoint posEnd = [_hero.gun getRabbitPoss];
        SparrowObject *so = [SparrowObject spriteWithSpriteFrameName:@"fly/sparrow_1.png"];
        [so setIsStarted:NO];
        [so setPosition:pos];
        [self addChild:so z:zHero];
        
        ccBezierConfig config;
        config.endPosition = posEnd;
        config.controlPoint_1 = ccp(posEnd.x + kScreenWidth * 2.0f / 3.0f, posEnd.y + 130 * kFactor);
        config.controlPoint_2 = ccp(posEnd.x + kScreenWidth * 1.0f / 3.0f, posEnd.y + 130 * kFactor);
        id bezierAction = [CCBezierTo actionWithDuration:2.5f bezier:config];

        delayTime += timeBetweenBirds;
        id action = [CCSequence actions:
                     [CCDelayTime actionWithDuration:delayTime],
                     [CCCallFunc actionWithTarget:so selector:@selector(startAnimationFly)],
                     [CCCallFunc actionWithTarget:so selector:@selector(startChirp)],
                     bezierAction,
                     [CCCallFunc actionWithTarget:self selector:@selector(deadRabit)],
                     nil];
        [so runAction:action];
        
        [_listOfSparrows addObject:so];
    }
    
    delayTime += 3.0f;
    
    for(NSInteger i = 0; i < 7; ++i) {
        CGPoint pos = ccp(_hero.gun.position.x + kScreenWidth + 30 * kFactor, _hero.position.y);
        CGPoint posEnd = [_hero.gun getRabbitPoss];
        SparrowObject *so = [SparrowObject spriteWithSpriteFrameName:@"fly/sparrow_1.png"];
        [so setIsStarted:NO];
        [so setPosition:pos];
        [self addChild:so z:zHero];
        
        ccBezierConfig config;
        config.endPosition = posEnd;
        config.controlPoint_1 = ccp(posEnd.x + kScreenWidth * 2.0f / 3.0f, posEnd.y - 130 * kFactor);
        config.controlPoint_2 = ccp(posEnd.x + kScreenWidth * 1.0f / 3.0f, posEnd.y - 130 * kFactor);
        id bezierAction = [CCBezierTo actionWithDuration:2.5f bezier:config];

        delayTime += timeBetweenBirds;
        id action = [CCSequence actions:
                     [CCDelayTime actionWithDuration:delayTime],
                     [CCCallFunc actionWithTarget:so selector:@selector(startAnimationFly)],
                     [CCCallFunc actionWithTarget:so selector:@selector(startChirp)],
                     bezierAction,
                     [CCCallFunc actionWithTarget:self selector:@selector(deadRabit)],
                     nil];
        [so runAction:action];
        
        [_listOfSparrows addObject:so];
    }
    
    delayTime += 4.0f;
    
    for(NSInteger i = 0; i < 5; ++i) {
        CGPoint pos = ccp(_hero.gun.position.x + kScreenWidth + 30 * kFactor, _hero.position.y - 60 * kFactor);
        CGPoint posEnd = [_hero.gun getRabbitPoss];
        SparrowObject *so = [SparrowObject spriteWithSpriteFrameName:@"fly/sparrow_1.png"];
        [so setIsStarted:NO];
        [so setPosition:pos];
        [self addChild:so z:zHero];
        
        ccBezierConfig config;
        config.endPosition = posEnd;
        config.controlPoint_1 = ccp(posEnd.x + kScreenWidth * 2.0f / 3.0f, posEnd.y + 40 * kFactor);
        config.controlPoint_2 = ccp(posEnd.x + kScreenWidth * 1.0f / 3.0f, posEnd.y + 40 * kFactor);
        id bezierAction = [CCBezierTo actionWithDuration:2.5f bezier:config];

        delayTime += timeBetweenBirds;
        id action = [CCSequence actions:
                     [CCDelayTime actionWithDuration:delayTime],
                     [CCCallFunc actionWithTarget:so selector:@selector(startAnimationFly)],
                     [CCCallFunc actionWithTarget:so selector:@selector(startChirp)],
                     bezierAction,
                     [CCCallFunc actionWithTarget:self selector:@selector(deadRabit)],
                     nil];
        [so runAction:action];
        
        [_listOfSparrows addObject:so];
    }
}
*/

-(void) createSparrows {
//    In particular, I would like you to focus on 36 (please randomise the start position, number of waves [3-6], number of birds[2-5],
//    and time between each wave[0-1.5 seconds]) and in general make it easier at the start and harder in the later levels.
    float delayTime = 0.0f;
    float timeBetweenBirds = 0.45f;

    NSInteger numberOfWaves = 3 + arc4random() % 4;
    
    for(NSUInteger i = 0; i < numberOfWaves; ++i) {
        NSInteger birdsCount = 4 + arc4random() % 4;
        NSInteger type = arc4random() % 4;
        NSInteger shift = arc4random() % 100;
        NSInteger shiftStart = arc4random() % 60;
        
        shift = (50 - shift) * kFactor;
        shiftStart = (30 - shiftStart) * kFactor;
        
        CCLOG(@"Type is %ld", type);
        
        for(NSUInteger i = 0; i < birdsCount; ++i) {
            CGPoint pos;
            CGPoint posEnd = [_hero.gun getRabbitPoss];
            
            ccBezierConfig config;
            config.endPosition = posEnd;
            
            switch (type) {
                case 0: {
                    pos = ccp(_hero.gun.position.x + kScreenWidth + 30 * kFactor, _hero.position.y + 100 * kFactor + shiftStart);
                    config.controlPoint_1 = ccp(posEnd.x + kScreenWidth * 2.0f / 3.0f, posEnd.y + 120 * kFactor + shift);
                    config.controlPoint_2 = ccp(posEnd.x + kScreenWidth * 1.0f / 3.0f, posEnd.y + 120 * kFactor + shift);
                    break;
                }
                case 1: {
                    pos = ccp(_hero.gun.position.x + kScreenWidth + 30 * kFactor, _hero.position.y + 20 * kFactor + shiftStart);
                    config.controlPoint_1 = ccp(posEnd.x + kScreenWidth * 2.0f / 3.0f, posEnd.y + 130 * kFactor + shift);
                    config.controlPoint_2 = ccp(posEnd.x + kScreenWidth * 1.0f / 3.0f, posEnd.y + 130 * kFactor + shift);
                }
                case 2: {
                    pos = ccp(_hero.gun.position.x + kScreenWidth + 30 * kFactor, _hero.position.y + shiftStart);
                    config.controlPoint_1 = ccp(posEnd.x + kScreenWidth * 2.0f / 3.0f, posEnd.y - 130 * kFactor + shift);
                    config.controlPoint_2 = ccp(posEnd.x + kScreenWidth * 1.0f / 3.0f, posEnd.y - 130 * kFactor + shift);
                }
                case 3: {
                    pos = ccp(_hero.gun.position.x + kScreenWidth + 30 * kFactor, _hero.position.y - 60 * kFactor + shiftStart);
                    config.controlPoint_1 = ccp(posEnd.x + kScreenWidth * 2.0f / 3.0f, posEnd.y + 40 * kFactor + shift);
                    config.controlPoint_2 = ccp(posEnd.x + kScreenWidth * 1.0f / 3.0f, posEnd.y + 40 * kFactor + shift);
                }
            }
            
            id bezierAction = [CCBezierTo actionWithDuration:2.5f bezier:config];
            
            SparrowObject *so = [SparrowObject spriteWithSpriteFrameName:@"fly/sparrow_1.png"];
            [so setIsStarted:NO];
            [so setPosition:pos];
            [self addChild:so z:zHero];
            
            delayTime += timeBetweenBirds;
            id action = [CCSequence actions:
                         [CCDelayTime actionWithDuration:delayTime],
                         [CCCallFunc actionWithTarget:so selector:@selector(startAnimationFly)],
                         [CCCallFunc actionWithTarget:so selector:@selector(startChirp)],
                         bezierAction,
                         [CCCallFunc actionWithTarget:self selector:@selector(deadRabit)],
                         nil];
            [so runAction:action];
            
            [_listOfSparrows addObject:so];
        }
        AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
        delayTime += 2.5f - appDelegate.currLevel / 100.0f;
    }
}

-(void) checkSparrows {
    if([_listOfSparrows count] <= 0) {
        if(_hero.state == kStateInGun) {
            isShoting = NO;
            wasFirstTouch = NO;
            [_hero setState:kStateNewObject];

            b2Body *heroBody = [_hero getBody];
            _hero.gun.alreadyUsed = YES;
            _hero.gun = nil;

            [_hero retain];
            [_hero removeFromParentAndCleanup:NO];
            _hero.parent = nil;
            [self addChild:_hero z:zHero];
            [_hero release];
            
            HUDLayer *hl = (HUDLayer *)[self.parent getChildByTag:kHudLayerTag];
            [hl hideBulletMeter];
            
            world->DestroyJoint([_hero getJoint]);
            heroBody->ApplyLinearImpulse(b2Vec2(6.0f * sinf(CC_DEGREES_TO_RADIANS(45)) * kFactor * kFactor * kFactor,
                                                8.5f * cosf(CC_DEGREES_TO_RADIANS(45)) * kFactor * kFactor * kFactor),
                                         heroBody->GetPosition());
            [_hero stopAllActions];
            
            cameraState = kStateNewObject;
            
            id action = [CCSequence actions:
                         [CCCallFunc actionWithTarget:_hero selector:@selector(startAnimationJump)], nil];
            [_hero runAction:action];
        }
    }
    else {
        for(NSUInteger i = [_listOfSparrows count]; i > 0; --i) {
            SparrowObject *so = (SparrowObject *)[_listOfSparrows objectAtIndex:i - 1];
            if(!so.isStarted) {
                continue;
            }
            
            for(NSUInteger j = [_listOfBullets count]; j > 0; --j) {
                BulletObject *bo = (BulletObject*)[_listOfBullets objectAtIndex:j - 1];
                
                if(ccpDistance(so.position, bo.position) < 18.0f * kFactor) {
                    [_listOfBullets removeObjectAtIndex:j - 1];
                    [bo removeFromParentAndCleanup:YES];
                    
                    [_listOfSparrows removeObjectAtIndex:i - 1];
                    
                    levelScores += 25;
                    HUDLayer *hl = (HUDLayer *)[self.parent getChildByTag:kHudLayerTag];
                    [hl updateScores:levelScores];
                    
                    [so stopAllActions];
                    id action = [CCSequence actions:
                                 [CCSpawn actions:
                                  [CCCallFunc actionWithTarget:so selector:@selector(startAnimationDeath)],
                                  [CCDelayTime actionWithDuration:1.5f],
                                  nil],
                                 [CCCallFuncN actionWithTarget:self selector:@selector(removeNode:)],
                                 nil];
                    [so runAction:action];
                }
            }
        }
    }
}

-(void) shotCannon {
    [[SimpleAudioEngine sharedEngine] playEffect:@"CannonBlast.mp3"];
    b2Body *heroBody = [_hero getBody];
    CannonObject *co = _hero.cannon;

    world->DestroyJoint([_hero getJoint]);
    heroBody->ApplyLinearImpulse(b2Vec2(100.0f * sinf(CC_DEGREES_TO_RADIANS([co getAngle] + 90)) * kFactor * kFactor,
                                        100.0f * cosf(CC_DEGREES_TO_RADIANS([co getAngle] + 90)) * kFactor * kFactor),
                                 heroBody->GetPosition());
    [_hero setState:kStateInShoot];
    [_hero stopAllActions];
    id action = [CCSequence actions:
                 [CCScaleTo actionWithDuration:0.001f scale:1.0f],
                 [CCCallFunc actionWithTarget:_hero selector:@selector(startAnimationFly)],
                 [CCDelayTime actionWithDuration:0.4f],
                 [CCCallFunc actionWithTarget:_hero selector:@selector(setNormalState)],
                 nil];
    [_hero runAction:action];
}

-(void) createBGObject: (CGPoint) pos withRotation: (NSInteger) angle withType: (NSInteger) type {
    NSString *objectName = nil;
    switch (type) {
        case 1501:
            objectName = @"statue.png";
            break;
    }

    if(objectName) {
        CCSprite *bgObject = [CCSprite spriteWithSpriteFrameName:objectName];
        [bgObject setRotation:-angle];
        [bgObject setPosition:pos];
        [self addChild:bgObject z:zBGObject];
    }
}

-(void) createHint: (CGPoint) pos withRotation: (NSInteger) angle withType: (NSInteger) type withMove: (NSInteger) move {
    isHintShown = YES;
    
    NSString *hintName = [NSString stringWithFormat:@"tutorial_%ld.png", (long)type];
    CCSprite *hintObject = [CCSprite spriteWithSpriteFrameName:hintName];
    [hintObject runAction:[CCFadeIn actionWithDuration:0.8f]];
    [hintObject setOpacity:0.0f];
    [hintObject setRotation:-angle];
    [hintObject setPosition:pos];
    [self addChild:hintObject z:zHint];
    
    [_listOfHints addObject:hintObject];
    
    if(move > 0) {
        id moveAction = [CCRepeatForever actionWithAction:
                         [CCSequence actions:
                          [CCMoveBy actionWithDuration:1.2f position:ccp(move * kFactor, 0)],
                          [CCMoveBy actionWithDuration:0.0f position:ccp(-move * kFactor, 0)],
                          nil]];
        [hintObject runAction:moveAction];
    }
}

-(void) removeHints {
    isHintShown = NO;
    isGameStarted = YES;
    [_hero startAnimationStarryEyed];
    
    for(NSUInteger i = [_listOfHints count]; i > 0; --i) {
        CCSprite *hintObject = (CCSprite *)[_listOfHints objectAtIndex:i - 1];
        if(hintObject) {
            [hintObject runAction:[CCSequence actions:
                                   [CCFadeOut actionWithDuration:0.8f],
                                   [CCCallFuncN actionWithTarget:self selector:@selector(removeNode:)],
                                   nil]];
            [_listOfHints removeObjectAtIndex:i - 1];
        }
    }
}

-(void) createBonus: (CGPoint) pos withType: (NSInteger) type {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    BonusObject *bonus = nil;
	bool needAdd = YES;
    switch (type) {
        case 701:
            bonus = [BonusObject spriteWithSpriteFrameName:@"5trampolines.png"];
            break;
        case 702:
            bonus = [BonusObject spriteWithSpriteFrameName:@"tramStickBonus.png"];
            break;
        case 703:
            bonus = [BonusObject spriteWithSpriteFrameName:@"purpleBonus.png"];
            break;
        case 704: {
            GameController *gc = [GameController sharedGameCtrl];
            if([gc getShieldForLevel:appDelegate.currLevel]) {
                needAdd = NO;
            }
            else {
                bonus = [BonusObject spriteWithSpriteFrameName:@"shieldPowerup.png"];
            }
            break;
        }
        case 705:
            bonus = [BonusObject spriteWithSpriteFrameName:@"bombPowerup.png"];
            break;
        default:
            bonus = [BonusObject spriteWithSpriteFrameName:@"5trampolines.png"];
            break;
    }
    
    if(needAdd) {
        [bonus setTypeOfObject:type];
        [bonus setPosition:pos];
        [self addChild:bonus z:1];
        [_listOfBonuses addObject:bonus];
    }
}

-(void) checkBonuses {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    for(NSUInteger i = [_listOfBonuses count]; i > 0; --i) {
        BonusObject *bonus = (BonusObject *)[_listOfBonuses objectAtIndex:i - 1];
        if(ccpDistance(bonus.position, _hero.position) < 30.0f * kFactor) {
            NSInteger type = bonus.typeOfObject;
            [_listOfBonuses removeObjectAtIndex:i - 1];
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"PowerUp.mp3"];

            levelScores += 100;
            HUDLayer *hl = (HUDLayer *)[self.parent getChildByTag:kHudLayerTag];
            [hl updateScores:levelScores];
            
            switch (type) {
                case 701:
                    [self showCollectedBonuseEffectWithType:5 withPos:bonus.position];
                    availableTrampolines += 5;
                    [self updateTrampolinesCount];
                    break;
                case 702:
                    purpleTrampolines = 0;
                    [self updateTrampolinesPurpleCount];
                    [self showCollectedBonuseEffectWithType:6 withPos:bonus.position];
                    stickyTrampolines += 6;
                    if(availableTrampolines < stickyTrampolines) {
                        stickyTrampolines = availableTrampolines;
                    }
                    [self updateTrampolinesStickCount];
                    break;
                case 703:
                    stickyTrampolines = 0;
                    [self updateTrampolinesStickCount];

                    [self showCollectedBonuseEffectWithType:6 withPos:bonus.position];
                    purpleTrampolines += 6;
                    if(availableTrampolines < purpleTrampolines) {
                        purpleTrampolines = availableTrampolines;
                    }
                    [self updateTrampolinesPurpleCount];
                    break;
                case 704: {
                    GameController *gc = [GameController sharedGameCtrl];
                    [gc setShieldForLevel:appDelegate.currLevel];
                    appDelegate.livesCount += kLivesBonus;
                    [self updateLivesCount];
                    break;
                }
                case 705:
                    [self showCollectedBonuseEffectWithType:1 withPos:bonus.position];
                    bombsCount += 1;
                    [self updateBombsCount];
                    break;
                default:
                    [self showCollectedBonuseEffectWithType:5 withPos:bonus.position];
                    availableTrampolines += 5;
                    [self updateTrampolinesCount];
                    break;
            }
            [bonus removeFromParentAndCleanup:YES];
        }
    }
}

-(void) updateLivesCount {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    if(appDelegate.livesCount < 0) {
        appDelegate.livesCount = 0;
    }
    HUDLayer *hl = (HUDLayer *)[self.parent getChildByTag:kHudLayerTag];
    [hl updateLives:appDelegate.livesCount];
}

-(void) updateTrampolinesCount {
    if(availableTrampolines < 0) {
        availableTrampolines = 0;
    }
    HUDLayer *hl = (HUDLayer *)[self.parent getChildByTag:kHudLayerTag];
    [hl updateTrampolines:availableTrampolines];
}

-(void) updateTrampolinesStickCount {
    if(stickyTrampolines < 0) {
        stickyTrampolines = 0;
    }
    HUDLayer *hl = (HUDLayer *)[self.parent getChildByTag:kHudLayerTag];
    [hl updateTrampolinesStick:stickyTrampolines];
}

-(void) updateTrampolinesPurpleCount {
    if(purpleTrampolines < 0) {
        purpleTrampolines = 0;
    }
    HUDLayer *hl = (HUDLayer *)[self.parent getChildByTag:kHudLayerTag];
    [hl updateTrampolinesPurple:purpleTrampolines];
}

-(void) updateBombsCount {
    if(bombsCount < 0) {
        bombsCount = 0;
    }
    HUDLayer *hl = (HUDLayer *)[self.parent getChildByTag:kHudLayerTag];
    [hl updateBombs:bombsCount];
}

-(void) updateCamera: (ccTime) dt {
    CGPoint layerPos = self.position;
    if(isStickyTrampoline) {
    }
    else if(cameraState == kStateNeedLoadInGun) {
        cameraState = kStateInGun;
        NSInteger deltaX = _hero.gun.position.x + self.position.x - 50 * kFactor;
        id action = [CCMoveBy actionWithDuration:1.2f position:ccp(-deltaX, 0)];
        [self runAction:action];
    }
    else if(cameraState == kStateInGun) {
        
    }
    else {
        if(levelWidth > screenSize.width) {
            float posX = self.position.x - (self.position.x - (-fromRatio([_hero getBody]->GetWorldCenter().x) + screenSize.width / 2.0f - [_hero getBody]->GetLinearVelocity().x * 1.0f)) / 3.0f;
            layerPos.x = posX;
            
            if(layerPos.x > 0) {
                layerPos.x = 0;
            }
            else if(layerPos.x < screenSize.width - levelWidth) {
                layerPos.x = screenSize.width - levelWidth;
            }
            CGPoint bgPos = ccp(-layerPos.x * 0.88f, 0);
            [bg setPosition:bgPos];
        }
        if(levelHeight > screenSize.height) {
            float posY = self.position.y - (self.position.y - (-fromRatio([_hero getBody]->GetWorldCenter().y) + screenSize.height / 2.0f - [_hero getBody]->GetLinearVelocity().y * 1.0f)) / 3.0f;
            layerPos.y = posY;
            if(layerPos.y > 0) {
                layerPos.y = 0;
            }
            else if(layerPos.y < screenSize.height - levelHeight) {
                layerPos.y = screenSize.height - levelHeight;
            }
        }
        CGPoint newPos = ccp(self.position.x - (self.position.x - layerPos.x) * dt * 12.0f,
                             self.position.y - (self.position.y - layerPos.y) * dt * 12.0f);
        [self setPosition:newPos];
    }
}

-(void) deadRabit {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    [appDelegate logLoseLevel:appDelegate.currLevel withReason:@"Enemy character death"];

    [[SimpleAudioEngine sharedEngine] playEffect:@"KilledByEnemy.mp3"];

    [_hero startAnimationShot];
    
    id action = [CCSequence actions:
                 [CCSpawn actions:
                  [CCMoveBy actionWithDuration:1.5f position:ccp(0.0f, -screenSize.height)],
                  [CCRotateBy actionWithDuration:1.5f angle:720.0f],
                  nil],
                 [CCDelayTime actionWithDuration:0.3f],
                 [CCCallFunc actionWithTarget:self selector:@selector(showFailedLevel)],
                 nil];
    [_hero runAction:action];
}

-(void) showContinueScreen {
    if(self.isMenuShown == YES) {
        return;
    }
    [self unscheduleUpdate];

    [[SimpleAudioEngine sharedEngine] playEffect:@"LevelCompleted.mp3"];

    GameController *gC = [GameController sharedGameCtrl];
    if(!gC.wasAllLivesSpend) {
        AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
        [appDelegate logSpendAllLivesWithLevel:appDelegate.currLevel];

        gC.wasAllLivesSpend = YES;
        [gC save];
    }
    
    
    // Added By Hans for Push Notification
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UILocalNotification* local = [[UILocalNotification alloc]init];
    if (local) {
        local.fireDate = [NSDate dateWithTimeIntervalSinceNow:kNotificationTime];
        local.alertBody = kNotificationText;
        local.applicationIconBadgeNumber++;
        //local.timeZone = [NSTimeZone defaultTimeZone];
        
        
        [[UIApplication sharedApplication] scheduleLocalNotification:local];
    }
    
    // Add End
    
    self.isMenuShown = YES;
    ContinueLayer *cl = [ContinueLayer node];
    cl.sceneType = kSceneGameplay;
    [self.parent addChild:cl z:1000];
}

-(void) showReviveScreenWithDelay {
    id action = [CCSequence actions:
                 [CCDelayTime actionWithDuration:1.0f],
                 [CCCallFunc actionWithTarget:self selector:@selector(showReviveScreen)],
                 nil];
    [self runAction:action];
}

-(void) showReviveScreen {
    if(self.isMenuShown == YES) {
        return;
    }
    self.isMenuShown = YES;
    ReviveLayer *rl = [ReviveLayer node];
    [self.parent addChild:rl z:1000];
}

-(void) showLevel {
    isGameStarted = NO;

    //Start level position
    CGPoint startLayerPos = self.position;
    if(levelWidth > screenSize.width) {
        float posX = self.position.x - (self.position.x - (-goalPos.x + screenSize.width / 2.0f));
        startLayerPos.x = posX;
        
        if(startLayerPos.x > 0) {
            startLayerPos.x = 0;
        }
        else if(startLayerPos.x < screenSize.width - levelWidth) {
            startLayerPos.x = screenSize.width - levelWidth;
        }
    }
    if(levelHeight > screenSize.height) {
        float posY = self.position.y - (self.position.y - (-goalPos.y + screenSize.height / 2.0f));
        startLayerPos.y = posY;
        if(startLayerPos.y > 0) {
            startLayerPos.y = 0;
        }
        else if(startLayerPos.y < screenSize.height - levelHeight) {
            startLayerPos.y = screenSize.height - levelHeight;
        }
    }
    [self setPosition:startLayerPos];
    CGPoint bgStartPos = ccp(-startLayerPos.x * 0.88f, 0);
    [bg setPosition:bgStartPos];
    
    //End level position.
    CGPoint endLayerPos = self.position;
    if(levelWidth > screenSize.width) {
        float posX = self.position.x - (self.position.x - (-fromRatio([_hero getBody]->GetWorldCenter().x) + screenSize.width / 2.0f));
        endLayerPos.x = posX;
        
        if(endLayerPos.x > 0) {
            endLayerPos.x = 0;
        }
        else if(endLayerPos.x < screenSize.width - levelWidth) {
            endLayerPos.x = screenSize.width - levelWidth;
        }
    }
    if(levelHeight > screenSize.height) {
        float posY = self.position.y - (self.position.y - (-fromRatio([_hero getBody]->GetWorldCenter().y) + screenSize.height / 2.0f));
        endLayerPos.y = posY;
        if(endLayerPos.y > 0) {
            endLayerPos.y = 0;
        }
        else if(endLayerPos.y < screenSize.height - levelHeight) {
            endLayerPos.y = screenSize.height - levelHeight;
        }
    }
    CGPoint bgEndPos = ccp(-endLayerPos.x * 0.88f, 0);

    float time = 2.0f;
    
    if(fabs(startLayerPos.x - endLayerPos.x) > fabs(startLayerPos.y - endLayerPos.y)) {
        time = fabs((startLayerPos.x - endLayerPos.x) / 3000.0f * 10.0f) / kFactor;
    }
    else {
        time = fabs((startLayerPos.y - endLayerPos.y) / 3000.0f * 10.0f) / kFactor;
    }
    
    id action = [CCSequence actions:
                 [CCDelayTime actionWithDuration:1.0f],
                 [CCMoveTo actionWithDuration:time position:endLayerPos],
                 [CCCallFunc actionWithTarget:self selector:@selector(endShowLevel)],
                 nil];
    [self runAction:action];
    
    id action2 = [CCSequence actions:
                 [CCDelayTime actionWithDuration:1.0f],
                 [CCMoveTo actionWithDuration:time position:bgEndPos],
                 nil];
    [bg runAction:action2];
}

-(void) endShowLevel {
    isLevelShown = YES;
    if(isHintShown) {
        return;
    }
    isGameStarted = YES;
    [_hero startAnimationStarryEyed];
}

-(void) saveHero {
    if(!_hero.lastGround) {
        return;
    }
    
    CGPoint heroPos = CGPointZero;
    GroundObject *lastGo = nil;
    
    if(_hero) {
        b2Body *heroBody = [_hero getBody];
        world->DestroyBody(heroBody);
        heroPos = _hero.position;
        lastGo = _hero.lastGround;
        [_hero removeFromParentAndCleanup:YES];
    }

//    NSInteger idx = 0;
//    NSInteger minDistance = 0;
//    
//    for(NSUInteger i = 0; i < [_listOfPlatforms count]; ++i) {
//        GroundObject *go = (GroundObject *)[_listOfPlatforms objectAtIndex:i];
//        CGPoint upPos = ccp(go.position.x, go.position.y + go.contentSize.height / 2.0f);
//        
//        if(i == 0) {
//            minDistance = ccpDistance(upPos, heroPos);
//            idx = i;
//        }
//        else if(minDistance > ccpDistance(upPos, heroPos)) {
//            minDistance = ccpDistance(upPos, heroPos);
//            idx = i;
//        }
//    }
//    GroundObject *goSelected = (GroundObject *)[_listOfPlatforms objectAtIndex:idx];
//    CGPoint upPosSelected = ccp(goSelected.position.x, goSelected.position.y + goSelected.contentSize.height / 2.0f + 40 * kFactor);
//   
//    [self createHeroObject:upPosSelected];
    
    CGPoint upPosSelected = ccp(lastGo.position.x,
                                lastGo.position.y + 160 * kFactor);// lastGo.contentSize.height / 2.0f + 40 * kFactor);
    [self createHeroObject:upPosSelected];
    
    _hero.isStarted = YES;
    _hero.isRun = NO;
    _hero.canWalk = YES;
}

-(void) checkPlatforms {
    for(NSUInteger i = [_listOfPlatforms count]; i > 0; --i) {
        GroundObject *go = (GroundObject *)[_listOfPlatforms objectAtIndex:i - 1];
        
        CGPoint upPos = ccp(go.position.x, go.position.y + go.contentSize.height / 2.0f);
        
        for(NSUInteger j = 0; j < [_listOfEnemies count]; ++j) {
            EnemyObject *eo = (EnemyObject *)[_listOfEnemies objectAtIndex:j];
            
            if(ccpDistance(upPos, eo.position) < 130 * kFactor) {
                [_listOfPlatforms removeObjectAtIndex:i - 1];
                break;
            }
        }
    }
}

-(void) checkBees {
    if(!isBeeExist) {
        return;
    }
    bool beeExist = NO;
    float minDistance = 300.0f * kFactor;
    for(NSUInteger i = 0; i < [_listOfEnemies count]; ++i) {
        EnemyObject *eo = (EnemyObject *)[_listOfEnemies objectAtIndex:i];
        if(eo.enemyType == kEnemyBee || eo.enemyType == kEnemyBlueBee) {
            beeExist = YES;
            float beeDistance = ccpDistance(eo.position, _hero.position);
            if(beeDistance < minDistance) {
                minDistance = beeDistance;
            }
        }
    }
    if(minDistance < 80 * kFactor) {
        [loopBeeSound setPitch:1.0f];
    }
    else {
        [loopBeeSound setPitch:0.0f];
    }
    if(!beeExist) {
        [loopBeeSound stop];
        [loopBeeSound release];
        loopBeeSound = nil;
        isBeeExist = NO;
    }
}

-(void) checkBird {
    if(!isBirdExist) {
        return;
    }
    bool birdExist = NO;
    float minDistance = 300.0f * kFactor;
    for(NSUInteger i = 0; i < [_listOfEnemies count]; ++i) {
        EnemyObject *eo = (EnemyObject *)[_listOfEnemies objectAtIndex:i];
        if(eo.enemyType == kEnemyBird) {
            birdExist = YES;
            float birdDistance = ccpDistance(eo.position, _hero.position);
            if(birdDistance < minDistance) {
                minDistance = birdDistance;
            }
        }
    }
    if(minDistance < 80 * kFactor) {
        [loopBirdSound setPitch:1.0f];
    }
    else {
        [loopBirdSound setPitch:0.0f];
    }
    if(!birdExist) {
        [loopBirdSound stop];
        [loopBirdSound release];
        loopBirdSound = nil;
        isBirdExist = NO;
    }
}

- (bool) checkCrossForPoint1: (CGPoint) start1
                   endPoint1: (CGPoint) end1
                      Point2: (CGPoint) start2
                   endPoint2: (CGPoint) end2 {

    NSTimeInterval deltaTime = [[NSDate date] timeIntervalSinceDate:self.prevTime];

    if(deltaTime > 2.0f) {
        return NO;
    }
    
    CGPoint dir1 = ccpSub(end1, start1);
    CGPoint dir2 = ccpSub(end2, start2);
    
    float a1 = -dir1.y;
    float b1 = dir1.x;
    float d1 = -(a1 * start1.x + b1 * start1.y);
    
    float a2 = -dir2.y;
    float b2 = dir2.x;
    float d2 = -(a2 * start2.x + b2 * start2.y);
    
    float seg1_line2_start = a2 * start1.x + b2 * start1.y + d2;
    float seg1_line2_end = a2 * end1.x + b2 * end1.y + d2;
    
    float seg2_line1_start = a1 * start2.x + b1 * start2.y + d1;
    float seg2_line1_end = a1 * end2.x + b1 * end2.y + d1;
    
    if (seg1_line2_start * seg1_line2_end >= 0 || seg2_line1_start * seg2_line1_end >= 0) {
        return NO;
    }
    
    float u = seg1_line2_start / (seg1_line2_start - seg1_line2_end);
    
    crossPoint = ccpAdd(start1, ccpMult(dir1, u));
    [self createBomb:crossPoint];
    
    return YES;
}

- (void) explodeEnemies: (id) sender {
    BombObject *bo = (BombObject *)sender;
    
    for(NSUInteger i = 0; i < [_listOfBombs count]; ++i) {
        BombObject *currBomb = (BombObject *)[_listOfBombs objectAtIndex:i];
        if(currBomb == bo) {
            [_listOfBombs removeObjectAtIndex:i];
            break;
        }
    }
    
    b2Body *trampoline1 = [bo getTrampoline1];
    if(trampoline1 != nil) {
        GameObject *to = (GameObject*)trampoline1->GetUserData();
        if(to) {
            [to removeFromParentAndCleanup:YES];
        }
        world->DestroyBody(trampoline1);
        trampoline1 = nil;
    }
    
    b2Body *trampoline2 = [bo getTrampoline2];
    if(trampoline2 != nil) {
        GameObject *to = (GameObject*)trampoline2->GetUserData();
        if(to) {
            [to removeFromParentAndCleanup:YES];
        }
        world->DestroyBody(trampoline2);
        trampoline2 = nil;
    }
    
    CGPoint pos = bo.explosionPos;
    for(NSUInteger i = [_listOfEnemies count]; i > 0; --i) {
        EnemyObject *eo = (EnemyObject *)[_listOfEnemies objectAtIndex:i - 1];
        if(ccpDistance(eo.position, pos) < 100 * kFactor) {
            b2Body *body = [eo getBody];
            world->DestroyBody(body);
            [_listOfEnemies removeObject:eo];
            id action = [CCSequence actions:
                         [CCSpawn actions:
                          [CCMoveBy actionWithDuration:1.5f position:ccp(0.0f, -screenSize.height)],
                          [CCRotateBy actionWithDuration:1.5f angle:720.0f],
                          nil],
                         [CCCallFunc actionWithTarget:eo selector:@selector(removeObject)],
                         nil];
            [eo runAction:action];
            [self checkBees];
            [self checkBird];
        }
    }
}

- (void) removeNode: (id) sender {
    CCNode *node = (CCNode *)sender;
    if(node) {
        [node removeFromParentAndCleanup:YES];
    }
}

-(void) startRaabit {
    if(!isHintShown) {
        [self checkPlatforms];
        
        if(isBeeExist) {
            [loopBeeSound stop];
            [loopBeeSound release];
            loopBeeSound = nil;
            loopBeeSound = [[SimpleAudioEngine sharedEngine] soundSourceForFile:@"BeeLoop.mp3"];
            loopBeeSound.looping = YES;
            [loopBeeSound play];
            [loopBeeSound retain];
            [loopBeeSound setPitch:0.0f];
        }
        if(isAirExist) {
            [loopAirSound stop];
            [loopAirSound release];
            loopAirSound = nil;
            loopAirSound = [[SimpleAudioEngine sharedEngine] soundSourceForFile:@"AirVent.mp3"];
            loopAirSound.looping = YES;
            [loopAirSound play];
            [loopAirSound retain];
            [loopAirSound setPitch:0.0f];
        }
        if(isBirdExist) {
//            [loopBirdSound stop];
//            [loopBirdSound release];
//            loopBirdSound = nil;
//            loopBirdSound = [[SimpleAudioEngine sharedEngine] soundSourceForFile:@"Bird.mp3"];
//            loopBirdSound.looping = YES;
//            [loopBirdSound play];
//            [loopBirdSound retain];
//            [loopBirdSound setPitch:0.0f];
        }

        if(levelWidth > screenSize.width || levelHeight > screenSize.height) {
            isGameStarted = NO;
            isLevelShown = NO;
            [self showLevel];
        }
        else {
            [self endShowLevel];
        }
    }
    else {
        if(levelWidth > screenSize.width || levelHeight > screenSize.height) {
            isGameStarted = NO;
            isLevelShown = NO;
            [self showLevel];
        }
        else {
            isLevelShown = YES;
        }
    }
}

-(void) add10Planks {
    self.isMenuShown = NO;
    availableTrampolines += kBuyPlankCount;     //Modified By Hans. Origin availableTrampolines += 10
    [self updateTrampolinesCount];
    [self saveHero];
}

-(void) continueGame {
    self.isMenuShown = NO;
}

-(void) moveBullets: (float) dt {
    for(NSUInteger i = [_listOfBullets count]; i > 0; --i) {
        BulletObject *bullet = (BulletObject *)[_listOfBullets objectAtIndex:i - 1];
        [bullet setPosition:ccp(bullet.position.x + bullet.speedX * dt, bullet.position.y + bullet.speedY * dt)];
        
        if(bullet.position.x > levelWidth || bullet.position.y > levelHeight) {
            [_listOfBullets removeObjectAtIndex:i - 1];
            [bullet removeFromParentAndCleanup:YES];
        }
    }
}

-(void) showCollectedBonuseEffectWithType: (NSInteger) type withPos: (CGPoint) pos {
    CCSprite *effectSprite = nil;
    switch (type) {
        case 1:
            effectSprite = [CCSprite spriteWithSpriteFrameName:@"plus1.png"];
            break;
        case 2:
            effectSprite = [CCSprite spriteWithSpriteFrameName:@"plus2.png"];
            break;
        case 5:
            effectSprite = [CCSprite spriteWithSpriteFrameName:@"plus5.png"];
            break;
        case 6:
            effectSprite = [CCSprite spriteWithSpriteFrameName:@"plus6.png"];
            break;
        case 8:
            effectSprite = [CCSprite spriteWithSpriteFrameName:@"plus8.png"];
            break;
        case 100:
            effectSprite = [CCSprite spriteWithSpriteFrameName:@"plus100.png"];
            break;
        case 250:
            effectSprite = [CCSprite spriteWithSpriteFrameName:@"plus250.png"];
            break;
        default:
            effectSprite = [CCSprite spriteWithSpriteFrameName:@"plus1.png"];
            break;
    }
    [effectSprite setPosition:pos];
    [self addChild:effectSprite z:zHero+1];
    
    id actionEffect = [CCSequence actions:
                       [CCSpawn actions:
                        [CCMoveBy actionWithDuration:1.0f position:ccp(0.0f, 100.0f * kFactor)],
                        [CCFadeOut actionWithDuration:1.0f],
                        nil],
                       [CCCallFuncN actionWithTarget:self selector:@selector(removeNode:)],
                       nil];
    [effectSprite runAction:actionEffect];
}

-(void) showHintAnimationWithType: (NSInteger)type {
    isHintAnimatedShown = YES;
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    
    id callFuncAction = nil;
    switch (type) {
        case kAnimationNormal:
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"hintsAnimationAtl.plist"];
            [appDelegate loadAnimCacheWithName:@"t_plank" delay:0.05f maxFrames:13];
            [appDelegate loadAnimCacheWithName:@"t_rabbit" delay:0.05f maxFrames:38];
            [appDelegate loadAnimCacheWithName:@"t_goal" delay:0.1f maxFrames:9];
            [appDelegate loadAnimCacheWithName:@"t_coins" delay:0.1f maxFrames:9];
            callFuncAction = [CCCallFunc actionWithTarget:self selector:@selector(createHintAnimationNormal)];
            break;
        case kAnimationSticky:
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"hints3AnimationAtl.plist"];
            [appDelegate loadAnimCacheWithName:@"t3_stickyplank" delay:0.05f maxFrames:28];
            [appDelegate loadAnimCacheWithName:@"t3_rabbit" delay:0.05f maxFrames:51];
            callFuncAction = [CCCallFunc actionWithTarget:self selector:@selector(createHintAnimationSticky)];
            break;
        case kAnimationSuper:
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"hints2AnimationAtl.plist"];
            [appDelegate loadAnimCacheWithName:@"t2_superplank" delay:0.05f maxFrames:12];
            [appDelegate loadAnimCacheWithName:@"t2_rabbit" delay:0.05f maxFrames:43];
            [appDelegate loadAnimCacheWithName:@"t_blueBee" delay:0.1f maxFrames:4];
            
            callFuncAction = [CCCallFunc actionWithTarget:self selector:@selector(createHintAnimationSuper)];
            break;
    }
    
    id actionDelay = [CCSequence actions:
                      [CCDelayTime actionWithDuration:0.5f],
                      callFuncAction,
                      nil];
    [self runAction:actionDelay];
}

-(void) createHintAnimationNormal {
    CCSprite *bgSprite = [CCSprite spriteWithSpriteFrameName:@"t_bg.png"];
    [bgSprite setPosition:ccp(kScreenCenterX, kScreenCenterY)];
    [self addChild:bgSprite z:20000 tag:kHintAnimationTag];
    
    CCSprite *bgShadow = [CCSprite spriteWithSpriteFrameName:@"t_shadow.png"];
    [bgShadow setScale:8];
    [bgShadow setPosition:ccp(bgSprite.contentSize.width / 2.0f, bgSprite.contentSize.height / 2.0f)];
    [bgSprite addChild:bgShadow z:-1];

    CCSprite *trampolineSprite = [CCSprite spriteWithSpriteFrameName:@"t_plank_1.png"];
    [trampolineSprite setAnchorPoint:ccp(0.0f, 0.0f)];
    [trampolineSprite setScaleX:0.0f];
    [trampolineSprite setPosition:ccp((100 - 15) * kFactor, (115 - 21) * kFactor)];
    [bgSprite addChild:trampolineSprite z:10];

    CCSprite *trampolineSprite2 = [CCSprite spriteWithSpriteFrameName:@"t_plank_1.png"];
    [trampolineSprite2 setAnchorPoint:ccp(0.0f, 0.0f)];
    [trampolineSprite2 setScaleX:0.0f];
    [trampolineSprite2 setRotation:-5.0f];
    [trampolineSprite2 setPosition:ccp((250 - 15) * kFactor, (85 - 21) * kFactor)];
    [bgSprite addChild:trampolineSprite2 z:10];

    CCSprite *goalSprite = [CCSprite spriteWithSpriteFrameName:@"t_goal_1.png"];
    [goalSprite setPosition:ccp((400 - 15) * kFactor, (195 - 21) * kFactor)];
    [bgSprite addChild:goalSprite z:9];
    
    CCAnimation *animationGoal = [[CCAnimationCache sharedAnimationCache] animationByName:@"t_goal"];
    id actionAnimationGoal = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animationGoal]];
    [goalSprite runAction:actionAnimationGoal];

    //Coin 1
    CCSprite *coin1Sprite = [CCSprite spriteWithSpriteFrameName:@"t_coins_1.png"];
    [coin1Sprite setPosition:ccp((175 - 15) * kFactor, (180 - 21) * kFactor)];
    [bgSprite addChild:coin1Sprite z:9];
    
    CCAnimation *animationCoin1 = [[CCAnimationCache sharedAnimationCache] animationByName:@"t_coins"];
    id actionAnimationCoin1 = [CCAnimate actionWithAnimation:animationCoin1];
    
    id coin1Action = [CCSequence actions:
                      [CCDelayTime actionWithDuration:2.4f],
                      actionAnimationCoin1,
                      [CCCallFuncN actionWithTarget:self selector:@selector(removeNode:)],
                      nil];
    [coin1Sprite runAction:coin1Action];
    
    //Coin 2
    CCSprite *coin2Sprite = [CCSprite spriteWithSpriteFrameName:@"t_coins_1.png"];
    [coin2Sprite setPosition:ccp((230 - 15) * kFactor, (215 - 21) * kFactor)];
    [bgSprite addChild:coin2Sprite z:9];

    CCAnimation *animationCoin2 = [[CCAnimationCache sharedAnimationCache] animationByName:@"t_coins"];
    id actionAnimationCoin2 = [CCAnimate actionWithAnimation:animationCoin2];
    
    id coin2Action = [CCSequence actions:
                      [CCDelayTime actionWithDuration:2.7f],
                      actionAnimationCoin2,
                      [CCCallFuncN actionWithTarget:self selector:@selector(removeNode:)],
                      nil];
    [coin2Sprite runAction:coin2Action];

    //Coin 3
    CCSprite *coin3Sprite = [CCSprite spriteWithSpriteFrameName:@"t_coins_1.png"];
    [coin3Sprite setPosition:ccp((285 - 15) * kFactor, (180 - 21) * kFactor)];
    [bgSprite addChild:coin3Sprite z:9];

    CCAnimation *animationCoin3 = [[CCAnimationCache sharedAnimationCache] animationByName:@"t_coins"];
    id actionAnimationCoin3 = [CCAnimate actionWithAnimation:animationCoin3];
    
    id coin3Action = [CCSequence actions:
                      [CCDelayTime actionWithDuration:3.0f],
                      actionAnimationCoin3,
                      [CCCallFuncN actionWithTarget:self selector:@selector(removeNode:)],
                      nil];
    [coin3Sprite runAction:coin3Action];

    
    CCSprite *rabbitSprite = [CCSprite spriteWithSpriteFrameName:@"t_rabbit_1.png"];
    [rabbitSprite setPosition:ccp((50 - 15) * kFactor, (192 - 21) * kFactor)];
    [bgSprite addChild:rabbitSprite z:10];

    CCSprite *handSprite = [CCSprite spriteWithSpriteFrameName:@"t_hand.png"];
    [handSprite setPosition:ccp(kScreenCenterX, -kScreenHeight / 2.0f)];
    [bgSprite addChild:handSprite z:10];

    //Rabbit
    CCAnimation *animationRabbit = [[CCAnimationCache sharedAnimationCache] animationByName:@"t_rabbit"];
    id actionAnimationRabbit = [CCSequence actions:
                                [CCDelayTime actionWithDuration:0.8f],
                                [CCAnimate actionWithAnimation:animationRabbit],
                                nil];
    [rabbitSprite runAction:actionAnimationRabbit];
    
    id rabbitAction = [CCSequence actions:
                       [CCDelayTime actionWithDuration:0.8f],
                       [CCMoveBy actionWithDuration:0.6f position:ccp(45 * kFactor, 0)],
                       [CCDelayTime actionWithDuration:0.1f],
                       [CCMoveBy actionWithDuration:0.2f position:ccp(10 * kFactor, 10 * kFactor)],
                       [CCMoveBy actionWithDuration:0.55f position:ccp(40 * kFactor, -45 * kFactor)],
                       [CCMoveBy actionWithDuration:0.5f position:ccp(65 * kFactor, 50 * kFactor)],
                       [CCMoveBy actionWithDuration:0.5f position:ccp(68 * kFactor, -70 * kFactor)],
                       [CCMoveBy actionWithDuration:0.6f position:ccp(75 * kFactor, 40 * kFactor)],
                       [CCSpawn actions:
                        [CCMoveBy actionWithDuration:0.6f position:ccp(40 * kFactor, 15 * kFactor)],
                        [CCRotateBy actionWithDuration:0.6f angle:360.0f],
                        [CCScaleTo actionWithDuration:0.6f scale:0.0f],
                        nil],
                       nil];
    [rabbitSprite runAction:rabbitAction];
    
    //Trampoline 1
    CCAnimation *animationTrampoline = [[CCAnimationCache sharedAnimationCache] animationByName:@"t_plank"];
    id actionAnimationTrampoline = [CCAnimate actionWithAnimation:animationTrampoline];
    
    id trampolineAction = [CCSequence actions:
                           [CCDelayTime actionWithDuration:0.8f + 0.75f],
                           [CCScaleTo actionWithDuration:0.4f scaleX:1.0f scaleY:1.0f],
                           [CCDelayTime actionWithDuration:0.35f],
                           actionAnimationTrampoline,
                           [CCFadeOut actionWithDuration:0.3f],
                           [CCCallFuncN actionWithTarget:self selector:@selector(removeNode:)],
                           
                           nil];
    [trampolineSprite runAction:trampolineAction];

    //Trampoline 2
    CCAnimation *animationTrampoline2 = [[CCAnimationCache sharedAnimationCache] animationByName:@"t_plank"];
    id actionAnimationTrampoline2 = [CCAnimate actionWithAnimation:animationTrampoline2];
    
    id trampolineAction2 = [CCSequence actions:
                            [CCDelayTime actionWithDuration:1.1f],
                            [CCDelayTime actionWithDuration:0.8f + 0.75f],
                            [CCScaleTo actionWithDuration:0.4f scaleX:1.0f scaleY:1.0f],
                            [CCDelayTime actionWithDuration:0.25f],
                            actionAnimationTrampoline2,
                            [CCFadeOut actionWithDuration:0.3f],
                            [CCCallFuncN actionWithTarget:self selector:@selector(removeNode:)],
                            nil];
    [trampolineSprite2 runAction:trampolineAction2];

    //Hand
    id handAction = [CCSequence actions:
                     [CCDelayTime actionWithDuration:0.8f + 0.45f],
                     [CCMoveTo actionWithDuration:0.25f position:ccp((180 - 15) * kFactor, (88 - 21) * kFactor)],
                     [CCDelayTime actionWithDuration:0.05f],
                     [CCMoveBy actionWithDuration:0.4f position:ccp(100 * kFactor, -20 * kFactor)],
                     [CCDelayTime actionWithDuration:0.1f],
                     [CCJumpBy actionWithDuration:0.5f position:ccp(50 * kFactor, -16 * kFactor) height:5 * kFactor jumps:1],
                     [CCDelayTime actionWithDuration:0.1f],
                     [CCMoveBy actionWithDuration:0.4f position:ccp(105 * kFactor, -10 * kFactor)],
                     [CCMoveTo actionWithDuration:0.35f position:ccp(0, -kScreenHeight / 2.0f)],
                     nil];
    [handSprite runAction:handAction];

    //Closes
    MyMenuItemSprite *closeItem = [MyMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"t_green_button.png"]
                                                          selectedSprite:nil
                                                          disabledSprite:[CCSprite spriteWithSpriteFrameName:@"t_green_button_d.png"]
                                                                  target:self
                                                                selector:@selector(hideHintAnimation)];
    [closeItem setPosition:ccp(bgSprite.contentSize.width / 2.0f + 40 * kFactor, 30 * kFactor)];
    [closeItem setIsEnabled:NO];
    
    id buttonAction = [CCSequence actions:
                       [CCDelayTime actionWithDuration:2.75f],
                       [CCCallFuncN actionWithTarget:self selector:@selector(activateButton:)],
                       nil];
    [closeItem runAction:buttonAction];

    
    MyMenuItemSprite *restartItem = [MyMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"t_green_button2.png"]
                                                            selectedSprite:nil
                                                            disabledSprite:nil
                                                                    target:self
                                                                  selector:@selector(restartHintAnimation)];
    [restartItem setPosition:ccp(bgSprite.contentSize.width / 2.0f - 40 * kFactor, 30 * kFactor)];

	CCMenu *menu = [CCMenu menuWithItems:closeItem, restartItem, nil];
	[menu setPosition:CGPointZero];
	[bgSprite addChild: menu z:20];
}

-(void) createHintAnimationSticky {
    CCSprite *bgSprite = [CCSprite spriteWithSpriteFrameName:@"t3_bg.png"];
    [bgSprite setPosition:ccp(kScreenCenterX, kScreenCenterY)];
    [self addChild:bgSprite z:20000 tag:kHintAnimationTag];
    
    CCSprite *bgShadow = [CCSprite spriteWithSpriteFrameName:@"t3_shadow.png"];
    [bgShadow setScale:8];
    [bgShadow setPosition:ccp(bgSprite.contentSize.width / 2.0f, bgSprite.contentSize.height / 2.0f)];
    [bgSprite addChild:bgShadow z:-1];
    
    CCSprite *trampolineSprite = [CCSprite spriteWithSpriteFrameName:@"t3_stickyplank_1.png"];
    [trampolineSprite setAnchorPoint:ccp(0.0f, 0.0f)];
    [trampolineSprite setScaleX:0.0f];
    [trampolineSprite setPosition:ccp(222 * kFactor - 80 * kFactor, 68 * kFactor)];
    [bgSprite addChild:trampolineSprite z:10];
    
    CCSprite *rabbitSprite = [CCSprite spriteWithSpriteFrameName:@"t3_rabbit_1.png"];
    [rabbitSprite setPosition:ccp(80 * kFactor, 162 * kFactor)];
    [bgSprite addChild:rabbitSprite z:10];
    
    CCSprite *handSprite = [CCSprite spriteWithSpriteFrameName:@"t3_hand.png"];
    [handSprite setPosition:ccp(kScreenCenterX, -kScreenHeight / 2.0f)];
    [bgSprite addChild:handSprite z:10];
    
    //Rabbit
    CCAnimation *animationRabbit = [[CCAnimationCache sharedAnimationCache] animationByName:@"t3_rabbit"];
    id actionAnimationRabbit = [CCSequence actions:
                                [CCDelayTime actionWithDuration:0.8f],
                                [CCAnimate actionWithAnimation:animationRabbit],
                                nil];
    [rabbitSprite runAction:actionAnimationRabbit];
    
    id rabbitAction = [CCSequence actions:
                       [CCDelayTime actionWithDuration:0.8f],
                       [CCMoveBy actionWithDuration:0.6f position:ccp(45 * kFactor, 0)],
                       [CCDelayTime actionWithDuration:0.1f],
                       [CCMoveBy actionWithDuration:0.15f position:ccp(12 * kFactor, 10 * kFactor)],
                       [CCMoveBy actionWithDuration:0.5f position:ccp(42 * kFactor, -45 * kFactor)],
                       
                       [CCMoveBy actionWithDuration:0.38f position:ccp(-5 * kFactor, 17 * kFactor)],
                       [CCDelayTime actionWithDuration:0.0f],
                       [CCMoveBy actionWithDuration:0.30f position:ccp(5 * kFactor, -20 * kFactor)],

                       [CCDelayTime actionWithDuration:0.3f],
                       [CCMoveBy actionWithDuration:0.5f position:ccp(65 * kFactor, 30 * kFactor)],
                       nil];
    [rabbitSprite runAction:rabbitAction];
    
    //Trampoline
    CCAnimation *animationTrampoline = [[CCAnimationCache sharedAnimationCache] animationByName:@"t3_stickyplank"];
    id actionAnimationTrampoline = [CCAnimate actionWithAnimation:animationTrampoline];
    
    id trampolineAction = [CCSequence actions:
                           [CCDelayTime actionWithDuration:0.8f + 0.4f],
                           [CCScaleTo actionWithDuration:0.4f scaleX:1.0f scaleY:1.0f],
                           [CCDelayTime actionWithDuration:0.35f],
                           actionAnimationTrampoline,
                           nil];
    [trampolineSprite runAction:trampolineAction];
    
    //Hand
    id handAction = [CCSequence actions:
                     [CCDelayTime actionWithDuration:0.8f + 0.1f],
                     [CCMoveTo actionWithDuration:0.25f position:ccp(220 * kFactor, 44 * kFactor)],
                     [CCDelayTime actionWithDuration:0.05f],
                     [CCMoveBy actionWithDuration:0.4f position:ccp(110 * kFactor, 10 * kFactor)],
                     [CCDelayTime actionWithDuration:0.5f],

                     [CCMoveBy actionWithDuration:0.33f position:ccp(-14 * kFactor, 46 * kFactor)],
                     [CCDelayTime actionWithDuration:0.15f],
                     [CCMoveBy actionWithDuration:0.38f position:ccp(8 * kFactor, -68 * kFactor)],
                     
                     [CCDelayTime actionWithDuration:0.25f],
                     [CCMoveTo actionWithDuration:0.35f position:ccp(0, -kScreenHeight / 2.0f)],
                     nil];
    [handSprite runAction:handAction];
    
    //Closes
    MyMenuItemSprite *closeItem = [MyMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"t3_green_button.png"]
                                                          selectedSprite:nil
                                                          disabledSprite:[CCSprite spriteWithSpriteFrameName:@"t3_green_button_d.png"]
                                                                  target:self
                                                                selector:@selector(hideHintAnimation)];
    [closeItem setPosition:ccp(bgSprite.contentSize.width / 2.0f + 40 * kFactor, 30 * kFactor)];
    [closeItem setIsEnabled:NO];
    
    id buttonAction = [CCSequence actions:
                       [CCDelayTime actionWithDuration:2.75f],
                       [CCCallFuncN actionWithTarget:self selector:@selector(activateButton:)],
                       nil];
    [closeItem runAction:buttonAction];
    
    MyMenuItemSprite *restartItem = [MyMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"t3_green_button2.png"]
                                                            selectedSprite:nil
                                                            disabledSprite:nil
                                                                    target:self
                                                                  selector:@selector(restartHintAnimation)];
    [restartItem setPosition:ccp(bgSprite.contentSize.width / 2.0f - 40 * kFactor, 30 * kFactor)];
    
	CCMenu *menu = [CCMenu menuWithItems:closeItem, restartItem, nil];
	[menu setPosition:CGPointZero];
	[bgSprite addChild: menu z:20];
}

-(void) createHintAnimationSuper {
    CCSprite *bgSprite = [CCSprite spriteWithSpriteFrameName:@"t2_bg.png"];
    [bgSprite setPosition:ccp(kScreenCenterX, kScreenCenterY)];
    [self addChild:bgSprite z:20000 tag:kHintAnimationTag];
    
    CCSprite *bgShadow = [CCSprite spriteWithSpriteFrameName:@"t2_shadow.png"];
    [bgShadow setScale:8];
    [bgShadow setPosition:ccp(bgSprite.contentSize.width / 2.0f, bgSprite.contentSize.height / 2.0f)];
    [bgSprite addChild:bgShadow z:-1];
    
    CCSprite *trampolineSprite = [CCSprite spriteWithSpriteFrameName:@"t2_superplank_1.png"];
    [trampolineSprite setAnchorPoint:ccp(0.9f, 0.5f)];
    [trampolineSprite setScaleX:0.0f];
    [trampolineSprite setScaleY:0.8f];
    [trampolineSprite setRotation:8.0f];
    [trampolineSprite setPosition:ccp(262 * kFactor, 85 * kFactor)];
    [bgSprite addChild:trampolineSprite z:10];
    
    CCSprite *rabbitSprite = [CCSprite spriteWithSpriteFrameName:@"t2_rabbit_1.png"];
    [rabbitSprite setPosition:ccp(80 * kFactor, 162 * kFactor)];
    [bgSprite addChild:rabbitSprite z:10];
    
    CCSprite *handSprite = [CCSprite spriteWithSpriteFrameName:@"t2_hand.png"];
    [handSprite setPosition:ccp(kScreenCenterX, -kScreenHeight / 2.0f)];
    [bgSprite addChild:handSprite z:10];
    
    //Rabbit
    CCAnimation *animationRabbit = [[CCAnimationCache sharedAnimationCache] animationByName:@"t2_rabbit"];
    id actionAnimationRabbit = [CCSequence actions:
                                [CCDelayTime actionWithDuration:0.8f],
                                [CCAnimate actionWithAnimation:animationRabbit],
                                nil];
    [rabbitSprite runAction:actionAnimationRabbit];
    
    id rabbitAction = [CCSequence actions:
                       [CCDelayTime actionWithDuration:0.8f],
                       [CCMoveBy actionWithDuration:0.6f position:ccp(45 * kFactor, 0)],
                       [CCDelayTime actionWithDuration:0.1f],
                       [CCMoveBy actionWithDuration:0.2f position:ccp(10 * kFactor, 10 * kFactor)],
                       [CCMoveBy actionWithDuration:0.55f position:ccp(40 * kFactor, -45 * kFactor)],
                       [CCMoveBy actionWithDuration:0.5f position:ccp(125 * kFactor, 65 * kFactor)],
                       nil];
    [rabbitSprite runAction:rabbitAction];
    
    //Bee
    CCSprite *beeSprite = [CCSprite spriteWithSpriteFrameName:@"t_blueBee_1.png"];
    [beeSprite setPosition:ccp(227 * kFactor, 170 * kFactor)];
    [bgSprite addChild:beeSprite z:10];

    CCAnimation *animationBee = [[CCAnimationCache sharedAnimationCache] animationByName:@"t_blueBee"];
    id actionAnimationBee = [CCRepeatForever actionWithAction:
                                [CCAnimate actionWithAnimation:animationBee]];
    [beeSprite runAction:actionAnimationBee];
    
    id action = [CCSequence actions:
                 [CCDelayTime actionWithDuration:2.5f],
                 [CCSpawn actions:
                  [CCMoveBy actionWithDuration:0.8f position:ccp(0.0f, -150 * kFactor)],
                  [CCRotateBy actionWithDuration:0.8f angle:560.0f],
                  nil],
                 nil];
    [beeSprite runAction:action];

    //Trampoline
    CCAnimation *animationTrampoline = [[CCAnimationCache sharedAnimationCache] animationByName:@"t2_superplank"];
    id actionAnimationTrampoline = [CCAnimate actionWithAnimation:animationTrampoline];
    
    id trampolineAction = [CCSequence actions:
                           [CCDelayTime actionWithDuration:0.8f + 0.75f],
                           [CCScaleTo actionWithDuration:0.4f scaleX:0.8f scaleY:0.8f],
                           [CCDelayTime actionWithDuration:0.35f],
                           actionAnimationTrampoline,
                           nil];
    [trampolineSprite runAction:trampolineAction];
    
    //Hand
    id handAction = [CCSequence actions:
                     [CCDelayTime actionWithDuration:0.8f + 0.45f],
                     [CCMoveTo actionWithDuration:0.25f position:ccp(340 * kFactor, 34 * kFactor)],
                     [CCDelayTime actionWithDuration:0.05f],
                     [CCMoveBy actionWithDuration:0.4f position:ccp(-150 * kFactor, 24 * kFactor)],
                     [CCMoveTo actionWithDuration:0.35f position:ccp(0, -kScreenHeight / 2.0f)],
                     nil];
    [handSprite runAction:handAction];
    
    //Closes
    MyMenuItemSprite *closeItem = [MyMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"t2_green_button.png"]
                                                          selectedSprite:nil
                                                          disabledSprite:[CCSprite spriteWithSpriteFrameName:@"t2_green_button_d.png"]
                                                                  target:self
                                                                selector:@selector(hideHintAnimation)];
    [closeItem setPosition:ccp(bgSprite.contentSize.width / 2.0f + 40 * kFactor, 30 * kFactor)];
    [closeItem setIsEnabled:NO];
    
    id buttonAction = [CCSequence actions:
                       [CCDelayTime actionWithDuration:2.75f],
                       [CCCallFuncN actionWithTarget:self selector:@selector(activateButton:)],
                       nil];
    [closeItem runAction:buttonAction];
    
    MyMenuItemSprite *restartItem = [MyMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"t2_green_button2.png"]
                                                            selectedSprite:nil
                                                            disabledSprite:nil
                                                                    target:self
                                                                  selector:@selector(restartHintAnimation)];
    [restartItem setPosition:ccp(bgSprite.contentSize.width / 2.0f - 40 * kFactor, 30 * kFactor)];
    
	CCMenu *menu = [CCMenu menuWithItems:closeItem, restartItem, nil];
	[menu setPosition:CGPointZero];
	[bgSprite addChild: menu z:20];
}

-(void) activateButton: (id) sender {
    MyMenuItemSprite *mm = (MyMenuItemSprite *)sender;
    [mm setIsEnabled:YES];
}

-(void) hideHintAnimation {
    isHintAnimatedShown = NO;
    CCSprite *bgSprite = (CCSprite *)[self getChildByTag:kHintAnimationTag];
    if(bgSprite) {
        [bgSprite removeFromParentAndCleanup:YES];
    }
    switch (currAnimationID) {
        case kAnimationNormal:
            [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"hintsAnimationAtl.plist"];
            break;
        case kAnimationSticky:
            [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"hints3AnimationAtl.plist"];
            break;
        case kAnimationSuper:
            [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"hints2AnimationAtl.plist"];
            break;
    }
    [self startRaabit];
}

-(void) restartHintAnimation {
    CCSprite *bgSprite = (CCSprite *)[self getChildByTag:kHintAnimationTag];
    if(bgSprite) {
        [bgSprite removeFromParentAndCleanup:YES];
    }
    switch (currAnimationID) {
        case kAnimationNormal:
            [self createHintAnimationNormal];
            break;
        case kAnimationSticky:
            [self createHintAnimationSticky];
            break;
        case kAnimationSuper:
            [self createHintAnimationSuper];
            break;
    }
}

#pragma mark -
#pragma mark Coins

-(void) createCoin: (CGPoint) pos {
    CoinObject *coin = [CoinObject spriteWithSpriteFrameName:@"coin_1.png"];
    [coin startAnimationRotate];
    [coin setPosition:pos];
    [self addChild:coin z:1];
    [_listOfCoins addObject:coin];
    ++[GameController sharedGameCtrl].totalCoins;
}

-(void) checkCoins {
    for(NSUInteger i = [_listOfCoins count]; i > 0; --i) {
        CoinObject *coin = (CoinObject *)[_listOfCoins objectAtIndex:i - 1];
        if(ccpDistance(coin.position, _hero.position) < 30.0f * kFactor) {
            [_listOfCoins removeObjectAtIndex:i - 1];
            
            if([self addCollectedCarrot]) {
                [self showComboEffectWithPos:coin.position];
            }
            
            [coin collectAnimation];
            levelScores += 50;
            ++[GameController sharedGameCtrl].collectedCoins;
            HUDLayer *hl = (HUDLayer *)[self.parent getChildByTag:kHudLayerTag];
            [hl updateScores:levelScores];
            [hl updateCoins:[GameController sharedGameCtrl].collectedCoins withTotal:[GameController sharedGameCtrl].totalCoins];
            if([GameController sharedGameCtrl].collectedCoins == [GameController sharedGameCtrl].totalCoins) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"Woohoo.mp3"];
            }
            [[SimpleAudioEngine sharedEngine] playEffect:[NSString stringWithFormat:@"%ldCoin.mp3", (long)coinNumber]];
            ++coinNumber;
            if (coinNumber > 5) {
                coinNumber = 1;
            }
            
            if(!_hero.isGoalAvailable || !isGoalAnimated) {
                if([[GameController sharedGameCtrl] collectedCoins] >= 1) {
                    _hero.isGoalAvailable = YES;
                    GoalObject *go = (GoalObject *)[self getChildByTag:kTagGoal];
                    [go startAnimationGoal];
                    isGoalAnimated = YES;
                }
            }
        }
    }
}

-(void) showComboEffectWithPos: (CGPoint) pos {
    [[SimpleAudioEngine sharedEngine] playEffect:@"carrot_combo.mp3"];
    CCSprite *effect = [CCSprite spriteWithSpriteFrameName:@"carrot_combo_1.png"];
    [effect setPosition:pos];
    [self addChild:effect z:zHint - 1];
    
    CCAnimation *animation = [[CCAnimationCache sharedAnimationCache] animationByName:@"carrot_combo"];
    id action = [CCSequence actions:
                 [CCAnimate actionWithAnimation:animation],
                 [CCCallFuncN actionWithTarget:self selector:@selector(removeNode:)],
                 nil];
    [effect runAction:action];
    
    levelScores += 250;
    HUDLayer *hl = (HUDLayer *)[self.parent getChildByTag:kHudLayerTag];
    [hl updateScores:levelScores];
    [self showCollectedBonuseEffectWithType:250 withPos:ccp(pos.x, pos.y + 20 * kFactor)];
}

-(bool) addCollectedCarrot {
    ++collectedCarrots;
    id action = [CCSequence actions:
                 [CCDelayTime actionWithDuration:2.0f],
                 [CCCallFunc actionWithTarget:self selector:@selector(removeCollectedCarrot)],
                 nil];
    [coinsCounterNode runAction:action];
    if(collectedCarrots >= 6) {
        collectedCarrots = 0;
        [coinsCounterNode stopAllActions];
        return YES;
    }
    return NO;
}

-(void) removeCollectedCarrot {
    if(collectedCarrots > 0) {
        --collectedCarrots;
    }
}

//calculates the point where the object will be after nth iterations for a given start point and start velocity
-(b2Vec2) getTrajectoryPoint:(b2Vec2) startingPosition andStartVelocity:(b2Vec2) startingVelocity andSteps: (float)n {
    //velocity and gravity are given per second but we want time step values here
    // seconds per time step (at 60fps)
    float t = 1 / 60.0f;
    
    // m/s
    b2Vec2 stepVelocity = t * startingVelocity;
    
    // m/s/s
    b2Vec2 stepGravity = t * t * world->GetGravity();
    
    return startingPosition + n * stepVelocity + 0.5f * (n*n+n) * stepGravity;
}

// Added By Hans
-(void) showAdInterstitial {
    UIViewController *rootViewController = (UIViewController *)[[[CCDirector sharedDirector] openGLView] nextResponder];
    if ([AdTapsy isInterstitialReadyToShow]) {
        NSLog(@"Ad is ready be shown");
        [AdTapsy showInterstitial:rootViewController];
    } else {
        NSLog(@"Ad is not ready to be shown");
    }
}

@end