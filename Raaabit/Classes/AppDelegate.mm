//
//  AppDelegate.mm
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright Dmitry Valov 2013. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "IntroLayer.h"
#import "GB2ShapeCache.h"
#import "Constants.h"
#import "GameProgressController.h"
#import "Flurry.h"
#import "FlurryAds.h"
#import "GameController.h"
#import "PushNotificationManager.h"
#import "GameController.h"
#import "Constants.h"
#import "Appirater.h"
#import "MBProgressHUD.h"
#import "AdTapsy.h"             // Added By Hans
#import <Appsee/Appsee.h>

#import "SimpleAudioEngine.h"

@implementation MyNavigationController

// The available orientations should be defined in the Info.plist file.
// And in iOS 6+ only, you can override it in the Root View controller in the "supportedInterfaceOrientations" method.
// Only valid for iOS 6+. NOT VALID for iOS 4 / 5.
-(NSUInteger)supportedInterfaceOrientations {
	
	// iPhone only
	if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
		return UIInterfaceOrientationMaskLandscape;
	
	// iPad only
	return UIInterfaceOrientationMaskLandscape;
}

// Supported orientations. Customize it for your own needs
// Only valid on iOS 4 / 5. NOT VALID for iOS 6.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// iPhone only
	if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
		return UIInterfaceOrientationIsLandscape(interfaceOrientation);
	
	// iPad only
	// iPhone only
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

// This is needed for iOS4 and iOS5 in order to ensure
// that the 1st scene has the correct dimensions
// This is not needed on iOS6 and could be added to the application:didFinish...
-(void) directorDidReshapeProjection:(CCDirector*)director {
	if(director.runningScene == nil) {
		// Add the first scene to the stack. The director will draw it immediately into the framebuffer. (Animation is started automatically when the view is displayed.)
		// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
		[director runWithScene: [IntroLayer scene]];
	}
}

- (void) sendEmail {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc] init];
        mailView.mailComposeDelegate = self;

        NSString *mailSubject = @"Danger Rabbit feedback";
        NSString *mailBody = @"";
        
        NSArray *recepients = [NSArray arrayWithObject:@"games@flowsparkstudios.com"];
        [mailView setSubject:mailSubject];
        [mailView setMessageBody:mailBody isHTML:NO];
        [mailView setToRecipients:recepients];
        [self presentViewController:mailView animated:YES completion:nil];
        [mailView release];
    }
    else {
        CCLOG(@"Mail Not Supported");
    }
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

@implementation AppController

@synthesize window=window_;
@synthesize navController=navController_;
@synthesize director=director_;
@synthesize currLevel;
@synthesize currArea;
@synthesize currLevelScores;
@synthesize currLevelStars;
@synthesize bounceScores;
@synthesize enemiesScore;
@synthesize loadLevelsFromServer;
@synthesize numberRevivesFB;
@synthesize numberRevivesMSG;
@synthesize livesCount;
@synthesize continuesCount;
@synthesize numberOfAttempts;
@synthesize gameController;
@synthesize carrotsEarned;
@synthesize planksUsed;
@synthesize gameCenterEnabled;
@synthesize gameCenterPlayerID;
@synthesize gameCenterPlayerAlias;
@synthesize kochavaTracker;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Create the main window
    
// Added By Hans for PushNotification
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
// Add End
    
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
    self.currLevel = 1;
    self.currArea = 1;
	self.currLevelScores = 0;
    self.currLevelStars = 0;
    self.bounceScores = 0;
    self.enemiesScore = 0;
    self.carrotsEarned = 0;
    self.planksUsed = 0;

    self.loadLevelsFromServer = kLoadLevelsFromServer;

    gc_ = [[GameController alloc] init];
    gpc_ = [[GameProgressController alloc] init];
    fc_ = [[FacebookController alloc] init];
    
    NSDictionary *initDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"kodangerrabbit4385537253b353e8e", @"kochavaAppId",
                              nil];
    kochavaTracker = [[KochavaTracker alloc] initKochavaWithParams:initDict];

	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];

	// Enable multiple touches
	[glView setMultipleTouchEnabled:YES];

	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
	
	director_.wantsFullScreenLayout = YES;
	
	// Display FSP and SPF
	[director_ setDisplayStats:NO];
	
	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];
	
	// attach the openglView to the director
	[director_ setView:glView];
	
	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
	//	[director setProjection:kCCDirectorProjection3D];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:YES];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

    [self initGameCenter];

    [self loadOptions];

    //Store Observer
	observer = [[StoreObserver alloc] init];
    observer.delegate = self;
    [[SKPaymentQueue defaultQueue] addTransactionObserver:observer];
    [self requestPrices];
    
	// Create a Navigation Controller with the Director
	navController_ = [[MyNavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
	
	// for rotation and other messages
	[director_ setDelegate:navController_];
	
	// set the Navigation Controller as the root view controller
	[window_ setRootViewController:navController_];
	
	// make main window visible
	[window_ makeKeyAndVisible];
    
    [Flurry startSession:kFlurryID];
    [Appirater appLaunched:YES];
    [self preloadBanner];
    
//added By Hans
    
    [AdTapsy setTestMode:YES andTestDevices:@[ @"Simulator", @"5745e0e7d8877fe11232e7f6c591f57d" ]]; // Only AdMob and RevMob, for the rest go to ad network dashboard
    [AdTapsy startSession:kAdtapsy_appID];
    
// Add End Hans
    
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"commonAtl.plist"];

//    [SuperT startWithAPIKey:@"flowspark-studios/danger-rabbit-1"];
    [Appsee start:@"195c9c15257a4895a7a353d561132b28"];
    
//    NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
//    NSArray *fontNames;
//    NSInteger indFamily, indFont;
//    for (indFamily=0; indFamily<[familyNames count]; ++indFamily)
//    {
//        NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
//        fontNames = [[NSArray alloc] initWithArray:
//                     [UIFont fontNamesForFamilyName:
//                      [familyNames objectAtIndex:indFamily]]];
//        for (indFont=0; indFont<[fontNames count]; ++indFont)
//        {
//            NSLog(@"    Font name: %@", [fontNames objectAtIndex:indFont]);
//        }
//        [fontNames release];
//    }
//    [familyNames release];
	return YES;
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
	if( [navController_ visibleViewController] == director_ )
		[director_ pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
    [self exitLevel:currLevel];

	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
    
    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppRestoredNotification
                                                        object:nil];
    
    [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application {
    [observer release];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0]; // Added By Hans_1127
    [AdTapsy destroy];      // Added By Hans
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) onPushAccepted:(PushNotificationManager *)pushManager withNotification:(NSDictionary *)pushNotification {
    CCLOG(@"Push notification received");
}

- (void) dealloc {
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"commonAtl.plist"];

    [kochavaTracker release];
	[window_ release];
	[navController_ release];
	[gpc_ release];
    [gc_ release];
    [fc_ release];
    [observer release];
	[super dealloc];
}

#pragma mark -
#pragma mark Resources management

- (bool) spendLife {
    
    
    GameController *gC = [GameController sharedGameCtrl];
    
// Added By Hans_1127
    if (gC.isUnlimitedLife) {
        return YES;
    }
// Add End
    
    --livesCount;
    
    [[GameController sharedGameCtrl] spendLife];
    
    [self saveOptions];    
    
    if(livesCount == -1) {
        NSInteger timeCounter = -[gC.timeContinue timeIntervalSinceNow];
        timeCounter = kTimeAddLife - timeCounter;
        if(timeCounter <= 0) {
            gC.timeContinue = [NSDate date];
            [gC save];
        }
    }
    
    if(livesCount < 0) {
        NSInteger timeCounter = -[gC.timeContinue timeIntervalSinceNow];
        timeCounter = kTimeAddLife - timeCounter;
        if(timeCounter <= 0) {
            livesCount = kLivesBonus - 1;
        }
    }
    return YES;
}

- (void) addLives: (NSInteger) lives {
    if(self.livesCount < 0) {
        self.livesCount = 0;
    }
    self.livesCount += lives;
    [self saveOptions];
}

- (void) saveOptions {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	NSString *filePath = [documentDirectory stringByAppendingPathComponent:kOptionsFileName];
	
  	NSMutableDictionary *options;
	
	if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		options = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
	} else {
		options = [[NSMutableDictionary alloc] init];
	}

    //save params here
    [options setObject:[NSNumber numberWithFloat:self.numberRevivesFB] forKey:@"numberRevivesFB"];
    [options setObject:[NSNumber numberWithFloat:self.numberRevivesMSG] forKey:@"numberRevivesMSG"];
    [options setObject:[NSNumber numberWithFloat:self.livesCount] forKey:@"livesCount"];
    [options setObject:[NSNumber numberWithFloat:self.continuesCount] forKey:@"continuesCount"];

	[options writeToFile:filePath atomically:YES];
	[options release];
}

- (void) loadOptions {
    self.numberRevivesFB = 5;
    self.numberRevivesMSG = 5;
    self.livesCount = kLivesDefault;
    self.continuesCount = kContinuesCount;

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDirectory = [paths objectAtIndex:0];
	NSString *filePath = [documentDirectory stringByAppendingPathComponent:kOptionsFileName];
	NSDictionary *options;
	
	if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		options = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        //load params here
        if([options objectForKey:@"numberRevivesFB"] != nil) {
            self.numberRevivesFB = [[options objectForKey:@"numberRevivesFB"] intValue];
        }
        if([options objectForKey:@"numberRevivesMSG"] != nil) {
            self.numberRevivesMSG = [[options objectForKey:@"numberRevivesMSG"] intValue];
        }
        if([options objectForKey:@"livesCount"] != nil) {
            self.livesCount = [[options objectForKey:@"livesCount"] intValue];
        }
        if([options objectForKey:@"continuesCount"] != nil) {
            self.continuesCount = [[options objectForKey:@"continuesCount"] intValue];
        }
		[options release];
	}
}

- (void) loadResourcesForGame {
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"gameObjectsAtl.plist"];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"gameObjectsAtl2.plist"];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"hintsAtl.plist"];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"platformsAtl.plist"];
	[[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"gameObjects.plist"];
    
    [self loadAnimCacheWithName:@"fly/fly" delay:0.1f maxFrames:7];
    [self loadAnimCacheWithName:@"jump/jump" delay:0.05f maxFrames:7];
    [self loadAnimCacheWithName:@"shoot/shoot" delay:0.1f maxFrames:1];
    [self loadAnimCacheWithName:@"stand/stand" delay:0.1f maxFrames:1];
    [self loadAnimCacheWithName:@"walk/walk" delay:0.1f maxFrames:9];
    [self loadAnimCacheWithName:@"starry_eyed/starry_eyed" delay:0.13f maxFrames:10];
    [self loadAnimCacheWithName:@"run/run" delay:0.1f maxFrames:10];
    [self loadAnimCacheWithName:@"Bear_roar/Bearroar" delay:0.1f maxFrames:20];
    [self loadAnimCacheWithName:@"Bear_walk/Bearwalk" delay:0.1f maxFrames:9];
    [self loadAnimCacheWithName:@"Bear_flash/Bearflash" delay:0.1f maxFrames:9];
    [self loadAnimCacheWithName:@"Birdflying" delay:0.04f maxFrames:30];
    [self loadAnimCacheWithName:@"turtlewalk" delay:0.1f maxFrames:10];
    [self loadAnimCacheWithName:@"bee" delay:0.1f maxFrames:4];
    [self loadAnimCacheWithName:@"blueBee" delay:0.1f maxFrames:4];
    [self loadAnimCacheWithName:@"coin" delay:0.07f maxFrames:9];
    [self loadAnimCacheWithName:@"tram" delay:0.06f maxFrames:13];
    [self loadAnimCacheWithName:@"tram2" delay:0.05f maxFrames:14];
    [self loadAnimCacheWithName:@"tramI2" delay:0.05f maxFrames:9   ];
    [self loadAnimCacheWithName:@"tram3" delay:0.05f maxFrames:11];
    [self loadAnimCacheWithName:@"tramI3" delay:0.05f maxFrames:8];
    [self loadAnimCacheWithName:@"tram4" delay:0.05f maxFrames:11];
    [self loadAnimCacheWithName:@"tramI4" delay:0.05f maxFrames:8];
    [self loadAnimCacheWithName:@"stickTram" delay:0.05f maxFrames:12];
    [self loadAnimCacheWithName:@"purpleTram" delay:0.05f maxFrames:12];
    [self loadAnimCacheWithName:@"wind" delay:0.1f maxFrames:7];
    [self loadAnimCacheWithName:@"fuse/fuse" delay:0.1f maxFrames:9];
    [self loadAnimCacheWithName:@"explosion/explosion" delay:0.1f maxFrames:9];
    [self loadAnimCacheWithName:@"jumpInGun/jumpInGun" delay:0.1f maxFrames:8];
    [self loadAnimCacheWithName:@"fly/sparrow" delay:0.1f maxFrames:6];
    [self loadAnimCacheWithName:@"death/sparrow_death" delay:0.1f maxFrames:16];
    [self loadAnimCacheWithName:@"gun_top_part" delay:0.1f maxFrames:2];
    [self loadAnimCacheWithName:@"goal_animation" delay:0.1f maxFrames:10];
    [self loadAnimCacheWithName:@"carrot_combo" delay:0.1f maxFrames:12];
    [self loadAnimCacheWithName:@"speed_run" delay:0.1f maxFrames:10];
}

- (void) unloadResourcesForGame {
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"fly/fly"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"jump/jump"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"shoot/shoo"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"stand/stand"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"walk/walk"];    
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"starry_eyed/starry_eyed"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"run/run"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"Bear_roar/Bearroar"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"Bear_walk/Bearwalk"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"Bear_flash/Bearflash"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"Birdflying"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"turtlewalk"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"bee"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"blueBee"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"coin"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"tram"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"tram2"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"tramI2"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"tram3"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"tramI3"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"tram4"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"tramI4"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"stickTram"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"purpleTram"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"wind"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"fuse/fuse"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"explosion/explosion"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"jumpInGun/jumpInGun"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"fly/sparrow"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"death/sparrow_death"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"gun_top_part"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"goal_animation"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"carrot_combo"];
    [[CCAnimationCache sharedAnimationCache] removeAnimationByName:@"speed_run"];

	[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"gameObjectsAtl.plist"];
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"gameObjectsAtl2.plist"];
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"hintsAtl.plist"];
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"platformsAtl.plist"];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

- (void) loadResourcesForMenu {
}

- (void) unloadResourcesForMenu {
}

- (void)loadAnimCacheWithName:(NSString*)name delay:(float)delay maxFrames:(int)maxFrames {
    NSMutableArray* frames = [NSMutableArray array];
    CCSpriteFrame* frame = nil;
    for (int frameIdx = 1; frameIdx <= maxFrames; ++frameIdx)
    {
        NSString *frameName = [NSString stringWithFormat:@"%@_%d.png", name, frameIdx];
        frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
        if (frame == nil)
            break;
        [frames addObject:frame];
    }
    CCAnimation* animation = [CCAnimation animationWithSpriteFrames:frames delay:delay];
    [[CCAnimationCache sharedAnimationCache] addAnimation:animation name:name];
}

#pragma mark -
#pragma mark In App Purchase
- (void) requestPrices {
    [observer requestProUpgradeProductData:kAppleID_UnlockAllLevels];
    
    [observer requestProUpgradeProductData:kAppleID_1kCarrots];
    [observer requestProUpgradeProductData:kAppleID_2kCarrots];
    [observer requestProUpgradeProductData:kAppleID_4kCarrots];

    [observer requestProUpgradeProductData:kAppleID_5Continues];
    [observer requestProUpgradeProductData:kAppleID_15Continues];

    [observer requestProUpgradeProductData:kAppleID_NextWorld];
    
    [observer requestProUpgradeProductData:kAppleID_UnlimitedLife];     // Added By Hans
}

- (void) transactionDidError:(NSError*)error {
    [self cancelLoadingAlert];
    
    if(error != nil) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error localizedDescription]
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
}

- (void) transactionDidFinish:(NSString*)transactionIdentifier {
    [self cancelLoadingAlert];
}

- (void) purchase:(NSInteger)purchase_id {
	if (![SKPaymentQueue canMakePayments]) {
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error"
															message:@"inApp purchase Disabled"
														   delegate:self
												  cancelButtonTitle:@"Ok"
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		return;
	}

    NSString *purchase_id_string = @"";
    
    switch (purchase_id) {
        case kShopID_UnlockAllLevels:
            purchase_id_string = kAppleID_UnlockAllLevels;
            break;
        case kShopID_1kCarrots:
            purchase_id_string = kAppleID_1kCarrots;
            break;
        case kShopID_2kCarrots:
            purchase_id_string = kAppleID_2kCarrots;
            break;
        case kShopID_4kCarrots:
            purchase_id_string = kAppleID_4kCarrots;
            break;
        case kShopID_5Continues:
            purchase_id_string = kAppleID_5Continues;
            break;
        case kShopID_15Continues:
            purchase_id_string = kAppleID_15Continues;
            break;
        case kShopID_30Continues:
            purchase_id_string = kAppleID_30Continues;
            break;
        case kShopID_NextWorld:
            purchase_id_string = kAppleID_NextWorld;
            break;
        case kShopID_UnlimitedLife:
            purchase_id_string = kAppleID_UnlimitedLife;
            break;
        default:
            return;
    }
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:purchase_id_string];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    [self showWaitingAlert];
}

- (void) restorePurchases {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    [self showWaitingAlert];
}

- (void) showWaitingAlert {
    float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (sysVer < 7) {
        loadingView = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        
        UIActivityIndicatorView *actInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        actInd.frame = CGRectMake(128.0f, 45.0f, 25.0f, 25.0f);
        [loadingView addSubview:actInd];
        [actInd startAnimating];
        [actInd release];
        
        UILabel *l = [[UILabel alloc]init];
        l.frame = CGRectMake(100, -25, 210, 100);
        l.text = @"Please wait...";
        l.font = [UIFont fontWithName:@"Helvetica" size:16];
        l.textColor = [UIColor whiteColor];
        l.shadowColor = [UIColor blackColor];
        l.shadowOffset = CGSizeMake(1.0, 1.0);
        l.backgroundColor = [UIColor clearColor];
        [loadingView addSubview:l];
        [l release];
        
        [loadingView show];
        [loadingView release];
    }
    else {
        [MBProgressHUD showHUDAddedTo:navController_.view animated:YES];
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    CCLOG(@"[ IN APP PURCHASE] request error: %@", [error localizedDescription]);
}

- (void) transactionDidError {
    float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (sysVer < 7) {
        [loadingView dismissWithClickedButtonIndex:0 animated:NO];
    }
    else {
        [MBProgressHUD hideHUDForView:navController_.view animated:YES];
    }
}

- (void) cancelLoadingAlert {
    float sysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (sysVer < 7) {
        [loadingView dismissWithClickedButtonIndex:0 animated:NO];
    }
    else {
        [MBProgressHUD hideHUDForView:navController_.view animated:YES];
    }
}

- (void) logEvent: (NSString *) event {
    [Flurry logEvent:event];
}

- (void) logSpendAllLivesWithLevel: (NSInteger) levelNum {
    NSDictionary *levelParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%ld", (long)levelNum] , @"Level number",
                                 nil];
    [Flurry logEvent:@"Run out of all lives" withParameters:levelParams];
}

- (void) logLoseLevel: (NSInteger) levelNum withReason: (NSString *) reason {
    NSDictionary *levelParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%ld", (long)levelNum] , @"Level number",
                                 nil];
    [Flurry logEvent:[NSString stringWithFormat:@"Lose level (%@)", reason] withParameters:levelParams];
}

- (void) logWinLevel: (NSInteger) levelNum {
    NSDictionary *levelParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%ld", (long)levelNum] , @"Level number",
                                 [NSString stringWithFormat:@"%ld", (long)currLevelStars] , @"Stars count",
                                 nil];
    [Flurry logEvent:@"Win level" withParameters:levelParams];
}

- (void) logWinLevel: (NSInteger) levelNum withNumberOfLoses: (NSInteger) loses {
    [self logWinLevel:levelNum];
    NSDictionary *levelParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%ld", (long)loses] , @"Lost lives",
                                 [NSString stringWithFormat:@"%ld", (long)currLevelStars] , @"Stars count",
                                 nil];
    [Flurry logEvent:[NSString stringWithFormat:@"Win level %ld", (long)levelNum] withParameters:levelParams];
    
    GameController *gC = [GameController sharedGameCtrl];
    NSInteger timeSinceStart = -[gC.timeStart timeIntervalSinceNow];
    if(timeSinceStart < 24 * 60 * 60) {
        [Flurry logEvent:[NSString stringWithFormat:@"Day 0 - win level %ld", (long)levelNum]];
    }
}

- (void) exitLevel: (NSInteger) levelNum {
    NSDictionary *levelParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%ld", (long)levelNum] , @"Level number",
                                 nil];
    [Flurry logEvent:@"Game closed" withParameters:levelParams];
}

#pragma mark -
#pragma mark GameKit

- (bool) isGameCenterAvailable {
	// Check for presence of GKLocalPlayer API.
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
	
    // The device must be running running iOS 4.1 or later.
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
	
    return (gcClass && osVersionSupported);
}

- (void) initGameCenter {
	// Only continue if Game Center is available on this device
	if ([self isGameCenterAvailable]) {
		// Authenticate the local player
		[self gameCenterAuthenticate];
		// Register the GKPlayerAuthenticationDidChangeNotificationName notification
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
			   selector:@selector(gameCenterAuthenticationChanged)
				   name:GKPlayerAuthenticationDidChangeNotificationName
				 object:nil];
	}
}

- (void) gameCenterAuthenticate {
	// Authenticate the local user
	CCLOG(@"Game Center - Trying to authenticate...");
	if([GKLocalPlayer localPlayer].authenticated == NO) {
		[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
			 if(error == nil) {
				 CCLOG(@"Game Center - Authenticated successfully");
				 self.gameCenterEnabled = YES;
				 self.gameCenterPlayerID = [GKLocalPlayer localPlayer].playerID;
				 self.gameCenterPlayerAlias = [GKLocalPlayer localPlayer].alias;
			 }
			 else {
				 CCLOG(@"Game Center - Failed to authenticate");
				 self.gameCenterEnabled = NO;
			 }
		 }];
	}
	else {
		CCLOG(@"Game Center - Has already authenticated");
		self.gameCenterEnabled = YES;
	}
}

- (void) gameCenterAuthenticationChanged {
    //[self gameCenterAuthenticate];
}

- (void) submitHighScore:(int64_t)scoreValue leaderboard:(NSString *)leaderboard {
	// Report the high score to Game Center
	GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:leaderboard] autorelease];
	scoreReporter.value = scoreValue;
	[scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
		 if (error == nil) {
			 CCLOG(@"Game Center - High score successfully sent");
		 }
		 else {
			 CCLOG(@"Game Center - Error:%@", [error localizedDescription]);
		 }
	 }];
}

- (NSString *) getLeaderBoardNameForCurrArea {
    GameController *gC = [GameController sharedGameCtrl];
    NSString *leaderboardName = @"freedom.fields.easy";
    switch (self.currArea) {
        case 1:
            if(gC.difficultyLevel == kDifficultyEasy) {
                leaderboardName = @"freedom.fields.easy";
            }
            else if(gC.difficultyLevel == kDifficultyMedium) {
                leaderboardName = @"freedom.fields.medium1";
            }
            else {
                leaderboardName = @"freedom.fields.hard1";
            }
            break;
        case 2:
            if(gC.difficultyLevel == kDifficultyEasy) {
                leaderboardName = @"fossil.forest.easy";
            }
            else if(gC.difficultyLevel == kDifficultyMedium) {
                leaderboardName = @"fossil.forest.medium";
            }
            else {
                leaderboardName = @"fossil.forest.hard";
            }
            break;
        case 3:
            if(gC.difficultyLevel == kDifficultyEasy) {
                leaderboardName = @"lost.desert.easy";
            }
            else if(gC.difficultyLevel == kDifficultyMedium) {
                leaderboardName = @"lost.desert.medium1";
            }
            else {
                leaderboardName = @"lost.desert.hard1";
            }
            break;
        case 4:
            if(gC.difficultyLevel == kDifficultyEasy) {
                leaderboardName = @"jungle.fever.easy";
            }
            else if(gC.difficultyLevel == kDifficultyMedium) {
                leaderboardName = @"jungle.fever.medium1";
            }
            else {
                leaderboardName = @"jungle.fever.hard1";
            }
            break;
        case 5:
            if(gC.difficultyLevel == kDifficultyEasy) {
                leaderboardName = @"";
            }
            else if(gC.difficultyLevel == kDifficultyMedium) {
                leaderboardName = @"";
            }
            else {
                leaderboardName = @"";
            }
            break;
    }
    return  leaderboardName;
}

- (NSString *) getTotalScoresLeaderboard {
    NSString *leaderboardName = @"danger.rabbit.easy";
    switch ([GameController sharedGameCtrl].difficultyLevel) {
        case kDifficultyEasy:
            leaderboardName = @"danger.rabbit.easy";
            break;
        case kDifficultyMedium:
            leaderboardName = @"danger.rabbit.medium";
            break;
        case kDifficultyHard:
            leaderboardName = @"danger.rabbit.hard";
            break;
    }
    return  leaderboardName;
}

- (NSString *) getTotalScoresLeaderboardWithDifficulty: (NSInteger) difficulty {
    NSString *leaderboardName = @"danger.rabbit.easy";
    switch (difficulty) {
        case kDifficultyEasy:
            leaderboardName = @"danger.rabbit.easy";
            break;
        case kDifficultyMedium:
            leaderboardName = @"danger.rabbit.medium";
            break;
        case kDifficultyHard:
            leaderboardName = @"danger.rabbit.hard";
            break;
    }
    return  leaderboardName;
}

#pragma mark -
#pragma mark Ad Banner

- (void) preloadBanner {
    if([GameController sharedGameCtrl].wasPurchase) {
        return;
    }
    [FlurryAds fetchAdForSpace:@"In Between Levels" frame:self.navController.view.frame size:FULLSCREEN];
}

- (void) showAdBanner {
    if([GameController sharedGameCtrl].wasPurchase) {
        return;
    }
    if ([FlurryAds adReadyForSpace:@"In Between Levels"]) {
        [FlurryAds displayAdForSpace:@"In Between Levels" onView:self.navController.view];
    }
    [self preloadBanner];
}

// Added by Hans
-(GADRequest *)createRequest {
    GADRequest *request = [GADRequest request];
    return request;
}
-(void)adViewDidReceiveAd:(GADBannerView *)adView {
    
    NSLog(@"Ad Received");
        
    [UIView animateWithDuration:1.0 animations:^{
        CGPoint origin = CGPointMake(0.0,0.0);
        _bannerView = [[[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait origin:origin ] autorelease];
    }];
        
}

-(void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"Failed to receive ad due to: %@", [error localizedFailureReason]);
}

@end