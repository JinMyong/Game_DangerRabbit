////  SWTableViewSpriteCell.h//  PingPing2////  Created by Sangwoo Im on 10/22/10.//  Copyright 2010 Sangwoo Im. All rights reserved.//#import <Foundation/Foundation.h>#import "SWTableViewCell.h"#import "cocos2d.h"@interface SWTableViewSpriteCell : SWTableViewCell {    CCSprite *_sprite;}@property (nonatomic, retain) CCSprite *sprite;@end