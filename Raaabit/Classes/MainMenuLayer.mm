//
//  MainMenuLayer.m
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "MainMenuLayer.h"
#import "Constants.h"
#import "SelectAreaLayer.h"
#import "AppDelegate.h"
#import "SimpleAudioEngine.h"

#import "ContinueLayer.h"
#import "ShopLayer.h"
#import "DifficultyLayer.h"

#import "NoCarrotsLayer.h"
#import "ContinuePackLayer.h"

#import "ReviveLayer.h"
#import "OptionsLayer.h"
#import "GameController.h"

#import "Appirater/Appirater.h"
#import "PW_SBJsonWriter.h"

@implementation MainMenuLayer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	MainMenuLayer *layer = [MainMenuLayer node];
	[scene addChild: layer];
	
	return scene;
}

-(id) init {
	if( (self=[super init])) {
        [SimpleAudioEngine sharedEngine].backgroundMusicVolume = kBackgroundMusicVolume;
        if ([GameController sharedGameCtrl].isMusicOff == YES) {
            [SimpleAudioEngine sharedEngine].backgroundMusicVolume = 0;
        }
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Menu.mp3" loop:YES];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"mainMenuAtl.plist"];

        [CCMenuItemFont setFontSize:40 * kFactor];

        CCSprite *bg = [CCSprite spriteWithFile:@"mainMenuBg.jpg"];
        [bg setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg z:-2];
        
        AppController *appDelegate = (AppController *)[UIApplication sharedApplication].delegate;
        
        itemServer = [CCMenuItemFont itemWithString:@"Server" block:^(id sender) {
            appDelegate.loadLevelsFromServer = YES;
            [itemServer setColor:ccc3(0, 0, 255)];
            [itemLocal setColor:ccc3(0, 0, 0)];
		}];
        [itemServer setAnchorPoint:ccp(0.0f, 0.5f)];
        [itemServer setPosition:ccp(10 * kFactor, kScreenHeight - 20 * kFactor)];
		
		itemLocal = [CCMenuItemFont itemWithString:@"Local" block:^(id sender) {
            appDelegate.loadLevelsFromServer = NO;
            [itemServer setColor:ccc3(0, 0, 0)];
            [itemLocal setColor:ccc3(0, 0, 255)];
		}];
        [itemLocal setAnchorPoint:ccp(0.0f, 0.5f)];
        [itemLocal setPosition:ccp(10 * kFactor, kScreenHeight - 60 * kFactor)];
        
        if(appDelegate.loadLevelsFromServer) {
            [itemServer setColor:ccc3(0, 0, 255)];
            [itemLocal setColor:ccc3(0, 0, 0)];
        }
        else {
            [itemServer setColor:ccc3(0, 0, 0)];
            [itemLocal setColor:ccc3(0, 0, 255)];
        }
        
        //Play
        CCMenuItemSprite *playItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"mm_play.png"]
                                                             selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mm_play_p.png"]
                                                             disabledSprite:nil
                                                                     target:self
                                                                   selector:@selector(playHandler)];
        [playItem setPosition:ccp(kScreenCenterX, kScreenCenterY - 44 * kFactor)];

        //Options
        CCMenuItemSprite *optionsItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"mm_info.png"]
                                                                selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mm_info_p.png"]
                                                                disabledSprite:nil
                                                                        target:self
                                                                      selector:@selector(optionsHandler)];
        [optionsItem setPosition:ccp(kScreenCenterX - 77 * kFactor, kScreenCenterY - 95 * kFactor)];

        //Store
        CCSprite *storeSprite = [CCSprite spriteWithSpriteFrameName:@"mm_shop.png"];
        CCSprite *storeSprite_p = [CCSprite spriteWithSpriteFrameName:@"mm_shop_p.png"];
        
        if([GameController sharedGameCtrl].carrotsCount >= 100) {
            CCSprite *badge1 = [CCSprite spriteWithSpriteFrameName:@"mm_box_count.png"];
            [badge1 setPosition:ccp(87 * kFactor, 35 * kFactor)];
            [storeSprite addChild:badge1];

            CCSprite *badge2 = [CCSprite spriteWithSpriteFrameName:@"mm_box_count.png"];
            [badge2 setPosition:ccp(87 * kFactor, 35 * kFactor)];
            [storeSprite_p addChild:badge2];
        }
        
        CCMenuItemSprite *storeItem = [CCMenuItemSprite itemWithNormalSprite:storeSprite
                                                              selectedSprite:storeSprite_p
                                                              disabledSprite:nil
                                                                      target:self
                                                                    selector:@selector(storeHandler)];
        [storeItem setPosition:ccp(kScreenCenterX, kScreenCenterY - 95 * kFactor)];

        //Facebook
        CCMenuItemSprite *facebookItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"mm_facebook.png"]
                                                                 selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mm_facebook_p.png"]
                                                                 disabledSprite:nil
                                                                         target:self
                                                                       selector:@selector(facebookHandler)];
        [facebookItem setPosition:ccp(kScreenCenterX + 77 * kFactor, kScreenCenterY - 95 * kFactor)];

        CCMenu *menu = [CCMenu menuWithItems: playItem, optionsItem, storeItem, facebookItem, nil];
        [menu setPosition:CGPointZero];
        [self addChild: menu z:20];
	}
	return self;
}

-(void) onEnter {
	[super onEnter];
}

-(void) onExit {
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"mainMenuAtl.plist"];
    [super onExit];
}

-(void) playHandler {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f
                                                                                 scene:[DifficultyLayer scene]]];
}

-(void) optionsHandler {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f
                                                                                 scene:[OptionsLayer scene]]];
}

-(void) storeHandler {
    [[SimpleAudioEngine sharedEngine] playEffect:@"Select.mp3"];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f
                                                                                 scene:[ShopLayer scene]]];
}

-(void) facebookHandler {
    if(![GameController sharedGameCtrl].wasFacebookLike) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Want to earn 200 free carrots?"
                                                            message:@"Like us on Facebook!"
                                                           delegate:self
                                                  cancelButtonTitle:@"Like"
                                                  otherButtonTitles:@"Cancel", nil];
        [alertView show];
        [alertView release];
    }
    else {
        [self postWithText:@"Currently playing: Danger Rabbit on IOS. It rocks!"
                 ImageName:kFBIcon
                       URL:kAppURL
                   Caption:@"Danger Rabbit out now on iPhone + iPad"
                      Name:@"Danger Rabbit"
            andDescription:@" "];
    }
}

-(void) alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger) buttonIndex {
    if (buttonIndex == 0) {
        NSString *facebookUrlString = kFacebookURL;
        
        if ([[facebookUrlString pathComponents] count] > 0) {
            if ([[facebookUrlString pathComponents][1] isEqualToString:@"www.facebook.com"]) {
                NSMutableArray *pathComponents = [[facebookUrlString pathComponents] mutableCopy];
                [pathComponents replaceObjectAtIndex:1 withObject:@"facebook.com"];
                facebookUrlString = [NSString pathWithComponents:pathComponents];
            }
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:facebookUrlString]];
        [GameController sharedGameCtrl].wasFacebookLike = YES;
        [[GameController sharedGameCtrl] addCoins:200];
    }
}

-(void) postWithText: (NSString*) message
           ImageName: (NSString*) image
                 URL: (NSString*) url
             Caption: (NSString*) caption
                Name: (NSString*) name
      andDescription: (NSString*) description {
    if(![FacebookController sharedFacebookCtrl].isLoggedIn) {
        [[FacebookController sharedFacebookCtrl] login];
    }
    else {
        PW_SBJsonWriter *jsonWriter = [[PW_SBJsonWriter alloc] init];
        
        NSArray *actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          @"Click here to Play Danger Rabbit", @"name",
                                                          kAppURL, @"link",
                                                          nil],
                                nil];
        NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
        
        NSMutableDictionary *params =
        [NSMutableDictionary dictionaryWithObjectsAndKeys:
         kFBAppID, @"app_id",
         name, @"name",
         message, @"message",
         caption, @"caption",
         description, @"description",
         actionLinksStr, @"actions",
         kAppURL, @"link",
         kFBIcon, @"picture",
         nil];
        
        if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
            // No permissions found in session, ask for it
            [FBSession.activeSession requestNewPublishPermissions: [NSArray arrayWithObject:@"publish_actions"]
                                                  defaultAudience: FBSessionDefaultAudienceFriends
                                                completionHandler: ^(FBSession *session, NSError *error) {
                 if (!error) {
                     // If permissions granted and not already posting then publish the story
                     if (!m_postingInProgress) {
                         [self postToWall: params];
                     }
                 }
             }];
        }
        else {
            // If permissions present and not already posting then publish the story
            if (!m_postingInProgress) {
                [self postToWall: params];
            }
        }
    }
}

-(void) postToWall: (NSMutableDictionary*) params {
    m_postingInProgress = YES; //for not allowing multiple hits
    
    
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:params
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                              }
     ];

    //
//    [FBRequestConnection startWithGraphPath:@"me/feed"
//                                 parameters:params
//                                 HTTPMethod:@"POST"
//                          completionHandler:^(FBRequestConnection *connection,
//                                              id result,
//                                              NSError *error) {
//         if (error) {
//             //showing an alert for failure
//             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Post Failed"
//                                                                 message:error.localizedDescription
//                                                                delegate:nil
//                                                       cancelButtonTitle:@"OK"
//                                                       otherButtonTitles:nil];
//                [alertView show];
//         }
//         else {
//             UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Post Completed"
//                                                                 message:nil
//                                                                delegate:nil
//                                                       cancelButtonTitle:@"OK"
//                                                       otherButtonTitles:nil];
//             [alertView show];
//         }
//         m_postingInProgress = NO;
//     }];
}

@end
