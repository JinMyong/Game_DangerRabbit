//
//  MyMenu.m
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright Dmitry Valov 2013. All rights reserved.
//

#import "MyMenu.h"

@implementation MyMenu

@synthesize needClick;

- (id) init
{
	if ((self = [super init]) != nil)
	{
		needClick = NO;
	}	
	return self;
}		

#pragma mark -
#pragma mark Touches

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if(needClick == NO)
	{
		[(CCLayer *)self.parent ccTouchBegan:touch withEvent:event];
	}
	else
	{
		needClick = NO;
		
		[super ccTouchBegan:touch withEvent:event];
		if(_state == kCCMenuStateTrackingTouch)
		{
			[super ccTouchEnded:touch withEvent:event];
		}
	}
	return NO;
}

@end
