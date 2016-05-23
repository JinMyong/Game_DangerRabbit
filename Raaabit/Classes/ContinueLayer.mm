//
//  ContinueLayer.m
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "ContinueLayer.h"
#import "MainMenuLayer.h"
#import "GameLayer.h"
#import "MyMenuItemSprite.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "GameProgressController.h"
#import "Util.h"
#import "ContinuePackLayer.h"
#import "GameController.h"
#import "InviteLayer.h"
#import "NoCarrotsLayer.h"
#import "SimpleAudioEngine.h"
#import "PW_SBJsonWriter.h"
#import "LoadingLayer.h"
#import "LevelStartLayer.h"     // Added By Hans

#import "AdTapsy.h"             // Added By Hans

#import <GoogleMobileAds/GoogleMobileAds.h>

#import "AppTracker.h"
#define APP_API_KEY             @"8uc8Kd5b6LoyJZCAsFUCY2sWmSJkXZ6c"
#define LOCATION_CODE_VIDEO     @"video"

@implementation ContinueLayer

@synthesize sceneType;

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	ContinueLayer *layer = [ContinueLayer node];
	[scene addChild: layer];
	
	return scene;
}

-(id) init {
	if((self=[super init])) {
        sceneType = kSceneNone;

        AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
        GameController *gC = [GameController sharedGameCtrl];

        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"continueAtl.plist"];
        
        NSInteger timeCounter = -[gC.timeContinue timeIntervalSinceNow];
        timeCounter = kTimeAddLife - timeCounter;
        livesTime = timeCounter;
        livesTimeCounter = livesTime;

        CCSprite *bg1 = nil;
        if(appDelegate.currArea > kAreasCount) {
            bg1 = [CCSprite spriteWithFile:@"bg1.jpg"];
        }
        else {
            bg1 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"bg%d.jpg", appDelegate.currArea]];
        }
        [bg1 setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg1 z:-3];

        CCSprite *bg = [CCSprite spriteWithSpriteFrameName:@"c_shadow.png"];
        [bg setScale:8];
        [bg setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg z:-2];

        id shadowAction = [CCFadeIn actionWithDuration:0.3f];
        [bg runAction:shadowAction];
        
        CCNode *containerNode = [CCNode node];
		[containerNode setContentSize:CGSizeMake(kScreenWidth, kScreenHeight)];
        float offset = 0.0f;
		[containerNode setPosition:ccp(offset, kScreenHeight)];
		[self addChild:containerNode z:1];
        
        
        CCSprite *text = [CCSprite spriteWithSpriteFrameName:@"c_caption.png"];
        [text setPosition:ccp(kScreenCenterX, kScreenCenterY + 20 * kFactor)];
        [containerNode addChild:text z:1];
        
        //Menu
        CCMenu *menu = [CCMenu menuWithItems:nil];
        [menu setPosition:CGPointZero];
        [containerNode addChild: menu z:20];

        MyMenuItemSprite *closeItem = [MyMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"c_x.png"]
                                                              selectedSprite:nil
                                                              disabledSprite:nil
                                                                      target:self
                                                                    selector:@selector(closeHandler)];
        [closeItem setPosition:ccp(kScreenCenterX + 200 * kFactor, kScreenCenterY + 141 * kFactor)];
        [menu addChild:closeItem];
        
        //Timer
        NSString *time = [[Util sharedUtil] secondsToString:livesTime];
        timeToContinueLabel = [CCLabelTTF labelWithString:time fontName:@"BradyBunchRemastered" fontSize:60 * kFactor];
        timeToContinueLabel.color = ccc3(255, 102, 0);
        timeToContinueLabel.position = ccp(kScreenCenterX, kScreenCenterY + 40 * kFactor);
        [containerNode addChild:timeToContinueLabel z:30];

        //Facebook
//        CCMenuItemSprite *facebookItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"c_fb.png"]
//                                                                 selectedSprite:[CCSprite spriteWithSpriteFrameName:@"c_fb_p.png"]
//                                                                 disabledSprite:nil
//                                                                         target:self
//                                                                       selector:@selector(facebookHandler)];
//        [facebookItem setPosition:ccp(kScreenCenterX - 100 * kFactor, kScreenCenterY - 106 * kFactor)];
//        [menu addChild:facebookItem];
        
//Video ADS
        CCMenuItemSprite *adsItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"c_ads.png"]
                                                                 selectedSprite:[CCSprite spriteWithSpriteFrameName:@"c_ads_p.png"]
                                                                 disabledSprite:nil
                                                                         target:self
                                                                       selector:@selector(videoAdsHandler)];
        [adsItem setPosition:ccp(kScreenCenterX - 100 * kFactor, kScreenCenterY - 106 * kFactor)];
        [menu addChild:adsItem];
        
// Video ADS End
        
//Buy
        
        CCMenuItemSprite *unlimitedlife_item = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"c_5pack.png"]
                                                                 selectedSprite:[CCSprite spriteWithSpriteFrameName:@"c_5pack_p.png"]
                                                                 disabledSprite:nil
                                                                         target:self
                                                                       selector:@selector(unlimitLifeHandler)];
        [unlimitedlife_item setPosition:ccp(kScreenCenterX, kScreenCenterY - 106 * kFactor)];
        [unlimitedlife_item setScale:0.75f];
        [menu addChild:unlimitedlife_item];
// Added By Hans_1128
        NSString *priceString_unlimit = [[GameController sharedGameCtrl].listOfPrices objectForKey:kAppleID_UnlimitedLife];
        if(!priceString_unlimit || [priceString_unlimit length] <= 0) {
            priceString_unlimit = @"n/a";
        }
        
        [[Util sharedUtil] showLabel:priceString_unlimit
                              atNode:containerNode
                          atPosition:ccp(unlimitedlife_item.position.x, unlimitedlife_item.position.y - 44 * kFactor)
                            fontName:@"BradyBunchRemastered"
                            fontSize:20 * kFactor
                           fontColor:ccc3(255, 204, 102)
                         anchorPoint:ccp(0.5, 0.5)
                           isEnabled:YES
                                 tag:1
                          dimensions:CGSizeMake(100, 100)
                            rotation:0
                             bgColor:ccc3(51, 0, 0)];
// Add End
        

/*  Remarked By Hans_1128
 
        CCMenuItemSprite *buy5PackItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"c_5pack.png"]
                                                                 selectedSprite:[CCSprite spriteWithSpriteFrameName:@"c_5pack_p.png"]
                                                                 disabledSprite:nil
                                                                         target:self
                                                                       selector:@selector(buy5PackHandler)];
        [buy5PackItem setPosition:ccp(kScreenCenterX, kScreenCenterY - 106 * kFactor)];
        [buy5PackItem setScale:0.75f];
        [menu addChild:buy5PackItem];
        

        NSString *priceString1 = [[GameController sharedGameCtrl].listOfPrices objectForKey:kAppleID_5Continues];
        if(!priceString1 || [priceString1 length] <= 0) {
            priceString1 = @"n/a";
        }
        
        [[Util sharedUtil] showLabel:priceString1
                              atNode:containerNode
                          atPosition:ccp(buy5PackItem.position.x, buy5PackItem.position.y - 44 * kFactor)
                            fontName:@"BradyBunchRemastered"
                            fontSize:20 * kFactor
                           fontColor:ccc3(255, 204, 102)
                         anchorPoint:ccp(0.5, 0.5)
                           isEnabled:YES
                                 tag:1
                          dimensions:CGSizeMake(100, 100)
                            rotation:0
                             bgColor:ccc3(51, 0, 0)];
 */

/*  //Remarked By Hans_1128
 
        CCMenuItemSprite *buy15PackItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"c_15pack.png"]
                                                                  selectedSprite:[CCSprite spriteWithSpriteFrameName:@"c_15pack_p.png"]
                                                                  disabledSprite:nil
                                                                          target:self
                                                                        selector:@selector(buy15PackHandler)];
        [buy15PackItem setPosition:ccp(kScreenCenterX + 100 * kFactor, kScreenCenterY - 106 * kFactor)];
        [buy15PackItem setScale:0.75f];
        [menu addChild:buy15PackItem];
        
        NSString *priceString2 = [[GameController sharedGameCtrl].listOfPrices objectForKey:kAppleID_15Continues];
        if(!priceString2 || [priceString2 length] <= 0) {
            priceString2 = @"n/a";
        }
        
        [[Util sharedUtil] showLabel:priceString2
                              atNode:containerNode
                          atPosition:ccp(buy15PackItem.position.x, buy15PackItem.position.y - 44 * kFactor)
                            fontName:@"BradyBunchRemastered"
                            fontSize:20 * kFactor
                           fontColor:ccc3(255, 204, 102)
                         anchorPoint:ccp(0.5, 0.5)
                           isEnabled:YES
                                 tag:1
                          dimensions:CGSizeMake(100, 100)
                            rotation:0
                             bgColor:ccc3(51, 0, 0)];
    //Remarked By Hans_1128
*/
        
//        //Pack
//        CCMenuItemSprite *continuePackItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"c_pack.png"]
//                                                                 selectedSprite:[CCSprite spriteWithSpriteFrameName:@"c_pack_p.png"]
//                                                                 disabledSprite:nil
//                                                                         target:self
//                                                                       selector:@selector(packHandler)];
//        [continuePackItem setPosition:ccp(kScreenCenterX, kScreenCenterY - 106 * kFactor)];
//        [menu addChild:continuePackItem];
//        
//        //Buy
//        CCMenuItemSprite *buyItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"c_coin.png"]
//                                                            selectedSprite:[CCSprite spriteWithSpriteFrameName:@"c_coin_p.png"]
//                                                            disabledSprite:nil
//                                                                    target:self
//                                                                  selector:@selector(buyHandler)];
//        [buyItem setPosition:ccp(kScreenCenterX + 100 * kFactor, kScreenCenterY - 106 * kFactor)];
//        [menu addChild:buyItem];
        
        [self scheduleUpdate];

        CCSprite *carrot = [CCSprite spriteWithSpriteFrameName:@"c_carrot.png"];
        [carrot setPosition:ccp(10 * kFactor, 25 * kFactor)];
        [carrot setScale:1.3f];
        [containerNode addChild:carrot];

        NSInteger xPos = 25 * kFactor - kScreenWidth / 2.0f;
        
        if([[Util sharedUtil] isiPad]) {
            xPos = 35 * kFactor - kScreenWidth / 4.0f;
        }
        else if([[Util sharedUtil] isiPhone5]) {
            xPos = 65 * kFactor - kScreenWidth / 2.0f;
        }
        
        [[Util sharedUtil] showLabel:[NSString stringWithFormat:@"%li",  (long)[GameController sharedGameCtrl].carrotsCount]
                              atNode:containerNode
                          atPosition:ccp(xPos, 25 * kFactor)
                            fontName:@"BradyBunchRemastered"
                            fontSize:28 * kFactor
                           fontColor:ccc3(255, 255, 255)
                         anchorPoint:ccp(0.0, 0.5)
                           isEnabled:YES
                                 tag:1
                          dimensions:CGSizeMake(500, 56)
                            rotation:0
                             bgColor:ccc3(255, 153, 51)];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appRestored)
                                                     name:kAppRestoredNotification
                                                   object:nil];
        
        id move = [CCMoveBy actionWithDuration:0.5f position:ccp(0.0f, -kScreenHeight)];
        id action = [CCSequence actions:
                     [CCEaseBackOut actionWithAction:move],
                     nil];
        [containerNode runAction:action];
        
        // Added By Hans for video ADS
        
        [AdTapsy setDelegate:self];
        
    // Add End
        
    
	}
	return self;
}


-(void)initializeEventListeners
{
    // Update this to trigger relevant sdk event listeners
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSString *afw = @"AppFireworksNotification";
    [nc addObserverForName:@"onModuleLoaded" object:afw queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif) {
        NSString *placement = [notif.userInfo objectForKey:@"placement"];
//        _msg.text = [NSString stringWithFormat:@"Module %@ loaded successfuly!", placement];
        //NSLog(@"Ad displayed");
        
    }];
    [nc addObserverForName:@"onModuleFailed" object:afw queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif) {
        NSString *placement = [notif.userInfo objectForKey:@"placement"];
        if([[notif.userInfo objectForKey:@"cached"] isEqualToString:@"yes"]) {
//            _msg.text = [NSString stringWithFormat:@"Module %@ failed to cache!", placement];
        } else {
//            _msg.text = [NSString stringWithFormat:@"Module %@ failed to load!", placement];
        }
    }];
    [nc addObserverForName:@"onModuleClosed" object:afw queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif) {
        NSString *placement = [notif.userInfo objectForKey:@"placement"];
//        _msg.text = [NSString stringWithFormat:@"Module %@ closed", placement];
    }];
    [nc addObserverForName:@"onModuleCached" object:afw queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notif) {
        NSString *placement = [notif.userInfo objectForKey:@"placement"];
//        _msg.text = [NSString stringWithFormat:@"Module %@ cached successfully", placement];
        NSLog(@"Ad successfully cached");
        // Ad has been cached, now enable the Show Ad button
    }];
}



-(void) onEnter {
	[super onEnter];
}

-(void) onExit {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"continueAtl.plist"];
    [super onExit];
}

- (void) update: (ccTime) dt {
    livesTime -= dt;
    if(livesTime < livesTimeCounter - 1) {
        --livesTimeCounter;
        [self updateTime];
    }
    
    if(livesTime <= 0) {
        [self unscheduleUpdate];
        AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.livesCount <= 0) {
            appDelegate.livesCount = kLivesBonus;
            [appDelegate saveOptions];
        }
        if(sceneType == kSceneGameplay) {
            appDelegate.livesCount = kLivesBonus;
            GameController *gC = [GameController sharedGameCtrl];
            gC.timeContinue = [NSDate dateWithTimeIntervalSince1970:0];
            [gC save];
            
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0
                                                                                         scene:[GameLayer scene]]];
        }
        else {
            appDelegate.livesCount = kLivesBonus;
            GameController *gC = [GameController sharedGameCtrl];
            gC.timeContinue = [NSDate dateWithTimeIntervalSince1970:0];
            [gC save];
            
            [appDelegate unloadResourcesForMenu];
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f
                                                                                         scene:[LoadingLayer scene]]];
        }
    }
}

-(void) closeHandler {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0
                                                                                 scene:[MainMenuLayer scene]]];
}

-(void) facebookHandler {
    
    if(![GameController sharedGameCtrl].wasFacebookLike) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Want to earn 200 free carrots?"
                                                            message:@"Like us on Facebook!"
                                                           delegate:self
                                                  cancelButtonTitle:@"Like"
                                                  otherButtonTitles:@"Cancel", nil];
        [alertView setTag:1];
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

-(void) videoAdsHandler{
    if ([AdTapsy isRewardedVideoReadyToShow]) {
        NSLog(@"Ad is ready be shown");
        
        [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
        
        UIViewController *rootViewController = (UIViewController *)[[[CCDirector sharedDirector] openGLView] nextResponder];
        [AdTapsy showRewardedVideo:rootViewController];
    } else {
        NSLog(@"Ad is not ready to be shown");
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                            message:@"Ad is not ready to be shown. Please again Later"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}

-(void) packHandler {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    [appDelegate logEvent:@"Press continue pack, on the continue screen."];

    [[SimpleAudioEngine sharedEngine] playEffect:@"HeyHey.mp3"];
    ContinuePackLayer *cpl = [ContinuePackLayer node];
    [self addChild:cpl z:100];
}

-(void) buyHandler {
    if([GameController sharedGameCtrl].carrotsCount >= 150) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"You have %d carrots.", [GameController sharedGameCtrl].carrotsCount]
                                                            message:@"Buy one continue (8 lives) now for 125 carrots?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Confirm", nil];
        [alertView setTag:2];
        [alertView show];
        [alertView release];
    }
    else {
        NoCarrotsLayer *ncl = [NoCarrotsLayer node];
        [self addChild:ncl z:100];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 2) {
        if(buttonIndex == 1) {
            [[GameController sharedGameCtrl] spendCoins:125];
            AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
            appDelegate.livesCount = kLivesBonus;
            [appDelegate saveOptions];
            
            GameController *gC = [GameController sharedGameCtrl];
            gC.timeContinue = [NSDate dateWithTimeIntervalSince1970:0];
            [gC save];
            
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f
                                                                                         scene:[GameLayer scene]]];
        }
        else {
        }
    }
    else {
        if (buttonIndex == 0) {
            NSURL *url = [NSURL URLWithString:kFacebookURL];
            [[UIApplication sharedApplication] openURL:url];
            [GameController sharedGameCtrl].wasFacebookLike = YES;
            [[GameController sharedGameCtrl] addCoins:200];
        }
    }
}

-(void) updateTime {
    [timeToContinueLabel setString:[[Util sharedUtil] secondsToString:livesTime]];
}

- (void) appRestored {
    GameController *gC = [GameController sharedGameCtrl];

    NSInteger timeCounter = -[gC.timeContinue timeIntervalSinceNow];
    timeCounter = kTimeAddLife - timeCounter;
    livesTime = timeCounter;
    livesTimeCounter = livesTime;
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
    
    [FBRequestConnection startWithGraphPath:@"me/feed"
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              if (error) {
                                  //showing an alert for failure
                                  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Post Failed"
                                                                                      message:error.localizedDescription
                                                                                     delegate:nil
                                                                            cancelButtonTitle:@"OK"
                                                                            otherButtonTitles:nil];
                                  [alertView show];
                              }
                              else {
                                  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Post Completed"
                                                                                      message:nil
                                                                                     delegate:nil
                                                                            cancelButtonTitle:@"OK"
                                                                            otherButtonTitles:nil];
                                  [alertView show];
                              }
                              m_postingInProgress = NO;
                          }];
}

-(void) unlimitLifeHandler{
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    [appDelegate purchase:kShopID_UnlimitedLife];
}


-(void) buy5PackHandler {
    
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    [appDelegate purchase:kShopID_UnlimitedLife];

    
//    GameController *gC = [GameController sharedGameCtrl];
//    gC.isUnlimitedLife = true;
//
//    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
//    gC.timeContinue = [NSDate dateWithTimeIntervalSince1970:0];
//    [appDelegate addLives:kLivesBonus];
//    [gC save];
//    
//    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0                                                                                 scene:[GameLayer scene]]];

}

-(void) buy15PackHandler {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    [appDelegate purchase:kShopID_15Continues];
}

// Added By Hans

-(void)adtapsyDidEarnedReward:(BOOL)success andAmount:(int)amount {
    NSLog(@"***adtapsyDidEarnedReward*** success: %d amount %d", success, amount);
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    [appDelegate addLives:kLivesEarnADVideo];
    
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
//    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    GameController *gC = [GameController sharedGameCtrl];
    gC.timeContinue = [NSDate dateWithTimeIntervalSince1970:0];
    [gC save];
    
    [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0                                                                                 scene:[GameLayer scene]]];
}

-(void)adtapsyDidCachedInterstitialAd {
    NSLog(@"***adtapsyDidCachedInterstitialAd***");
}

-(void)adtapsyDidCachedRewardedVideoAd {
    NSLog(@"***adtapsyDidCachedRewardedVideoAd***");
}

-(void)adtapsyDidClickedInterstitialAd {
    NSLog(@"***adtapsyDidClickedInterstitialAd***");
}

-(void)adtapsyDidClickedRewardedVideoAd {
    NSLog(@"***adtapsyDidClickedRewardedVideoAd***");
}

-(void)adtapsyDidFailedToShowInterstitialAd {
    NSLog(@"***adtapsyDidFailedToShowInterstitialAd***");
}

-(void)adtapsyDidFailedToShowRewardedVideoAd {
    NSLog(@"***adtapsyDidFailedToShowRewardedVideoAd***");
}

-(void)adtapsyDidShowInterstitialAd {
    NSLog(@"***adtapsyDidShowInterstitialAd***");
}

-(void)adtapsyDidShowRewardedVideoAd {
    NSLog(@"***adtapsyDidShowRewardedVideoAd***");
}

-(void)adtapsyDidSkippedInterstitialAd {
    NSLog(@"***adtapsyDidSkippedInterstitialAd***");
}

-(void)adtapsyDidSkippedRewardedVideoAd {
    NSLog(@"***adtapsyDidSkippedRewardedVideoAd***");
}


@end
