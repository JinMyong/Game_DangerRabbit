//
//  AppDelegate.h
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright Dmitry Valov 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "StoreObserver.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "FacebookController.h"
#import <GameKit/GameKit.h>
#import "GameKitHelper.h"
#import "TrackAndAd.h"
#import "GoogleMobileAds/GoogleMobileAds.h"

// Added only for iOS 6 support
@interface MyNavigationController : UINavigationController <MFMailComposeViewControllerDelegate, CCDirectorDelegate>

- (void) sendEmail;

@end

@class GameProgressController;
@class GameController;

@interface AppController : NSObject <UIApplicationDelegate, StoreObserverProtocol>
{
	UIWindow *window_;
	MyNavigationController *navController_;
    KochavaTracker *kochavaTracker;
    
	CCDirectorIOS	*director_;							// weak ref
    
    NSInteger currLevel;
    NSInteger currArea;
    NSInteger currLevelScores;
    NSInteger bounceScores;
    NSInteger enemiesScore;
    NSInteger currLevelStars;
    NSInteger carrotsEarned;
    NSInteger planksUsed;
    
    NSInteger numberRevivesFB;
    NSInteger numberRevivesMSG;
    NSInteger livesCount;
    NSInteger continuesCount;
    
    NSInteger numberOfAttempts;
    
    GameProgressController  *gpc_;
    GameController          *gc_;
    FacebookController      *fc_;
    
    bool      loadLevelsFromServer;

    StoreObserver           *observer;
	UIAlertView				*loadingView;
    
    bool					gameCenterEnabled;
	NSString				*gameCenterPlayerID;
	NSString				*gameCenterPlayerAlias;
    
    
    GADBannerView *bannerView_;         //Added by Hans
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) MyNavigationController *navController;
@property (readonly) CCDirectorIOS *director;
@property (nonatomic, retain) GameController *gameController;
@property(readonly) KochavaTracker *kochavaTracker;

@property NSInteger currLevel;
@property NSInteger currArea;
@property NSInteger currLevelScores;
@property NSInteger bounceScores;
@property NSInteger enemiesScore;
@property NSInteger currLevelStars;
@property NSInteger numberRevivesFB;
@property NSInteger numberRevivesMSG;
@property NSInteger livesCount;
@property NSInteger continuesCount;
@property NSInteger numberOfAttempts;
@property NSInteger carrotsEarned;
@property NSInteger planksUsed;
@property bool loadLevelsFromServer;

@property                   bool     gameCenterEnabled;
@property (nonatomic, copy) NSString *gameCenterPlayerID;
@property (nonatomic, copy) NSString *gameCenterPlayerAlias;

@property (nonatomic,strong)GADBannerView *bannerView;          // By Hans
-(GADRequest *)createRequest;                                   // By Hans


- (bool) spendLife;
- (void) addLives: (NSInteger) lives;
- (void) saveOptions;

- (void) loadResourcesForGame;
- (void) unloadResourcesForGame;
- (void) loadResourcesForMenu;
- (void) unloadResourcesForMenu;
- (void) loadAnimCacheWithName:(NSString*)name delay:(float)delay maxFrames:(int)maxFrames;

- (void) requestPrices;
- (void) purchase:(NSInteger)purchase_id;
- (void) cancelLoadingAlert;
- (void) restorePurchases;
- (void) showWaitingAlert;

- (void) logEvent: (NSString *) event;
- (void) logSpendAllLivesWithLevel: (NSInteger) levelNum;
- (void) logLoseLevel: (NSInteger) levelNum withReason: (NSString *) reason;
- (void) logWinLevel: (NSInteger) levelNum;
- (void) logWinLevel: (NSInteger) levelNum withNumberOfLoses: (NSInteger) loses;
- (void) exitLevel: (NSInteger) levelNum;

- (bool) isGameCenterAvailable;
- (void) initGameCenter;
- (void) gameCenterAuthenticate;
- (void) gameCenterAuthenticationChanged;
- (void) submitHighScore:(int64_t)scoreValue leaderboard:(NSString *)leaderboard;
- (NSString *) getLeaderBoardNameForCurrArea;
- (NSString *) getTotalScoresLeaderboard;
- (NSString *) getTotalScoresLeaderboardWithDifficulty: (NSInteger) difficulty;

- (void) preloadBanner;
- (void) showAdBanner;

@end
