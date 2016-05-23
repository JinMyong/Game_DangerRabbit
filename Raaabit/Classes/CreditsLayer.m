//
//  CreditsLayer.m
//  Raaabit
//
//  Created by Anna Valova on 2/3/14.
//  Copyright 2014 Dmitry Valov. All rights reserved.
//

#import "CreditsLayer.h"
#import "Constants.h"
#import "OptionsLayer.h"

@implementation CreditsLayer
+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	CreditsLayer *layer = [CreditsLayer node];
	[scene addChild: layer];
	
	return scene;
}

-(id) init {
	if((self=[super init])) {
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"optionsAtl.plist"];
        
        CCSprite *bg = [CCSprite spriteWithFile:@"mainMenuBg.jpg"];
        [bg setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg z:-21];
        
        CCSprite *bg2 = [CCSprite spriteWithSpriteFrameName:@"o_shadow.png"];
        [bg2 setScale:8];
        [bg2 setOpacity:200];
        [bg2 setPosition:ccp(kScreenCenterX, kScreenCenterY)];
        [self addChild:bg2 z:-20];
        
        //Menu
        CCMenu * menu = [CCMenu menuWithItems:nil];
        [menu setPosition:CGPointZero];
        [self addChild: menu];
        
        CCMenuItemSprite *backItem = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"o_back.png"]
                                                             selectedSprite:[CCSprite spriteWithSpriteFrameName:@"o_back_p.png"]
                                                             disabledSprite:nil
                                                                     target:self
                                                                   selector:@selector(backHandler)];
        [backItem setPosition:ccp(36 * kFactor, 36 * kFactor)];
        [menu addChild:backItem];
        
        CCLabelTTF *creditsLabel1 = [CCLabelTTF labelWithString:@"Publisher and Developer:\nFlow Spark Studios\n\nGame Concept:\nLloyd Perry\n\nLevel Design:\nLloyd Perry\n\nGame Art:\nRoyce Bentley\nRaymond Villar" fontName:@"BradyBunchRemastered" fontSize:20 * kFactor];
        [creditsLabel1 setAnchorPoint:ccp(0, 1)];
        creditsLabel1.position = ccp(kScreenCenterX - 190 * kFactor, kScreenHeight - 10 * kFactor);
        creditsLabel1.color = ccc3(255, 102, 0);
        [self addChild:creditsLabel1];    
        
        CCLabelTTF *creditsLabel2 = [CCLabelTTF labelWithString:@"Development:\nDmitry Valve\nAnna Valova\n\nSound Design:\nJesse Ratterree\nAnar Yusufov" fontName:@"BradyBunchRemastered" fontSize:20 * kFactor];
        [creditsLabel2 setAnchorPoint:ccp(0, 1)];
        creditsLabel2.position = ccp(kScreenCenterX + 60 * kFactor, kScreenHeight - 10 * kFactor);
        creditsLabel2.color = ccc3(255, 102, 0);
        [self addChild:creditsLabel2];
    }
    return self;
}

-(void) backHandler {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0f
                                                                                 scene:[OptionsLayer scene]]];
    
}

@end
