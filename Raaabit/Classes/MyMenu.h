//
//  MyMenu.h
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright Dmitry Valov 2013. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MyMenu : CCMenu 
{
	bool needClick;
}

@property bool needClick;

@end
