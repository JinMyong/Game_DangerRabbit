//"$(SRCROOT)/Raaabit/libs/Flurry"
//"$(SRCROOT)/Raaabit/libs/PushWoosh"

/*
 We need to add a new tutorial at the start of the game which shows danger rabbit bouncing twice. location here for iPhone: Dropbox\Raaabit\Assets\iPhone\tutorial\tutorial_animation_fixed, and same again for iPad.
 
 We must, must get Supertag working in the game. If needed, we need to send the source code to them so they can check that it has been correctly implemented. They are not seeing it firing on their servers.
 */

//
//  Constants.mm
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright Dmitry Valov 2013. All rights reserved.
//

//20, 42, 36,

//com.flowsparkstudios.raabit
//#ifdef UI_USER_INTERFACE_IDIOM
//#define VERSION_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//#else
//#define VERSION_IPAD false
//#endif
//
//#define kFactor (VERSION_IPAD ? 2 : 1)


#define VERSION_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kFactor (VERSION_IPHONE ? 1 : 2)

#define xFactor [[CCDirector sharedDirector] winSize].width/480.0f
#define yFactor [[CCDirector sharedDirector] winSize].height/320.0f

#define kScreenCenterX				[[CCDirector sharedDirector] winSize].width/2
#define kScreenCenterY				[[CCDirector sharedDirector] winSize].height/2
#define kScreenWidth				[[CCDirector sharedDirector] winSize].width
#define kScreenHeight				[[CCDirector sharedDirector] winSize].height

#define kEditorHalfWidth            240

#define kBackgroundMusicVolume      1.0f //Test 1.0f

//----- Levels -----//
#define kLoadLevelsFromServer		0	// 1 - levels from server,
                                        // 0 - local levels.
#define kTestMode                   0   // 1 - test mode (all levels opened) //Hans only for test
                                        // 0 - release mode
#define kB2D_DebugMode				0   // 1 - test mode
                                        // 0 - release mode
#define kLevelsCountInArea          20
#define kAreasCount                 4

#define kLevelsURL                  @"https://dl.dropboxusercontent.com/u/8849331" //Dmitry
//#define kLevelsURL                  @"https://dl.dropboxusercontent.com/u/3945553" //Lloyd

//#define kLevelsURL                  @"https://dl.dropboxusercontent.com/u/3945553" //Ann

//----- Physics -----//
#define kSpeedLimit					7.1f * kFactor

#define kMinPower                   1.2f
#define kMaxPower                   2.5f
#define kMinTrampLength             30.0f * kFactor
#define kMaxTrampLength             100.0f * kFactor
#define kMaxTrampSuperLength        135.0f * kFactor

#define kEnemySpeed                 1.5f * kFactor
#define kRabitSpeed                 1.30f * kFactor

#define kOptionsFileName            @"options.plist"

#define kTypePlatform               100
#define kTypeGoal                   200
#define kTypeCoin                   300
#define kTypeHero                   400
#define kTypeCannon                 500
#define kTypeEnemy                  600
#define kTypeBonus                  700
#define kTypeBoulder                800
#define kTypeAirduct                1000
#define kTypeHint                   1400
#define kTypeBGObject               1500
#define kTypeGun                    1100

#define kMoveNone                   0
#define kMoveTop                    1
#define kMoveDown                   2
#define kMoveLeft                   3
#define kMoveRight                  4

#define kTypeThorns                 14
#define kTypeTrampoline             15

#define kGroupIndexGround           4
#define kGroupIndexNotGround        3

#define kLivesDefault               8              //Modified by Hans origin 25
#define kLivesBonus                 8               //Modified by Hans origin 8

#define kLivesEarnADVideo           4           // Added By Hans

#define kContinuesCount             0
#define kTimeAddLife                (8 * 60)   // origin is (22 * 60)

#define kTimeAddLife1               (1 * 60)    // Added by Hans    1
#define kTimeAddLife2               (2 * 60)    // Added by Hans    2
#define kTimeAddLife3               (4 * 60)    // Added by Hans    4
#define kTimeAddLife4               (8 * 60)    // Added by Hans    8
#define kTimeAddLife5               (16 * 60)   // Added by Hans    16
#define kTimeAddLife6               (30 * 60)   // Added by Hans    30
#define kTimeAddLife7               (45 * 60)   // Added by Hans    45
#define kTimeAddLife8               (60 * 60)   // Added by Hans    60

#define kBuyPlankCarrotPrice        75          // Added by Hans
#define kBuyPlankCount              8           // Added by Hans

#define kNotificationText           @"Lives refilled. Danger Rabbit needs your help. Play now!"
#define kNotificationTime           (3 * 60 * 60)   //3 * 60 * 60

#define kSceneNone                  0
#define kSceneGameplay              1
#define kSceneSelectLevel           2


#define kFlurryID                   @"FCMKWSFK4JV5VQDKY7K7"

#define kCarrotUpdateNotification   @"carrotUpdate"
#define kWorldUnlockedNotification  @"WorldUnlocked"

#define kAdd10PlanksNotification    @"Add10PlanksNotification"
#define kContinueGameNotification   @"ContinueGameNotification"
#define kAppRestoredNotification    @"AppRestoredNotification"
#define kUpdatePrceNotification     @"UpdatePrceNotification"

//#define APPIRATER_APP_ID            @""
#define kITUNES_APP_ID              @"https://itunes.apple.com/us/app/animal-sounds-zoo-learning/id641406875?ls=1&mt=8"             


// Purchases

#define kShopID_UnlockAllLevels     1
#define kAppleID_UnlockAllLevels    @"com.flowsparkstudios.raabit.unlock_all_worlds1"

#define kShopID_1kCarrots           2
#define kAppleID_1kCarrots          @"com.flowsparkstudios.raabit.1_k_carrots11"

#define kShopID_2kCarrots           3
#define kAppleID_2kCarrots          @"com.flowsparkstudios.raabit.2_k_carrots1"

#define kShopID_4kCarrots           4
#define kAppleID_4kCarrots          @"com.flowsparkstudios.raabit.4_k_carrots1"

#define kShopID_5Continues          6
#define kAppleID_5Continues         @"com.flowsparkstudios.raabit.5_continues1"

#define kShopID_15Continues         7
#define kAppleID_15Continues        @"com.flowsparkstudios.raabit.15_continues1"

#define kShopID_30Continues         8
#define kAppleID_30Continues        @"com.flowsparkstudios.raabit.30_continues" //

#define kShopID_NextWorld           9
#define kAppleID_NextWorld          @"com.flowsparkstudios.raabit.unlock_next_world1"


#define kShopID_UnlimitedLife       10
#define kAppleID_UnlimitedLife      @"com.flowsparkstudios.raabit.max.lives"        // Added By Hans_1128
#define kAdtapsy_appID              @"56534c7ee4b0c516c767995d"
                        // Sample ID: 539777bae4b02eacca4bcb67
                    // This Game ID : 56534c7ee4b0c516c767995d


#define kFacebookURL                @"https://www.facebook.com/dangerrabbitgame"


#define kTapjoyID                   @"ScIWrcuiT_6guJuReXjmlgEBAIczp37wP00eSuhsNWW5i092ir2GiLGuKqM1"

//Test user
// login 1@raabit.com
// password Raabit11

//dk@thegiantmachine.com
//hamish.ogilvy@gmail.com
//adamsolano@hotmail.com

/*
 >>The goal on level 33 and 34 is not working, rabbit turns back and forth rapidly on screen, not entering the goal
 >>Continue screen and lives working

 For flurry, here's what I want to track:
 
 - seconds per session
 - where/when a user stops play
 - no. of sessions per day/week
 - When a user clicks on something to buy
 - When a user invites a friend to the game


facebook
Danger Rabbit
App ID:	237915279688936
App Secret:	067c23f4de5611976471bab49c750c2f

 
3. The shop doesnt appear to be working. When I purchase something it doesnt appear to be active
in the next level. Whenever he buys something, he starts the next level with 3 sticky planks.

 
 
Facebook text:
Hey, do you have an iphone or android phone? If you have an iphone check out this game: http://bit.ly/dangerrabbit, it's awesome!

 
*/



// Pushwoosh:
// flowspark
// fss070645
// Danger Rabbit 45DCA-CC5A4

// Dveloper.apple.com
// lloyd@bigrichard.com.au
// Brb1gr1ch1eapp

// flurry:
// lloyd@flowsparkstudios.com
// fss070645

// mobileapptracking.com:
// lloyd@flowsparkstudios.com
// fss070645



// 136 x 152  (272 x 304)

// 160 x 92 (320 x 184)



/*
 
And we need a final screen that appears if player beats all 60 levels saying 
 
 More levels coming soon! Please rate Danger Rabbit on the app store,
 or like us on Facebook to keep us going!!
 Email feedback to games@flowsparkstudios.com
 
 and then a 'rate', 'like' and 'email' button below
 
 */

