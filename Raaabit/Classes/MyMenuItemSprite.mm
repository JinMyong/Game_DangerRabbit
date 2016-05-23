//
//  MyMenuItemSprite.m
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright Dmitry Valov 2013. All rights reserved.
//

#import "MyMenuItemSprite.h"

enum 
{
	kZoomActionTag = 0xc0c05002,
};

@implementation MyMenuItemSprite

-(void) selected
{
	[super selected];
	
	if(_isEnabled) 
	{
		[super selected];
		[self stopActionByTag:kZoomActionTag];
		CCAction *zoomAction = [CCScaleTo actionWithDuration:0.1f scale:1.1f];
		zoomAction.tag = kZoomActionTag;
		[self runAction:zoomAction];
	}
}

-(void) unselected
{
	if(_isEnabled) 
	{
		[super unselected];
		[self stopActionByTag:kZoomActionTag];
		CCAction *zoomAction = [CCScaleTo actionWithDuration:0.1f scale:1.0f];
		zoomAction.tag = kZoomActionTag;
		[self runAction:zoomAction];
	}
}

- (void) dealloc
{
	[super dealloc];
}

@end
