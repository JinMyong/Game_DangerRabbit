//
//  GameController.m
//  CombiCats
//
//  Created by Dmitry Valov on 21.08.13.
//  Copyright Dmitry Valov 2013. All rights reserved.
//

#import "GameController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "GameProgressController.h"

#define kProgressFileName			@"progress.plist"

#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define kCarrotsCountKey                @"23njdwq0r"
#define kCarrotsCountShift              92344567875
#define kPlanksCountKey                 @"reg903uer0"
#define kPlanksCountShift               83456454435
#define kStickyPlanksCountKey           @"sdfwe8rt94"
#define kStickyPlanksCountShift         99456564545
#define kSuperPlanksCountKey            @"sd45gdt9g4"
#define kSuperPlanksCountShift          99897564545
#define kWorldsCountKey                 @"kiuygdt9g4"
#define kWorldsCountShift               99894567845
#define kBombsCountKey                  @"sfrghyt94"
#define kBombsCountShift                99897689045
#define kTimeContinue                   @"554tghgf34"
#define kTimeStart                      @"x43535ir4"
#define kShieldsKey                     @"th53r34t3"
#define kAllWorldsUnlockedKey           @"534t4f66vy"
#define kWasAllLivesSpend               @"e23r43c54c6"

#define kWorld2UnlockedKeyE             @"v9g5r0gg5"
#define kWorld2UnlockedKeyM             @"v9g5r0gg5m"
#define kWorld2UnlockedKeyH             @"v9g5r0gg5h"

#define kWorld3UnlockedKeyE             @"cerw9f05g"
#define kWorld3UnlockedKeyM             @"cerw9f05gm"
#define kWorld3UnlockedKeyH             @"cerw9f05gh"

#define kWorld4UnlockedKeyE             @"d34r05404"
#define kWorld4UnlockedKeyM             @"d34r05404m"
#define kWorld4UnlockedKeyH             @"d34r05404h"

#define kWorld5UnlockedKeyE             @"v9g5r0gg5ee"
#define kWorld5UnlockedKeyM             @"v9g5r0gg5mm"
#define kWorld5UnlockedKeyH             @"v9g5r0gg5hh"

#define kLostLivesKey                   @"fifjgfjeo55"
#define kLostLivesShift                 7458954765
#define kWasPurchaseKey                 @"433v5v45t"
#define kWasFBLikeKey                   @"tvt45t4y334d"
#define kPricesKey                      @"4x3tvy5u76bu"


@implementation GameController

@synthesize carrotsCount;
@synthesize planksCount;
@synthesize stickyPlanksCount;
@synthesize superPlanksCount;
@synthesize worldsCount;
@synthesize bombsCount;
@synthesize timeContinue;
@synthesize needInitNextWorld;
@synthesize listOfShields = listOfShields_;
@synthesize difficultyLevel;
@synthesize isMusicOff;
@synthesize isSFXOff;
@synthesize collectedCoins;
@synthesize totalCoins;
@synthesize levelStars;
@synthesize lostLives;
@synthesize isAllWorldsUnlocked;

@synthesize timeStart;
@synthesize wasAllLivesSpend;

@synthesize isWorld2UnlockedE;
@synthesize isWorld3UnlockedE;
@synthesize isWorld4UnlockedE;
@synthesize isWorld5UnlockedE;
@synthesize isWorld2UnlockedM;
@synthesize isWorld3UnlockedM;
@synthesize isWorld4UnlockedM;
@synthesize isWorld5UnlockedM;
@synthesize isWorld2UnlockedH;
@synthesize isWorld3UnlockedH;
@synthesize isWorld4UnlockedH;
@synthesize isWorld5UnlockedH;

@synthesize wasWorld1PerfectE;
@synthesize wasWorld2PerfectE;
@synthesize wasWorld3PerfectE;
@synthesize wasWorld4PerfectE;
@synthesize wasWorld5PerfectE;
@synthesize wasWorld1PerfectM;
@synthesize wasWorld2PerfectM;
@synthesize wasWorld3PerfectM;
@synthesize wasWorld4PerfectM;
@synthesize wasWorld5PerfectM;
@synthesize wasWorld1PerfectH;
@synthesize wasWorld2PerfectH;
@synthesize wasWorld3PerfectH;
@synthesize wasWorld4PerfectH;
@synthesize wasWorld5PerfectH;

@synthesize isWasWorld2UnlockedAnimationE;
@synthesize isWasWorld3UnlockedAnimationE;
@synthesize isWasWorld4UnlockedAnimationE;
@synthesize isWasWorld5UnlockedAnimationE;
@synthesize isWasWorld2UnlockedAnimationM;
@synthesize isWasWorld3UnlockedAnimationM;
@synthesize isWasWorld4UnlockedAnimationM;
@synthesize isWasWorld5UnlockedAnimationM;
@synthesize isWasWorld2UnlockedAnimationH;
@synthesize isWasWorld3UnlockedAnimationH;
@synthesize isWasWorld4UnlockedAnimationH;
@synthesize isWasWorld5UnlockedAnimationH;

@synthesize isUnlimitedLife;           // Added By Hans_1127

@synthesize listOfScoresForLevel = listOfScoresForLevel_;
@synthesize needShowLockAnimation;
@synthesize listOfPrices;

@synthesize wasPurchase;
@synthesize completedLevels;
@synthesize wasFacebookLike;

static GameController *gameControllerInstance;

+ (GameController*) sharedGameCtrl {
	return gameControllerInstance;
}

- (id) init {
    if (self = [super init]) {
//        self.prevScreen = kScreenLoading;
		gameControllerInstance = self;
        
        // for test only!!
//        self.carrotsCount = 10000;      //by Hans
//        self.planksCount = 3;
//        self.stickyPlanksCount = 5;
//        self.superPlanksCount = 7;
//        self.worldsCount = 10;
//        self.bombsCount = 12;
        
        listOfShields_ = [[NSMutableArray alloc] init];
        listOfScoresForLevel_ = [[NSMutableArray alloc] init];
        listOfPrices = [[NSMutableDictionary alloc] init];
        
        [listOfPrices setObject:@"$1.99" forKey:kAppleID_UnlockAllLevels];
        [listOfPrices setObject:@"$1.99" forKey:kAppleID_1kCarrots];
        [listOfPrices setObject:@"$2.99" forKey:kAppleID_2kCarrots];
        [listOfPrices setObject:@"$4.99" forKey:kAppleID_4kCarrots];
        [listOfPrices setObject:@"$0.99" forKey:kAppleID_5Continues];
        [listOfPrices setObject:@"$2.99" forKey:kAppleID_15Continues];
        [listOfPrices setObject:@"$0.99" forKey:kAppleID_NextWorld];

        [listOfPrices setObject:@"$2.99" forKey:kAppleID_UnlimitedLife];        // Added By Hans_1128
        
        self.needShowLockAnimation = NO;
        self.needInitNextWorld = NO;
        self.isAllWorldsUnlocked = NO;
        self.wasPurchase = NO;
        self.wasFacebookLike = NO;

        self.timeStart = [NSDate date];
        self.wasAllLivesSpend = NO;

        self.isWorld2UnlockedE = NO;
        self.isWorld3UnlockedE = NO;
        self.isWorld4UnlockedE = NO;
        self.isWorld5UnlockedE = NO;
        self.isWorld2UnlockedM = NO;
        self.isWorld3UnlockedM = NO;
        self.isWorld4UnlockedM = NO;
        self.isWorld5UnlockedM = NO;
        self.isWorld2UnlockedH = NO;
        self.isWorld3UnlockedH = NO;
        self.isWorld4UnlockedH = NO;
        self.isWorld5UnlockedH = NO;
        
        self.wasWorld1PerfectE = NO;
        self.wasWorld2PerfectE = NO;
        self.wasWorld3PerfectE = NO;
        self.wasWorld4PerfectE = NO;
        self.wasWorld5PerfectE = NO;
        self.wasWorld1PerfectM = NO;
        self.wasWorld2PerfectM = NO;
        self.wasWorld3PerfectM = NO;
        self.wasWorld4PerfectM = NO;
        self.wasWorld5PerfectM = NO;
        self.wasWorld1PerfectH = NO;
        self.wasWorld2PerfectH = NO;
        self.wasWorld3PerfectH = NO;
        self.wasWorld4PerfectH = NO;
        self.wasWorld5PerfectH = NO;
        
        self.isWasWorld2UnlockedAnimationE = NO;
        self.isWasWorld3UnlockedAnimationE = NO;
        self.isWasWorld4UnlockedAnimationE = NO;
        self.isWasWorld5UnlockedAnimationE = NO;
        self.isWasWorld2UnlockedAnimationM = NO;
        self.isWasWorld3UnlockedAnimationM = NO;
        self.isWasWorld4UnlockedAnimationM = NO;
        self.isWasWorld5UnlockedAnimationM = NO;
        self.isWasWorld2UnlockedAnimationH = NO;
        self.isWasWorld3UnlockedAnimationH = NO;
        self.isWasWorld4UnlockedAnimationH = NO;
        self.isWasWorld5UnlockedAnimationH = NO;
        
        self.isUnlimitedLife = NO;           // Added By Hans_1127 For test yes, normal no
        
        self.lostLives = 0;
        difficultyLevel = kDifficultyEasy;
        isMusicOff = NO;
        isSFXOff = NO;

        self.completedLevels = 0;

        [self load];
	}
	return self;
}

-(void)dealloc {
	[self save];

    [listOfShields_ release];
    listOfShields_ = nil;
    [listOfScoresForLevel_ release];
    listOfScoresForLevel_ = nil;
    [listOfPrices release];
    listOfPrices = nil;

	[super dealloc];
}

-(void)load {
	self.timeContinue = [NSDate dateWithTimeIntervalSince1970:0];

    for(NSUInteger i = 0; i < kLevelsCountInArea * kAreasCount; ++i) {
        [self.listOfShields addObject:[NSNumber numberWithInt:0]];
    }

    NSString *filePath = [DOCUMENTS stringByAppendingPathComponent:kProgressFileName];
    NSDictionary *progress = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        progress = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        
        if([progress objectForKey:kCarrotsCountKey]) {
            self.carrotsCount = (NSUInteger)kCarrotsCountShift - [[progress objectForKey:kCarrotsCountKey] integerValue];
        }
        if([progress objectForKey:kPlanksCountKey]) {
            self.planksCount = (NSUInteger)kPlanksCountShift - [[progress objectForKey:kPlanksCountKey] integerValue];
        }
        if([progress objectForKey:kStickyPlanksCountKey]) {
            self.stickyPlanksCount = (NSUInteger)kStickyPlanksCountShift - [[progress objectForKey:kStickyPlanksCountKey] integerValue];
        }
        if([progress objectForKey:kSuperPlanksCountKey]) {
            self.superPlanksCount = (NSUInteger)kSuperPlanksCountShift - [[progress objectForKey:kSuperPlanksCountKey] integerValue];
        }
        if([progress objectForKey:kWorldsCountKey]) {
            self.worldsCount = (NSUInteger)kWorldsCountShift - [[progress objectForKey:kWorldsCountKey] integerValue];
        }
        if([progress objectForKey:kBombsCountKey]) {
            self.bombsCount = (NSUInteger)kBombsCountShift - [[progress objectForKey:kBombsCountKey] integerValue];
        }
        if([progress objectForKey:kTimeContinue] != nil) {
            self.timeContinue = [progress objectForKey:kTimeContinue];
        }
        if([progress objectForKey:kTimeStart] != nil) {
            self.timeStart = [progress objectForKey:kTimeStart];
        }
        if([progress objectForKey:kWasAllLivesSpend]) {
            self.wasAllLivesSpend = [[progress objectForKey:kWasAllLivesSpend] boolValue];
        }
        if([progress objectForKey:kShieldsKey] != nil) {
            [self.listOfShields removeAllObjects];
            self.listOfShields = [progress objectForKey:kShieldsKey];
        }
        if([progress objectForKey:@"isMusicOff"]) {
            self.isMusicOff = [[progress objectForKey:@"isMusicOff"] boolValue];
        }
        if([progress objectForKey:@"isEffectsOff"]) {
            self.isSFXOff = [[progress objectForKey:@"isEffectsOff"] boolValue];
        }
        if([progress objectForKey:kAllWorldsUnlockedKey]) {
            self.isAllWorldsUnlocked = [[progress objectForKey:kAllWorldsUnlockedKey] boolValue];
        }

        if([progress objectForKey:kWorld2UnlockedKeyE]) {
            self.isWorld2UnlockedE = [[progress objectForKey:kWorld2UnlockedKeyE] boolValue];
        }
        if([progress objectForKey:kWorld3UnlockedKeyE]) {
            self.isWorld3UnlockedE = [[progress objectForKey:kWorld3UnlockedKeyE] boolValue];
        }
        if([progress objectForKey:kWorld4UnlockedKeyE]) {
            self.isWorld4UnlockedE = [[progress objectForKey:kWorld4UnlockedKeyE] boolValue];
        }
        if([progress objectForKey:kWorld5UnlockedKeyE]) {
            self.isWorld5UnlockedE = [[progress objectForKey:kWorld5UnlockedKeyE] boolValue];
        }
        if([progress objectForKey:kWorld2UnlockedKeyM]) {
            self.isWorld2UnlockedM = [[progress objectForKey:kWorld2UnlockedKeyM] boolValue];
        }
        if([progress objectForKey:kWorld3UnlockedKeyM]) {
            self.isWorld3UnlockedM = [[progress objectForKey:kWorld3UnlockedKeyM] boolValue];
        }
        if([progress objectForKey:kWorld4UnlockedKeyM]) {
            self.isWorld4UnlockedM = [[progress objectForKey:kWorld4UnlockedKeyM] boolValue];
        }
        if([progress objectForKey:kWorld5UnlockedKeyM]) {
            self.isWorld5UnlockedM = [[progress objectForKey:kWorld5UnlockedKeyM] boolValue];
        }
        if([progress objectForKey:kWorld2UnlockedKeyH]) {
            self.isWorld2UnlockedH = [[progress objectForKey:kWorld2UnlockedKeyH] boolValue];
        }
        if([progress objectForKey:kWorld3UnlockedKeyH]) {
            self.isWorld3UnlockedH = [[progress objectForKey:kWorld3UnlockedKeyH] boolValue];
        }
        if([progress objectForKey:kWorld4UnlockedKeyH]) {
            self.isWorld4UnlockedH = [[progress objectForKey:kWorld4UnlockedKeyH] boolValue];
        }
        if([progress objectForKey:kWorld5UnlockedKeyH]) {
            self.isWorld5UnlockedH = [[progress objectForKey:kWorld5UnlockedKeyH] boolValue];
        }
       
        if([progress objectForKey:@"kWasWorld2UnlockedAnimation"]) {
            self.isWasWorld2UnlockedAnimationE = [[progress objectForKey:@"kWasWorld2UnlockedAnimation"] boolValue];
        }
        if([progress objectForKey:@"kWasWorld3UnlockedAnimation"]) {
            self.isWasWorld3UnlockedAnimationE = [[progress objectForKey:@"kWasWorld3UnlockedAnimation"] boolValue];
        }
        if([progress objectForKey:@"kWasWorld4UnlockedAnimation"]) {
            self.isWasWorld4UnlockedAnimationE = [[progress objectForKey:@"kWasWorld4UnlockedAnimation"] boolValue];
        }
        if([progress objectForKey:@"kWasWorld5UnlockedAnimation"]) {
            self.isWasWorld5UnlockedAnimationE = [[progress objectForKey:@"kWasWorld5UnlockedAnimation"] boolValue];
        }
        if([progress objectForKey:@"kWasWorld2UnlockedAnimationM"]) {
            self.isWasWorld2UnlockedAnimationM = [[progress objectForKey:@"kWasWorld2UnlockedAnimationM"] boolValue];
        }
        if([progress objectForKey:@"kWasWorld3UnlockedAnimationM"]) {
            self.isWasWorld3UnlockedAnimationM = [[progress objectForKey:@"kWasWorld3UnlockedAnimationM"] boolValue];
        }
        if([progress objectForKey:@"kWasWorld4UnlockedAnimationM"]) {
            self.isWasWorld4UnlockedAnimationM = [[progress objectForKey:@"kWasWorld4UnlockedAnimationM"] boolValue];
        }
        if([progress objectForKey:@"kWasWorld5UnlockedAnimationM"]) {
            self.isWasWorld5UnlockedAnimationM = [[progress objectForKey:@"kWasWorld5UnlockedAnimationM"] boolValue];
        }
        if([progress objectForKey:@"kWasWorld2UnlockedAnimationH"]) {
            self.isWasWorld2UnlockedAnimationH = [[progress objectForKey:@"kWasWorld2UnlockedAnimationH"] boolValue];
        }
        if([progress objectForKey:@"kWasWorld3UnlockedAnimationH"]) {
            self.isWasWorld3UnlockedAnimationH = [[progress objectForKey:@"kWasWorld3UnlockedAnimationH"] boolValue];
        }
        if([progress objectForKey:@"kWasWorld4UnlockedAnimationH"]) {
            self.isWasWorld4UnlockedAnimationH = [[progress objectForKey:@"kWasWorld4UnlockedAnimationH"] boolValue];
        }
        if([progress objectForKey:@"kWasWorld5UnlockedAnimationH"]) {
            self.isWasWorld5UnlockedAnimationH = [[progress objectForKey:@"kWasWorld5UnlockedAnimationH"] boolValue];
        }
        
        if([progress objectForKey:@"kWasWorld1Perfect"]) {
            self.wasWorld1PerfectE = [[progress objectForKey:@"kWasWorld1Perfect"] boolValue];
        }
        if([progress objectForKey:@"kWasWorld2Perfect"]) {
            self.wasWorld2PerfectE = [[progress objectForKey:@"kWasWorld2Perfect"] boolValue];
        }
        if([progress objectForKey:@"kWasWorld3Perfect"]) {
            self.wasWorld3PerfectE = [[progress objectForKey:@"kWasWorld3Perfect"] boolValue];
        }
        if([progress objectForKey:@"kWasWorld4Perfect"]) {
            self.wasWorld4PerfectE = [[progress objectForKey:@"kWasWorld4Perfect"] boolValue];
        }
        if([progress objectForKey:@"kWasWorld5Perfect"]) {
            self.wasWorld5PerfectE = [[progress objectForKey:@"kWasWorld5Perfect"] boolValue];
        }
        if([progress objectForKey:@"kWasWorld1PerfectM"]) {
            self.wasWorld1PerfectM = [[progress objectForKey:@"kWasWorld1PerfectM"] boolValue];
        }
        if([progress objectForKey:@"kWasWorld2PerfectM"]) {
            self.wasWorld2PerfectM = [[progress objectForKey:@"kWasWorld2PerfectM"] boolValue];
        }
        if([progress objectForKey:@"kWasWorld3PerfectM"]) {
            self.wasWorld3PerfectM = [[progress objectForKey:@"kWasWorld3PerfectM"] boolValue];
        }
        if([progress objectForKey:@"kWasWorld4PerfectM"]) {
            self.wasWorld4PerfectM = [[progress objectForKey:@"kWasWorld4PerfectM"] boolValue];
        }
        if([progress objectForKey:@"kWasWorld5PerfectM"]) {
            self.wasWorld5PerfectM = [[progress objectForKey:@"kWasWorld5PerfectM"] boolValue];
        }
        if([progress objectForKey:@"kWasWorld1PerfectH"]) {
            self.wasWorld1PerfectH = [[progress objectForKey:@"kWasWorld1PerfectH"] boolValue];
        }
        if([progress objectForKey:@"kWasWorld2PerfectH"]) {
            self.wasWorld2PerfectH = [[progress objectForKey:@"kWasWorld2PerfectH"] boolValue];
        }
        if([progress objectForKey:@"kWasWorld3PerfectH"]) {
            self.wasWorld3PerfectH = [[progress objectForKey:@"kWasWorld3PerfectH"] boolValue];
        }
        if([progress objectForKey:@"kWasWorld4PerfectH"]) {
            self.wasWorld4PerfectH = [[progress objectForKey:@"kWasWorld4PerfectH"] boolValue];
        }
        if([progress objectForKey:@"kWasWorld5PerfectH"]) {
            self.wasWorld5PerfectH = [[progress objectForKey:@"kWasWorld5PerfectH"] boolValue];
        }
        
    // Added By Hans_1127
        
        if([progress objectForKey:@"kisUnlimitedLife"]) {
            self.isUnlimitedLife = [[progress objectForKey:@"kisUnlimitedLife"] boolValue];
        }
        
    // Add end _1127

        if([progress objectForKey:kLostLivesKey]) {
            self.lostLives = (NSUInteger)kLostLivesShift - [[progress objectForKey:kLostLivesKey] integerValue];
        }
        if([progress objectForKey:kWasPurchaseKey]) {
            self.wasPurchase = [[progress objectForKey:kWasPurchaseKey] boolValue];
        }
        if([progress objectForKey:kWasFBLikeKey]) {
            self.wasFacebookLike = [[progress objectForKey:kWasFBLikeKey] boolValue];
        }

        if([progress objectForKey:kPricesKey]) {
            self.listOfPrices = [progress objectForKey:kPricesKey];
        }

        [progress release];
    }
    else {
        [self save];
    }
}

- (void) save {
	NSString *filePath = [DOCUMENTS stringByAppendingPathComponent:kProgressFileName];
  	NSMutableDictionary *progress = nil;
	if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
		progress = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
	}
	else {
		progress = [[NSMutableDictionary alloc] init];
	}
    [progress setObject:[NSNumber numberWithInteger:((NSUInteger)kCarrotsCountShift - self.carrotsCount)] forKey:kCarrotsCountKey];
    [progress setObject:[NSNumber numberWithInteger:((NSUInteger)kPlanksCountShift - self.planksCount)] forKey:kPlanksCountKey];
    [progress setObject:[NSNumber numberWithInteger:((NSUInteger)kStickyPlanksCountShift - self.stickyPlanksCount)] forKey:kStickyPlanksCountKey];
    [progress setObject:[NSNumber numberWithInteger:((NSUInteger)kSuperPlanksCountShift - self.superPlanksCount)] forKey:kSuperPlanksCountKey];
    [progress setObject:[NSNumber numberWithInteger:((NSUInteger)kWorldsCountShift - self.worldsCount)] forKey:kWorldsCountKey];
    [progress setObject:[NSNumber numberWithInteger:((NSUInteger)kBombsCountShift - self.bombsCount)] forKey:kBombsCountKey];
    [progress setObject:self.timeContinue forKey:kTimeContinue];
    [progress setObject:self.listOfShields forKey:kShieldsKey];
    [progress setObject:[NSNumber numberWithBool:self.isMusicOff] forKey:@"isMusicOff"]; 
    [progress setObject:[NSNumber numberWithBool:self.isSFXOff] forKey:@"isEffectsOff"];
    [progress setObject:[NSNumber numberWithBool:self.isAllWorldsUnlocked] forKey:kAllWorldsUnlockedKey];

    [progress setObject:self.timeStart forKey:kTimeStart];
    [progress setObject:[NSNumber numberWithBool:self.wasAllLivesSpend] forKey:kWasAllLivesSpend];
    
    [progress setObject:[NSNumber numberWithBool:self.isWorld2UnlockedE] forKey:kWorld2UnlockedKeyE];
    [progress setObject:[NSNumber numberWithBool:self.isWorld3UnlockedE] forKey:kWorld3UnlockedKeyE];
    [progress setObject:[NSNumber numberWithBool:self.isWorld4UnlockedE] forKey:kWorld4UnlockedKeyE];
    [progress setObject:[NSNumber numberWithBool:self.isWorld5UnlockedE] forKey:kWorld5UnlockedKeyE];
    [progress setObject:[NSNumber numberWithBool:self.isWorld2UnlockedM] forKey:kWorld2UnlockedKeyM];
    [progress setObject:[NSNumber numberWithBool:self.isWorld3UnlockedM] forKey:kWorld3UnlockedKeyM];
    [progress setObject:[NSNumber numberWithBool:self.isWorld4UnlockedM] forKey:kWorld4UnlockedKeyM];
    [progress setObject:[NSNumber numberWithBool:self.isWorld5UnlockedM] forKey:kWorld5UnlockedKeyM];
    [progress setObject:[NSNumber numberWithBool:self.isWorld2UnlockedH] forKey:kWorld2UnlockedKeyH];
    [progress setObject:[NSNumber numberWithBool:self.isWorld3UnlockedH] forKey:kWorld3UnlockedKeyH];
    [progress setObject:[NSNumber numberWithBool:self.isWorld4UnlockedH] forKey:kWorld4UnlockedKeyH];
    [progress setObject:[NSNumber numberWithBool:self.isWorld5UnlockedH] forKey:kWorld5UnlockedKeyH];
    
    [progress setObject:[NSNumber numberWithBool:self.isWasWorld2UnlockedAnimationE] forKey:@"kWasWorld2UnlockedAnimation"];
    [progress setObject:[NSNumber numberWithBool:self.isWasWorld3UnlockedAnimationE] forKey:@"kWasWorld3UnlockedAnimation"];
    [progress setObject:[NSNumber numberWithBool:self.isWasWorld4UnlockedAnimationE] forKey:@"kWasWorld4UnlockedAnimation"];
    [progress setObject:[NSNumber numberWithBool:self.isWasWorld5UnlockedAnimationE] forKey:@"kWasWorld5UnlockedAnimation"];
    [progress setObject:[NSNumber numberWithBool:self.isWasWorld2UnlockedAnimationM] forKey:@"kWasWorld2UnlockedAnimationM"];
    [progress setObject:[NSNumber numberWithBool:self.isWasWorld3UnlockedAnimationM] forKey:@"kWasWorld3UnlockedAnimationM"];
    [progress setObject:[NSNumber numberWithBool:self.isWasWorld4UnlockedAnimationM] forKey:@"kWasWorld4UnlockedAnimationM"];
    [progress setObject:[NSNumber numberWithBool:self.isWasWorld5UnlockedAnimationM] forKey:@"kWasWorld5UnlockedAnimationM"];
    [progress setObject:[NSNumber numberWithBool:self.isWasWorld2UnlockedAnimationH] forKey:@"kWasWorld2UnlockedAnimationH"];
    [progress setObject:[NSNumber numberWithBool:self.isWasWorld3UnlockedAnimationH] forKey:@"kWasWorld3UnlockedAnimationH"];
    [progress setObject:[NSNumber numberWithBool:self.isWasWorld4UnlockedAnimationH] forKey:@"kWasWorld4UnlockedAnimationH"];
    [progress setObject:[NSNumber numberWithBool:self.isWasWorld5UnlockedAnimationH] forKey:@"kWasWorld5UnlockedAnimationH"];

    [progress setObject:[NSNumber numberWithBool:self.wasWorld1PerfectE] forKey:@"kWasWorld1Perfect"];
    [progress setObject:[NSNumber numberWithBool:self.wasWorld2PerfectE] forKey:@"kWasWorld2Perfect"];
    [progress setObject:[NSNumber numberWithBool:self.wasWorld3PerfectE] forKey:@"kWasWorld3Perfect"];
    [progress setObject:[NSNumber numberWithBool:self.wasWorld4PerfectE] forKey:@"kWasWorld4Perfect"];
    [progress setObject:[NSNumber numberWithBool:self.wasWorld5PerfectE] forKey:@"kWasWorld5Perfect"];
    [progress setObject:[NSNumber numberWithBool:self.wasWorld1PerfectM] forKey:@"kWasWorld1PerfectM"];
    [progress setObject:[NSNumber numberWithBool:self.wasWorld2PerfectM] forKey:@"kWasWorld2PerfectM"];
    [progress setObject:[NSNumber numberWithBool:self.wasWorld3PerfectM] forKey:@"kWasWorld3PerfectM"];
    [progress setObject:[NSNumber numberWithBool:self.wasWorld4PerfectM] forKey:@"kWasWorld4PerfectM"];
    [progress setObject:[NSNumber numberWithBool:self.wasWorld5PerfectM] forKey:@"kWasWorld5PerfectM"];
    [progress setObject:[NSNumber numberWithBool:self.wasWorld1PerfectH] forKey:@"kWasWorld1PerfectH"];
    [progress setObject:[NSNumber numberWithBool:self.wasWorld2PerfectH] forKey:@"kWasWorld2PerfectH"];
    [progress setObject:[NSNumber numberWithBool:self.wasWorld3PerfectH] forKey:@"kWasWorld3PerfectH"];
    [progress setObject:[NSNumber numberWithBool:self.wasWorld4PerfectH] forKey:@"kWasWorld4PerfectH"];
    [progress setObject:[NSNumber numberWithBool:self.wasWorld5PerfectH] forKey:@"kWasWorld5PerfectH"];
    
    [progress setObject:[NSNumber numberWithBool:self.isUnlimitedLife] forKey:@"kisUnlimitedLife"];     //Added By Hans_1127

    [progress setObject:[NSNumber numberWithInteger:((NSUInteger)kLostLivesShift - self.lostLives)] forKey:kLostLivesKey];
    
    [progress setObject:[NSNumber numberWithBool:self.wasPurchase] forKey:kWasPurchaseKey];
    [progress setObject:[NSNumber numberWithBool:self.wasFacebookLike] forKey:kWasFBLikeKey];

    [progress setObject:self.listOfPrices forKey:kPricesKey];

    [progress writeToFile:filePath atomically:YES];
	[progress release];
}

- (bool) getShieldForLevel: (NSInteger) level {
    if([[listOfShields_ objectAtIndex:level - 1] intValue] > 0) {
        return YES;
    }
    return NO;
}

- (void) setShieldForLevel: (NSInteger) level {
    [listOfShields_ replaceObjectAtIndex:level - 1 withObject:[NSNumber numberWithInt:1]];
}

- (void) addCoins: (NSInteger) coins {
    carrotsCount += coins;
    [self save];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCarrotUpdateNotification
                                                        object:nil];
}

- (bool) spendCoins: (NSInteger) coins {
    if(coins > self.carrotsCount) {
        return NO;
    }
    
    self.carrotsCount -= coins;
    [self save];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCarrotUpdateNotification
                                                        object:nil];
    return YES;
}

- (void) clearPlanks {
    self.planksCount = 0;
    self.stickyPlanksCount = 0;
    self.superPlanksCount = 0;
    self.bombsCount = 0;
    [self save];
}

- (NSInteger) countLevelStars {
    levelStars = 3;
    NSInteger starsCoeff =  (float)collectedCoins / (float)totalCoins * 100;
    
    if(totalCoins <= 0) {
        levelStars = 0;
    }
    else if(collectedCoins == totalCoins) {
        levelStars = 3;
    }
    else if(starsCoeff >= 80) {
        levelStars = 2;
    }
    else if(starsCoeff >= 50) {
        levelStars = 1;
    }
    else {
        levelStars = 0;
    }
    return levelStars;
}

- (NSInteger) unlockNextLevel {
    NSInteger unlockedLevelsInWorld1 = [[[GameProgressController sharedGProgressCtrl].openedLevelsInWorld objectAtIndex:0] intValue];
    NSInteger unlockedLevelsInWorld2 = [[[GameProgressController sharedGProgressCtrl].openedLevelsInWorld objectAtIndex:1] intValue];
    NSInteger unlockedLevelsInWorld3 = [[[GameProgressController sharedGProgressCtrl].openedLevelsInWorld objectAtIndex:2] intValue];
    GameProgressController *gpc = [GameProgressController sharedGProgressCtrl];
    NSInteger levelNum = 1;
    
    if(unlockedLevelsInWorld1 < kLevelsCountInArea ||
       [[GameProgressController sharedGProgressCtrl] getStarsForLevel:kLevelsCountInArea] <= 0) {
        levelNum = unlockedLevelsInWorld1;
        [gpc setScore:0 forLevel:levelNum withStars:2 withCarrots:0];
    }
    else if(unlockedLevelsInWorld2 < kLevelsCountInArea ||
            [[GameProgressController sharedGProgressCtrl] getStarsForLevel:kLevelsCountInArea * 2] <= 0) {
        levelNum = kLevelsCountInArea + unlockedLevelsInWorld2;
        [gpc setScore:0 forLevel:levelNum withStars:2 withCarrots:0];
    }
    else if(unlockedLevelsInWorld3 < kLevelsCountInArea ||
            [[GameProgressController sharedGProgressCtrl] getStarsForLevel:kLevelsCountInArea * 3] <= 0) {
        levelNum = kLevelsCountInArea * 2 + unlockedLevelsInWorld3;
        [gpc setScore:0 forLevel:levelNum withStars:2 withCarrots:0];
    }
    return levelNum + 1;
}

- (void) unlockNextWorld {
    if(difficultyLevel == kDifficultyEasy) {
        if( !self.isWorld2UnlockedE) {
            self.isWorld2UnlockedE = YES;
            [self save];
        }
        else if(!self.isWorld3UnlockedE) {
            self.isWorld3UnlockedE = YES;
            [self save];
        }
        else if(!self.isWorld4UnlockedE) {
            self.isWorld4UnlockedE = YES;
            [self save];
        }
    }
    else if(difficultyLevel == kDifficultyMedium) {
        if( !self.isWorld2UnlockedM) {
            self.isWorld2UnlockedM = YES;
            [self save];
        }
        else if(!self.isWorld3UnlockedM) {
            self.isWorld3UnlockedM = YES;
            [self save];
        }
        else if(!self.isWorld4UnlockedM) {
            self.isWorld4UnlockedM = YES;
            [self save];
        }
    }
    else {
        if( !self.isWorld2UnlockedH) {
            self.isWorld2UnlockedH = YES;
            [self save];
        }
        else if(!self.isWorld3UnlockedH) {
            self.isWorld3UnlockedH = YES;
            [self save];
        }
        else if(!self.isWorld4UnlockedH) {
            self.isWorld4UnlockedH = YES;
            [self save];
        }
    }
}

- (void) unlockAllWorlds {
    self.isAllWorldsUnlocked = YES;
    [self save];
}

- (void) loadListOfScoresForLevel: (NSInteger) level {
    self.listOfScoresForLevel = [NSArray arrayWithArray:[[FacebookController sharedFacebookCtrl] getListOfScoresForLevel:level]];
}

- (void) spendLife {
    self.lostLives += 1;
    [self save];
}

@end