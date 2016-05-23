//
//  Util.m
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "Util.h"
#import "Constants.h"
#import "cocos2d.h"

#define kTextLabel  444

@implementation Util

static Util *utilInstance;

+ (Util*) sharedUtil {
	if (!utilInstance) {
        utilInstance = [[self alloc] init];
	}
	return utilInstance;
}

- (id) init {
	if ((self = [super init]) != nil) {
		utilInstance = self;
	}
	return self;
}

+(id)alloc {
	NSAssert(utilInstance == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

- (void) dealloc {
    utilInstance = nil;
	[super dealloc];
}

-(CCNode *)showLabel:(NSString*)str atNode:(CCNode*)node atPosition:(CGPoint)pos
        fontSize:(CGFloat)fontSize fontColor:(ccColor3B)color {
    return [self showLabel:str atNode:node atPosition:pos fontSize:fontSize fontColor:(ccColor3B)color isEnabled:YES];
}

-(CCNode *)showLabel:(NSString*)str atNode:(CCNode*)node atPosition:(CGPoint)pos
        fontSize:(CGFloat)fontSize fontColor:(ccColor3B)color dimensions:(CGSize)rect rotation:(float)CWAngle {
    return [self showLabel:str atNode:node atPosition:pos fontName:nil fontSize:fontSize fontColor:(ccColor3B)color anchorPoint:ccp(0.5f,0.5f) isEnabled:YES tag:0 dimensions:rect rotation:CWAngle bgColor:ccc3(88, 29, 0)];
}

-(CCNode *)showLabel:(NSString*)str atNode:(CCNode*)node atPosition:(CGPoint)pos
        fontSize:(CGFloat)fontSize fontColor:(ccColor3B)color isEnabled:(BOOL)isEnabled {
    return [self showLabel:str atNode:node atPosition:pos fontName:nil fontSize:fontSize fontColor:(ccColor3B)color anchorPoint:ccp(0.5f,0.5f) isEnabled:isEnabled tag:0 dimensions:CGSizeMake(0,0) rotation:0 bgColor:ccc3(88, 29, 0)];
}

-(CCNode *)showLabel:(NSString*)str atNode:(CCNode*)node atPosition:(CGPoint)pos
        fontSize:(CGFloat)fontSize fontColor:(ccColor3B)color isEnabled:(BOOL)isEnabled tag:(NSInteger)tag {

    return [self showLabel:str atNode:node atPosition:pos fontName:nil fontSize:fontSize fontColor:(ccColor3B)color anchorPoint:ccp(0.5f,0.5f) isEnabled:isEnabled tag:tag dimensions:CGSizeMake(0,0) rotation:0 bgColor:ccc3(88, 29, 0)];
}

-(CCNode *)showLabel:(NSString*)str atNode:(CCNode*)node atPosition:(CGPoint)pos
        fontSize:(CGFloat)fontSize fontColor:(ccColor3B)color anchorPoint:(CGPoint)anchorPoint {
    return [self showLabel:str atNode:node atPosition:pos fontName:nil fontSize:fontSize fontColor:(ccColor3B)color anchorPoint:anchorPoint isEnabled:YES tag:0 dimensions:CGSizeMake(0,0) rotation:0 bgColor:ccc3(88, 29, 0)];
}

-(CCNode *)showLabel:(NSString*)str atNode:(CCNode*)node atPosition:(CGPoint)pos
        fontName:(NSString*)fontName fontSize:(CGFloat)fontSize fontColor:(ccColor3B)color anchorPoint:(CGPoint)anchorPoint bgColor:(ccColor3B)colorBG {
    return [self showLabel:str atNode:node atPosition:pos fontName:fontName fontSize:fontSize fontColor:(ccColor3B)color anchorPoint:anchorPoint isEnabled:YES tag:0 dimensions:CGSizeMake(0,0) rotation:0 bgColor:colorBG];
}

-(CCNode *)showLabel:(NSString*)str atNode:(CCNode*)node atPosition:(CGPoint)pos
        fontSize:(CGFloat)fontSize fontColor:(ccColor3B)color anchorPoint:(CGPoint)anchorPoint
       isEnabled:(BOOL)isEnabled tag:(NSInteger)tag {
    return [self showLabel:str atNode:node atPosition:pos fontName:nil fontSize:fontSize fontColor:color anchorPoint:anchorPoint isEnabled:isEnabled tag:tag dimensions:CGSizeMake(0,0) rotation:0 bgColor:ccc3(88, 29, 0)];
}

-(CCNode *)showLabel:(NSString*)str atNode:(CCNode*)node atPosition:(CGPoint)pos fontName:(NSString*)fontName
            fontSize:(CGFloat)fontSize fontColor:(ccColor3B)color anchorPoint:(CGPoint)anchorPoint
           isEnabled:(BOOL)isEnabled tag:(NSInteger)tag dimensions:(CGSize)rect rotation:(float)CWAngle bgColor:(ccColor3B)colorBG {
    
    NSString *font = fontName == nil ? NSLocalizedString(@"fontName", @"") : fontName;
    if (!isEnabled) {
        color = ccc3(200, 110, 28);
        pos = ccpAdd(pos, ccp(0.0f, 1.0f));
    }
    CCNode *button = [CCNode node];
    [button setContentSize:[[CCDirector sharedDirector] winSize]];
    [button setPosition:ccp(pos.x, pos.y)];
    
    CCLabelTTF *label;
    if (rect.width > 0) {
        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize dimensions:rect hAlignment:kCCTextAlignmentCenter vAlignment:kCCVerticalTextAlignmentCenter];
    } else {
        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize];
    }
    [label setColor:colorBG];
    label.anchorPoint = anchorPoint;
    label.position = CGPointZero;
    label.rotation = CWAngle;
    [button addChild: label z:1];
    [label release];		
    
    if (rect.width > 0) {
        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize dimensions:rect hAlignment:kCCTextAlignmentCenter vAlignment:kCCVerticalTextAlignmentCenter];
    } else {
        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize];
    }
    [label setColor:colorBG];
    label.anchorPoint = anchorPoint;
    label.position = ccp(-1.5f, 1.5f);
    label.rotation = CWAngle;
    [button addChild: label z:3];
    [label release];
    
    if (rect.width > 0) {
        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize dimensions:rect hAlignment:kCCTextAlignmentCenter vAlignment:kCCVerticalTextAlignmentCenter];
    } else {
        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize];
    }
    [label setColor:colorBG];
    label.anchorPoint = anchorPoint;
    label.position = ccp(0.0f, 1.5f);
    label.rotation = CWAngle;
    [button addChild: label z:3];
    [label release];
    
    if (rect.width > 0) {
        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize dimensions:rect hAlignment:kCCTextAlignmentCenter vAlignment:kCCVerticalTextAlignmentCenter];
    } else {
        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize];
    }
    [label setColor:colorBG];
    label.anchorPoint = anchorPoint;
    label.position = ccp(1.5f, 1.5f);
    label.rotation = CWAngle;
    [button addChild: label z:3];
    [label release];
    
    if (rect.width > 0) {
        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize dimensions:rect hAlignment:kCCTextAlignmentCenter vAlignment:kCCVerticalTextAlignmentCenter];
    } else {
        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize];
    }
    [label setColor:colorBG];
    label.anchorPoint = anchorPoint;
    label.position = ccp(1.5f, 0.0f);
    label.rotation = CWAngle;
    [button addChild: label z:3];
    [label release];
    
    if (rect.width > 0) {
        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize dimensions:rect hAlignment:kCCTextAlignmentCenter vAlignment:kCCVerticalTextAlignmentCenter];
    } else {
        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize];
    }
    [label setColor:colorBG];
    label.anchorPoint = anchorPoint;
    label.position = ccp(1.5f, -1.5f);
    label.rotation = CWAngle;
    [button addChild: label z:3];
    [label release];
    
    if (rect.width > 0) {
        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize dimensions:rect hAlignment:kCCTextAlignmentCenter vAlignment:kCCVerticalTextAlignmentCenter];
    } else {
        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize];
    }
    [label setColor:colorBG];
    label.anchorPoint = anchorPoint;
    label.position = ccp(0.0f, -1.5f);
    label.rotation = CWAngle;
    [button addChild: label z:3];
    [label release];
    
    if (rect.width > 0) {
        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize dimensions:rect hAlignment:kCCTextAlignmentCenter vAlignment:kCCVerticalTextAlignmentCenter];
    } else {
        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize];
    }
    [label setColor:colorBG];
    label.anchorPoint = anchorPoint;
    label.position = ccp(-1.5f, -1.5f);
    label.rotation = CWAngle;
    [button addChild: label z:3];
    [label release];
    
    if (rect.width > 0) {
        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize dimensions:rect hAlignment:kCCTextAlignmentCenter vAlignment:kCCVerticalTextAlignmentCenter];
    } else {
        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize];
    }
    [label setColor:colorBG];
    label.anchorPoint = anchorPoint;
    label.position = ccp(-1.5f, 0.5f);
    label.rotation = CWAngle;
    [button addChild: label z:3];
    [label release];
    
    if (rect.width > 0) {
        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize dimensions:rect hAlignment:kCCTextAlignmentCenter vAlignment:kCCVerticalTextAlignmentCenter];
    } else {
        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize];
    }
    [label setColor:color];
    label.anchorPoint = anchorPoint;
    label.position = CGPointZero;
    label.rotation = CWAngle;
    [button addChild:label z:5 tag:kTextLabel];
    [label release];		
    
    [node addChild:button z:20 tag:tag];
    
    return button;
}

//-(CCNode *)showLabel:(NSString*)str atNode:(CCNode*)node atPosition:(CGPoint)pos fontName:(NSString*)fontName
//        fontSize:(CGFloat)fontSize fontColor:(ccColor3B)color anchorPoint:(CGPoint)anchorPoint
//       isEnabled:(BOOL)isEnabled tag:(NSInteger)tag dimensions:(CGSize)rect rotation:(float)CWAngle bgColor:(ccColor3B)colorBG {
//    
//    NSString *font = fontName == nil ? NSLocalizedString(@"fontName", @"") : fontName;
//    if (!isEnabled) {
//        color = ccc3(200, 110, 28);
//        pos = ccpAdd(pos, ccp(0.0f, 1.0f));
//    }
//    CCNode *button = [CCNode node];
//    [button setContentSize:[[CCDirector sharedDirector] winSize]];
//    [button setPosition:ccp(pos.x, pos.y)];
//
//    CCLabelTTF *label;
//    if (rect.width > 0) {
//        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize dimensions:rect hAlignment:kCCTextAlignmentCenter vAlignment:kCCVerticalTextAlignmentCenter];
//    } else {
//        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize];
//    }
//    [label setColor:colorBG];
//    label.anchorPoint = anchorPoint;
//    label.position = CGPointZero;
//    label.rotation = CWAngle;
//    [button addChild: label z:1];
//    [label release];		
//    
//    if (rect.width > 0) {
//        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize dimensions:rect hAlignment:kCCTextAlignmentCenter vAlignment:kCCVerticalTextAlignmentCenter];
//    } else {
//        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize];
//    }
//    [label setColor:colorBG];
//    label.anchorPoint = anchorPoint;
//    label.position = ccp(1.0f, -1.0f);
//    label.rotation = CWAngle;
//    [button addChild: label z:2];
//    [label release];		
//    
//    if (rect.width > 0) {
//        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize dimensions:rect hAlignment:kCCTextAlignmentCenter vAlignment:kCCVerticalTextAlignmentCenter];
//    } else {
//        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize];
//    }
//    [label setColor:colorBG];
//    label.anchorPoint = anchorPoint;
//    label.position = ccp(0.0f, -2.0f);
//    label.rotation = CWAngle;
//    [button addChild: label z:3];
//    [label release];		
//    
//    if (rect.width > 0) {
//        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize dimensions:rect hAlignment:kCCTextAlignmentCenter vAlignment:kCCVerticalTextAlignmentCenter];
//    } else {
//        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize];
//    }
//    [label setColor:colorBG];
//    label.anchorPoint = anchorPoint;
//    label.position = ccp(-1.0f, -1.0f);
//    label.rotation = CWAngle;
//    [button addChild: label z:4];
//    [label release];		
//    
//    if (rect.width > 0) {
//        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize dimensions:rect hAlignment:kCCTextAlignmentCenter vAlignment:kCCVerticalTextAlignmentCenter];
//    } else {
//        label = [[CCLabelTTF alloc] initWithString:str fontName:font fontSize:fontSize];
//    }
//    [label setColor:color];
//    label.anchorPoint = anchorPoint;
//    label.position = CGPointZero;
//    label.rotation = CWAngle;
//    [button addChild:label z:5 tag:kTextLabel];
//    [label release];		
//    
//    [node addChild:button z:20 tag:tag];
//    
//    return button;
//}

-(void)disableLabelWithTag:(NSInteger)tag atNode:(CCNode*)node { 
    CCLabelTTF *label = (CCLabelTTF*)[node getChildByTag:tag];
    if (label) {
        if ([label getChildByTag:kTextLabel]) [(CCLabelTTF*)[label getChildByTag:kTextLabel] setColor:ccc3(200, 110, 28)];
        label.position = ccpAdd(label.position, ccp(0.0f,1.0f));
    }
}

- (bool) isiPhone5 {
    return CGSizeEqualToSize([[UIScreen mainScreen] preferredMode].size,CGSizeMake(640, 1136));
}

- (bool) isiPad {
    return !VERSION_IPHONE;
}

- (NSString *)secondsToString: (NSInteger) seconds {
    NSInteger min = seconds / 60;
    NSInteger sec = seconds - min * 60;
    NSString *result;
    
    if(seconds <= 0) {
        result = [NSString stringWithFormat:@"0:00"];
    }
    else if(min < 10 && sec < 10) {
        result = [NSString stringWithFormat:@"%d:0%d", min, sec];
    }
    else if (min < 10) {
        result = [NSString stringWithFormat:@"%d:%d", min, sec];
    }
    else if (sec < 10) {
        result = [NSString stringWithFormat:@"%d:0%d", min, sec];
    }
    else {
        result = [NSString stringWithFormat:@"%d:%d", min, sec];
    }
    return result;
}

@end
