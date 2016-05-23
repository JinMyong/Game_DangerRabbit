//
//  MyPopupLayer.m
//  Raaabit
//
//  Created by Dmitry Valov on 23.10.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "MyPopupLayer.h"
#import "MyMenuItemSprite.h"
#import "Constants.h"

@implementation MyPopupLayer

-(id) init {
	if( (self=[super init]) ) {
        [self addLockBackground];
	}
	return self;
}

- (void) dealloc {
	[super dealloc];
}

- (void) onEnter {
    [super onEnter];
}

- (void) onExit {
    [super onExit];
}

#pragma mark -
#pragma mark Handlers


- (void) addLockBackground {
    CCSprite *lockSprite = [CCSprite spriteWithFile:@"empty.png"];
    [lockSprite setContentSize:CGSizeMake(kScreenWidth, kScreenHeight)];
    MyMenuItemSprite *lockItem = [MyMenuItemSprite itemWithNormalSprite:lockSprite
                                                         selectedSprite:nil
                                                         disabledSprite:nil
                                                                 target:self
                                                               selector:@selector(emptyHandler)];
    [lockItem setContentSize:CGSizeMake(kScreenWidth, kScreenHeight)];
    
    menuPopup = [CCMenu menuWithItems:lockItem, nil];
    [menuPopup setPosition:ccp(kScreenCenterX, kScreenCenterY)];
    [self addChild: menuPopup z:-250];
}

- (void) emptyHandler {
    
}

@end
