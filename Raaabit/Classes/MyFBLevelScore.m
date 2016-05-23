//
//  MyFBLevelScore.m
//  Raaabit
//
//  Created by Dmitry Valov on 23.01.13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MyFBLevelScore.h"

@implementation MyFBLevelScore

@synthesize scoreID;
@synthesize level;
@synthesize score;
@synthesize userID;

-(id)init {
	if((self = [super init]) != nil) {
        self.scoreID = nil;
        self.userID = nil;
        self.level = 0;
        self.score = 0;
	}
	return self;
}

- (void) dealloc {
    self.scoreID = nil;
    self.userID = nil;
	[super dealloc];
}

@end
