//
//  IntroLayer.m
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright Dmitry Valov 2013. All rights reserved.
//


#import "IntroLayer.h"
#import "MainMenuLayer.h"
#import "Constants.h"
#import "ContinueLayer.h"

#pragma mark - IntroLayer

@implementation IntroLayer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	IntroLayer *layer = [IntroLayer node];
	[scene addChild: layer];
	
	return scene;
}

-(id) sinit {
	if( (self=[super init])) {		
		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
		
		CCSprite *background;
		
		if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
            if(kScreenWidth == 568) {
                background = [CCSprite spriteWithFile:@"Default-568h@2x.png"];
            }
            else {
                background = [CCSprite spriteWithFile:@"Default.png"];
            }
			background.rotation = -90;
		}
        else {
            if([CCDirector sharedDirector].contentScaleFactor > 1.0f) {
                background = [CCSprite spriteWithFile:@"Default-Landscape~ipad@2x.png"];
            }
            else {
                background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
            }
		}
		background.position = ccp(size.width/2, size.height/2);
		
		// add the label as a child to this Layer
		[self addChild: background];
	}
	
	return self;
}

-(void) onEnter {
	[super onEnter];
   	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0
                                                                                 scene:[MainMenuLayer scene]]];

}
@end
