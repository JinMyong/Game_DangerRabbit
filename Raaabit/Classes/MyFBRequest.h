//
//  MyFBRequest.h
//  Raaabit
//
//  Created by Dmitry Valov on 23.01.14.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MyFBRequest : NSObject {
    NSString *requestID;
    NSString *senderID;
    NSString *senderName;
    NSString *data;
    NSString *message;
}

@property (nonatomic, retain) NSString *requestID;
@property (nonatomic, retain) NSString *senderID;
@property (nonatomic, retain) NSString *senderName;
@property (nonatomic, retain) NSString *data;
@property (nonatomic, retain) NSString *message;

@end
