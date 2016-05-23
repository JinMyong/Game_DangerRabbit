//
//  Util.h
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCNode.h"

@interface Util : NSObject {
    
}
+ (Util*) sharedUtil;

-(CCNode *)showLabel:(NSString*)str atNode:(CCNode*)node atPosition:(CGPoint)pos
        fontSize:(CGFloat)fontSize fontColor:(ccColor3B)color;

-(CCNode *)showLabel:(NSString*)str atNode:(CCNode*)node atPosition:(CGPoint)pos
        fontSize:(CGFloat)fontSize fontColor:(ccColor3B)color dimensions:(CGSize)rect rotation:(float)CWAngle;

-(CCNode *)showLabel:(NSString*)str atNode:(CCNode*)node atPosition:(CGPoint)pos
        fontSize:(CGFloat)fontSize fontColor:(ccColor3B)color isEnabled:(BOOL)isEnabled;

-(CCNode *)showLabel:(NSString*)str atNode:(CCNode*)node atPosition:(CGPoint)pos
        fontSize:(CGFloat)fontSize fontColor:(ccColor3B)color isEnabled:(BOOL)isEnabled tag:(NSInteger)tag;

-(CCNode *)showLabel:(NSString*)str atNode:(CCNode*)node atPosition:(CGPoint)pos
        fontSize:(CGFloat)fontSize fontColor:(ccColor3B)color anchorPoint:(CGPoint)anchorPoint;

-(CCNode *)showLabel:(NSString*)str atNode:(CCNode*)node atPosition:(CGPoint)pos
        fontName:(NSString*)fontName fontSize:(CGFloat)fontSize fontColor:(ccColor3B)color anchorPoint:(CGPoint)anchorPoint bgColor:(ccColor3B)colorBG;

-(CCNode *)showLabel:(NSString*)str atNode:(CCNode*)node atPosition:(CGPoint)pos
        fontSize:(CGFloat)fontSize fontColor:(ccColor3B)color anchorPoint:(CGPoint)anchorPoint
       isEnabled:(BOOL)isEnabled tag:(NSInteger)tag;

-(CCNode *)showLabel:(NSString*)str atNode:(CCNode*)node atPosition:(CGPoint)pos
        fontName:(NSString*)fontName fontSize:(CGFloat)fontSize fontColor:(ccColor3B)color anchorPoint:(CGPoint)anchorPoint
isEnabled:(BOOL)isEnabled tag:(NSInteger)tag dimensions:(CGSize)rect rotation:(float)CWAngle bgColor:(ccColor3B)colorBG;

-(void)disableLabelWithTag:(NSInteger)tag atNode:(CCNode*)node;

- (bool) isiPhone5;
- (bool) isiPad;

- (NSString *)secondsToString: (NSInteger) seconds;


@end
