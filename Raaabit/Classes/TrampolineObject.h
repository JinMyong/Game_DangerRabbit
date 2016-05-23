//
//  TrampolineObject.h
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "GameObject.h"

#define kTrampolineNone         50100
#define kTrampolineRegular      50101
#define kTrampolineSticky       50102
#define kTrampolinePurple       50103


@interface TrampolineObject : GameObject {
    NSInteger trampolineType;
    CGPoint centerPos;
}

@property (nonatomic, assign) NSInteger trampolineType;
@property CGPoint centerPos;

-(void) startAnimationSwing;
-(void) startAnimationStickSwing;
-(void) startAnimationPurpleSwing;

@end
