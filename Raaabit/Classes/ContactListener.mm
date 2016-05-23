//
//  ContactListener.mm
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright Dmitry Valov 2013. All rights reserved.
//

#import "ContactListener.h"
#import "GameLayer.h"
#import "GameObject.h"
#import "Constants.h"
#import "HeroObject.h"
#import "EnemyObject.h"
#import "Constants.h"
#import "TrampolineObject.h"
#import "BearObject.h"
#import "TurtleObject.h"
#import "GroundObject.h"
#import "AirductObject.h"
#import "SimpleAudioEngine.h"
#import "GunObject.h"

void ContactListener::BeginContact(b2Contact* contact) {
	b2Body* body1 = contact->GetFixtureA()->GetBody();
	b2Body* body2 = contact->GetFixtureB()->GetBody();
	GameObject* object1 = (GameObject*)body1->GetUserData();
	GameObject* object2 = (GameObject*)body2->GetUserData();
    b2Fixture *fixture2 = nil;
    
    if(object2.typeOfObject == kTypeHero) {
        object1 = (GameObject*)body2->GetUserData();
        object2 = (GameObject*)body1->GetUserData();
        fixture2 = contact->GetFixtureA();
        
        body2 = contact->GetFixtureA()->GetBody();
        body1 = contact->GetFixtureB()->GetBody();
    }
    else {
        fixture2 = contact->GetFixtureB();
    }

    if(object1.typeOfObject == kTypeHero) {
        if(object2.typeOfObject == kTypeGoal) {
            HeroObject *ho = (HeroObject *)object1;
            if(ho.isGoalAvailable) {
                object1.state = kStateGoalAchieved;
                ((HeroObject*)object1).goalPosition = object2.position;
            }
            else {
                [[SimpleAudioEngine sharedEngine] playEffect:@"BumpWall.mp3"];
                if(object1.position.x < object2.position.x) {
                    ((HeroObject *)object1).moveType = kMoveLeft;
                }
                else {
                    ((HeroObject *)object1).moveType = kMoveRight;
                }
            }
        }
        else if(object2.typeOfObject == kTypePlatform) {
            ((HeroObject*)object1).isKillMode = NO;
            NSInteger idx = fixture2->GetFilterData().groupIndex;
            if(idx == kGroupIndexGround) {
                ((HeroObject*)object1).lastGround = (GroundObject*)object2;
                [((HeroObject*)object1) addConnection];
            }
//            else if(idx == kGroupIndexNotGround) {
//                if(((HeroObject *)object1).position.x < ((GroundObject *)object2).position.x) {
//                    ((HeroObject *)object1).moveType = kMoveLeft;
//                }
//                else {
//                    ((HeroObject *)object1).moveType = kMoveRight;
//                }
//                NSLog(@"Rotate");
//            }
            object2.state = kStateNeedSwing;
            ((HeroObject*)object1).speedFactor = 1.0f;
        }
        else if(object2.typeOfObject == kTypeTrampoline && object1.state != kStateSticked) {
            TrampolineObject *to = (TrampolineObject *)object2;
            if(to.trampolineType == kTrampolinePurple) {
                ((HeroObject*)object1).speedFactor = 1.2f;
                ((HeroObject*)object1).isKillMode = YES;
            }
            else {
                ((HeroObject*)object1).speedFactor = 1.0f;
                ((HeroObject*)object1).isKillMode = NO;
            }
            object2.state = kStateNeedRemove;
        }
        else if(object2.typeOfObject == kTypeEnemy && object2.state != kStateNeedDead) {
            EnemyObject *eo = (EnemyObject*)object2;
            if(eo.enemyType == kEnemyBee) {
                object1.state = kStateNeedDead;
            }
            else if(eo.enemyType == kEnemyBear) {
                BearObject *bo = (BearObject *)object2;
                if(bo.isInRoar &&
                   ((HeroObject*)object1).isKillMode == NO) {
                    object1.state = kStateNeedDead;
                }
                else {
                    if(object1.position.y > object2.position.y + 10 * kFactor ||
                       ((HeroObject*)object1).isKillMode == YES) {
                        if([bo loseLife]) {
                            object2.state = kStateNeedDead;
                        }
                    }
                    else {
                        object1.state = kStateNeedDead;
                    }
                }
            }
            else if(eo.enemyType == kEnemyTurtle) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"BumpWall.mp3"];
                if(object1.position.x < object2.position.x) {
                    ((HeroObject *)object1).moveType = kMoveLeft;
                }
                else {
                    ((HeroObject *)object1).moveType = kMoveRight;
                }
            }
            else {
                if(object1.position.y > object2.position.y + 10 * kFactor ||
                   ((HeroObject*)object1).isKillMode == YES) {
                    object2.state = kStateNeedDead;
                }
                else {
                    object1.state = kStateNeedDead;
                }
            }
            
            ((HeroObject*)object1).isKillMode = NO;
        }
        else if(object2.typeOfObject == kTypeAirduct) {
            if(fixture2->IsSensor()) {
                AirductObject *ao = (AirductObject *)object2;
                HeroObject *ho = (HeroObject *)object1;
                [ho setInFlowWithAngle:[ao getAngleForAir]];
            }
            else {
                NSInteger idx = fixture2->GetFilterData().groupIndex;
                if(idx == kGroupIndexGround) {
                    [((HeroObject*)object1) addConnection];
                }
            }
        }
        else if(object1.state != kStateNeedShoot && object2.typeOfObject == kTypeCannon) {
            ((HeroObject*)object1).isKillMode = NO;
            object1.state = kStateNeedLoad;
            ((HeroObject*)object1).cannon = (CannonObject*)object2;
        }
        else if(object1.state != kStateInGun && object2.typeOfObject == kTypeGun) {
            ((HeroObject*)object1).isKillMode = NO;
            GunObject *go = (GunObject *)object2;
            if(!go.alreadyUsed) {
                object1.state = kStateNeedLoadInGun;
                ((HeroObject*)object1).gun = go;
            }
        }
        
        //
        NSInteger idx = fixture2->GetFilterData().groupIndex;
        if(idx == kGroupIndexNotGround) {
            ((HeroObject*)object1).isKillMode = NO;
            [[SimpleAudioEngine sharedEngine] playEffect:@"BumpWall.mp3"];
            if(((HeroObject *)object1).position.x < ((GroundObject *)object2).position.x) {
                ((HeroObject *)object1).moveType = kMoveLeft;
            }
            else {
                ((HeroObject *)object1).moveType = kMoveRight;
            }
        }
    }
    else {
        b2Body* boulderBody = body1;
        if(object2.typeOfObject == kTypeBoulder) {
            object1 = (GameObject*)body2->GetUserData();
            object2 = (GameObject*)body1->GetUserData();
            boulderBody = body2;
        }
        
        if(object1.typeOfObject == kTypeBoulder && object2.typeOfObject == kTypeEnemy) {
            object2.state = kStateNeedDead;
            boulderBody->SetLinearVelocity(b2Vec2(0, 0));
        }
        else if(object1.typeOfObject == kTypeBoulder && object2.typeOfObject == kTypeTrampoline) {
            object2.state = kStateNeedRemoveBoulder;
        }
    }
}

void ContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold) {
}

void ContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {
}

void ContactListener::EndContact(b2Contact* contact) {
	b2Body* body1 = contact->GetFixtureA()->GetBody();
	b2Body* body2 = contact->GetFixtureB()->GetBody();
	GameObject* object1 = (GameObject*)body1->GetUserData();
	GameObject* object2 = (GameObject*)body2->GetUserData();
    b2Fixture *fixture2 = nil;
    
    if(object2.typeOfObject == kTypeHero) {
        body1 = contact->GetFixtureB()->GetBody();
        body2 = contact->GetFixtureA()->GetBody();
        object1 = (GameObject*)body1->GetUserData();
        object2 = (GameObject*)body2->GetUserData();
        fixture2 = contact->GetFixtureA();
    }
    else {
        fixture2 = contact->GetFixtureB();
    }
    
    if(object1.typeOfObject == kTypeHero && (object2.typeOfObject == kTypePlatform || object2.typeOfObject == kTypeAirduct)) {
        NSInteger idx = fixture2->GetFilterData().groupIndex;
        if(idx == kGroupIndexGround) {
            [((HeroObject*)object1) removeConnection];
        }
    }
    else if(object1.typeOfObject == kTypeHero && object2.typeOfObject == kTypeTrampoline) {
        if(((HeroObject *)object1).position.x < ((TrampolineObject*)object2).centerPos.x) {
            ((HeroObject *)object1).moveType = kMoveLeft;
        }
        else {
            ((HeroObject *)object1).moveType = kMoveRight;
        }
    }
}
