//
//  ShopLayer.m
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "ShopLayer.h"
#import "MainMenuLayer.h"
#import "MyMenuItemSprite.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "GameProgressController.h"
#import "Util.h"
#import "SWTableView.h"
#import "IAPTable.h"
#import "GameController.h"

#define kBackgroundTag 10001

@implementation ShopLayer

@synthesize isPopup;

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	ShopLayer *layer = [ShopLayer node];
    layer.isPopup = NO;
    [layer addBackground];
	[scene addChild: layer];
	
	return scene;
}

-(id) init {
	if((self=[super init])) {
        self.isPopup = YES;
        
        AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
        [appDelegate logEvent:@"Shop opened"];

        GameController *gameController = [GameController sharedGameCtrl];

        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"shopAtl.plist"];

        CCSprite *bg3 = [CCSprite spriteWithSpriteFrameName:@"sp_shadow.png"];
        [bg3 setScale:8];
        [bg3 setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg3 z:-3 tag:kBackgroundTag];

        id shadowAction = [CCFadeIn actionWithDuration:0.3f];
        [bg3 runAction:shadowAction];

        containerNode = [CCNode node];
		[containerNode setContentSize:CGSizeMake(kScreenWidth, kScreenHeight)];
        float offset = 0.0f;
		[containerNode setPosition:ccp(offset, kScreenHeight)];
		[self addChild:containerNode z:1];
        
        CCSprite *bg = [CCSprite spriteWithSpriteFrameName:@"ShopBase.png"];
        [bg setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [containerNode addChild:bg z:-2];

        CCSprite *arrowUP = [CCSprite spriteWithSpriteFrameName:@"sp_arrow_up.png"];
        [arrowUP setPosition:ccp(kScreenCenterX + 165 * kFactor, kScreenCenterY + 70 * kFactor)];
        [containerNode addChild:arrowUP z:-1];

        CCSprite *arrowDown = [CCSprite spriteWithSpriteFrameName:@"sp_arrow_down.png"];
        [arrowDown setPosition:ccp(kScreenCenterX + 165 * kFactor, kScreenCenterY - 90 * kFactor)];
        [containerNode addChild:arrowDown z:-1];

//        CCSprite *bar = [CCSprite spriteWithSpriteFrameName:@"sp_bar.png"];
//        [bar setPosition:ccp(kScreenCenterX + 112 * kFactor, kScreenCenterY - 22 * kFactor)];
//        [self addChild:bar z:-1];
//        
//        barSlider = [CCSprite spriteWithSpriteFrameName:@"sp_scroll.png"];
//        [barSlider setPosition:ccp(kScreenCenterX + 112 * kFactor, kScreenCenterY - 22 * kFactor)];
//        [self addChild:barSlider z:-1];

        //Menu
        CCMenu *menu = [CCMenu menuWithItems:nil];
        [menu setPosition:CGPointZero];
        [containerNode addChild: menu z:20];

        CCMenuItemSprite *backItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"sp_back.png"]
                                                             selectedSprite:[CCSprite spriteWithSpriteFrameName:@"sp_back_p.png"]
                                                             disabledSprite:nil
                                                                     target:self
                                                                   selector:@selector(backHandler)];
        [backItem setPosition:ccp(36 * kFactor, 36 * kFactor)];
        [menu addChild:backItem];
        
        //Restore
        CCMenuItemSprite *restoreItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"s_restore.png"]
                                                                selectedSprite:[CCSprite spriteWithSpriteFrameName:@"s_restore_p.png"]
                                                                disabledSprite:nil
                                                                        target:self
                                                                      selector:@selector(restoreHandler)];
        [restoreItem setPosition:ccp(kScreenWidth - 36 * kFactor, 36 * kFactor)];
        [restoreItem setScale:0.95f];
        [menu addChild:restoreItem];

        labelContainer =[CCNode node];
        [containerNode addChild:labelContainer];

        NSInteger shiftBalance = -9;
        if([Util sharedUtil].isiPad) {
            shiftBalance = -16;
        }
        
        [[Util sharedUtil] showLabel:[NSString stringWithFormat:@"%i",  gameController.carrotsCount] 
                              atNode:labelContainer 
                          atPosition:ccp(kScreenCenterX + 172 * kFactor,  kScreenCenterY + 115 * kFactor + shiftBalance)
                            fontName:@"BradyBunchRemastered" 
                            fontSize:18 * kFactor 
                           fontColor:ccc3(255, 204, 102) 
                         anchorPoint:ccp(0.5, 0.5) 
                           isEnabled:YES 
                                 tag:1 
                          dimensions:CGSizeMake(200, 40) 
                            rotation:0 
                             bgColor:ccc3(51, 0, 0)];
        
        CGSize tSize = CGSizeMake(350, 180);
        NSInteger deltaY = 10;
        if([Util sharedUtil].isiPad) {
            tSize = CGSizeMake(600, 360);
            deltaY = 20;
        }
        
        iapTableData=[[IAPTable alloc] init];
        
        myIAPtable = [SWTableView viewWithDataSource:iapTableData size:tSize];
        myIAPtable.position =ccp(kScreenCenterX - tSize.width / 2.0f,
                                 kScreenCenterY - tSize.height / 2.0f - deltaY);
        myIAPtable.delegate = iapTableData; //set if you need touch detection on cells.
        myIAPtable.verticalFillOrder = SWTableViewFillTopDown;
        myIAPtable.direction = SWScrollViewDirectionVertical;
        [myIAPtable reloadData];
        [containerNode addChild:myIAPtable];

        id move = [CCMoveBy actionWithDuration:0.5f position:ccp(0.0f, -kScreenHeight)];
        id action = [CCSequence actions:
                     [CCEaseBackOut actionWithAction:move],
                     nil];
        [containerNode runAction:action];
	}
	return self;
}

-(void) onEnter {
    if(self.isPopup == YES) {
        //Some kind of magic!
        CCDirector *director = [CCDirector sharedDirector];
        [[director touchDispatcher] removeDelegate:myIAPtable];
        [myIAPtable setTouchPriority:-128];
        [myIAPtable setTouchMode:kCCTouchesOneByOne];
        [myIAPtable setTouchEnabled:NO];
        [myIAPtable setTouchEnabled:YES];
        //End some kind of magic!
    }
    else {
        [menuPopup removeFromParentAndCleanup:YES];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onCarrotUpdate)
                                                 name:kCarrotUpdateNotification
                                               object:nil];

	[super onEnter];
}

-(void) onExit {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFramesFromFile:@"shopAtl.plist"];
    [super onExit];
}

-(void) backHandler {
    if(self.isPopup) {
        [self removeFromParentAndCleanup:YES];
    }
    else {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f
                                                                                     scene:[MainMenuLayer scene]]];
    }
}

- (void) restoreHandler {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    [appDelegate logEvent:@"Purchase restored"];
    [appDelegate restorePurchases];
}

#pragma mark -
#pragma mark Touches

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
        location = [self convertToNodeSpace:location];
	}
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
        location = [self convertToNodeSpace:location];
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
        location = [self convertToNodeSpace:location];
    }
}

-(void) onCarrotUpdate {
    [containerNode removeChild:labelContainer];
    labelContainer =[CCNode node];
    [containerNode addChild:labelContainer];
    
    NSInteger shiftBalance = -9;
    if([Util sharedUtil].isiPad) {
        shiftBalance = -16;
    }
    
    GameController *gameController = [GameController sharedGameCtrl];
    [[Util sharedUtil] showLabel:[NSString stringWithFormat:@"%i",  gameController.carrotsCount]
                          atNode:labelContainer
                      atPosition:ccp(kScreenCenterX + 172 * kFactor,  kScreenCenterY + 115 * kFactor + shiftBalance)
                        fontName:@"BradyBunchRemastered"
                        fontSize:18 * kFactor
                       fontColor:ccc3(255, 204, 102)
                     anchorPoint:ccp(0.5, 0.5)
                       isEnabled:YES
                             tag:1
                      dimensions:CGSizeMake(200, 40)
                        rotation:0
                         bgColor:ccc3(51, 0, 0)];
    
    CGSize tSize = CGSizeMake(350, 180);
    NSInteger deltaY = 10;
    if([Util sharedUtil].isiPad) {
        tSize = CGSizeMake(600, 360);
        deltaY = 20;
    }
}

-(void) addBackground {
    CCSprite *bg1 = (CCSprite *)[self getChildByTag:kBackgroundTag];
    if(bg1) {
        [bg1 removeFromParentAndCleanup:YES];
    }
    
    bg1 = [CCSprite spriteWithFile:@"bg1.jpg"];
    [bg1 setPosition:ccp(kScreenCenterX, kScreenCenterY)];
    [self addChild:bg1 z:-3];
}

@end
