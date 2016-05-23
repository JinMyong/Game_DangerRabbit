//
//  MyFBRequest.m
//  Raaabit
//
//  Created by Dmitry Valov on 23.01.14.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MyFBRequest.h"

@implementation MyFBRequest

@synthesize requestID;
@synthesize senderID;
@synthesize senderName;
@synthesize data;
@synthesize message;

-(id)init {
	if((self = [super init]) != nil) {
        self.requestID = @"";
        self.senderID = @"";
        self.senderName = @"";
        self.data = @"";
        self.message = @"";
	}
	return self;
}

- (void) dealloc {
    self.requestID = nil;
    self.senderID = nil;
    self.senderName = nil;
    self.data = nil;
    self.message = nil;
    
	[super dealloc];
}

@end
